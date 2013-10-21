//
//  ReceiptViewController.m
//  StripeStore
//
//  Created by Caroline Simpson on 2013-09-13.
//

#import "ReceiptViewController.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "CartLineItem.h"
#import "Store.h"

@interface ReceiptViewController ()
-(NSString *)constructInvoice:(Order *)order store:(Store*)store;
@end

@implementation ReceiptViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.receiptViewer loadHTMLString:[self constructInvoice:self.currentOrder store:self.activeStore] baseURL:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)sendReceipt:(id)sender {
    
    if ([MFMailComposeViewController canSendMail]) {
        [self sendEmail];
    } else {
        // Handle the error
    }
//    
}

-(NSString *)constructInvoice:(Order *)order store:(Store *)store{
    NSString * invoice = @"";
    
    //heading
    invoice = [invoice stringByAppendingString: [NSString stringWithFormat:@"<h1>%@</h1>", store.name]];
    invoice = [invoice stringByAppendingString: [NSString stringWithFormat:@"<h2>Order Number: %@</h2>", order.orderNumber]];
    invoice = [invoice stringByAppendingString: [NSString stringWithFormat:@"<p>%@</p>", order.transactionDate]];
    
    //line items
    NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    
    invoice = [invoice stringByAppendingString: @"<table border='1'>"];
    invoice = [invoice stringByAppendingString: @"<tr align='left'><th>Item</th><th>Quantity</th><th>Item Price</th><th>Item Total</th></tr>"];
    for(CartLineItem* item in self.currentOrder.lineItems){
        invoice = [invoice stringByAppendingString: @"<tr>"];
        invoice = [invoice stringByAppendingString: @"<td>"];
        invoice = [invoice stringByAppendingString: item.itemName];
        invoice = [invoice stringByAppendingString: @"</td>"];
        
        invoice = [invoice stringByAppendingString: @"<td>"];
        invoice = [invoice stringByAppendingString: item.quantity.stringValue];
        invoice = [invoice stringByAppendingString: @"</td>"];
        
        invoice = [invoice stringByAppendingString: @"<td>"];
        invoice = [invoice stringByAppendingString: [formatter stringFromNumber: item.itemPrice]];
        invoice = [invoice stringByAppendingString: @"</td>"];
        
        invoice = [invoice stringByAppendingString: @"<td>"];
        invoice = [invoice stringByAppendingString: [formatter stringFromNumber: item.rowTotal]];
        invoice = [invoice stringByAppendingString: @"</td>"];
        
        invoice = [invoice stringByAppendingString: @"</tr>"];
    }
    
    //total
    
    invoice = [invoice stringByAppendingString: [NSString stringWithFormat:@"<tr><th>Order Total</th><td></td><td></td><th>%@</th></tr>", [formatter stringFromNumber: order.orderTotal]]];
    
    invoice = [invoice stringByAppendingString: @"</table>"];
    
    

    
    
    return invoice;
}

-(void)sendEmail{
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setSubject:[NSString stringWithFormat:@"Receipt From %@", self.activeStore.name]];
    [controller setMessageBody:[self constructInvoice:self.currentOrder store:self.activeStore] isHTML:YES];
    if (controller)
        [self presentViewController:controller animated:YES completion:nil];
}
- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error;
{
    if (result == MFMailComposeResultSent) {
        NSLog(@"It's away!");
    }
    [self dismissViewControllerAnimated:YES completion:^{
        [self dismissViewControllerAnimated:YES completion:^{
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            [nc postNotificationName:kReceiptComplete  object:nil userInfo:nil];
        }];

    }];
    
    }

- (IBAction)skipReceipt:(id)sender {
    
        
    [self dismissViewControllerAnimated:YES completion:^{
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:kReceiptComplete  object:nil userInfo:nil];
    }];
}

@end
