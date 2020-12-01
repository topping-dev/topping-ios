#import "LuaBuffer.h"
#import "LuaAll.h"

@implementation LuaBuffer

@synthesize data;

+(LuaBuffer *)Create:(int)capacity
{
    LuaBuffer *buf = [[LuaBuffer alloc] init];
    buf.data = [NSMutableArray arrayWithCapacity:capacity];
    return buf;
}

-(int)GetByte:(int)index
{
    return [[data objectAtIndex:index] intValue];
}

-(void)SetByte:(int)index :(int)value
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
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(Create:))
										:@selector(Create:)
										:[NSObject class]
										:[NSArray arrayWithObjects:[LuaInt class], nil]
										:[LuaBuffer class]]
			 forKey:@"Create"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(GetByte:))
									   :@selector(GetByte:)
									   :[LuaInt class]
									   :[NSArray arrayWithObjects:[LuaInt class], nil]]
			 forKey:@"GetByte"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetByte::))
									   :@selector(SetByte::)
									   :nil
									   :[NSArray arrayWithObjects:[LuaInt class], [LuaInt class], nil]]
			 forKey:@"SetByte"];
	return dict;
}

@end
