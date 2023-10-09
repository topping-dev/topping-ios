#import <QuartzCore/QuartzCore.h>
#import "LGAutoCompleteTextView.h"
#import "Defines.h"
#import "LuaFunction.h"

@implementation LGAutoCompleteTextView

//Lua
+(LGAutoCompleteTextView*)create:(LuaContext *)context
{
	LGAutoCompleteTextView *lst = [[LGAutoCompleteTextView alloc] init];
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
    return [LGAutoCompleteTextView className];
}

+ (NSString*)className
{
	return @"LGAutoCompleteTextView";
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(create:))
										:@selector(create:)
										:[LGAutoCompleteTextView class]
										:[NSArray arrayWithObjects:[LuaContext class], [NSString class], nil] 
										:[LGAutoCompleteTextView class]]
			 forKey:@"create"];
	return dict;
}

@end
