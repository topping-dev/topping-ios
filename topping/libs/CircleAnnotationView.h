#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>

@class CircleViewInternal;
@class CircleAnnotation;
@class CircleAnnotationView;
// this is an internally used view to CSRouteView. The CSRouteView needs a subview that does not get clipped to always
// be positioned at the full frame size and origin of the map. This way the view can be smaller than the route, but it
// always draws in the internal subview, which is the size of the map view.
@interface CircleViewInternal : UIView
{
    // route view which added this as a subview.
    CircleAnnotationView* _routeView;
}
@property (nonatomic, retain) CircleAnnotationView *routeView;

-(UIImage *)routeImage;

@end

// annotation view that is created for display of a route.
@interface CircleAnnotationView: MKAnnotationView
{
}

// signal from our view controller that the map region changed. We will need to resize, recenter and
// redraw the contents of this view when this happens.
-(void) regionChanged;

@property (nonatomic, retain) MKMapView* mapView;
@property (nonatomic, retain) CircleViewInternal* internalRouteView;
@property (nonatomic, retain) UIColor *strokeColor;
@property (nonatomic, retain) UIColor *fillColor;
@property (nonatomic) int lineWidth;

-(void)setScaleWithNumber:(NSNumber*)scale;

@end
