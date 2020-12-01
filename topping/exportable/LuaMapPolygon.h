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

@interface LuaMapPolygon : PolyAnnotation<LuaClass, LuaInterface>
{
}

+(LuaMapPolygon *)polyWithCoordinatesArr:(MKMapView *)mapView :(id)points;
-(void)SetStrokeColor:(LuaColor*) color;
-(void)SetStrokeColorEx:(int) color;
-(void)SetStrokeWidth:(double) width;
-(void)SetFillColor:(LuaColor*) color;
-(void)SetFillColorEx:(int) color;
-(void)SetZIndex:(double)index;
-(void)SetVisible:(BOOL)visible;

@property (nonatomic, retain) PolyAnnotationView *view;

@end
