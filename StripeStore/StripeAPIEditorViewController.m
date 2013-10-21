//
//  StripeAPIEditorViewController.m
//  StripeStore
//
//  Created by Caroline Simpson on 2013-07-15.
//

#import "StripeAPIEditorViewController.h"
#import "Store.h"

@interface StripeAPIEditorViewController ()

@property (weak, nonatomic) IBOutlet UITextField *storeNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *publicKeyTextField;
@property (weak, nonatomic) IBOutlet UITextField *secretKeyTextField;
@property (weak, nonatomic) IBOutlet UITextField *orderPrefixTextField;

- (IBAction)storeNameChanged:(id)sender;
- (IBAction)publicKeyChanged:(id)sender;
- (IBAction)secretKeyChanged:(id)sender;
- (IBAction)orderPrefixChanged:(id)sender;

- (IBAction)done:(id)sender;

- (void)saveStore;


@end

@implementation StripeAPIEditorViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.storeNameTextField.text = self.activeStore.name;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)storeNameChanged:(id)sender {
    self.activeStore.name = self.storeNameTextField.text;
    
    [self saveStore];
}

- (IBAction)publicKeyChanged:(id)sender {
    self.activeStore.publicStripeAPIKey = self.publicKeyTextField.text;
    
    [self saveStore];
}

- (void)saveStore{
    NSError *error = nil;
    NSManagedObjectContext *context = self.activeStore.managedObjectContext;
    
    if (![context save:&error]){
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

}

- (IBAction)secretKeyChanged:(id)sender {
    self.activeStore.secretStripeAPIKey = self.secretKeyTextField.text;
    
    [self saveStore];
}

- (IBAction)orderPrefixChanged:(id)sender {
    self.activeStore.orderPrefix = self.orderPrefixTextField.text;
    
    [self saveStore];
}

- (IBAction)done:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
