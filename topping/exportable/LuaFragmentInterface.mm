#import "LuaFragmentInterface.h"
#import "LuaFunction.h"
#import "ToppingEngine.h"

@implementation LuaFragmentInterface

+(LuaFragmentInterface *)Create {
    return [[LuaFragmentInterface alloc] init];
}

-(NSString*)GetId
{
    return [LuaFragmentInterface className];
}

+ (NSString*)className
{
	return @"LuaFragmentInterface";
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
        
	return dict;
}

@end
