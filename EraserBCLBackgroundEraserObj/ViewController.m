//
//  ViewController.m
//  EraserBCLBackgroundEraserObj
//
//  Created by BCL Device 3 on 11/1/23.
//

#import "ViewController.h"
#import "UIImage+maskImage.h"
#import "UIImage+image.h"
#import "EraseLayer.h"
#import "DrawingHandler.h"

@interface ViewController () {
    CIImage *maskedCIImage;
    UIImage *originalImage;
    CIContext *context;
    
    CGRect desiredFrame;
    CGSize sizeOfCurrentLayer;
    EraseLayer  *holdingLayer, *selectedLayer, *maskingLayer;
    
    UIPanGestureRecognizer *panGesture, *panGestureToErase;
    UIPinchGestureRecognizer *pinchGesture;
    CGPoint stateBeginPoint;
    CGRect initialFrameWhenGestureBegan;
    CGFloat lastScale;
    
    CGPoint lastPoint,newPoint;
    CGFloat defaultBrushWidth;
    int numberOfPoints;
    
    BOOL erase, redraw;
    
    DrawingHandler *drawingHandler;
    CGPoint pathArray[5];
    
    //brush
    //static brush
    UIImageView *staticBrushView;
    CGFloat staticBrushWidth;
    //movingBrush
    UIView *movingBrushView;
    CGFloat movingBrushWidth;
    BOOL isCircleShapeBrush;
    BOOL isSquareShapeBrush;
    BOOL isTriangleShapeBrush;
}

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UISlider *brushSizeSlider;
@property (weak, nonatomic) IBOutlet UISlider *brushOffsetSlider;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    originalImage = [UIImage imageNamed:@"inputImage"];
    maskedCIImage = [UIImage getMaskImageFromOriginalImage: originalImage];
    
    drawingHandler = [[DrawingHandler alloc] init];
    defaultBrushWidth = 5;
    [self addGesture];
   
    
    _brushSizeSlider.maximumValue = 50;
    _brushSizeSlider.minimumValue = defaultBrushWidth;
    _brushSizeSlider.value = ((_brushSizeSlider.maximumValue + defaultBrushWidth) / 2);
    
    isCircleShapeBrush = YES;
    isSquareShapeBrush = NO;
    isTriangleShapeBrush = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self prepareLayers];
    [self createBrushView];
}

#pragma mark:- Layers & Segmentation
- (void)prepareLayers {
    CGImageRef imgRef = [originalImage CGImage];
    CGSize offsetSize;
    offsetSize = (IS_IPAD) ? CGSizeMake(110, 110) : CGSizeMake(104, 104);
    desiredFrame = [UIImage imageSizeAfterAspectFit:self.containerView.frame.size withOriginalImage:originalImage withOffsetValue:CGSizeMake(offsetSize.width*RATIO, offsetSize.width*RATIO)];
    sizeOfCurrentLayer = desiredFrame.size;
    
    selectedLayer = [[EraseLayer layer] initWithFrame:CGRectMake(0, 0, desiredFrame.size.width, desiredFrame.size.height)];
    selectedLayer.contents = (__bridge id)(imgRef);
    
    holdingLayer = [[EraseLayer layer] initWithFrame:desiredFrame];
    [holdingLayer addSublayer:selectedLayer];
    [self.containerView.layer addSublayer:holdingLayer];
    
    maskingLayer = [[EraseLayer layer] initWithFrame:CGRectMake(0, 0, desiredFrame.size.width, desiredFrame.size.height)];
    selectedLayer.mask = maskingLayer;
    [self performSegmentation];
}

- (void)performSegmentation {
    CGImageRef imageRef = [originalImage CGImage];
    context = [CIContext contextWithOptions:nil];
    imageRef = [context createCGImage:maskedCIImage fromRect:maskedCIImage.extent];
    maskingLayer.imageref = imageRef;
    [maskingLayer setNeedsDisplay];
    
    maskingLayer.segmentationFlag = YES;
    maskingLayer.hardBrush = YES;
    maskingLayer.opacity = 1.0;
    [maskingLayer setNeedsDisplay];

}

#pragma mark:- Handle Gesture
- (void)addGesture {
    panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    panGesture.maximumNumberOfTouches = 2;
    panGesture.minimumNumberOfTouches = 2;
    [self.containerView addGestureRecognizer:panGesture];
    
    pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [self.containerView addGestureRecognizer:pinchGesture];
    
    panGestureToErase = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanToErase:)];
    panGestureToErase.maximumNumberOfTouches = 1;
    panGestureToErase.minimumNumberOfTouches = 1;
    [self.containerView addGestureRecognizer:panGestureToErase];
}

-(void) removeGestureFromcontainerView{
    [self.containerView removeGestureRecognizer:panGesture];
    [self.containerView removeGestureRecognizer:pinchGesture];
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    if(selectedLayer != nil) {
        if (gesture.state ==UIGestureRecognizerStateBegan){
            stateBeginPoint = CGPointMake(holdingLayer.position.x, holdingLayer.position.y);
        }
        CGPoint translation = [gesture translationInView:gesture.view];
        [CATransaction setDisableActions:YES];
        [holdingLayer setPosition:CGPointMake(stateBeginPoint.x+translation.x,stateBeginPoint.y+translation.y)];
    }
}

- (void)handlePinch:(UIPinchGestureRecognizer *)gesture {
    if(selectedLayer != nil) {
        if([gesture state] == UIGestureRecognizerStateBegan) {
            lastScale = [gesture scale];
            initialFrameWhenGestureBegan = holdingLayer.frame;
        }
        else if ([gesture state] == UIGestureRecognizerStateChanged) {
            CGFloat currentScale = [[holdingLayer valueForKeyPath:@"transform.scale"] floatValue];
            const CGFloat kMaxScale = 5.5;
            const CGFloat kMinScale = 0.75;
            CGFloat newScale = 1 -  (lastScale - [gesture scale]); // new scale is in the range (0-1)
            newScale = MIN(newScale, kMaxScale / currentScale);
            newScale = MAX(newScale, kMinScale / currentScale);
            [CATransaction setDisableActions:YES];
            CATransform3D trans = holdingLayer.transform;
            trans=CATransform3DScale(trans, newScale, newScale, 1);
            holdingLayer.transform = trans; //holding layer's transformation is changed here.
            lastScale = [gesture scale];
        }
    }
}

- (void)handlePanToErase:(UIPanGestureRecognizer *)gesture {
    if(selectedLayer!=nil){
        if([gesture state] == UIGestureRecognizerStateBegan){
            numberOfPoints = 0;
            NSLog(@"numberOfPoints reset : %d", numberOfPoints);
                if(erase||redraw){
                    lastPoint= [gesture locationInView:self.containerView];
                    lastPoint = [selectedLayer convertPoint:lastPoint fromLayer:self.containerView.layer];
                    lastPoint.y = lastPoint.y - _brushOffsetSlider.value;
                }
        }
        if([gesture state]==UIGestureRecognizerStateChanged){
//            if(erase||redraw){
                newPoint = [gesture locationInView:self.containerView];
                newPoint = [selectedLayer convertPoint:newPoint fromLayer:self.containerView.layer];
                [staticBrushView setCenter:[gesture locationInView:self.containerView]];
               
                CGPoint staticBrushCenter = CGPointMake(staticBrushView.frame.origin.x + (staticBrushView.frame.size.width /2), staticBrushView.frame.origin.y + (staticBrushWidth/2) - _brushOffsetSlider.value);
                [movingBrushView setCenter:staticBrushCenter];
                
                newPoint.y = newPoint.y - _brushOffsetSlider.value;
                
                CGFloat brushWidth = lroundf(([self.brushSizeSlider value] + defaultBrushWidth)/(holdingLayer.frame.size.width/sizeOfCurrentLayer.width));
                NSLog(@"numberOfPoints : %d", numberOfPoints);
                pathArray[numberOfPoints++] = newPoint;
                if(numberOfPoints==5){
                    pathArray[3] = CGPointMake((pathArray[2].x + pathArray[4].x)/2.0, (pathArray[2].y + pathArray[4].y)/2.0);
                    if(drawingHandler) {
                        [drawingHandler drawInEraseLayerAndWhiteMaskLayerWithMainLayerMask:selectedLayer.mask withPathArray:pathArray withCurrentDrawingState:erase drawingStatewithLineWidth:brushWidth];
                    }
                    pathArray[0] = pathArray[3];
                    pathArray[1] = pathArray[4];
                    numberOfPoints = 2;
                }
            
            
//            [drawingHandler drawInEraseLayerAndWhiteMaskLayerWithMainLayerMask:selectedLayer.mask drawPoint:newPoint withCurrentDrawingState:erase drawingStatewithLineWidth:brushWidth];
            
                lastPoint=newPoint;
//            }
        }
        
    }
}

#pragma mark:- Events
- (IBAction)brushSliderChanged:(UISlider *)sender {
    CGFloat value = [self.brushSizeSlider value];
    NSLog(@"defaultBrushWidth exckude: %f", value);
    
    if(isCircleShapeBrush) {
        CGPoint staticBrushCenter = CGPointMake(staticBrushView.frame.origin.x + (staticBrushView.frame.size.width /2), staticBrushView.frame.origin.y + (staticBrushWidth/2) - _brushOffsetSlider.value);
        [self drawCircleInView:_brushSizeSlider.value position:staticBrushCenter];
        [movingBrushView setCenter:staticBrushCenter];
    }
    if(isSquareShapeBrush) {
        CGPoint staticBrushCenter = CGPointMake(staticBrushView.frame.origin.x + (staticBrushView.frame.size.width /2), staticBrushView.frame.origin.y + (staticBrushWidth/2) - _brushOffsetSlider.value);
        [self drawSquareInView:_brushSizeSlider.value position:staticBrushCenter];
        [movingBrushView setCenter:staticBrushCenter];
    }
    if(isTriangleShapeBrush) {
        CGPoint staticBrushCenter = CGPointMake(staticBrushView.frame.origin.x + (staticBrushView.frame.size.width /2), staticBrushView.frame.origin.y + (staticBrushWidth/2) - _brushOffsetSlider.value);
        [self drawTriangleInView:_brushSizeSlider.value position:staticBrushCenter];
        [movingBrushView setCenter:staticBrushCenter];
    }
}
- (IBAction)brushOffsetSliderMoved:(id)sender {
    CGFloat value = [self.brushOffsetSlider value];
    NSLog(@"brushOffsetSliderMoved %f", value);
    
    
    CGPoint staticBrushCenter = CGPointMake(staticBrushView.frame.origin.x + (staticBrushView.frame.size.width /2), staticBrushView.frame.origin.y + (staticBrushWidth/2) - _brushOffsetSlider.value);
    [movingBrushView setCenter:staticBrushCenter];
    
}

- (IBAction)eraseBtnClicked:(id)sender {
    erase = YES;
    maskingLayer.segFlag = YES;
    [maskingLayer setNeedsDisplay];
}


- (IBAction)restoreBtnClicked:(id)sender {
    redraw = YES;
    maskingLayer.segFlag = NO;
    [maskingLayer setNeedsDisplay];
}

- (IBAction)roundShapeClicked:(id)sender {
    isCircleShapeBrush = YES;
    isSquareShapeBrush = NO;
    isTriangleShapeBrush = NO;
    CGPoint staticBrushCenter = CGPointMake(staticBrushView.frame.origin.x + (staticBrushView.frame.size.width /2), staticBrushView.frame.origin.y + (staticBrushWidth/2) - _brushOffsetSlider.value);
    [self drawCircleInView:_brushSizeSlider.value position:staticBrushCenter];
    [movingBrushView setCenter:staticBrushCenter];
}

- (IBAction)squareShapeClicked:(id)sender {
    isCircleShapeBrush = NO;
    isSquareShapeBrush = YES;
    isTriangleShapeBrush = NO;
    CGPoint staticBrushCenter = CGPointMake(staticBrushView.frame.origin.x + (staticBrushView.frame.size.width /2), staticBrushView.frame.origin.y + (staticBrushWidth/2) - _brushOffsetSlider.value);
    [self drawSquareInView:_brushSizeSlider.value position:staticBrushCenter];
    [movingBrushView setCenter:staticBrushCenter];
}

- (IBAction)triangleShapeClicked:(id)sender {
    isCircleShapeBrush = NO;
    isSquareShapeBrush = NO;
    isTriangleShapeBrush = YES;
    CGPoint staticBrushCenter = CGPointMake(staticBrushView.frame.origin.x + (staticBrushView.frame.size.width /2), staticBrushView.frame.origin.y + (staticBrushWidth/2) - _brushOffsetSlider.value);
    [self drawTriangleInView:_brushSizeSlider.value position:staticBrushCenter];
    [movingBrushView setCenter:staticBrushCenter];
}

#pragma mark:- Create & Draw Brush
-(void) createBrushView{
    //Static Brush
    staticBrushWidth = 14.0 * RATIO;
    staticBrushView = [[UIImageView alloc] initWithFrame:CGRectMake(self.containerView.frame.size.width /2, self.containerView.frame.size.height - 50, staticBrushWidth, staticBrushWidth)];
    staticBrushView.layer.cornerRadius = staticBrushWidth/2.0;
    staticBrushView.layer.borderColor = [UIColor colorWithRed: 0.72 green: 0.38 blue: 1.00 alpha: 1.00].CGColor;
    staticBrushView.layer.borderWidth = 2.0;
    staticBrushView.backgroundColor = [UIColor whiteColor];
    [self.containerView addSubview:staticBrushView];
    [self.containerView bringSubviewToFront:staticBrushView];
    
    //EraseBrush
    movingBrushView = [[UIView alloc] init];
    [self.containerView addSubview:movingBrushView];
    [self.containerView bringSubviewToFront:movingBrushView];
  
    CGPoint staticBrushCenter = CGPointMake(staticBrushView.frame.origin.x + (staticBrushView.frame.size.width /2), staticBrushView.frame.origin.y + (staticBrushWidth/2) - _brushOffsetSlider.value);
    [self drawCircleInView:_brushSizeSlider.value position:staticBrushCenter];
    [movingBrushView setCenter:staticBrushCenter];
}

- (void)drawTriangleInView:(CGFloat)size position:(CGPoint)position {
    NSArray *layersInView = [NSArray arrayWithArray:movingBrushView.layer.sublayers];
    for(CALayer *layer in layersInView) {
        [layer removeFromSuperlayer];
    }
    
    movingBrushView.frame = CGRectMake(position.x, position.y, size, size);

    CGPoint p1 = CGPointMake(movingBrushView.frame.size.width/2, 0);
    CGPoint p2 = CGPointMake(0, movingBrushView.frame.size.height);
    CGPoint p3 = CGPointMake(movingBrushView.frame.size.width, movingBrushView.frame.size.height);
    
    UIBezierPath* trianglePath = [UIBezierPath bezierPath];
    [trianglePath moveToPoint: p1];
    [trianglePath addLineToPoint:p2];
    [trianglePath addLineToPoint:p3];
    [trianglePath closePath];

    CAShapeLayer *triangleMaskLayer = [CAShapeLayer layer];
    [triangleMaskLayer setPath:trianglePath.CGPath];
    triangleMaskLayer.fillColor = UIColor.clearColor.CGColor;
    triangleMaskLayer.fillRule = kCAFillRuleEvenOdd;
    triangleMaskLayer.strokeColor = [UIColor colorWithRed: 0.72 green: 0.38 blue: 1.00 alpha: 1.00].CGColor;
    triangleMaskLayer.lineWidth = 2.0;
    [movingBrushView.layer addSublayer:triangleMaskLayer];
}

- (void)drawCircleInView:(CGFloat)size position:(CGPoint)position {
    NSArray *layersInView = [NSArray arrayWithArray:movingBrushView.layer.sublayers];
    for(CALayer *layer in layersInView) {
        [layer removeFromSuperlayer];
    }
    movingBrushView.frame = CGRectMake(position.x, position.y, size, size);

    UIBezierPath *circlePath = [[UIBezierPath alloc] init];
    [circlePath addArcWithCenter:CGPointMake(movingBrushView.frame.size.width/2, movingBrushView.frame.size.height/2) radius:size/2 startAngle:0 endAngle:M_PI * 2 clockwise:TRUE];

    CAShapeLayer *circleMaskLayer = [CAShapeLayer layer];
    [circleMaskLayer setPath:circlePath.CGPath];
    circleMaskLayer.fillColor = UIColor.clearColor.CGColor;
    circleMaskLayer.fillRule = kCAFillRuleEvenOdd;
    circleMaskLayer.strokeColor = [UIColor colorWithRed: 0.72 green: 0.38 blue: 1.00 alpha: 1.00].CGColor;
    circleMaskLayer.lineWidth = 2.0;
    [movingBrushView.layer addSublayer:circleMaskLayer];
}

- (void)drawSquareInView:(CGFloat)size position:(CGPoint)position{
    NSArray *layersInView = [NSArray arrayWithArray:movingBrushView.layer.sublayers];
    for(CALayer *layer in layersInView) {
        [layer removeFromSuperlayer];
    }
    
    movingBrushView.frame = CGRectMake(position.x, position.y, size, size);
    
    CGPoint p1 = CGPointMake(0, 0);
    CGPoint p2 = CGPointMake(0, movingBrushView.frame.size.height);
    CGPoint p3 = CGPointMake(movingBrushView.frame.size.width, movingBrushView.frame.size.height);
    CGPoint p4 = CGPointMake(movingBrushView.frame.size.width, 0);
    
    UIBezierPath* squarePath = [UIBezierPath bezierPath];
    [squarePath moveToPoint: p1];
    [squarePath addLineToPoint:p2];
    [squarePath addLineToPoint:p3];
    [squarePath addLineToPoint:p4];
    [squarePath closePath];

    CAShapeLayer *squareMaskLayer = [CAShapeLayer layer];
    [squareMaskLayer setPath:squarePath.CGPath];
    squareMaskLayer.fillColor = UIColor.clearColor.CGColor;
    squareMaskLayer.fillRule = kCAFillRuleEvenOdd;
    squareMaskLayer.strokeColor = [UIColor colorWithRed: 0.72 green: 0.38 blue: 1.00 alpha: 1.00].CGColor;
    squareMaskLayer.lineWidth = 2.0;
    [movingBrushView.layer addSublayer:squareMaskLayer];
}

@end
