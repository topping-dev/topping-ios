#import "LuaMapCircle.h"
#import "MapHelper.h"
#import "LuaFunction.h"
#import "LuaValues.h"

@implementation LuaMapCircle

@synthesize lastPoint, lastRaidus, view;

+(LuaMapCircle *)circleWithCenterCoordinate:(CLLocationCoordinate2D)coord radiusCoordinate:(CLLocationCoordinate2D)rcoord mapView:(MKMapView *)mapView
{
    LuaMapCircle *circle = [[LuaMapCircle alloc] init];
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

-(void)SetCenter:(LuaPoint *)center
{
    CLLocationCoordinate2D coord;
    coord.latitude = [center GetX];
    coord.longitude = [center GetY];
    lastPoint = coord;
    [self setCoordinate:coord];
}

-(void)SetCenterEx:(float)x :(float)y
{
    CLLocationCoordinate2D coord;
    coord.latitude = x;
    coord.longitude = y;
    lastPoint = coord;
    [self setCoordinate:coord];
}

-(void)SetRadius:(float)radius
{
    CLLocationCoordinate2D radiusPoint = [MapHelper GetRadiusPoint:lastPoint :radius];
    [self setRadiusCoordinate:radiusPoint];
}

-(void)SetStrokeColor:(LuaColor *)color
{
    self.strokeColor = [color colorValue];
}

-(void)SetStrokeColorEx:(int)color
{
    self.strokeColor = [[LuaColor ColorFromInt:color] colorValue];
}

-(void)SetStrokeWidth:(float)width
{
    self.lineWidth = width;
}

-(void)SetFillColor:(LuaColor *)color
{
    self.fillColor = [color colorValue];
}

-(void)SetFillColorEx:(int)color
{
    self.fillColor = [[LuaColor ColorFromInt:color] colorValue];
}

-(void)SetZIndex:(float)index
{
    
}

-(NSString*)GetId
{
	return @"LuaMapCircle";
}

+ (NSString*)className
{
	return @"LuaMapCircle";
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetCenter:)) :@selector(SetCenter:) :nil :MakeArray([LuaPoint class]C nil)] forKey:@"SetCenter"];
   	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetCenterEx::)) :@selector(SetCenterEx::) :nil :MakeArray([LuaFloat class]C [LuaFloat class]C nil)] forKey:@"SetCenterEx"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetRadius:)) :@selector(SetRadius:) :nil :MakeArray([LuaFloat class]C nil)] forKey:@"SetRadius"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetStrokeColor:)) :@selector(SetStrokeColor:) :nil :MakeArray([LuaColor class]C nil)] forKey:@"SetStrokeColor"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetStrokeColorEx:)) :@selector(SetStrokeColorEx:) :nil :MakeArray([LuaInt class]C nil)] forKey:@"SetStrokeColorEx"];
   	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetStrokeWidth:)) :@selector(SetStrokeWidth:) :nil :MakeArray([LuaFloat class]C nil)] forKey:@"SetStrokeWidth"];
  	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetFillColor:)) :@selector(SetFillColor:) :nil :MakeArray([LuaColor class]C nil)] forKey:@"SetFillColor"];
   	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetFillColorEx:)) :@selector(SetFillColorEx:) :nil :MakeArray([LuaInt class]C nil)] forKey:@"SetFillColorEx"];
   	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetZIndex:)) :@selector(SetZIndex:) :nil :MakeArray([LuaFloat class]C nil)] forKey:@"SetZIndex"];
	return dict;
}


@end
