//
//  EraseLayer.h
//  CALayerMaskSublayer
//
//  Created by leo on 1/7/19.
//  Copyright © 2019 Shafiq Shovo. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN


@interface EraseLayer : CALayer

@property (nonatomic,nullable) CGImageRef imageref;
@property (nonatomic) BOOL flag; //flag for erasing or redrawing.
@property (nonatomic) BOOL segmentationFlag; //Whether Segmentation is on
@property (nonatomic) BOOL segFlag; //Flag for erasing or redrawing
@property (strong, nonatomic) UIBezierPath *drawingPath;
@property (nonatomic) CGFloat brushWidth;
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;
@property (nonatomic) BOOL hardBrush;
-(instancetype) initWithFrame:(CGRect) frame;
@end

NS_ASSUME_NONNULL_END
