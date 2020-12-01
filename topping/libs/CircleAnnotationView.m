#import "Common.h"
#import "CircleAnnotation.h"
#import "CircleAnnotationView.h"

@implementation CircleViewInternal
@synthesize routeView = _routeView;

-(void) drawRect:(CGRect) rect
{
    CircleAnnotation* routeAnnotation = (CircleAnnotation*)self.routeView.annotation;
    
    if(self.routeView.strokeColor == nil)
        self.routeView.strokeColor = UIColorFromARGB(255, 0, 0, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 2.0);
    CGContextSetStrokeColorWithColor(context, self.routeView.strokeColor.CGColor);
    
    CGPoint point = [routeAnnotation getCenterProjection:self];
    CGPoint rPoint = [routeAnnotation getRadiusProjection:self];
    float deltaX = rPoint.x - point.x;
    float deltaY = rPoint.y - point.y;
    int radius = (int) sqrt((deltaY * deltaY) + (deltaX * deltaX));
    CGRect rectangle = CGRectMake(point.x - radius, point.y - radius, radius * 2, radius * 2);
    CGContextAddEllipseInRect(context, rectangle);
    CGContextStrokePath(context);
    if(self.routeView.fillColor != nil)
    {
        CGContextSetFillColorWithColor(context, self.routeView.fillColor.CGColor);
        CGContextFillEllipseInRect(context, rectangle);
    }
        // debug. Draw the line around our view.
        
        //        CGContextMoveToPoint(context, 0, 0);
        //        CGContextAddLineToPoint(context, 0, self.frame.size.height);
        //        CGContextAddLineToPoint(context, self.frame.size.width, self.frame.size.height);
        //        CGContextAddLineToPoint(context, self.frame.size.width, 0);
        //        CGContextAddLineToPoint(context, 0, 0);
        //        CGContextStrokePath(context);
}

-(id) init
{
    self = [super init];
    self.backgroundColor = [UIColor clearColor];
    self.clipsToBounds = NO;
    
    return self;
}

-(UIImage *)routeImage
{
    UIGraphicsBeginImageContext(self.bounds.size);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return viewImage;
}

@end

@implementation CircleAnnotationView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor clearColor];
        
        // do not clip the bounds. We need the CSRouteViewInternal to be able to render the route, regardless of where the
        // actual annotation view is displayed.
        self.clipsToBounds = NO;
        
        // create the internal route view that does the rendering of the route.
        self.internalRouteView = [[CircleViewInternal alloc] init];
        self.internalRouteView.routeView = self;
        self.internalRouteView.alpha = 0.75;
        [self addSubview:self.internalRouteView];
    }
    return self;
}

-(void) setMapView:(MKMapView*) mapView
{
    [self regionChanged];
}

-(void) regionChanged
{
    NSLog(@"Region Changed");
    
    // move the internal route view.
    CGPoint origin = CGPointMake(0, 0);
    origin = [self.mapView convertPoint:origin toView:self];
    
    self.internalRouteView.frame = CGRectMake(origin.x, origin.y, self.mapView.frame.size.height, self.mapView.frame.size.height);
    [self.internalRouteView setNeedsDisplay];
    
}

-(void)setScaleWithNumber:(NSNumber*)scale{
    
}

@end
