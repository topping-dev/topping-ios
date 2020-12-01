#import "PointAnnotationView.h"
#import "PointAnnotation.h"
#import <QuartzCore/QuartzCore.h> // For CAAnimation

@implementation PointAnnotationView

// Thanks to Bret Cheng (@bretcheng)'s suggestion on avoiding memory leaks in -initWithAnnotation:reuseIdentifier: when returning MKPinAnnotationView instead
+ (id)annotationViewWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier mapView:(MKMapView *)mapView {
    
    // iOS 3.2 will respond to isDraggable property, so use systemVersion to do the check. Thanks to Erich Wood (@erichwood) for the report.
    //BOOL draggingSupport = ([[[UIDevice currentDevice] systemVersion] compare:@"4.0" options:NSNumericSearch] != NSOrderedAscending);
    BOOL draggingSupport = SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"4.0");
    
    if (draggingSupport) {
        MKPinAnnotationView *annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
        [annotationView performSelector:NSSelectorFromString(@"setDraggable:") withObject:[NSNumber numberWithBool:YES]];
        //annotationView.canShowCallout = YES;
        return annotationView;
    }
    
    return [[self alloc] initWithAnnotation_:annotation reuseIdentifier:reuseIdentifier mapView:mapView];
}

- (id)initWithAnnotation_:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier mapView:(MKMapView *)mapView {
    if ((self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier])) {
        self.image = [UIImage imageNamed:@"Pin.png"];
        self.centerOffset = CGPointMake(8, -14);
        self.calloutOffset = CGPointMake(-8, 0);
        self.canShowCallout = YES;
        
        self.pinShadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PinShadow.png"]];
        self.pinShadow.frame = CGRectMake(0, 0, 32, 39);
        self.pinShadow.hidden = YES;
        [self addSubview:self.pinShadow];
        
        self.mapView = mapView;
    }
    
    return self;
}

-(void) setDragState:(MKAnnotationViewDragState)newDragState
{
    [super setDragState:newDragState animated:NO];
}

-(void) setDragState:(MKAnnotationViewDragState)newDragState animated:(BOOL)animated
{
    [super setDragState:newDragState animated:NO];
}

// NOTE: iOS 4 MapKit won't use the source code below, we return a draggable MKPinAnnotationView instance instead.

#if __IPHONE_OS_VERSION_MIN_REQUIRED < 40000

#pragma mark -
#pragma mark Core Animation class methods

+ (CAAnimation *)pinBounceAnimation_ {
    
    CAKeyframeAnimation *pinBounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
    
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:(id)[UIImage imageNamed:@"PinDown1.png"].CGImage];
    [values addObject:(id)[UIImage imageNamed:@"PinDown2.png"].CGImage];
    [values addObject:(id)[UIImage imageNamed:@"PinDown3.png"].CGImage];
    
    [pinBounceAnimation setValues:values];
    pinBounceAnimation.duration = 0.1;
    
    return pinBounceAnimation;
}

+ (CAAnimation *)pinFloatingAnimation_ {
    
    CAKeyframeAnimation *pinFloatingAnimation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
    
    [pinFloatingAnimation setValues:[NSArray arrayWithObject:(id)[UIImage imageNamed:@"PinFloating.png"].CGImage]];
    pinFloatingAnimation.duration = 0.2;
    
    return pinFloatingAnimation;
}

+ (CAAnimation *)pinLiftAnimation_ {
    
    CABasicAnimation *liftAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    
    liftAnimation.byValue = [NSValue valueWithCGPoint:CGPointMake(0.0, -39.0)];
    liftAnimation.duration = 0.2;
    
    return liftAnimation;
}

+ (CAAnimation *)liftForDraggingAnimation_ {
    
    CAAnimation *pinBounceAnimation = [CirclePointAnnotationView pinBounceAnimation_];
    CAAnimation *pinFloatingAnimation = [CirclePointAnnotationView pinFloatingAnimation_];
    pinFloatingAnimation.beginTime = CirclePointAnnotationinBounceAnimation.duration;
    CAAnimation *pinLiftAnimation = [CirclePointAnnotationView pinLiftAnimation_];
    pinLiftAnimation.beginTime = pinBounceAnimation.duration;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = [NSArray arrayWithObjects:pinBounceAnimation, pinFloatingAnimation, pinLiftAnimation, nil];
    group.duration = pinBounceAnimation.duration + pinFloatingAnimation.duration;
    group.fillMode = kCAFillModeForwards;
    group.removedOnCompletion = NO;
    
    return group;
}

+ (CAAnimation *)liftAndDropAnimation_ {
    
    CAAnimation *pinLiftAndDropAnimation = [CirclePointAnnotationView pinLiftAnimation_];
    CAAnimation *pinFloatingAnimation = [CirclePointAnnotationView pinFloatingAnimation_];
    CAAnimation *pinBounceAnimation = [CirclePointAnnotationView pinBounceAnimation_];
    pinBounceAnimation.beginTime = pinFloatingAnimation.duration;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = [NSArray arrayWithObjects:pinLiftAndDropAnimation, pinFloatingAnimation, pinBounceAnimation, nil];
    group.duration = pinFloatingAnimation.duration + pinBounceAnimation.duration;
    
    return group;
}

#pragma mark -
#pragma mark UIView animation delegates

- (void)shadowLiftWillStart_:(NSString *)animationID context:(void *)context {
    self.pinShadow.hidden = NO;
}

- (void)shadowDropDidStop_:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    self.pinShadow.hidden = YES;
}

#pragma mark NSTimer fire method

- (void)resetPinPosition_:(NSTimer *)timer {
    
    [self.pinTimer invalidate];
    self.pinTimer = nil;
    
    [self.layer addAnimation:[CirclePointAnnotationView liftAndDropAnimation_] forKey:@"CirclePinAnimation"];
    
    // TODO: animation out-of-sync with self.layer
    [UIView beginAnimations:@"CircleShadowLiftDropAnimation" context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(shadowDropDidStop_:finished:context:)];
    [UIView setAnimationDuration:0.1];
    self.pinShadow.center = CGPointMake(90, -30);
    self.pinShadow.center = CGPointMake(16.0, 19.5);
    self.pinShadow.alpha = 0;
    [UIView commitAnimations];
    
    // Update the map coordinate to reflect the new position.
    CGPoint newCenter;
    newCenter.x = self.center.x - self.centerOffset.x;
    newCenter.y = self.center.y - self.centerOffset.y - self.image.size.height + 4.;
    
    CirclePointAnnotation *theAnnotation = (CirclePointAnnotation *)self.annotation;
    CLLocationCoordinate2D newCoordinate = [self.mapView convertPoint:newCenter toCoordinateFromView:self.superview];
    [theAnnotation setCoordinate:newCoordinate];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CirclePointAnnotationCoordinateDidChangeNotification" object:theAnnotation];
    
    // Clean up the state information.
    self.startLocation = CGPointZero;
    self.originalCenter = CGPointZero;
    self.isMoving = NO;
}

#pragma mark -
#pragma mark Handling events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (self.mapView) {
        [self.layer removeAllAnimations];
        
        [self.layer addAnimation:[CirclePointAnnotationView liftForDraggingAnimation_] forKey:@"CirclePinAnimation"];
        
        [UIView beginAnimations:@"CircleShadowLiftAnimation" context:NULL];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationWillStartSelector:@selector(shadowLiftWillStart_:context:)];
        [UIView setAnimationDuration:0.2];
        self.pinShadow.center = CGPointMake(80, -20);
        self.pinShadow.alpha = 1;
        [UIView commitAnimations];
    }
    
    // The view is configured for single touches only.
    self.startLocation = [[touches anyObject] locationInView:[self superview]];
    self.originalCenter = self.center;
    
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    CGPoint newLocation = [[touches anyObject] locationInView:[self superview]];
    CGPoint newCenter;
    
    // If the user's finger moved more than 5 pixels, begin the drag.
    if ((abs(newLocation.x - self.startLocation.x) > 5.0) || (abs(newLocation.y - self.startLocation.y) > 5.0)) {
        self.isMoving = YES;
    }
    
    // If dragging has begun, adjust the position of the view.
    if (self.mapView && self.isMoving) {
        
        newCenter.x = self.originalCenter.x + (newLocation.x - self.startLocation.x);
        newCenter.y = self.originalCenter.y + (newLocation.y - self.startLocation.y);
        
        self.center = newCenter;
        
        [self.pinTimer invalidate];
        self.pinTimer = nil;
        self.pinTimer = [NSTimer timerWithTimeInterval:0.3 target:self selector:@selector(resetPinPosition_:) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:self.pinTimer forMode:NSDefaultRunLoopMode];
    } else {
        // Let the parent class handle it.
        [super touchesMoved:touches withEvent:event];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (self.mapView) {
        if (self.isMoving) {
            [self.pinTimer invalidate];
            self.pinTimer = nil;
            
            [self.layer addAnimation:[CirclePointAnnotationView liftAndDropAnimation_] forKey:@"CirclePinAnimation"];
            
            // TODO: animation out-of-sync with self.layer
            [UIView beginAnimations:@"CircleShadowLiftDropAnimation" context:NULL];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDidStopSelector:@selector(shadowDropDidStop_:finished:context:)];
            [UIView setAnimationDuration:0.1];
            self.pinShadow.center = CGPointMake(90, -30);
            self.pinShadow.center = CGPointMake(16.0, 19.5);
            self.pinShadow.alpha = 0;
            [UIView commitAnimations];
            
            // Update the map coordinate to reflect the new position.
            CGPoint newCenter;
            newCenter.x = self.center.x - self.centerOffset.x;
            newCenter.y = self.center.y - self.centerOffset.y - self.image.size.height + 4.;
            
            CirclePointAnnotation* theAnnotation = (CirclePointAnnotation *)self.annotation;
            CLLocationCoordinate2D newCoordinate = [self.mapView convertPoint:newCenter toCoordinateFromView:self.superview];
            
            [theAnnotation setCoordinate:newCoordinate];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CirclePointAnnotationCoordinateDidChangeNotification" object:theAnnotation];
            
            // Clean up the state information.
            self.startLocation = CGPointZero;
            self.originalCenter = CGPointZero;
            self.isMoving = NO;
        } else {
            
            // TODO: Currently no drop down effect but pin bounce only
            [self.layer addAnimation:[CirclePointAnnotationView pinBounceAnimation_] forKey:@"CirclePinAnimation"];
            
            // TODO: animation out-of-sync with self.layer
            [UIView beginAnimations:@"CircleShadowDropAnimation" context:NULL];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDidStopSelector:@selector(shadowDropDidStop_:finished:context:)];
            [UIView setAnimationDuration:0.2];
            self.pinShadow.center = CGPointMake(16.0, 19.5);
            self.pinShadow.alpha = 0;
            [UIView commitAnimations];
        }
    } else {
        [super touchesEnded:touches withEvent:event];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (self.mapView) {
        // TODO: Currently no drop down effect but pin bounce only
        [self.layer addAnimation:[CirclePointAnnotationView pinBounceAnimation_] forKey:@"CirclePinAnimation"];
        
        // TODO: animation out-of-sync with self.layer
        [UIView beginAnimations:@"CircleShadowDropAnimation" context:NULL];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(shadowDropDidStop_:finished:context:)];
        [UIView setAnimationDuration:0.2];
        self.pinShadow.center = CGPointMake(16.0, 19.5);
        self.pinShadow.alpha = 0;
        [UIView commitAnimations];
        
        if (self.isMoving) {
            [self.pinTimer invalidate];
            self.pinTimer = nil;
            
            // Move the view back to its starting point.
            self.center = self.originalCenter;
            
            // Clean up the state information.
            self.startLocation = CGPointZero;
            self.originalCenter = CGPointZero;
            self.isMoving = NO;
        }
    } else {
        [super touchesCancelled:touches withEvent:event];
    }
}

#endif

@end
