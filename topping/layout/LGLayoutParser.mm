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
#import "LGTabLayout.h"
#import "LGTextView.h"
#import "LGView.h"
#import "LGRecyclerView.h"
#import "LGToolbar.h"
#import "LGConstraintLayout.h"
#import "LGHorizontalScrollView.h"
#import "LGFragmentContainerView.h"
#import "LGViewPager.h"
#import "LuaFragment.h"
#import "LuaEvent.h"
#import "LGBottomNavigationView.h"
#import "LGWebView.h"
#import "LGTextInputEditText.h"
#import "LGTextInputLayout.h"
#import "LGDrawerLayout.h"
#import "LGNavigationView.h"
#import "LGRelativeLayout.h"

#import "Defines.h"
#import "ToppingEngine.h"
#import "LGParser.h"
#import "LuaResource.h"
#import "GDataXMLNode.h"
 

@implementation LGLayoutParser

+(LGLayoutParser*)getInstance
{
	return [LGParser getInstance].pLayout;
}

- (id) init
{
	self = [super init];
	if (self != nil) {
	}
	return self;
}

-(void)initialize
{
    NSArray *layoutDirectories = [LuaResource getResourceDirectories:LUA_LAYOUT_FOLDER];
    self.clearedDirectoryList = [[LGParser getInstance] tester:layoutDirectories :LUA_LAYOUT_FOLDER];

    [self.clearedDirectoryList sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2)
    {
        NSString *aData = (NSString*)((DynamicResource*)obj1).data;
        NSString *bData = (NSString*)((DynamicResource*)obj2).data;
        if(COMPARE(aData, bData))
            return NSOrderedSame;
        else if(aData.length > bData.length)
            return NSOrderedAscending;
        else
            return NSOrderedDescending;
    }];
    self.layoutMap = [NSMutableDictionary dictionary];
    for(DynamicResource *dr in self.clearedDirectoryList)
    {
        NSArray *files = [LuaResource getResourceFiles:(NSString*)dr.data];
        [files enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *filename = (NSString *)obj;
            NSString *fNameNoExt = [filename stringByDeletingPathExtension];
            [self.layoutMap setObject:fNameNoExt forKey:fNameNoExt];
        }];
    }
}

-(LuaStream*)GetLayout:(NSString*)name
{
    LuaStream *ls = nil;
    for(DynamicResource *dr in self.clearedDirectoryList)
    {
        NSString *path = [[sToppingEngine getUIRoot] stringByAppendingPathComponent:(NSString*)dr.data];
        ls = [LuaResource getResource:path :name];
        if([ls hasStream])
            break;
    }
    return ls;
}

-(UIView*) parseRef:(LuaRef *)filename :(UIView*)parentView :(LGView*)parent :(LuaForm*)cont :(LGView **)lgview
{
    NSArray *arr = SPLIT(filename.idRef, @"/");
    return [self parseXML:[[arr lastObject] stringByAppendingString:@".xml"] :parentView :parent :cont :lgview];
}

-(UIView*) parseData:(NSData*)data :(UIView*)parentView :(LGView*)parent :(LuaForm*)cont :(LGView **)lgview {
    GDataXMLDocument *xml = [[GDataXMLDocument alloc] initWithData:data error:nil];
    if(xml == nil)
    {
        NSLog(@"Cannot read xml file data");
        return nil;
    }
        
    GDataXMLElement *root = [xml rootElement];
    LGView *rootView = [self parseChildXML:nil :root];
    *lgview = rootView;
    if(cont.lgview == nil)
        cont.lgview = rootView;
    return [self generateUIViewFromLGView:rootView :parentView :parent :cont];
}

-(UIView*) parseXML:(NSString *)filename :(UIView*)parentView :(LGView*)parent :(LuaForm*)cont :(LGView **)lgview
{
    self.lastFileName = filename;
    LuaStream *ls = [self GetLayout:filename];
    if(![ls hasStream])
    {
        NSLog(@"Cannot read xml file %@", filename);
        return nil;
    }
	NSData *dat = [ls getData];
    return [self parseData:dat :parentView :parent :cont :lgview];
}

-(LGView*) parseUI:(NSString*)name :(UIView*)parentView :(LGView*)parent :(LuaForm*)cont :(NSArray *)attrs {
    LGView *rootView = nil;
    
    rootView = [self getViewFromName:name :attrs :parent];
    if(rootView == nil) {
        NSLog(@"Unknown class %@ at ParseChildXml in file %@", name, self.lastFileName);
        return nil;
    }
    for(GDataXMLNode *node in attrs)
    {
        [rootView setAttributeValue:[node name] :[node stringValue]];
    }
    [rootView applyStyles];
        
    [self generateUIViewFromLGView:rootView :parentView :parent :cont];
    return rootView;
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

-(LGView*) getViewFromName:(NSString*)name :(NSArray*)attrs :(LGView*)parent
{
    LGView *rootView = nil;
    Class pluginClass = nil;
    
    if([name compare:@"View"] == 0
       || [name compare:@"LGView"] == 0)
        rootView = [[LGView alloc] init];
    else if([name compare:@"AbsListView"] == 0
       || [name compare:@"LGAbsListView"] == 0)
        rootView = [[LGAbsListView alloc] init];
    else if([name compare:@"AutoCompleteTextView"] == 0
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
        rootView = [[LGHorizontalScrollView alloc] init];
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
    else if([name compare:@"com.google.android.material.tabs.TabLayout"] == 0
        || [name compare:@"LGTabLayout"] == 0)
        rootView = [[LGTabLayout alloc] init];
    else if([name compare:@"com.google.android.material.tabs.TabItem"] == 0
        || [name compare:@"LuaTab"] == 0)
        rootView = [[LuaTab alloc] init];
    else if([name compare:@"androidx.viewpager2.widget.ViewPager2"] == 0
        || [name compare:@"android.support.v4.view.ViewPager"] == 0
        || [name compare:@"LGViewPager"] == 0)
        rootView = [[LGViewPager alloc] init];
    else if([name compare:@"WebView"] == 0
        || [name compare:@"LGWebView"] == 0)
        rootView = [[LGWebView alloc] init];
    else if([name compare:@"com.google.android.material.textfield.TextInputLayout"] == 0)
        rootView = [[LGTextInputLayout alloc] init];
    else if([name compare:@"com.google.android.material.textfield.TextInputEditText"] == 0)
    {
        LGTextInputEditText *et = [LGTextInputEditText new];
        if(parent.style != nil && [parent.style containsString:@"@style/Widget.MaterialComponents.TextInputLayout.OutlinedBox"]) {
            et.editTextType = 1;
        }
        else
        {
            et.editTextType = 0;
        }
        et.parentStyle = parent.style;
        et.android_hint = ((LGTextInputLayout*)parent).android_hint;
        rootView = et;
    }
    else if([name compare:@"androidx.drawerlayout.widget.DrawerLayout"] == 0)
        rootView = [[LGDrawerLayout alloc] init];
    else if([name compare:@"android.support.design.widget.NavigationView"] == 0
            || [name compare:@"com.google.android.material.navigation.NavigationView"] == 0)
        rootView = [[LGNavigationView alloc] init];
    else if([ToppingEngine getViewPlugins] != nil && (pluginClass = [self ContainsClassNameStringInArray:[ToppingEngine getViewPlugins] :name]) != nil)
    {
        rootView = [[pluginClass alloc] init];
    }
    else if([name compare:@"RelativeLayout"] == 0
            || [name compare:@"LGRelativeLayout"] == 0)
        rootView = [[LGRelativeLayout alloc] init];
    else
    {
        return nil;
    }
    
    [rootView initProperties];
    
    return rootView;
}

-(LGView*) parseChildXML:(LGView*)parent :(GDataXMLElement*)view
{
    GDataXMLNodeKind kind = [view kind];
    if(kind != GDataXMLElementKind) {
        return nil;
    }
	NSString *name = [view name];
	LGView *rootView = nil;
    NSArray *attrs = [view attributes];
    
    rootView = [self getViewFromName:name :attrs :parent];
    if(rootView == nil) {
        NSLog(@"Unknown class %@ at ParseChildXml in file %@", name, self.lastFileName);
        return nil;
    }
	for(GDataXMLNode *node in attrs)
	{
		[rootView setAttributeValue:[node name] :[node stringValue]];
	}
    rootView.attrs = attrs;
    [rootView applyStyles];
	
    if([rootView isKindOfClass:[LGViewGroup class]])
    {
        for(GDataXMLElement *child in [view children])
        {
            [((LGViewGroup*)rootView) addSubview:[self parseChildXML:rootView :child]];
        }
    }
    
    [self applyOverrides:parent :rootView];
	return rootView;
}

-(UIView*) generateUIViewFromLGView:(LGView*)view :(UIView*)parentView :(LGView*)parent :(LuaForm*)cont;
{
    view.parent = parent;
    [view resize];
    UIView *viewRoot = [view createComponent];
		
    if([view isKindOfClass:[LGViewGroup class]])
    {
		for(LGView *w in ((LGViewGroup*)view).subviews)
		{
			[w addSelfToParent:viewRoot :cont];
            [LuaEvent onUIEvent:w :UI_EVENT_VIEW_CREATE :w.lc :0, nil];
		}
	}
    [view initComponent:viewRoot :cont.context];
    [LuaEvent onUIEvent:view :UI_EVENT_VIEW_CREATE :view.lc :0, nil];
    return viewRoot;
}

-(void)applyOverrides:(LGView *)lgview :(LGView*)parent {
    
}

-(NSDictionary *)getKeys
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for(NSString *key in self.layoutMap)
    {
        [dict setObject:key forKey:key];
    }

    return dict;
}

@end
