#import "LuaToast.h"
#import "LuaFunction.h"
#import "LuaTranslator.h"
#import "LuaValues.h"

#import <topping/topping-Swift.h>

@implementation LuaToast

+(void) Show:(LuaContext *)context :(NSString *)text :(int)duration
{
    [[[LuaToaster alloc] initWithText:text delay:0 duration:(((float)duration) / 1000.0f)] showToast];
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
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(Show:::)) 
										:@selector(Show:::) 
										:nil
										:MakeArray([LuaContext class]C [NSString class]C [LuaInt class]C nil)
										:[LuaToast class]] 
			 forKey:@"Show"];
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
