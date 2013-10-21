//
//  CatalogEditorViewController.m
//  StripeStore
//
//  Created by Caroline Simpson on 2013-07-09.
//

#import "CatalogEditorViewController.h"
#import "ProductDetailViewController.h"
#import "Product.h"
#import "ProductCell.h"

@interface CatalogEditorViewController ()

- (IBAction)addProduct:(id)sender;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, assign, readwrite) NSInteger selectedProductIndex;
- (IBAction)doneEditingCatalog:(id)sender;

@end

@implementation CatalogEditorViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void) reloadData
{
    self.fetchedResultsController = nil;
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)addProduct:(id)sender {
    NSManagedObjectContext *context = self.managedObjectContext;
    
    Product *product;
    product = [NSEntityDescription insertNewObjectForEntityForName:@"Product" inManagedObjectContext:context];
    product.name = @"New Product";
    [product saveImage:[UIImage imageNamed: @"defaultProduct.png"]];
    product.details = @"Product Details...";
    product.price = [NSDecimalNumber decimalNumberWithString:@"0.00"];
    
    
    NSError *error = nil;
    if (![context save:&error]){
        // Replace this implementation with code to handle
        // the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id destinationVC = segue.destinationViewController;
    if ([[segue identifier] isEqualToString:@"editorShowProductDetail"]) {
        
        ProductDetailViewController *dvc = (ProductDetailViewController *)destinationVC;
        
        dvc.selectedProduct = self.selectedProduct;
        
    }
}


#pragma mark - NSFetchedResultsController

- (NSFetchedResultsController *)fetchedResultsController{
    if (_fetchedResultsController){
        return _fetchedResultsController;
    }
    
    NSString *cacheName = NSStringFromClass(self.class);
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Product"];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    
    fetchRequest.sortDescriptors = @[sortDescriptor];
    NSFetchedResultsController *newFetchedResultsController;
    newFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:cacheName];
    newFetchedResultsController.delegate = self;
    
    NSError *error = nil;
    if (![newFetchedResultsController performFetch:&error]){
        // Replace this implementation with code to handle
        // the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    self.fetchedResultsController = newFetchedResultsController;
    return _fetchedResultsController;
}

- (void) controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    [self.collectionView reloadData];
}

- (void) controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource and UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSFetchedResultsController *frc = self.fetchedResultsController;
    NSInteger count = [[frc.sections objectAtIndex:section] numberOfObjects];
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ProductCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"EditorProductCell" forIndexPath:indexPath];
    
    NSFetchedResultsController *frc = self.fetchedResultsController;
    Product *product = [frc objectAtIndexPath:indexPath];
    cell.imageView.image = product.thumbnailImage;
    cell.nameLabel.text = product.name;
    
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedProductIndex = indexPath.item;
    
    UIApplication *app = [UIApplication sharedApplication];
    [app sendAction:@selector(showProductDetail:) to:nil from:self forEvent:nil];
}

- (Product *)selectedProduct
{
    NSInteger index = self.selectedProductIndex;
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    NSFetchedResultsController *frc = self.fetchedResultsController;
    Product *product = [frc objectAtIndexPath:indexPath];
    return product;
}


- (IBAction)doneEditingCatalog:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
