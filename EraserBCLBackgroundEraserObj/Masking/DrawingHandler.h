//
//  DrawingHandler.h
//  StickerMakerUI
//
//  Created by leo on 16/3/21.
//  Copyright © 2021 Shafiq Shovo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EraseLayer.h"

NS_ASSUME_NONNULL_BEGIN

@interface DrawingHandler : NSObject

-(void) drawInEraseLayerAndWhiteMaskLayerWithMainLayerMask:(EraseLayer *) mainLayerMask withPathArray:(CGPoint *) pathArray withCurrentDrawingState:(BOOL) drawingState drawingStatewithLineWidth:(CGFloat)lineWidth;

-(void) drawInEraseLayerAndWhiteMaskLayerWithMainLayerMask:(EraseLayer *) mainLayerMask drawPoint:(CGPoint)drawPoint withCurrentDrawingState:(BOOL) drawingState drawingStatewithLineWidth:(CGFloat)lineWidth;

@end

NS_ASSUME_NONNULL_END
