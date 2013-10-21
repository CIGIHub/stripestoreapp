//
//  StripeExtensions.m
//  StripeStore
//
//  Created by Caroline Simpson on 2013-07-16.
//

#import "StripeExtensions.h"
#import "Store.h"

@interface StripeExtensions ()
- (NSString *)URLEncodedString:(NSString *)string;

@end

@implementation StripeExtensions


- (void)processPayment:(Store *)store token:(NSString *)token amount:(int)amount completion:(void (^)(NSURLResponse*, NSData*, NSError*)) handler
{
    
    NSURL *url = [NSURL URLWithString:@"https://api.stripe.com/v1/charges"];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setValue:[NSString stringWithFormat:@"Bearer %@", store.secretStripeAPIKey] forHTTPHeaderField:@"Authorization"];
    request.HTTPMethod = @"POST";
    
    NSString *body     = [NSString stringWithFormat:@"amount=%d&currency=cad&card=%@&description=%@", amount, token, @"Charge from iOS app."];
    request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *body, NSError *requestError)
     {
         handler(response, body, requestError);
     }];

}


/* This code is adapted from the code by David DeLong in this StackOverflow post:
 http://stackoverflow.com/questions/3423545/objective-c-iphone-percent-encode-a-string .  It is protected under the terms of a Creative Commons
 license: http://creativecommons.org/licenses/by-sa/3.0/
 */
- (NSString *)URLEncodedString:(NSString *)string {
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[string UTF8String];
    int sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i)
    {
        const unsigned char thisChar = source[i];
        if (thisChar == ' ')
            [output appendString:@"+"];
        else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                 (thisChar >= 'a' && thisChar <= 'z') ||
                 (thisChar >= 'A' && thisChar <= 'Z') ||
                 (thisChar >= '0' && thisChar <= '9'))
            [output appendFormat:@"%c", thisChar];
        else
            [output appendFormat:@"%%%02X", thisChar];
    }
    return output;
}

@end
