#import "LuaMapImage.h"
#import "LuaFunction.h"
#import "LuaValues.h"

@implementation LuaMapImage

-(void)SetBearing:(float)bearing
{
    
}

-(void)SetDimensions:(float)dimensions
{
    
}

-(void)SetDimensionsEx:(float)width :(float)height
{
    
}

-(void)SetPosition:(LuaPoint*) point
{
    CLLocationCoordinate2D coord;
    coord.latitude = [point GetX];
    coord.longitude = [point GetY];
    [self setCoordinate:coord];
}

-(void)SetPositionEx:(float)x :(float)y
{
    CLLocationCoordinate2D coord;
    coord.latitude = x;
    coord.longitude = y;
    [self setCoordinate:coord];
}

-(void)SetTransparency:(float)transparency
{
    
}

-(void)SetVisible:(bool)value
{
    
}

-(void)SetZIndex:(float)index
{
    
}

-(NSString*)GetId
{
	return @"LuaMapImage";
}

+ (NSString*)className
{
	return @"LuaMapImage";
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetBearing:)) :@selector(SetBearing:) :nil :MakeArray([LuaFloat class]C nil)] forKey:@"SetBearing"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetDimensions:)) :@selector(SetDimensions:) :nil :MakeArray([LuaFloat class]C nil)] forKey:@"SetDimensions"];
   	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetDimensionsEx::)) :@selector(SetDimensionsEx::) :nil :MakeArray([LuaFloat class]C [LuaFloat class]C nil)] forKey:@"SetDimensionsEx"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetPosition:)) :@selector(SetPosition:) :nil :MakeArray([LuaPoint class]C nil)] forKey:@"SetPosition"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetPositionEx::)) :@selector(SetPositionEx::) :nil :MakeArray([LuaFloat class]C [LuaFloat class]C nil)] forKey:@"SetPositionEx"];
   	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetTransparency:)) :@selector(SetTransparency:) :nil :MakeArray([LuaFloat class]C nil)] forKey:@"SetTransparency"];
  	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetVisible:)) :@selector(SetVisible:) :nil :MakeArray([LuaBool class]C nil)] forKey:@"SetVisible"];
   	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetZIndex:)) :@selector(SetZIndex:) :nil :MakeArray([LuaFloat class]C nil)] forKey:@"SetZIndex"];
	return dict;
}


@end
