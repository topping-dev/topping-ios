#import "LGLayoutParser.h"
#import "DisplayMetrics.h"
#import "LGAbsListView.h"
#import "LGAdapterView.h"
#import "LGAutoCompleteTextView.h"
#import "LGButton.h"
#import "LGCheckBox.h"
#import "LGComboBox.h"
#import "LGCompoundButton.h"
#import "LGDatePicker.h"
#import "LGEditText.h"
#import "LGImageView.h"
#import "LGLinearLayout.h"
#import "LGListView.h"
#import "LGProgressBar.h"
#import "LGRadioButton.h"
#import "LGRadioGroup.h"
#import "LGScrollView.h"
#import "LGTextView.h"
#import "LGView.h"
#import "LGRecyclerView.h"
#import "LGToolbar.h"
#import "LGConstraintLayout.h"

#import "Defines.h"
#import "ToppingEngine.h"
#import "LGParser.h"
#import "LuaResource.h"
#import "GDataXMLNode.h"
 

@implementation LGLayoutParser

+(LGLayoutParser*)GetInstance
{
	return [LGParser GetInstance].pLayout;
}

- (id) init
{
	self = [super init];
	if (self != nil) {
	}
	return self;
}

-(void)Initialize
{
    NSArray *layoutDirectories = [LuaResource GetResourceDirectories:LUA_LAYOUT_FOLDER];
    self.clearedDirectoryList = [[LGParser GetInstance] Tester:layoutDirectories :LUA_LAYOUT_FOLDER];

    [self.clearedDirectoryList sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2)
    {
        NSString *aData = ((DynamicResource*)obj1).data;
        NSString *bData = ((DynamicResource*)obj2).data;
        if(COMPARE(aData, bData))
            return NSOrderedSame;
        else if(aData.length > bData.length)
            return NSOrderedAscending;
        else
            return NSOrderedDescending;
    }];
}

-(LuaStream*)GetLayout:(NSString*)name
{
    LuaStream *ls = nil;
    for(DynamicResource *dr in self.clearedDirectoryList)
    {
        NSString *path = [[sToppingEngine GetUIRoot] stringByAppendingPathComponent:(NSString*)dr.data];
        ls = [LuaResource GetResource:path :name];
        if([ls HasStream])
            break;
    }
    return ls;
}

-(UIView*) ParseXML:(NSString *)filename :(UIView*)parentView :(LGView*)parent :(LuaForm*)cont :(LGView **)lgview;
{
    self.lastFileName = filename;
    LuaStream *ls = [self GetLayout:filename];
    if(![ls HasStream])
    {
        NSLog(@"Cannot read xml file %@", filename);
        return nil;
    }
	NSData *dat = [ls GetData];
	GDataXMLDocument *xml = [[GDataXMLDocument alloc] initWithData:dat error:nil];
	if(xml == nil)
	{
		NSLog(@"Cannot read xml file %@", filename);
		return nil;
	}
		
	GDataXMLElement *root = [xml rootElement];
	LGView *rootView = [self ParseChildXML:nil :root];
	*lgview = rootView;
	return [self GenerateUIViewFromLGView:rootView :parentView :parent :cont];
}

-(Class) ContainsClassNameStringInArray:(NSArray*)arr :(NSString*)str
{
    for(Class cls : arr)
    {
        NSString *className = [cls performSelector:NSSelectorFromString(@"className")];
        if([str containsString:className])
            return cls;
    }
    
    return nil;
}

-(LGView*) ParseChildXML:(LGView*)view :(GDataXMLElement*)parent
{
	NSString *name = [parent name];
	LGView *rootView = nil;
    Class pluginClass = nil;
	
	if([name compare:@"AbsListView"] == 0
	   || [name compare:@"LGAbsListView"] == 0)
		rootView = [[LGAbsListView alloc] init];
	/*else if([name compare:@"AdapterView"] == 0
	   || [name compare:@"LGAdapterView"] == 0)
		rootView = [[LGAdapterView alloc] init];*/
    if([name compare:@"AutoCompleteTextView"] == 0
       || [name compare:@"LGAutoCompleteTextView"] == 0)
        rootView = [[LGAutoCompleteTextView alloc] init];
	else if([name compare:@"Button"] == 0
			|| [name compare:@"LGButton"] == 0)
		rootView = [[LGButton alloc] init];
	else if([name compare:@"CheckBox"] == 0
			|| [name compare:@"LGCheckBox"] == 0)
		rootView = [[LGCheckBox alloc] init];
	else if([name compare:@"ComboBox"] == 0
			|| [name compare:@"LGComboBox"] == 0)
		rootView = [[LGComboBox alloc] init];
	else if([name compare:@"CompoundButton"] == 0
			|| [name compare:@"LGCompoundButton"] == 0)
		rootView = [[LGCompoundButton alloc] init];
	else if([name compare:@"DatePicker"] == 0
			|| [name compare:@"LGDatePicker"] == 0)
		rootView = [[LGDatePicker alloc] init];
	else if([name compare:@"EditText"] == 0
			|| [name compare:@"LGEditText"] == 0)
		rootView = [[LGEditText alloc] init];
	else if([name compare:@"ImageView"] == 0
			|| [name compare:@"LGImageView"] == 0)
		rootView = [[LGImageView alloc] init];	
	else if([name compare:@"LinearLayout"] == 0
	   || [name compare:@"LGLinearLayout"] == 0)
		rootView = [[LGLinearLayout alloc] init];
    else if([name compare:@"FrameLayout"] == 0
       || [name compare:@"LGFrameLayout"] == 0)
        rootView = [[LGFrameLayout alloc] init];
	else if([name compare:@"ListView"] == 0
			|| [name compare:@"LGListView"] == 0)
		rootView = [[LGListView alloc] init];
	else if([name compare:@"ProgressBar"] == 0
			|| [name compare:@"LGProgressBar"] == 0)
		rootView = [[LGProgressBar alloc] init];
	else if([name compare:@"RadioButton"] == 0
			|| [name compare:@"LGRadioButton"] == 0)
		rootView = [[LGRadioButton alloc] init];
	else if([name compare:@"RadioGroup"] == 0
			|| [name compare:@"LGRadioGroup"] == 0)
		rootView = [[LGRadioGroup alloc] init];	
	else if([name compare:@"ScrollView"] == 0
			|| [name compare:@"LGScrollView"] == 0)
		rootView = [[LGScrollView alloc] init];
    else if([name compare:@"HorizontalScrollView"] == 0
        || [name compare:@"LGHorizontalScrollView"] == 0)
    rootView = [[LGScrollView alloc] init];
	else if([name compare:@"TextView"] == 0
			|| [name compare:@"LGTextView"] == 0)
		rootView = [[LGTextView alloc] init];	
	else if([name compare:@"View"] == 0
		|| [name compare:@"LGView"] == 0)
        rootView = [[LGView alloc] init];
    else if([name compare:@"android.support.v7.widget.RecyclerView"] == 0
        || [name compare:@"androidx.recyclerview.widget.RecyclerView"] == 0
        || [name compare:@"LGRecyclerView"] == 0)
        rootView = [[LGRecyclerView alloc] init];
    else if([name compare:@"android.support.v7.widget.Toolbar"] == 0
        || [name compare:@"androidx.appcompat.widget.Toolbar"] == 0
        || [name compare:@"LGToolbar"] == 0)
        rootView = [[LGToolbar alloc] init];
    else if([name compare:@"androidx.constraintlayout.widget.ConstraintLayout"] == 0
        || [name compare:@"LGConstraintLayout"] == 0)
        rootView = [[LGConstraintLayout alloc] init];
    else if([ToppingEngine GetViewPlugins] != nil && (pluginClass = [self ContainsClassNameStringInArray:[ToppingEngine GetViewPlugins] :name]) != nil)
    {
        rootView = [[pluginClass alloc] init];
    }
	else
	{
		NSLog(@"Unknown class %@ at ParseChildXml in file %@", name, self.lastFileName);
		return nil;
	}
	
	[rootView InitProperties];
	NSArray *attrs = [parent attributes];
	for(GDataXMLNode *node in attrs)
	{
		[rootView SetAttributeValue:[node name] :[node stringValue]];
	}
    [rootView ApplyStyles];
	
    if([rootView isKindOfClass:[LGViewGroup class]])
    {
        for(GDataXMLElement *child in [parent children])
        {
            [((LGViewGroup*)rootView) AddSubview:[self ParseChildXML:rootView :child]];
        }
    }
    
	return rootView;
}

-(UIView*) GenerateUIViewFromLGView:(LGView*)view :(UIView*)parentView :(LGView*)parent :(LuaForm*)cont;
{
    view.parent = parent;
    [view Resize];
    UIView *viewRoot = [view CreateComponent];
		
    if([view isKindOfClass:[LGViewGroup class]])
    {
		for(LGView *w in ((LGViewGroup*)view).subviews)
		{
			[w AddSelfToParent:viewRoot :cont];
		}
	}
    [view InitComponent:viewRoot :cont.context];
    return viewRoot;
}

@end
