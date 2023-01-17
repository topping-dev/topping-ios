#import "ILuaForm.h"
#import "LuaFunction.h"
#import "ToppingEngine.h"

@implementation ILuaForm

+(ILuaForm *)Create {
    return [[ILuaForm alloc] init];
}

-(NSString*)GetId
{
    return [ILuaForm className];
}

+ (NSString*)className
{
	return @"ILuaForm";
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
        
	return dict;
}

@end
