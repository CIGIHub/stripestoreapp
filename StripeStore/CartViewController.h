//
//  CartViewController.h
//  StripeStore
//
//  Created by Caroline Simpson on 2013-07-08.
//

#import <UIKit/UIKit.h>
#import "Order.h"

@interface CartViewController : UITableViewController<NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) Order *currentOrder;

@end
