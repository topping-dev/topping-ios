#import "LGHorizontalScrollView.h"
#import "LuaFunction.h"
#import "Defines.h"

@implementation LGHorizontalScrollView

-(UIView*)createComponent
{
	UIScrollView *sv = [[UIScrollView alloc] init];
    sv.delegate = self;
	sv.frame = CGRectMake(self.dX, self.dY, self.dWidth, self.dHeight);
    sv.contentSize = CGSizeMake(self.dWidth, self.dHeight);
	return sv;
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
+(LGHorizontalScrollView*)create:(LuaContext *)context
{
	LGHorizontalScrollView *lst = [[LGHorizontalScrollView alloc] init];
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
