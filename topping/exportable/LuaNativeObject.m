#import "LuaNativeObject.h"


@implementation LuaNativeObject

-(NSString*)GetId
{
	return @"LuaNativeObject"; 
}

+ (NSString*)className
{
	return @"LuaNativeObject";
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	return dict;
}

@end
