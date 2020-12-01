#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "LuaInterface.h"
#import "LuaClass.h"
#import "LuaColor.h"
#import "LuaContext.h"
#import "LuaPoint.h"
#import "PolyAnnotation.h"
#import "PolyAnnotationView.h"

@interface LuaMapPolyline : PolyAnnotation<LuaClass, LuaInterface>
{
}

+(LuaMapPolyline *)polyWithCoordinatesArr:(MKMapView *)mapView :(id)points;
-(void)SetColor:(LuaColor*) color;
-(void)SetColorEx:(int) color;
-(void)SetWidth:(double) width;
-(void)SetZIndex:(double)index;
-(void)SetVisible:(BOOL)visible;

@property (nonatomic, retain) PolyAnnotationView *view;
@end
