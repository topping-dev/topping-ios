#import "Common.h"
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface PointAnnotationView : MKPinAnnotationView {
}

@property (nonatomic) MKMapView *mapView;
@property BOOL isMoving;
@property CGPoint startLocation;
@property CGPoint originalCenter;
@property (nonatomic) UIImageView *pinShadow;
@property (nonatomic) NSTimer *pinTimer;


// Please use this class method to create DDAnnotationView (on iOS 3) or built-in draggble MKPinAnnotationView (on iOS 4).
+ (id)annotationViewWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier mapView:(MKMapView *)mapView;

#if __IPHONE_OS_VERSION_MIN_REQUIRED < 40000
+ (CAAnimation *)pinBounceAnimation_;
+ (CAAnimation *)pinFloatingAnimation_;
+ (CAAnimation *)pinLiftAnimation_;
+ (CAAnimation *)liftForDraggingAnimation_; // Used in touchesBegan:
+ (CAAnimation *)liftAndDropAnimation_;        // Used in touchesEnded: when touchesMoved: previous triggered
#endif

- (id)initWithAnnotation_:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier mapView:(MKMapView *)mapView;

#if __IPHONE_OS_VERSION_MIN_REQUIRED < 40000
- (void)shadowLiftWillStart_:(NSString *)animationID context:(void *)context;
- (void)shadowDropDidStop_:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
- (void)resetPinPosition_:(NSTimer *)timer;
#endif

@end
