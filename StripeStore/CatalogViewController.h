//
//  CatalogViewController.h
//  StripeStore
//
//  Created by Caroline Simpson on 2013-07-08.
//

#import <UIKit/UIKit.h>
#import "Product.h"

@interface CatalogViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

- (Product *) selectedProduct;

@end
