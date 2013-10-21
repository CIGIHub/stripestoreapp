//
//  CatalogEditorViewController.h
//  StripeStore
//
//  Created by Caroline Simpson on 2013-07-09.
//

#import <UIKit/UIKit.h>
#import "Product.h"

@interface CatalogEditorViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

- (Product *) selectedProduct;

@end
