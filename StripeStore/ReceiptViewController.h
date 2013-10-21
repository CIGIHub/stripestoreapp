//
//  ReceiptViewController.h
//  StripeStore
//
//  Created by Caroline Simpson on 2013-09-13.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "Order.h"
#import "Store.h"

@interface ReceiptViewController : UIViewController <MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) Order* currentOrder;
@property (nonatomic, strong) Store* activeStore;

@property (weak, nonatomic) IBOutlet UIWebView *receiptViewer;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;

- (IBAction)sendReceipt:(id)sender;
- (IBAction)skipReceipt:(id)sender;

@end
