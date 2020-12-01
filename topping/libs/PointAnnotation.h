#import <MapKit/MapKit.h>

@interface PointAnnotation : MKPlacemark {
}

// Re-declare MKAnnotation's readonly property 'coordinate' to readwrite.
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *subtitle;

@end
