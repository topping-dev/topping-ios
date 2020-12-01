#import "LGHorizontalScrollView.h"
#import "LuaFunction.h"
#import "Defines.h"

@implementation LGHorizontalScrollView

-(UIView*)CreateComponent
{
	UIScrollView *iv = [[UIScrollView alloc] init];
	iv.frame = CGRectMake(self.dX, self.dY, self.dWidth, self.dHeight);
	return iv;
}

-(void) ComponentAddMethod:(UIView *)par :(UIView *)me
{
	[super ComponentAddMethod:par :me];
	int totalWidth = 0;
	for(LGView *v in self.subviews)
	{
		totalWidth += [v GetContentW];
	}
	((UIScrollView*)me).contentSize = CGSizeMake(totalWidth + 10, ((UIScrollView*)me).contentSize.height);
}

//Lua
+(LGHorizontalScrollView*)Create:(LuaContext *)context
{
	LGHorizontalScrollView *lst = [[LGHorizontalScrollView alloc] init];
	[lst InitProperties];
	return lst;
}

-(NSString*)GetId
{
	if(self.lua_id != nil)
		return self.lua_id;
	if(self.android_tag != nil)
		return self.android_tag;
	else
		return [LGHorizontalScrollView className];
}

+ (NSString*)className
{
	return @"LGHorizontalScrollView";
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(Create::)) 
										:@selector(Create::) 
										:[LGHorizontalScrollView class]
										:[NSArray arrayWithObjects:[LuaContext class], [NSString class], nil] 
										:[LGHorizontalScrollView class]] 
			 forKey:@"Create"];
	return dict;
}

@end
