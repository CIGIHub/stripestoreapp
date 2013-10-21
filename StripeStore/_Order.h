//
//  Order.h
//  StripeStore
//
//  Created by Caroline Simpson on 2013-07-10.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CartLineItem;

@interface _Order : NSManagedObject

@property (nonatomic, retain) NSString * orderNumber;
@property (nonatomic, retain) NSDate * transactionDate;
@property (nonatomic, retain) NSDecimalNumber * orderTotal;
@property (nonatomic, retain) NSSet *lineItems;
@end

@interface _Order (CoreDataGeneratedAccessors)

- (void)addLineItemsObject:(CartLineItem *)value;
- (void)removeLineItemsObject:(CartLineItem *)value;
- (void)addLineItems:(NSSet *)values;
- (void)removeLineItems:(NSSet *)values;

@end
