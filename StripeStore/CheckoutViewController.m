//
//  CheckoutViewController.m
//  StripeStore
//
//  Created by Caroline Simpson on 2013-07-08.
//

#import "CheckoutViewController.h"
#import "Order.h"
#import "StripeExtensions.h"

@interface CheckoutViewController ()

@end

@implementation CheckoutViewController


- (void)dealloc
{
    NSNotificationCenter *nc = NSNotificationCenter.defaultCenter;
    [nc removeObserver:self name:kReceiptComplete object:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    self.totalLabel.text = [formatter stringFromNumber: self.currentOrder.orderTotal];
    self.stripeView = [[STPView alloc] initWithFrame:CGRectMake(150, 155, 500, 40) andKey:self.activeStore.publicStripeAPIKey];
    self.stripeView.delegate = self;
    [self.view addSubview:self.stripeView];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(receiptComplete:) name:kReceiptComplete object:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)stripeView:(STPView *)view withCard:(PKCard *)card isValid:(BOOL)valid
{
}

- (IBAction)cancelCheckout:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)confirmCheckout:(id)sender {
    
    [self disableButtons];
    
    [self.stripeView createToken:^(STPToken *token, NSError *error) {
        if (error) {
            [self handleError:error];
            [self enableButtons];
        } else {
            [self handleToken:token];
            
        }
    }];
    
    
}


- (void)handleError:(NSError *)error
{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                                      message:[error localizedDescription]
                                                     delegate:nil
                                            cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                            otherButtonTitles:nil];
    [message show];
}


- (void)handleToken:(STPToken *)token
{
    StripeExtensions *stripe = [[StripeExtensions alloc]init];
    
    int amountInCents = [self.currentOrder.orderTotal decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithMantissa:100 exponent:0 isNegative:NO]].intValue;
    
    [stripe processPayment: self.activeStore token:token.tokenId amount:amountInCents completion:^(NSURLResponse *response, NSData *body, NSError *requestError)
    {
        
        if (requestError)
        {
            [self handleError:requestError];
            
            // If this is an error that Stripe returned, let's handle it as a StripeDomain error
            NSDictionary *jsonDictionary = nil;
            if (body && (jsonDictionary = [self dictionaryFromJSONData:body error:nil]) && [jsonDictionary valueForKey:@"error"] != nil)
            {
                
                for(NSString *key in [jsonDictionary allKeys]) {
                    NSLog(@"%@",[jsonDictionary objectForKey:key]);
                }
                
            }
        
        }
        else
        {
            NSError *parseError;
            NSDictionary *jsonDictionary = [self dictionaryFromJSONData:body error:&parseError];
            
            if (jsonDictionary == nil){
                NSLog(@"Error getting dictionary");
                [self handleError:parseError];
            }
            else if ([(NSHTTPURLResponse *)response statusCode] == 200){
                for(NSString *key in [jsonDictionary allKeys]) {
                    NSLog(@"%@",[jsonDictionary objectForKey:key]);
                }
                
                [self performSegueWithIdentifier:@"ShowReceipt" sender:self];
                
                
            }
            else{
                for(NSString *key in [jsonDictionary allKeys]) {
                    NSLog(@"%@",[jsonDictionary objectForKey:key]);
                }
                [self handleError: [self errorFromStripeResponse:jsonDictionary]];
            }
        }
        
        [self enableButtons];

        
    }];
    
}

- (void)disableButtons{
    [self.confirmButton setAlpha:0.6f];
    [self.confirmButton setEnabled:NO];
    
    [self.cancelButton setAlpha:0.6f];
    [self.cancelButton setEnabled:NO];
}

- (void)enableButtons{
    [self.confirmButton setAlpha:1.0f];
    [self.confirmButton setEnabled:YES];
    
    [self.cancelButton setAlpha:1.0f];
    [self.cancelButton setEnabled:YES];
}

- (IBAction)receiptComplete: (NSNotification *)notification
{
        [self dismissViewControllerAnimated:YES completion:^{
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            [nc postNotificationName:kResetCurrentOrder  object:nil userInfo:nil];
            
        }];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id destinationVC = segue.destinationViewController;
    if ([[segue identifier] isEqualToString:@"ShowReceipt"]) {
        [destinationVC setCurrentOrder:self.currentOrder];
        [destinationVC setActiveStore:self.activeStore];
        
    }
    
}


- (NSDictionary *)dictionaryFromJSONData:(NSData *)data error:(NSError **)outError
{
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    if (jsonDictionary == nil)
    {
        NSDictionary *userInfoDict = @{ NSLocalizedDescriptionKey : STPUnexpectedError,
                                        STPErrorMessageKey : [NSString stringWithFormat:@"The response from Stripe failed to get parsed into valid JSON."]
                                        };
        
        if (outError) {
            *outError = [[NSError alloc] initWithDomain:StripeDomain
                                                   code:STPAPIError
                                               userInfo:userInfoDict];
        }
        return nil;
    }
    return jsonDictionary;
}

- (NSString *)camelCaseFromUnderscoredString:(NSString *)string
{
    if (string == nil || [string isEqualToString:@""])
        return @"";
    
    NSMutableString *output = [NSMutableString string];
    BOOL makeNextCharacterUpperCase = NO;
    for (NSInteger index = 0; index < [string length]; index += 1)
    {
        NSString *character = [string substringWithRange:NSMakeRange(index, 1)];
        if ([character isEqualToString:@"_"] && index != [string length] - 1)
            makeNextCharacterUpperCase = YES;
        else if (makeNextCharacterUpperCase == YES)
        {
            [output appendString:[character uppercaseString]];
            makeNextCharacterUpperCase = NO;
        }
        else
            [output appendString:character];
    }
    return output;
}

- (NSError *)errorFromStripeResponse:(NSDictionary *)jsonDictionary
{
    NSDictionary *errorDictionary = [jsonDictionary valueForKey:@"error"];
    NSString *type = [errorDictionary valueForKey:@"type"];
    NSString *devMessage = [errorDictionary valueForKey:@"message"];
    NSString *parameter = [errorDictionary valueForKey:@"param"];
    NSString *userMessage = nil;
    NSString *cardErrorCode = nil;
    NSInteger code = 0;
    
    // There should always be a message and type for the error
    if (devMessage == nil || type == nil)
    {
        NSDictionary *userInfoDict = @{ NSLocalizedDescriptionKey : STPUnexpectedError,
                                        STPErrorMessageKey : [NSString stringWithFormat:@"Could not interpret the error response that was returned from Stripe."]
                                        };
        return [[NSError alloc] initWithDomain:StripeDomain
                                          code:STPAPIError
                                      userInfo:userInfoDict];
    }
    
    NSMutableDictionary *userInfoDict = [NSMutableDictionary dictionary];
    [userInfoDict setValue:devMessage forKey:STPErrorMessageKey];
    
    if (parameter)
    {
        parameter = [self camelCaseFromUnderscoredString:parameter];
        [userInfoDict setValue:parameter forKey:STPErrorParameterKey];
    }
    
    if ([type isEqualToString:@"api_error"])
    {
        userMessage = STPUnexpectedError;
        code = STPAPIError;
    }
    else if ([type isEqualToString:@"invalid_request_error"])
    {
        code = STPInvalidRequestError;
        // This is probably not correct, but I think it's correct enough in most cases.
        userMessage = devMessage;
    }
    else if ([type isEqualToString:@"card_error"])
    {
        code = STPCardError;
        cardErrorCode = [jsonDictionary valueForKey:@"code"];
        if ([cardErrorCode isEqualToString:@"incorrect_number"])
        {
            cardErrorCode = STPIncorrectNumber;
            userMessage = STPCardErrorInvalidNumberUserMessage;
        }
        else if ([cardErrorCode isEqualToString:@"invalid_number"])
        {
            cardErrorCode = STPInvalidNumber;
            userMessage = STPCardErrorInvalidNumberUserMessage;
        }
        else if ([cardErrorCode isEqualToString:@"invalid_expiry_month"])
        {
            cardErrorCode = STPInvalidExpMonth;
            userMessage = STPCardErrorInvalidExpMonthUserMessage;
        }
        else if ([cardErrorCode isEqualToString:@"invalid_expiry_year"])
        {
            cardErrorCode = STPInvalidExpYear;
            userMessage = STPCardErrorInvalidExpYearUserMessage;
        }
        else if ([cardErrorCode isEqualToString:@"invalid_cvc"])
        {
            cardErrorCode = STPInvalidCVC;
            userMessage = STPCardErrorInvalidCVCUserMessage;
        }
        else if ([cardErrorCode isEqualToString:@"expired_card"])
        {
            cardErrorCode = STPExpiredCard;
            userMessage = STPCardErrorExpiredCardUserMessage;
        }
        else if ([cardErrorCode isEqualToString:@"incorrect_cvc"])
        {
            cardErrorCode = STPIncorrectCVC;
            userMessage = STPCardErrorInvalidCVCUserMessage;
        }
        else if ([cardErrorCode isEqualToString:@"card_declined"])
        {
            cardErrorCode = STPCardDeclined;
            userMessage = STPCardErrorDeclinedUserMessage;
        }
        else if ([cardErrorCode isEqualToString:@"processing_error"])
        {
            cardErrorCode = STPProcessingError;
            userMessage = STPCardErrorProcessingErrorUserMessage;
        }
        else
            userMessage = devMessage;
        
        [userInfoDict setValue:cardErrorCode forKey:STPCardErrorCodeKey];
    }
    
    [userInfoDict setValue:userMessage forKey:NSLocalizedDescriptionKey];
    
    return [[NSError alloc] initWithDomain:StripeDomain
                                      code:code
                                  userInfo:userInfoDict];
}



@end
