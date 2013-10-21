//
//  Product.h
//  StripeStore
//
//  Created by Caroline Simpson on 2013-07-08.
//

#import "_Product.h"

@interface Product : _Product

- (void)saveImage:(UIImage *)newImage;

- (UIImage *)originalImage;
- (UIImage *)largeImage;
- (UIImage *)thumbnailImage;

@end
