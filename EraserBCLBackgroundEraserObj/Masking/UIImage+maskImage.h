//
//  UIImage+maskImage.h
//  StickerMakerUI
//
//  Created by leo on 22/10/20.
//  Copyright © 2020 Shafiq Shovo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (maskImage)
+ (CIImage *) getMaskImageFromOriginalImage:(UIImage *) originalImage;
+ (BOOL) imageFound:(CIImage *) originalCIImage;
@end

NS_ASSUME_NONNULL_END
