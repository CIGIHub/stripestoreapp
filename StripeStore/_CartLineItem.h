//
//  CartLineItem.h
//  StripeStore
//
//  Created by Caroline Simpson on 2013-07-10.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Order, Product;

@interface _CartLineItem : NSManagedObject

@property (nonatomic, retain) NSDecimalNumber * itemPrice;
@property (nonatomic, retain) NSNumber * quantity;
@property (nonatomic, retain) NSDecimalNumber * rowTotal;
@property (nonatomic, retain) NSString * itemName;
@property (nonatomic, retain) Order *order;
@property (nonatomic, retain) Product *product;

@end
