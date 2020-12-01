#import "LuaMapMarker.h"
#import "LuaFunction.h"
#import "LuaValues.h"

@implementation LuaMapMarker

-(void)SetDraggable:(bool)draggableP
{
    self.draggable = draggableP;
}

-(void)SetPosition:(LuaPoint*)point
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

-(void)SetSnippet:(NSString*)value
{
    self.snippet = value;
}

-(void)SetTitle:(NSString*)value
{
    self.title = value;
}

-(void)SetVisible:(bool)value
{
    
}

-(NSString*)GetId
{
	return @"LuaMapMarker";
}

+ (NSString*)className
{
	return @"LuaMapMarker";
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetDraggable:)) :@selector(SetDraggable:) :nil :MakeArray([LuaBool class]C nil)] forKey:@"SetDraggable"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetPosition:)) :@selector(SetPosition:) :nil :MakeArray([LuaPoint class]C nil)] forKey:@"SetPosition"];
   	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetPositionEx::)) :@selector(SetPositionEx::) :nil :MakeArray([LuaFloat class]C [LuaFloat class]C nil)] forKey:@"SetPositionEx"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetSnippet:)) :@selector(SetSnippet:) :nil :MakeArray([NSString class]C nil)] forKey:@"SetSnippet"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetTitle:)) :@selector(SetTitle:) :nil :MakeArray([NSString class]C nil)] forKey:@"SetTitle"];
  	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetVisible:)) :@selector(SetVisible:) :nil :MakeArray([LuaBool class]C nil)] forKey:@"SetVisible"];
	return dict;
}

@end
