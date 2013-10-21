//
//  Store.h
//  StripeStore
//
//  Created by Caroline Simpson on 2013-07-15.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface _Store : NSManagedObject

@property (nonatomic, retain) NSString * publicStripeAPIKey;
@property (nonatomic, retain) NSString * secretStripeAPIKey;
@property (nonatomic, retain) NSNumber * active;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * orderPrefix;
@property (nonatomic, retain) NSNumber * storeId;
@property (nonatomic, retain) NSNumber * lastOrderId;

@end
