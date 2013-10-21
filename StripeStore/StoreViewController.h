//
//  StoreViewController.h
//  StripeStore
//
//  Created by Caroline Simpson on 2013-07-08.
//

#import <UIKit/UIKit.h>
#import "Product.h"
#import "Order.h"
#import "Store.h"

@interface StoreViewController : UIViewController

@property (nonatomic, strong, readonly) Product *selectedProduct;
@property (nonatomic, strong, readonly) Order *currentOrder;
@property (nonatomic, strong, readonly) Store *activeStore;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *checkoutButton;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
