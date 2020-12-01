#import "LuaMapPolygon.h"
#import "LuaFunction.h"
#import "LuaValues.h"

@implementation LuaMapPolygon

+(LuaMapPolygon *)polyWithCoordinatesArr:(MKMapView *)mapView :(id)points
{
    LuaMapPolygon *Poly = [[LuaMapPolygon alloc] init];
    
    // determine a logical center point for this route based on the middle of the lat/lon extents.
	double maxLat = -91;
	double minLat =  91;
	double maxLon = -181;
	double minLon =  181;
    
    for (NSValue* point in points)
    {
        CLLocationCoordinate2D value;
        [point getValue:&value];
        if(value.latitude > maxLat)
            maxLat = value.latitude;
        if(value.latitude < minLat)
            minLat = value.latitude;
        if(value.longitude > maxLon)
            maxLon = value.longitude;
        if(value.longitude < minLon)
            minLon = value.longitude;
        
        NSValue *val = [NSValue valueWithBytes:&value objCType:@encode(CLLocationCoordinate2D)];
        [Poly.coordArr addObject:val];
    }
    
    CLLocationCoordinate2D coord;
    if(Poly.coordArr.count > 0)
        [[Poly.coordArr objectAtIndex:0] getValue:&coord];
    
    Poly.coordinate = coord;
    
    Poly.mapView = mapView;
	
	MKCoordinateSpan span;
	
	span.latitudeDelta = (maxLat + 90) - (minLat + 90);
	span.longitudeDelta = (maxLon + 180) - (minLon + 180);
	
	span.longitudeDelta = 0.2f;
	span.latitudeDelta = 0.2f;
	
	[Poly setSpan:span];
	
	return Poly;
}

-(void)SetStrokeColor:(LuaColor*) color
{
    self.strokeColor = [color colorValue];
}

-(void)SetStrokeColorEx:(int) color
{
    self.strokeColor = [[LuaColor ColorFromInt:color] colorValue];
}

-(void)SetStrokeWidth:(double) width
{
    self.lineWidth = width;
}

-(void)SetFillColor:(LuaColor*) color
{
    self.fillColor = [color colorValue];
}

-(void)SetFillColorEx:(int) color
{
    self.fillColor = [[LuaColor ColorFromInt:color] colorValue];
}

-(void)SetZIndex:(double)index
{
    
}

-(void)SetVisible:(BOOL)visible
{
    
}

-(NSString*)GetId
{
	return @"LuaMapPolygon";
}

+ (NSString*)className
{
	return @"LuaMapPolygon";
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetStrokeColor:)) :@selector(SetStrokeColor:) :nil :MakeArray([LuaColor class]C nil)] forKey:@"SetStrokeColor"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetStrokeColorEx:)) :@selector(SetStrokeColorEx:) :nil :MakeArray([LuaInt class]C nil)] forKey:@"SetStrokeColorEx"];
   	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetStrokeWidth:)) :@selector(SetStrokeWidth:) :nil :MakeArray([LuaFloat class]C nil)] forKey:@"SetStrokeWidth"];
  	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetFillColor:)) :@selector(SetFillColor:) :nil :MakeArray([LuaColor class]C nil)] forKey:@"SetFillColor"];
   	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetFillColorEx:)) :@selector(SetFillColorEx:) :nil :MakeArray([LuaInt class]C nil)] forKey:@"SetFillColorEx"];
   	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetZIndex:)) :@selector(SetZIndex:) :nil :MakeArray([LuaFloat class]C nil)] forKey:@"SetZIndex"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetVisible:)) :@selector(SetVisible:) :nil :MakeArray([LuaBool class]C nil)] forKey:@"SetVisible"];
	return dict;
}

@end
