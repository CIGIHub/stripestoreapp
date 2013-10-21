//
//  Product.m
//  StripeStore
//
//  Created by Caroline Simpson on 2013-07-08.
//

#import "Product.h"

@implementation Product


- (UIImage *)originalImage
{
    return [UIImage imageWithData:self.originalImageData];
}

- (UIImage *)largeImage
{
    return [UIImage imageWithData:self.largeImageData];
}

- (UIImage *)thumbnailImage
{
    return [UIImage imageWithData:self.thumbnailImageData];
}


- (void)saveImage:(UIImage *)newImage
{
    [self createScaledImagesForImage:newImage];
}


- (void)createScaledImagesForImage:(UIImage *)originalImage
{
    // Save thumbnail
    CGSize thumbnailSize = CGSizeMake(100.0, 100.0);
    UIImage *thumbnailImage = [self image:originalImage scaleAndCropToMaxSize:thumbnailSize];
    NSData *thumbnailImageData = UIImageJPEGRepresentation(thumbnailImage,  0.8);
    self.thumbnailImageData = thumbnailImageData;
    
    
    CGSize largeSize = CGSizeMake(300.0, 300.0);
    UIImage *largeImage = [self image:originalImage scaleAndCropToMaxSize:largeSize];
    NSData *largeImageData = UIImageJPEGRepresentation(largeImage,  0.8);
    self.largeImageData = largeImageData;
    
}


- (UIImage *)image:(UIImage *)image scaleAspectToMaxSize:(CGFloat)newSize {
    CGSize size = [image size];
    CGFloat ratio;
    if (size.width > size.height) {
        ratio = newSize / size.width;
    } else {
        ratio = newSize / size.height;
    }
    
    CGRect rect = CGRectMake(0.0, 0.0, ratio * size.width, ratio * size.height);
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    return scaledImage;
}

- (UIImage *)image:(UIImage *)image scaleAndCropToMaxSize:(CGSize)newSize {
    CGFloat largestSize =
    (newSize.width > newSize.height) ? newSize.width : newSize.height;
    CGSize imageSize = [image size];
    
    // Scale the image while maintaining the aspect and making sure
    // the scaled image is not smaller than the given new size. In
    // other words, we calculate the aspect ratio using the largest
    // dimension from the new size and the smallest dimension from the
    // actual size.
    CGFloat ratio;
    if (imageSize.width > imageSize.height) {
        ratio = largestSize / imageSize.height;
    } else {
        ratio = largestSize / imageSize.width;
    }
    
    CGRect rect =
    CGRectMake(0.0, 0.0, ratio * imageSize.width, ratio * imageSize.height);
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // Crop the image to the requested new size, maintaining
    // the innermost parts of the image.
    CGFloat offsetX = 0;
    CGFloat offsetY = 0;
    imageSize = [scaledImage size];
    if (imageSize.width < imageSize.height) {
        offsetY = (imageSize.height / 2) - (imageSize.width / 2);
    } else {
        offsetX = (imageSize.width / 2) - (imageSize.height / 2);
    }
    
    CGRect cropRect = CGRectMake(offsetX, offsetY,
                                 imageSize.width - (offsetX * 2),
                                 imageSize.height - (offsetY * 2));
    
    CGImageRef croppedImageRef =
    CGImageCreateWithImageInRect([scaledImage CGImage], cropRect);
    UIImage *newImage = [UIImage imageWithCGImage:croppedImageRef];
    CGImageRelease(croppedImageRef);
    
    return newImage;
}
@end
