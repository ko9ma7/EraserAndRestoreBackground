//
//  UIImage+image.h
//  StickerMakerUI
//
//  Created by leo on 7/1/20.
//  Copyright © 2020 Shafiq Shovo. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import <CoreServices/CoreServices.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (image)
- (UIImage *) horizontalFlip;
- (UIImage *) verticalFlip;
- (UIImage *) flipImageH:(UIImage*)img;
- (UIImage *) flipImageV:(UIImage*)img;
- (UIImage *) rotatedImage:(UIImage *) image rotation: (CGFloat) rotation;
+ (UIImage *) trimImage: (CGImageRef) imageRefForShape;
+ (UIImage *) imageWithImage:(UIImage *)image AspectFitToSize:(CGSize)size;
+ (UIImage *) convertToWhatsAppSpecifiedSizeWithImage:(UIImage *)image;
+ (UIImage *) convertToiMessageSpecifiedSizeWithImage:(UIImage *)image;
+ (UIImage *) imageFromLayer:(CALayer *)layer;
+ (UIImage *)imageFromLayerFromShapeVC:(CALayer *)layer;
+ (CGSize) imageSize:(CGSize)size;
+ (CGRect) imageSizeAfterAspectFit:(CGSize) size withOriginalImage:(UIImage *) image withOffsetValue:(CGSize) offsetValue;
+ (CGRect) trimImageforRect:(CGImageRef) imageRefForShape;
- (BOOL) saveImageAtPath:(NSString*)path;
+ (void)saveImageWithPath:(NSString *)path withImage:(UIImage *)image withSize:(CGSize)size withCompletionHandler:(void (^) (BOOL complete))completionHandler;
@end

NS_ASSUME_NONNULL_END
