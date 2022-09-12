#import "LGScrollView.h"
#import "LuaTranslator.h"
#import "LuaFunction.h"
#import "Defines.h"

@implementation LGScrollView

-(UIView*)CreateComponent
{
	UIScrollView *iv = [[UIScrollView alloc] init];
	iv.frame = CGRectMake(self.dX, self.dY, self.dWidth, self.dHeight);
	return iv;
}

-(void) ComponentAddMethod:(UIView *)par :(UIView *)me
{
	[super ComponentAddMethod:par :me];
	int totalHeight = 0;
	for(LGView *v in self.subviews)
	{
		totalHeight += [v GetContentH];
	}
	((UIScrollView*)me).contentSize = CGSizeMake(((UIScrollView*)me).contentSize.width, totalHeight + 10);
}

//Lua
+(LGScrollView*)Create:(LuaContext *)context
{
	LGScrollView *lst = [[LGScrollView alloc] init];
	[lst InitProperties];
	return lst;
}

-(NSString*)GetId
{
    if(self.lua_id != nil)
        return self.lua_id;
    if(self.android_id != nil)
        return self.android_id;
    return [LGScrollView className];
}

+ (NSString*)className
{
	return @"LGScrollView";
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(Create:))
										:@selector(Create:) 
										:[LGScrollView class]
										:[NSArray arrayWithObjects:[LuaContext class], [NSString class], nil] 
										:[LGScrollView class]] 
			 forKey:@"Create"];
	return dict;
}

@end
