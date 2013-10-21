//
//  CatalogViewController.m
//  StripeStore
//
//  Created by Caroline Simpson on 2013-07-08.
//

#import "CatalogViewController.h"
#import "Product.h"
#import "ProductCell.h"


@interface CatalogViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, assign, readwrite) NSInteger selectedProductIndex;

@end

@implementation CatalogViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];}

- (void) reloadData
{
    self.fetchedResultsController = nil;
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
    ProductCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ProductCell" forIndexPath:indexPath];
    
    NSFetchedResultsController *frc = self.fetchedResultsController;
    Product *product = [frc objectAtIndexPath:indexPath];
    cell.imageView.image = product.thumbnailImage;
    cell.nameLabel.text = product.name;
    
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedProductIndex = indexPath.item;
    
    NSFetchedResultsController *frc = self.fetchedResultsController;
    Product *product = [frc objectAtIndexPath:indexPath];
    NSDictionary *userInfo = @{ @"Product":product };
    
   

    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:kCatalogDidSelectProduct  object:nil userInfo:userInfo];
}

- (Product *)selectedProduct
{
    NSInteger index = self.selectedProductIndex;
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    NSFetchedResultsController *frc = self.fetchedResultsController;
    Product *product = [frc objectAtIndexPath:indexPath];
    return product;
}



@end
