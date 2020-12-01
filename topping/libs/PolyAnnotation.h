#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface PolyAnnotation : NSObject <MKAnnotation> {
}

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic) NSMutableArray *coordArr;
@property (nonatomic) MKCoordinateSpan span;
@property (nonatomic) MKMapView *mapView;
@property (nonatomic, retain) UIColor *strokeColor;
@property (nonatomic) int lineWidth;
@property (nonatomic) int fillColor;

@end
