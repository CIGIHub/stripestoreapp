//
//  CheckoutViewController.h
//  StripeStore
//
//  Created by Caroline Simpson on 2013-07-08.
//

#import <UIKit/UIKit.h>
#import "Order.h"
#import "STPView.h"
#import "Store.h"

@interface CheckoutViewController : UIViewController <STPViewDelegate>

@property (nonatomic, strong) Order* currentOrder;
@property (nonatomic, strong) Store* activeStore;
@property (weak, nonatomic) IBOutlet UILabel *totalLabel;

@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;

@property STPView* stripeView;

- (IBAction)cancelCheckout:(id)sender;
- (IBAction)confirmCheckout:(id)sender;
@end
