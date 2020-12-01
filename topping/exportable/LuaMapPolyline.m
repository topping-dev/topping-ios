#import "LuaMapPolyline.h"
#import "LuaFunction.h"
#import "LuaValues.h"

@implementation LuaMapPolyline

+(LuaMapPolyline *)polyWithCoordinatesArr:(MKMapView *)mapView :(id)points
{
    LuaMapPolyline *Poly = [[LuaMapPolyline alloc] init];
    
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

-(void)SetColor:(LuaColor*) color
{
    self.strokeColor = [color colorValue];
}

-(void)SetColorEx:(int) color
{
    self.strokeColor = [[LuaColor ColorFromInt:color] colorValue];
}

-(void)SetWidth:(double) width
{
    self.lineWidth = width;
}

-(void)SetZIndex:(double)index
{
    
}

-(void)SetVisible:(BOOL)visible
{
    
}

-(NSString*)GetId
{
	return @"LuaMapPolyline";
}

+ (NSString*)className
{
	return @"LuaMapPolyline";
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetColor:)) :@selector(SetColor:) :nil :MakeArray([LuaColor class]C nil)] forKey:@"SetColor"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetColorEx:)) :@selector(SetColorEx:) :nil :MakeArray([LuaInt class]C nil)] forKey:@"SetColorEx"];
   	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetWidth:)) :@selector(SetWidth:) :nil :MakeArray([LuaFloat class]C nil)] forKey:@"SetWidth"];
   	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetZIndex:)) :@selector(SetZIndex:) :nil :MakeArray([LuaFloat class]C nil)] forKey:@"SetZIndex"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetVisible:)) :@selector(SetVisible:) :nil :MakeArray([LuaBool class]C nil)] forKey:@"SetVisible"];

	return dict;
}

@end
