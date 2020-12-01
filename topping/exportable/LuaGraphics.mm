#import "LuaGraphics.h"
#import "LuaFunction.h"

@implementation LuaGraphics

-(NSString*)GetId
{
	return [LuaGraphics className];
}

+ (NSString*)className
{
	return @"LuaGraphics";
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    /*[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetOnClickListener:)) :@selector(SetOnClickListener:) :nil :MakeArray([LuaTranslator class]C nil)] forKey:@"SetOnClickListener"];*/
	return dict;
}

@end
