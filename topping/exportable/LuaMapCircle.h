#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LuaInterface.h"
#import "LuaClass.h"
#import "LuaColor.h"
#import "LuaContext.h"
#import "LuaPoint.h"
#import "CircleAnnotation.h"
#import "CircleAnnotationView.h"

@interface LuaMapCircle : CircleAnnotation<LuaClass, LuaInterface>
{
    CLLocationCoordinate2D lastPoint;
    double lastRadius;
    CircleAnnotationView *view;
}

+(LuaMapCircle *)circleWithCenterCoordinate:(CLLocationCoordinate2D)coord radiusCoordinate:(CLLocationCoordinate2D)rcoord mapView:(MKMapView *)mapView;
-(void)SetCenter:(LuaPoint*) center;
-(void)SetCenterEx:(double) x :(double) y;
-(void)SetRadius:(double) radius;
-(void)SetStrokeColor:(LuaColor*) color;
-(void)SetStrokeColorEx:(int) color;
-(void)SetStrokeWidth:(double) width;
-(void)SetFillColor:(LuaColor*) color;
-(void)SetFillColorEx:(int) color;
-(void)SetZIndex:(double)index;

@property(nonatomic) CLLocationCoordinate2D lastPoint;
@property(nonatomic) double lastRaidus;
@property(nonatomic, retain) CircleAnnotationView *view;
@property (nonatomic, retain) UIColor *strokeColor;
@property (nonatomic, retain) UIColor *fillColor;
@property (nonatomic) int lineWidth;

@end
