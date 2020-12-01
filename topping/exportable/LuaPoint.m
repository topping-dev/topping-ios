#import "LuaPoint.h"
#import "LuaAll.h"

@implementation LuaPoint

+(LuaPoint *)CreatePoint
{
    return [[LuaPoint alloc] init];
}

+(LuaPoint *)CreatePointPar:(float)x :(float)y
{
    LuaPoint *point = [[LuaPoint alloc] init];
    [point Set:x :y];
    return point;
}

-(void)Set:(float)x :(float)y
{
    point = CGPointMake(x, y);
}

-(float)GetX
{
    return point.x;
}

-(float)GetY
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
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(CreatePoint))
										:@selector(CreatePoint)
										:[NSObject class]
										:[NSArray arrayWithObjects:nil]
										:[LuaPoint class]]
			 forKey:@"CreatePoint"];
    [dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(CreatePointPar::))
										:@selector(CreatePointPar::)
										:[NSObject class]
										:[NSArray arrayWithObjects:[LuaFloat class], [LuaFloat class], nil]
										:[LuaPoint class]]
			 forKey:@"CreatePointPar"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(Set::))
									   :@selector(Set::)
									   :nil
									   :[NSArray arrayWithObjects:[LuaFloat class], [LuaFloat class], nil]]
			 forKey:@"Set"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(GetX))
									   :@selector(GetX)
									   :[LuaFloat class]
									   :MakeArray(nil)]
			 forKey:@"GetX"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(GetY))
									   :@selector(GetY)
									   :[LuaFloat class]
									   :MakeArray(nil)]
			 forKey:@"GetY"];
	return dict;
}

@end
