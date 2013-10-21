//
//  Product.h
//  StripeStore
//
//  Created by Caroline Simpson on 2013-07-08.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface _Product : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * details;
@property (nonatomic, retain) NSData * originalImageData;
@property (nonatomic, retain) NSData * largeImageData;
@property (nonatomic, retain) NSData * thumbnailImageData;
@property (nonatomic, retain) NSDecimalNumber * price;

@end
