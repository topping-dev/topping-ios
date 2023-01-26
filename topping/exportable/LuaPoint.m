#import "LuaPoint.h"
#import "LuaAll.h"

@implementation LuaPoint

+(LuaPoint *)createPoint
{
    return [[LuaPoint alloc] init];
}

+(LuaPoint *)createPointPar:(float)x :(float)y
{
    LuaPoint *point = [[LuaPoint alloc] init];
    [point set:x :y];
    return point;
}

-(void)set:(float)x :(float)y
{
    point = CGPointMake(x, y);
}

-(float)getX
{
    return point.x;
}

-(float)getY
{
    return point.y;
}

-(NSString*)GetId
{
	return @"LuaPoint";
}

+ (NSString*)className
{
	return @"LuaPoint";
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(createPoint))
										:@selector(createPoint)
										:[NSObject class]
										:[NSArray arrayWithObjects:nil]
										:[LuaPoint class]]
			 forKey:@"createPoint"];
    [dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(createPointPar::))
										:@selector(createPointPar::)
										:[NSObject class]
										:[NSArray arrayWithObjects:[LuaFloat class], [LuaFloat class], nil]
										:[LuaPoint class]]
			 forKey:@"createPointPar"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(set::))
									   :@selector(set::)
									   :nil
									   :[NSArray arrayWithObjects:[LuaFloat class], [LuaFloat class], nil]]
			 forKey:@"set"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(getX))
									   :@selector(getX)
									   :[LuaFloat class]
									   :MakeArray(nil)]
			 forKey:@"getX"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(getY))
									   :@selector(getY)
									   :[LuaFloat class]
									   :MakeArray(nil)]
			 forKey:@"getY"];
	return dict;
}

@end
