//
//  ProductDetailViewController.h
//  StripeStore
//
//  Created by Caroline Simpson on 2013-07-08.
//

#import <UIKit/UIKit.h>
#import "Product.h"

@interface ProductDetailViewController : UIViewController
- (IBAction)saveProduct:(id)sender;
@property (nonatomic, strong) Product* selectedProduct;
@end
