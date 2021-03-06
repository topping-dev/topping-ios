#import <QuartzCore/QuartzCore.h>
#import "LGAutoCompleteTextView.h"
#import "Defines.h"
#import "LuaFunction.h"

@implementation LGAutoCompleteTextView

//Lua
+(LGAutoCompleteTextView*)Create:(LuaContext *)context
{
	LGAutoCompleteTextView *lst = [[LGAutoCompleteTextView alloc] init];
	[lst InitProperties];
	return lst;
}

-(NSString*)GetId
{
    if(self.lua_id != nil)
        return self.lua_id;
    if(self.android_id != nil)
        return self.android_id;
    if(self.android_tag != nil)
        return self.android_tag;
    return [LGAutoCompleteTextView className];
}

+ (NSString*)className
{
	return @"LGAutoCompleteTextView";
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(Create:))
										:@selector(Create:)
										:[LGAutoCompleteTextView class]
										:[NSArray arrayWithObjects:[LuaContext class], [NSString class], nil] 
										:[LGAutoCompleteTextView class]]
			 forKey:@"Create"];
	return dict;
}

@end
