#import "LGCompoundButton.h"
#import "Defines.h"
#import "LuaFunction.h"

@implementation LGCompoundButton

//Lua
+(LGCompoundButton*)Create:(LuaContext *)context
{
	LGCompoundButton *lst = [[LGCompoundButton alloc] init];
	[lst InitProperties];
	return lst;
}

-(NSString*)GetId
{
    GETID
    return [LGCompoundButton className];
}

+ (NSString*)className
{
	return @"LGCompoundButton";
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(Create:)) 
										:@selector(Create:)
										:[LGCompoundButton class]
										:[NSArray arrayWithObjects:[LuaContext class], [NSString class], nil] 
										:[LGCompoundButton class]] 
			 forKey:@"Create"];
	return dict;
}

@end
