#import "LuaRect.h"
#import "LuaAll.h"

@implementation LuaRect

+(LuaRect *)CreateRect
{
    return [[LuaRect alloc] init];
}

+(LuaRect *)CreateRectPar:(float)left :(float)top :(float)right :(float)bottom
{
    LuaRect *rect = [[LuaRect alloc] init];
    [rect Set:left :top :right :bottom];
    return rect;    
}

-(void)Set:(float)left :(float)top :(float)right :(float)bottom
{
    rect = CGRectMake(left, top, right - left, bottom - top);
}

-(float)GetLeft
{
    return rect.origin.x;
}

-(float)GetRight
{
    return rect.origin.x + rect.size.width;
}

-(float)GetTop
{
    return rect.origin.y;
}

-(float)GetBottom
{
    return rect.origin.y + rect.size.height;
}

-(NSString*)GetId
{
	return @"LuaRect";
}

+ (NSString*)className
{
	return @"LuaRect";
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(CreateRect))
										:@selector(CreateRect)
										:[NSObject class]
										:[NSArray arrayWithObjects:nil]
										:[LuaRect class]]
			 forKey:@"CreateRect"];
    [dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(CreateRectPar::::))
										:@selector(CreateRectPar::::)
										:[NSObject class]
										:[NSArray arrayWithObjects:[LuaFloat class], [LuaFloat class], [LuaFloat class], [LuaFloat class], nil]
										:[LuaRect class]]
			 forKey:@"CreateRectPar"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(Set::::))
									   :@selector(Set::::)
									   :nil
									   :[NSArray arrayWithObjects:[LuaFloat class], [LuaFloat class], [LuaFloat class], [LuaFloat class], nil]]
			 forKey:@"Set"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(GetLeft))
									   :@selector(GetLeft)
									   :[LuaFloat class]
									   :MakeArray(nil)]
			 forKey:@"GetLeft"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(GetRight))
									   :@selector(GetRight)
									   :[LuaFloat class]
									   :MakeArray(nil)]
			 forKey:@"GetRight"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(GetTop))
									   :@selector(GetTop)
									   :[LuaFloat class]
									   :MakeArray(nil)]
			 forKey:@"GetTop"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(GetBottom))
									   :@selector(GetBottom)
									   :[LuaFloat class]
									   :MakeArray(nil)]
			 forKey:@"GetBottom"];
	return dict;
}

@end
