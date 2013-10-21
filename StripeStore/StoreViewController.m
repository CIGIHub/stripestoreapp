//
//  StoreViewController.m
//  StripeStore
//
//  Created by Caroline Simpson on 2013-07-08.
//

#import "StoreViewController.h"
#import "CatalogViewController.h"
#import "CartViewController.h"
#import "CatalogEditorViewController.h"
#import "AppDelegate.h"
#import "Order.h"
#import "Store.h"

@interface StoreViewController () <UIActionSheetDelegate>
- (IBAction)showProductDetail: (id)sender;

@property (nonatomic, strong, readwrite) Product *selectedProduct;
@property (nonatomic, strong, readwrite) Order *currentOrder;

@property (nonatomic, strong, readwrite) Store *activeStore;

@end

@implementation StoreViewController

- (void)dealloc
{
    NSNotificationCenter *nc = NSNotificationCenter.defaultCenter;
    [nc removeObserver:self name:kDidSetCurrentOrder object:nil];
    [nc removeObserver:self name:kCartDidStateChange object:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

-(Store *)activeStore
{
    if (_activeStore != nil){
        return _activeStore;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Store" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    for(Store *store in fetchedObjects){
        if (store.active.boolValue){
            _activeStore = store;
            return _activeStore;
        }
    }
    
    NSManagedObjectContext *context = self.managedObjectContext;
    _activeStore = [NSEntityDescription insertNewObjectForEntityForName:@"Store" inManagedObjectContext:context];
    _activeStore.active = [NSNumber numberWithBool:YES];
    _activeStore.storeId = [NSNumber numberWithInt: arc4random_uniform(INT16_MAX)];
    _activeStore.lastOrderId = [NSNumber numberWithInt:0];
    
    if (![context save:&error]){
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    
    return _activeStore;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(handleCurrentOrderSet:) name:kDidSetCurrentOrder object:nil];
    [nc addObserver:self selector:@selector(handleCurrentOrderUpdated:) name:kCartDidStateChange object:nil];
    
    UIApplication *app = [UIApplication sharedApplication];
    AppDelegate *appDelegate = (AppDelegate *)app.delegate;
    
    self.managedObjectContext = appDelegate.managedObjectContext;
    [self.checkoutButton setEnabled:NO];

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)showProductDetail: (id)sender{
    [self performSegueWithIdentifier:@"ShowProductDetail" sender:sender];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id destinationVC = segue.destinationViewController;
    if ([destinationVC isKindOfClass:CatalogViewController.class] || [destinationVC isKindOfClass:CartViewController.class]) {
        
        UIApplication *app = [UIApplication sharedApplication];
        AppDelegate *appDelegate = (AppDelegate *)app.delegate;
        
        NSManagedObjectContext *context = appDelegate.managedObjectContext;
        [destinationVC setManagedObjectContext:context];
    } else if ([[segue identifier] isEqualToString:@"ShowProductDetail"]) {
        [destinationVC setSelectedProduct:[sender selectedProduct]];
        
        id sourceVC = segue.sourceViewController;
        [sourceVC setSelectedProduct:[sender selectedProduct]];
        
    } else if ([[segue identifier] isEqualToString:@"ShowCheckout"]) {
        [destinationVC setCurrentOrder:self.currentOrder];
        [destinationVC setActiveStore:self.activeStore];
        
    } else if ([[segue identifier] isEqualToString:@"ConfigureCatalog"]){
        
        UIApplication *app = [UIApplication sharedApplication];
        AppDelegate *appDelegate = (AppDelegate *)app.delegate;
        
        NSManagedObjectContext *context = appDelegate.managedObjectContext;
        
        UINavigationController *navVC = (UINavigationController *)destinationVC;
        
        CatalogEditorViewController * editor = (CatalogEditorViewController *)[navVC topViewController];
        [editor setManagedObjectContext:context];
    } else if ([[segue identifier] isEqualToString:@"ConfigureStripeAPI"]){
        
        [destinationVC setActiveStore:self.activeStore];
    } else if ([[segue identifier] isEqualToString:@"ShowReceipt"]) {
        [destinationVC setCurrentOrder:self.currentOrder];
        [destinationVC setActiveStore:self.activeStore];
        
    }
    
}

-(NSString *)generateOrderNumber{
    NSString * orderNumber = self.activeStore.orderPrefix;
    
    orderNumber = [orderNumber stringByAppendingString:self.activeStore.storeId.stringValue];
    self.activeStore.lastOrderId = [NSNumber numberWithInt:[self.activeStore.lastOrderId intValue] + 1];
    
    orderNumber = [orderNumber stringByAppendingString:self.activeStore.lastOrderId.stringValue]; ;
    return orderNumber;
}

-(IBAction)handleCurrentOrderSet:(NSNotification *)notification
{
    Order * order = nil;
    NSDictionary *userInfo = [notification userInfo];
    if (userInfo) {
        order = userInfo[@"Order"];
        order.orderNumber = [self generateOrderNumber];
        
        NSError *error = nil;
        if (![self.managedObjectContext save:&error])
        {
            // Replace this implementation with code to handle
            // the error appropriately.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    
    self.currentOrder = order;
    
}

-(IBAction)handleCurrentOrderUpdated:(NSNotification *)notification
{
    if (![self.currentOrder.orderTotal isEqualToNumber:[NSNumber numberWithInt:0]]){
        [self.checkoutButton setEnabled:YES];
    }
    else {
        [self.checkoutButton setEnabled:NO];
    }
    
}

#pragma mark - Action Sheet
- (IBAction)showActionMenu:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    actionSheet.delegate = self;
    [actionSheet addButtonWithTitle:@"Configure Product Catalog..."];
    [actionSheet addButtonWithTitle:@"Configure Stripe Account..."];
    [actionSheet showFromBarButtonItem:sender animated:YES];
}


- (void)actionSheet:(UIActionSheet *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // Do nothing if the user taps outside the action
    // sheet (thus closing the popover containing the
    // action sheet).
    if (buttonIndex < 0) {
        return;
    }
    
    if (buttonIndex == 0) {
        [self performSegueWithIdentifier:@"ConfigureCatalog" sender:self];
    } else if (buttonIndex == 1) {
        [self performSegueWithIdentifier:@"ConfigureStripeAPI" sender:self];
        
    } else {
    }
    
}


@end
