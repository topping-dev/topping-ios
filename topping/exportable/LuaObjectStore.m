#import "LuaObjectStore.h"


@implementation LuaObjectStore

@synthesize obj;

-(NSString*)GetId
{
	return @"LuaObjectStore"; 
}

+ (NSString*)className
{
	return @"LuaObjectStore";
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	return dict;
}

@end
