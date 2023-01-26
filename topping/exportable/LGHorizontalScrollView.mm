#import "LGHorizontalScrollView.h"
#import "LuaFunction.h"
#import "Defines.h"

@implementation LGHorizontalScrollView

-(UIView*)createComponent
{
	UIScrollView *iv = [[UIScrollView alloc] init];
	iv.frame = CGRectMake(self.dX, self.dY, self.dWidth, self.dHeight);
    iv.contentSize = CGSizeMake(self.dWidth, self.dHeight);
	return iv;
}

-(void) componentAddMethod:(UIView *)par :(UIView *)me
{
	[super componentAddMethod:par :me];
	int totalWidth = 0;
	for(LGView *v in self.subviews)
	{
		totalWidth += [v getContentW];
	}
	((UIScrollView*)me).contentSize = CGSizeMake(totalWidth + 10, ((UIScrollView*)me).contentSize.height);
}

//Lua
+(LGHorizontalScrollView*)create:(LuaContext *)context
{
	LGHorizontalScrollView *lst = [[LGHorizontalScrollView alloc] init];
	[lst initProperties];
	return lst;
}

-(NSString*)GetId
{
    if(self.lua_id != nil)
        return self.lua_id;
    if(self.android_id != nil)
        return self.android_id;
    return [LGHorizontalScrollView className];
}

+ (NSString*)className
{
	return @"LGHorizontalScrollView";
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(create:))
										:@selector(create:) 
										:[LGHorizontalScrollView class]
										:[NSArray arrayWithObjects:[LuaContext class], [NSString class], nil] 
										:[LGHorizontalScrollView class]] 
			 forKey:@"create"];
	return dict;
}

@end
