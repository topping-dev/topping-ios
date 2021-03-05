#import "ToppingEngine.h"
#import "LG.h"
#import "LGListView.h"

@class LuaTranslator;

@implementation LGListView

-(int) GetContentW
{
	UITableView *table = ((UITableView*)self._view);
	if(table != nil)
	{
		LGAdapterView *adapterL = (LGAdapterView*)table.delegate;
		if(adapterL != nil)
		{
			return [adapterL GetTotalWidth:0];
		}
	}
	return 0;
}

-(int) GetContentH
{
	UITableView *table = ((UITableView*)self._view);
	if(table != nil)
	{
		LGAdapterView *adapterL = (LGAdapterView*)table.delegate;
		if(adapterL != nil)
		{
			return [adapterL GetTotalHeight:0];
		}
	}
	return 0;
}

-(UIView *) CreateComponent
{
	UITableView *table = [[UITableView alloc] initWithFrame:CGRectMake(self.dX, self.dY, self.dWidth, self.dHeight) style:UITableViewStylePlain];
    table.frame = CGRectMake(self.dX, self.dY, self.dWidth, self.dHeight);
	return table;
}

-(void) SetupComponent:(UIView *)view
{
	UITableView *tv = (UITableView*)self._view;
	if(self.android_divider != nil)
		tv.separatorColor = [[LGColorParser GetInstance] ParseColor:self.android_divider];
}

+(LGListView *)Create:(LuaContext *)context
{
	LGListView *lst = [[LGListView alloc] init];
	return lst;
}

-(void)SetAdapter:(LGAdapterView *)val
{
	((UITableView*)self._view).delegate = val;
	((UITableView*)self._view).dataSource = val;
	val.parent = self;
    self.adapter = val;
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

-(LGAdapterView *)GetAdapter
{
    return self.adapter;
}

-(void)Refresh
{
    [((UITableView*)self._view) reloadData];
}

-(NSString*)GetId
{
    if(self.lua_id != nil)
        return self.lua_id;
    if(self.android_id != nil)
        return self.android_id;
    if(self.android_tag != nil)
        return self.android_tag;
    return [LGListView className];
}

+ (NSString*)className
{
	return @"LGListView";
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(Create:)) 
										:@selector(Create:)
										:[LGListView class]
										:[NSArray arrayWithObjects:[LuaContext class], [NSString class], nil] 
										:[LGListView class]] 
			 forKey:@"Create"];	
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetAdapter:)) :@selector(SetAdapter:) :nil :MakeArray([LGAdapterView class]C nil)] forKey:@"SetAdapter"];
   	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(GetAdapter)) :@selector(GetAdapter) :[LGAdapterView class] :MakeArray(nil)] forKey:@"GetAdapter"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(Refresh)) :@selector(Refresh) :nil :MakeArray(nil)] forKey:@"Refresh"];
	return dict;
}

@end
