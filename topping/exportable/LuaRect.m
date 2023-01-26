#import "LuaRect.h"
#import "LuaAll.h"

@implementation LuaRect

+(LuaRect *)createRect
{
    return [[LuaRect alloc] init];
}

+(LuaRect *)createRectPar:(float)left :(float)top :(float)right :(float)bottom
{
    LuaRect *rect = [[LuaRect alloc] init];
    [rect set:left :top :right :bottom];
    return rect;    
}

-(void)set:(float)left :(float)top :(float)right :(float)bottom
{
    rect = CGRectMake(left, top, right - left, bottom - top);
}

-(float)getLeft
{
    return rect.origin.x;
}

-(float)getRight
{
    return rect.origin.x + rect.size.width;
}

-(float)getTop
{
    return rect.origin.y;
}

-(float)getBottom
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
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(createRect))
										:@selector(createRect)
										:[NSObject class]
										:[NSArray arrayWithObjects:nil]
										:[LuaRect class]]
			 forKey:@"createRect"];
    [dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(createRectPar::::))
										:@selector(createRectPar::::)
										:[NSObject class]
										:[NSArray arrayWithObjects:[LuaFloat class], [LuaFloat class], [LuaFloat class], [LuaFloat class], nil]
										:[LuaRect class]]
			 forKey:@"createRectPar"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(set::::))
									   :@selector(set::::)
									   :nil
									   :[NSArray arrayWithObjects:[LuaFloat class], [LuaFloat class], [LuaFloat class], [LuaFloat class], nil]]
			 forKey:@"set"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(getLeft))
									   :@selector(getLeft)
									   :[LuaFloat class]
									   :MakeArray(nil)]
			 forKey:@"getLeft"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(getRight))
									   :@selector(getRight)
									   :[LuaFloat class]
									   :MakeArray(nil)]
			 forKey:@"getRight"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(getTop))
									   :@selector(getTop)
									   :[LuaFloat class]
									   :MakeArray(nil)]
			 forKey:@"getTop"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(getBottom))
									   :@selector(getBottom)
									   :[LuaFloat class]
									   :MakeArray(nil)]
			 forKey:@"getBottom"];
	return dict;
}

@end
