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
    GETID
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
