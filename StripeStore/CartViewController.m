//
//  CartViewController.m
//  StripeStore
//
//  Created by Caroline Simpson on 2013-07-08.
//

#import "CartViewController.h"
#import "Product.h"
#import "CartLineItem.h"
#import "CartRowCell.h"
#import "Order.h"

@interface CartViewController ()
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) Order *currentOrder;
@end

@implementation CartViewController


- (void)dealloc
{
    NSNotificationCenter *nc = NSNotificationCenter.defaultCenter;
    [nc removeObserver:self name:kCatalogDidSelectProduct object:nil];
    [nc removeObserver:self name:kCartDidZeroProduct object:nil];
    [nc removeObserver:self name:kResetCurrentOrder object:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.clearsSelectionOnViewWillAppear = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(addItemToCart:) name:kCatalogDidSelectProduct object:nil];
    [nc addObserver:self selector:@selector(removeItemFromCart:) name:kCartDidZeroProduct object:nil];
    [nc addObserver:self selector:@selector(resetCurrentOrder:) name:kResetCurrentOrder object:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(Order *)currentOrder
{
    if (_currentOrder != nil)
    {
        return _currentOrder;
    }
    
    NSManagedObjectContext *context = self.managedObjectContext;
    _currentOrder = [NSEntityDescription insertNewObjectForEntityForName:@"Order" inManagedObjectContext:context];
    _currentOrder.transactionDate = [NSDate date];
    _currentOrder.orderNumber = @"";
    
    NSError *error = nil;
    if (![context save:&error])
    {
        // Replace this implementation with code to handle
        // the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    NSDictionary *userInfo = @{ @"Order":_currentOrder };
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:kDidSetCurrentOrder  object:nil userInfo:userInfo];
    
    return _currentOrder;
}

- (IBAction)resetCurrentOrder: (NSNotification *)notification
{
    //TODO: save the context so the current order data gets stored.
    _currentOrder=nil;
    [self reloadData];
}


- (void) reloadData
{
    self.fetchedResultsController = nil;
    [self.tableView reloadData];
}

- (IBAction)addItemToCart: (NSNotification *)notification
{
    Product * product = nil;
    NSDictionary *userInfo = [notification userInfo];
    if (userInfo) {
        product = userInfo[@"Product"];
    }
    
    NSManagedObjectContext *context = self.managedObjectContext;
    CartLineItem *lineItem = [NSEntityDescription insertNewObjectForEntityForName:@"CartLineItem" inManagedObjectContext:context];
    lineItem.product = product;
    lineItem.itemName = product.name;
    lineItem.itemPrice = product.price;
    lineItem.rowTotal = product.price;
    lineItem.quantity = [NSNumber numberWithInt:1];
    lineItem.order = self.currentOrder;
    self.currentOrder.orderTotal = [self.currentOrder.orderTotal decimalNumberByAdding:product.price];
    
    NSError *error = nil;
    if (![context save:&error]){
        // Replace this implementation with code to handle
        // the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:kCartDidStateChange  object:nil userInfo:userInfo];
}

- (IBAction)removeItemFromCart: (NSNotification *)notification
{
    CartLineItem * lineItem = nil;
    NSDictionary *userInfo = [notification userInfo];
    if (userInfo) {
        lineItem = userInfo[@"LineItem"];
    }
    
    NSManagedObjectContext *context = self.managedObjectContext;
    
    [context deleteObject:lineItem];
    
    NSError *error = nil;
    if (![context save:&error]){
        // Replace this implementation with code to handle
        // the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    [self reloadData];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:kCartDidStateChange  object:nil userInfo:userInfo];
}


#pragma mark - NSFetchedResultsController and NSFetchedResultsControllerDelegate

- (NSFetchedResultsController *)fetchedResultsController                // 5
{
    if (_fetchedResultsController){
        return _fetchedResultsController;
    }
    
    NSString *cacheName = NSStringFromClass(self.class);
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"CartLineItem"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"order == %@", self.currentOrder];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"itemName" ascending:YES];
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
    [self.tableView reloadData];
}

- (void) controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView reloadData];
}

#pragma mark - TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0){
        NSFetchedResultsController *frc = self.fetchedResultsController;
        NSInteger count = [[frc.sections objectAtIndex:section] numberOfObjects];
        return count;
    } else {
        return 1;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0){
        static NSString *CellIdentifier = @"CartRowCell";
        
        CartRowCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[CartRowCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        NSFetchedResultsController *frc = self.fetchedResultsController;
        CartLineItem *lineItem = [frc objectAtIndexPath:indexPath];
        
        cell.lineItem = lineItem;
        
        
        return cell;

    }
    else {
        static NSString *CellIdentifier = @"CartOrderCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        cell.textLabel.text = @"Total";
        
        NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle: NSNumberFormatterCurrencyStyle];
        cell.detailTextLabel.text = [formatter stringFromNumber: self.currentOrder.orderTotal];
        
        return cell;

    }
}



@end
