#import "LGScrollView.h"
#import "LuaTranslator.h"
#import "LuaFunction.h"
#import "Defines.h"

@implementation LGScrollView

-(UIView*)createComponent
{
	UIScrollView *sv = [[UIScrollView alloc] init];
    sv.delegate = self;
	sv.frame = CGRectMake(self.dX, self.dY, self.dWidth, self.dHeight);
	return sv;
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

- (float)getScrollX {
    UIScrollView *sv = (UIScrollView*)self._view;
    return sv.contentOffset.x;
}

- (float)getScrollY {
    UIScrollView *sv = (UIScrollView*)self._view;
    return sv.contentOffset.y;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.viewTreeObserver dispatchScrollChanged];
}

//Lua
+(LGScrollView*)create:(LuaContext *)context
{
	LGScrollView *lst = [[LGScrollView alloc] init];
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

#pragma TIOSKHView start

-(BOOL)canScrollVerticallyVert:(int32_t)vert {
    return true;
}

@end
