#import "LGCompoundButton.h"
#import "Defines.h"
#import "LuaFunction.h"

@implementation LGCompoundButton

//Lua
+(LGCompoundButton*)create:(LuaContext *)context
{
	LGCompoundButton *lst = [[LGCompoundButton alloc] init];
    lst.lc = context;
	[lst initProperties];
	return lst;
}

-(NSString*)GetId
{
    if(self.lua_id != nil)
        return self.lua_id;
    if(self.android_id != nil)
        return self.android_id;
    return [LGCompoundButton className];
}

+ (NSString*)className
{
	return @"LGCompoundButton";
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(create:)) 
										:@selector(create:)
										:[LGCompoundButton class]
										:[NSArray arrayWithObjects:[LuaContext class], [NSString class], nil] 
										:[LGCompoundButton class]] 
			 forKey:@"create"];
	return dict;
}

@end
