#import "LuaBuffer.h"
#import "LuaAll.h"

@implementation LuaBuffer

@synthesize data;

+(LuaBuffer *)create:(int)capacity
{
    LuaBuffer *buf = [[LuaBuffer alloc] init];
    buf.data = [NSMutableArray arrayWithCapacity:capacity];
    return buf;
}

-(int)getByte:(int)index
{
    return [[data objectAtIndex:index] intValue];
}

-(void)setByte:(int)index :(int)value
{
    [data setObject:[NSNumber numberWithInt:value] atIndexedSubscript:index];
}

-(NSString*)GetId
{
	return @"LuaBuffer";
}

+ (NSString*)className
{
	return @"LuaBuffer";
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(create:))
										:@selector(create:)
										:[NSObject class]
										:[NSArray arrayWithObjects:[LuaInt class], nil]
										:[LuaBuffer class]]
			 forKey:@"create"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(getByte:))
									   :@selector(getByte:)
									   :[LuaInt class]
									   :[NSArray arrayWithObjects:[LuaInt class], nil]]
			 forKey:@"getByte"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(setByte::))
									   :@selector(setByte::)
									   :nil
									   :[NSArray arrayWithObjects:[LuaInt class], [LuaInt class], nil]]
			 forKey:@"setByte"];
	return dict;
}

@end
