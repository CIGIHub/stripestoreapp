//
//  ProductDetailViewController.m
//  StripeStore
//
//  Created by Caroline Simpson on 2013-07-08.
//

#import "ProductDetailViewController.h"

@interface ProductDetailViewController () <UITextFieldDelegate, UITextViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *priceTextField;
@property (weak, nonatomic) IBOutlet UITextView *detailsTextView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;


@property (strong, nonatomic) UIActionSheet *actionSheet;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (nonatomic, strong) UIPopoverController *imagePickerPopoverController;

@end

@implementation ProductDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.nameTextField.text = self.selectedProduct.name;
    self.priceTextField.text = self.selectedProduct.price.stringValue;
    self.detailsTextView.text = self.selectedProduct.details;
    self.imageView.image = self.selectedProduct.largeImage;
    
    self.imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(imageTapped:)];
    [self.imageView addGestureRecognizer:tap];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)saveProduct:(id)sender {
    
    Product * product = self.selectedProduct;
    
    product.name = self.nameTextField.text;
    product.price = [NSDecimalNumber decimalNumberWithString:self.priceTextField.text];
    product.details = self.detailsTextView.text;
    [product saveImage:self.imageView.image];
    
    NSManagedObjectContext *context = product.managedObjectContext;
    
    NSError *error = nil;
    
    if (![context save:&error]){
        // Replace this implementation with code to handle the
        // error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField                 
{
    [textField resignFirstResponder];
    return NO;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UIControl *control;
    NSArray *controls = [NSArray arrayWithObjects:self.nameTextField, self.priceTextField, self.detailsTextView, nil];
    UITouch *touch = [[event allTouches] anyObject];
    
    for (control in controls){
        if ([control isFirstResponder] && [touch view] != control) {
            [control resignFirstResponder];
        }
    }
    
    [super touchesBegan:touches withEvent:event];
}

#pragma mark - photo selection

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)
toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if ([self actionSheet]) {
        [[self actionSheet] dismissWithClickedButtonIndex:-1 animated:YES];
    }
}

- (void)imageTapped:(UIGestureRecognizer *)recognizer
{
    BOOL hasCamera = [UIImagePickerController isSourceTypeAvailable:
                      UIImagePickerControllerSourceTypeCamera];
    if (hasCamera) {
        [self presentPhotoPickerMenu];
    } else {
        [self presentPhotoLibrary];
    }
}

- (UIImagePickerController *)imagePickerController                      // 5
{
    if (_imagePickerController) {
        return _imagePickerController;
    }
    
    UIImagePickerController *imagePickerController =  nil;
    imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    self.imagePickerController = imagePickerController;
    
    return _imagePickerController;
}

- (IBAction)addPhoto:(id)sender 
{
    if ([self imagePickerPopoverController]) {
        [[self imagePickerPopoverController] dismissPopoverAnimated:YES];
    }
    
    [self presentPhotoPickerMenu];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex 
{
    // Do nothing if the user taps outside the action
    // sheet (thus closing the popover containing the
    // action sheet).
    if (buttonIndex < 0) {
        return;
    }
    
    NSMutableArray *names = [[NSMutableArray alloc] init]; 
    
    if ([actionSheet tag] == 1) {
        BOOL hasCamera = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
        if (hasCamera) [names addObject:@"presentCamera"];
        [names addObject:@"presentPhotoLibrary"];
    }
    
    SEL selector = NSSelectorFromString([names objectAtIndex:buttonIndex]);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self performSelector:selector];
#pragma clang diagnostic pop
}

#pragma mark - Image picker helper methods

- (void)presentCamera
{
    // Display the camera.
    UIImagePickerController *imagePicker = self.imagePickerController;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)presentPhotoLibrary
{
    // Display assets from the photo library only.
    UIImagePickerController *imagePicker = [self imagePickerController];
    [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    
    UIPopoverController *newPopoverController =
    [[UIPopoverController alloc] initWithContentViewController:imagePicker];
    [newPopoverController presentPopoverFromRect:self.imageView.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    [self setImagePickerPopoverController:newPopoverController];
}

- (void)presentPhotoPickerMenu
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    [actionSheet setDelegate:self];
    BOOL hasCamera = [UIImagePickerController
                      isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    if (hasCamera) {
        [actionSheet addButtonWithTitle:@"Take Photo"];
    }
    [actionSheet addButtonWithTitle:@"Choose from Library"];
    [actionSheet setTag:1];
    [actionSheet showFromRect:self.imageView.frame inView:self.view animated:YES];
}

#pragma mark - UIImagePickerControllerDelegate methods

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // If the popover controller is available,
    // assume the photo is selected from the library
    // and not from the camera.
    BOOL takenWithCamera = ([self imagePickerPopoverController] == nil);
    
    if (takenWithCamera) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [[self imagePickerPopoverController] dismissPopoverAnimated:YES];
        [self setImagePickerPopoverController:nil];
    }
    
    // Retrieve and display the image.
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    self.imageView.image = image;
}

@end
