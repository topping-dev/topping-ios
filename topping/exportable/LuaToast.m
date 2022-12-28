#import "LuaToast.h"
#import "LuaFunction.h"
#import "LuaTranslator.h"
#import "LuaValues.h"

#import <topping/topping-Swift.h>

@implementation LuaToast

+(void) ShowInternal:(LuaContext *)context :(NSString *)text :(int)duration
{
    [[[LuaToaster alloc] initWithText:text delay:0 duration:(((float)duration) / 1000.0f)] showToast];
}

+(void)Show:(LuaContext *)context :(LuaRef*)text :(int)duration {
    [LuaToast ShowInternal:context :(NSString*)[[LGValueParser GetInstance] GetValue:text.idRef] :duration];
}

-(NSString*)GetId
{
	return @"LuaToast"; 
}

+ (NSString*)className
{
	return @"LuaToast";
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    
    ClassMethodNoRet(ShowInternal:::, @[[LuaContext class]C [NSString class]C [LuaInt class]], @"ShowInternal", [LuaToast class])
    ClassMethodNoRet(Show:::, @[[LuaContext class]C [LuaRef class]C [LuaInt class]], @"Show", [LuaToast class])
    
	return dict;
}

+(NSMutableDictionary*)luaStaticVars
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	[dict setObject:[NSNumber numberWithInt:2000] forKey:@"TOAST_SHORT"];
	[dict setObject:[NSNumber numberWithInt:5000] forKey:@"TOAST_LONG"];
	return dict;
}

@end
