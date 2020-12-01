#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PolyAnnotationView : MKAnnotationView
{
}

-(void) regionChanged;

@property (nonatomic, retain) MKMapView* mapView;
@property (nonatomic, retain) UIColor *strokeColor;
@property (nonatomic) int lineWidth;
@property (nonatomic) int fillColor;

@end

NS_ASSUME_NONNULL_END
