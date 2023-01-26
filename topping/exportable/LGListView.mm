#import "ToppingEngine.h"
#import "LG.h"
#import "LGListView.h"

@class LuaTranslator;

@implementation LGListView

-(int) getContentW
{
	UITableView *table = ((UITableView*)self._view);
	if(table != nil)
	{
		LGAdapterView *adapterL = (LGAdapterView*)table.delegate;
		if(adapterL != nil)
		{
			return [adapterL getTotalWidth:0];
		}
	}
	return 0;
}

-(int) getContentH
{
	UITableView *table = ((UITableView*)self._view);
	if(table != nil)
	{
		LGAdapterView *adapterL = (LGAdapterView*)table.delegate;
		if(adapterL != nil)
		{
			return [adapterL getTotalHeight:0];
		}
	}
	return 0;
}

-(UIView *) createComponent
{
	UITableView *table = [[UITableView alloc] initWithFrame:CGRectMake(self.dX, self.dY, self.dWidth, self.dHeight) style:UITableViewStylePlain];
    table.frame = CGRectMake(self.dX, self.dY, self.dWidth, self.dHeight);
	return table;
}

-(void) setupComponent:(UIView *)view
{
	UITableView *tv = (UITableView*)self._view;
	if(self.android_divider != nil)
		tv.separatorColor = [[LGColorParser getInstance] parseColor:self.android_divider];
}

+(LGListView *)create:(LuaContext *)context
{
	LGListView *lst = [[LGListView alloc] init];
	return lst;
}

-(void)setAdapter:(LGAdapterView *)val
{
	((UITableView*)self._view).delegate = val;
	((UITableView*)self._view).dataSource = val;
	val.parent = self;
    self.adapter_ = val;
	[((UITableView*)self._view) reloadData];
	LGView *parToFind = self.parent;
	while(parToFind != nil)
	{
		LGView *findView = parToFind.parent;
		if(findView == nil)
			break;
		parToFind = findView;
	}
	
	/*if(parToFind != nil)
		[parToFind Resize];
	else
		[self Resize];*/
	
	[((UITableView*)self._view) setFrame:CGRectMake(self.dX, self.dY, self.dWidth, self.dHeight)];
}

-(LGAdapterView *)getAdapter
{
    return self.adapter_;
}

-(void)refresh
{
    [((UITableView*)self._view) reloadData];
}

-(NSString*)GetId
{
    if(self.lua_id != nil)
        return self.lua_id;
    if(self.android_id != nil)
        return self.android_id;
    return [LGListView className];
}

+ (NSString*)className
{
	return @"LGListView";
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(create:)) 
										:@selector(create:)
										:[LGListView class]
										:[NSArray arrayWithObjects:[LuaContext class], [NSString class], nil] 
										:[LGListView class]] 
			 forKey:@"create"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(setAdapter:)) :@selector(setAdapter:) :nil :MakeArray([LGAdapterView class]C nil)] forKey:@"setAdapter"];
   	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(getAdapter)) :@selector(getAdapter) :[LGAdapterView class] :MakeArray(nil)] forKey:@"getAdapter"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(refresh)) :@selector(refresh) :nil :MakeArray(nil)] forKey:@"refresh"];
	return dict;
}

@end
