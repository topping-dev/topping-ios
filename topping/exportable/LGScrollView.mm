#import "LGScrollView.h"
#import "LuaTranslator.h"
#import "LuaFunction.h"
#import "Defines.h"

@implementation LGScrollView

-(UIView*)createComponent
{
	UIScrollView *iv = [[UIScrollView alloc] init];
	iv.frame = CGRectMake(self.dX, self.dY, self.dWidth, self.dHeight);
	return iv;
}

-(void) componentAddMethod:(UIView *)par :(UIView *)me
{
	[super componentAddMethod:par :me];
	int totalHeight = 0;
	for(LGView *v in self.subviews)
	{
		totalHeight += [v getContentH];
	}
	((UIScrollView*)me).contentSize = CGSizeMake(((UIScrollView*)me).contentSize.width, totalHeight + 10);
}

//Lua
+(LGScrollView*)create:(LuaContext *)context
{
	LGScrollView *lst = [[LGScrollView alloc] init];
	[lst initProperties];
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
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(create:))
										:@selector(create:) 
										:[LGScrollView class]
										:[NSArray arrayWithObjects:[LuaContext class], [NSString class], nil] 
										:[LGScrollView class]] 
			 forKey:@"create"];
	return dict;
}

@end
