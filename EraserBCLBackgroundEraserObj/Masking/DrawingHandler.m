//
//  DrawingHandler.m
//  StickerMakerUI
//
//  Created by leo on 16/3/21.
//  Copyright © 2021 Shafiq Shovo. All rights reserved.
//

#import "DrawingHandler.h"

@implementation DrawingHandler

#pragma mark - For finding the Mid point of Two Touch Point
CGPoint findMiddlePoint(CGPoint p1, CGPoint p2) {
    return CGPointMake((p1.x + p2.x)/2.0, ((p1.y + p2.y)/2.0));
}

#pragma mark - Mask layer are drawn to show erase and redraw
-(void) drawInEraseLayerAndWhiteMaskLayerWithMainLayerMask:(EraseLayer *) mainLayerMask
                                   withPathArray:(CGPoint *) pathArray withCurrentDrawingState:(BOOL) drawingState drawingStatewithLineWidth:(CGFloat)lineWidth{
//    mainLayerMask.flag = drawingState;
//    [mainLayerMask.drawingPath setLineWidth:lineWidth];
//    [mainLayerMask.drawingPath moveToPoint:pathArray[0]];
//    [mainLayerMask.drawingPath addCurveToPoint:pathArray[3] controlPoint1:pathArray[1] controlPoint2:pathArray[2]];
//    [mainLayerMask setNeedsDisplay];
    
    mainLayerMask.flag = drawingState;
    [mainLayerMask.drawingPath setLineWidth:lineWidth];
    [mainLayerMask.drawingPath moveToPoint:pathArray[1]];
    [mainLayerMask.drawingPath addLineToPoint:pathArray[2]];
    [mainLayerMask.drawingPath addLineToPoint:pathArray[3]];
    [mainLayerMask.drawingPath addLineToPoint:pathArray[4]];
    [mainLayerMask.drawingPath addLineToPoint:pathArray[1]];
//    [mainLayerMask.drawingPath closePath];
    [mainLayerMask setNeedsDisplay];

}

-(void) drawInEraseLayerAndWhiteMaskLayerWithMainLayerMask:(EraseLayer *) mainLayerMask drawPoint:(CGPoint)drawPoint withCurrentDrawingState:(BOOL) drawingState drawingStatewithLineWidth:(CGFloat)lineWidth{
//    mainLayerMask.flag = drawingState;
//    [mainLayerMask.drawingPath setLineWidth:lineWidth];
//    [mainLayerMask.drawingPath moveToPoint:pathArray[0]];
//    [mainLayerMask.drawingPath addCurveToPoint:pathArray[3] controlPoint1:pathArray[1] controlPoint2:pathArray[2]];
//    [mainLayerMask setNeedsDisplay];
    
    mainLayerMask.flag = drawingState;
    [mainLayerMask.drawingPath setLineWidth:lineWidth];
    [mainLayerMask.drawingPath moveToPoint:drawPoint];
    [mainLayerMask.drawingPath addLineToPoint:CGPointMake(drawPoint.x, drawPoint.y)];
    [mainLayerMask.drawingPath addLineToPoint:CGPointMake(drawPoint.x , drawPoint.y)];
    [mainLayerMask.drawingPath addLineToPoint:CGPointMake(drawPoint.x, drawPoint.y)];
    [mainLayerMask.drawingPath addLineToPoint:drawPoint];
//    [mainLayerMask.drawingPath closePath];
    [mainLayerMask setNeedsDisplay];

}

@end
