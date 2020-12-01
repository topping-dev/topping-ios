#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


@interface CircleAnnotation : NSObject <MKAnnotation> {
    CLLocationCoordinate2D coordinate;
    MKCoordinateSpan span;
    //CLLocationDistance radius;
    CLLocationCoordinate2D radiusCoordinate;
    MKMapView *mapView;
}

+ (CircleAnnotation *)circleWithCenterCoordinate:(CLLocationCoordinate2D)coord
                                  //radius:(CLLocationDistance)radius
                                  radiusCoordinate:(CLLocationCoordinate2D)rcoord
                                  mapView:(MKMapView *)mapView;

- (CGPoint)getCenterProjection:(UIView *)view;
- (CGPoint)getRadiusProjection:(UIView *)views;

@property (nonatomic, readwrite, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, readwrite) MKCoordinateSpan span;
//@property (nonatomic, readwrite) CLLocationDistance radius;
@property (nonatomic, readwrite, assign) CLLocationCoordinate2D radiusCoordinate;
@property (nonatomic, readwrite, retain) MKMapView *mapView;
@end
