#import "CircleAnnotation.h"


@implementation CircleAnnotation
@synthesize coordinate = coordinate;
@synthesize span = span;
//@synthesize radius = radius;
@synthesize radiusCoordinate = radiusCoordinate;
@synthesize mapView = mapView;

+(CircleAnnotation *) circleWithCenterCoordinate:(CLLocationCoordinate2D)coord
                                         //radius:(CLLocationDistance)radius
                                         radiusCoordinate:(CLLocationCoordinate2D)rcoord
                                         mapView:(MKMapView *)mapView
{
    CircleAnnotation *circle = [[CircleAnnotation alloc] init];
    [circle setCoordinate:coord];
    //[circle setRadius:radius];
    [circle setRadiusCoordinate:rcoord];
    circle.mapView = mapView;
    
    // determine a logical center point for this route based on the middle of the lat/lon extents.
    double maxLat = -91;
    double minLat =  91;
    double maxLon = -181;
    double minLon =  181;
        
    if(circle.coordinate.latitude > maxLat)
        maxLat = circle.coordinate.latitude;
    if(circle.coordinate.latitude < minLat)
        minLat = circle.coordinate.latitude;
    if(circle.coordinate.longitude > maxLon)
        maxLon = circle.coordinate.longitude;
    if(circle.coordinate.longitude < minLon)
        minLon = circle.coordinate.longitude;
    
    MKCoordinateSpan span;
    
    span.latitudeDelta = (maxLat + 90) - (minLat + 90);
    span.longitudeDelta = (maxLon + 180) - (minLon + 180);
    
    span.longitudeDelta = 0.2f;
    span.latitudeDelta = 0.2f;
    
    [circle setSpan:span];
    
    return circle;
}

-(MKCoordinateRegion) region
{
    MKCoordinateRegion region;
    region.center = coordinate;
    region.span = span;
    
    return region;
}

-(CGPoint) getCenterProjection:(UIView *)view
{
    return [mapView convertCoordinate:coordinate toPointToView:view];
}

-(CGPoint) getRadiusProjection:(UIView *)view
{
    return [mapView convertCoordinate:radiusCoordinate toPointToView:view];
}

@end
