#import "ILuaFragment.h"
#import "LuaFunction.h"
#import "ToppingEngine.h"

@implementation ILuaFragment

+(ILuaFragment *)Create {
    return [[ILuaFragment alloc] init];
}

-(NSString*)GetId
{
    return [ILuaFragment className];
}

+ (NSString*)className
{
	return @"ILuaFragment";
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
        
	return dict;
}

@end
