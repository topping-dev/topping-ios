#import "LuaViewInflator.h"
#import "LuaFunction.h"
#import "LGLayoutParser.h"
#import "LGView.h"
#import "LuaTranslator.h"
#import "Defines.h"

@implementation LuaViewInflator

+(NSObject *) Create:(LuaContext*)lc
{
	return [[LuaViewInflator alloc] init];
}

-(LGView*)ParseFile:(NSString *)filename :(LGView*)parent
{
	LGView *lgview = nil;
	[[LGLayoutParser GetInstance] ParseXML:filename :[parent GetView] :parent :nil :&lgview];
	return lgview;
}

-(NSString*)GetId
{
	return @"LuaViewInflator";
}

+ (NSString*)className
{
	return @"LuaViewInflator";
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(Create:)) 
										:@selector(Create:) 
										:[NSObject class]
										:[NSArray arrayWithObjects:[LuaContext class], nil] 
										:[LuaViewInflator class]] 
			 forKey:@"Create"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(ParseFile::)) 
									   :@selector(ParseFile::) 
									   :[LGView class]
									   :MakeArray([NSString class]C [LGView class]C nil)]
			 forKey:@"ParseFile"];
	return dict;
}

@end
