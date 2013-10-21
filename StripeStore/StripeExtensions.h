//
//  StripeExtensions.h
//  StripeStore
//
//  Created by Caroline Simpson on 2013-07-16.
//

#import <Foundation/Foundation.h>
#import "Store.h"
#import "Stripe.h"

@interface StripeExtensions : NSObject

- (void)processPayment:(Store *)store token:(NSString *)token amount:(int)amount completion:(void (^)(NSURLResponse*, NSData*, NSError*)) handler;

@end
