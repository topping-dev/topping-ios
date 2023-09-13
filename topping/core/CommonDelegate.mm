#import "CommonDelegate.h"

#import "AudioUnit/AudioUnit.h"
#import "DatabaseHelper.h"
#import "DataToBeDownloaded.h"

#import "Defines.h"

#import "URLDownloader.h"

#import "LGLayoutParser.h"
#import "LuaForm.h"
#import "LuaEvent.h"
#import "DisplayMetrics.h"

#import "LGStyleParser.h"
#import "LGColorParser.h"
#import "LGNavigationParser.h"

#import "UIColor+Lum.h"

#import "IOSKotlinHelper/IOSKotlinHelper.h"
#import <Topping/Topping-Swift.h>

static CommonDelegate *sCommonDelegate;
static LuaForm *sActiveForm;

@implementation NSString (intCompare)
-(NSComparisonResult) intCompare:(id) obj
{
	int v1 = [self intValue];
	
	int v2 = [obj intValue];
	
	if (v1 < v2)
		return NSOrderedAscending;
	else if (v1 > v2)
		return NSOrderedDescending;
	else
		return NSOrderedSame;
}
@end

@implementation CommonDelegate

+ (CommonDelegate *)getInstance
{
	if(sCommonDelegate == nil)
		sCommonDelegate = [[CommonDelegate alloc] init];
	return sCommonDelegate;
}

+(LuaForm*)getActiveForm
{
	return sActiveForm;
}

+(void)setActiveForm:(LuaForm *)form
{
	sActiveForm = form;
}

-(void)initMain:(UIWindow *)windw :(UIScene *)scene
{
    [DisplayMetrics setDensity:windw.screen.scale :1.0f];

	//[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
	self.statusBarHidden = YES;
	self.window = windw;
	
    // Override point for customization after application launch.
	//self.window.rootViewController.wantsFullScreenLayout = NO;
	
	[sToppingEngine startup];
	int height = self.window.frame.size.height;
    float sbarHeight = 0;
    if(@available(iOS 13.0, *))
    {
        sbarHeight = ((UIWindowScene*)scene).statusBarManager.statusBarFrame.size.height;
    }
    else
    {
        sbarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    }
    [DisplayMetrics setStatusBarHeight:sbarHeight];
    
    CGFloat topPadding = 0;
    CGFloat bottomPadding = 0;
    if (@available(iOS 11.0, *)) {
        topPadding = self.window.safeAreaInsets.top;
        bottomPadding = self.window.safeAreaInsets.bottom;
    }
    else
    {
        height -= sbarHeight;
    }
    height -= topPadding;
    height -= bottomPadding;
    LuaContext *context = [[LuaContext alloc] init];
	self.startForm = [[LuaForm alloc] initWithContext:context];
    [CommonDelegate setActiveForm:self.startForm];
    [context setup:self.startForm];
    self.startForm.context = context;
    self.startForm.luaId = [sToppingEngine getMainForm];
    self.window.rootViewController = self.startForm.context.navController;
    if(!self.startForm.context.navController.isNavigationBarHidden)
    {
        //Subtract nav bar
        height -= self.startForm.context.navController.navigationBar.frame.size.height;
    }

    self.startForm.view.frame = CGRectMake(0, 0, self.window.frame.size.width, height);
    self.window.rootViewController.view.autoresizesSubviews = YES;
    
    [DisplayMetrics setMasterView:self.window.rootViewController.view];
    [DisplayMetrics setBaseFrame:CGRectMake(0, 0, self.window.frame.size.width, height)];
    
    //Apply styles
    NSString *style = [sToppingEngine getAppStyle];
    NSDictionary *styleMap = [[LGStyleParser getInstance] getStyle:style];
    
    if (@available(iOS 13.0, *))
    {
        NSString *iosTheme = [styleMap objectForKey:@"iosTheme"];
        if(COMPARE(iosTheme, @"1"))
        {
            self.window.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
        }
        else if(COMPARE(iosTheme, @"0"))
        {
            self.window.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;
        }
    }
        
    NSString *windowBackgroundColor = [styleMap objectForKey:@"android:windowBackground"];
    if(windowBackgroundColor != nil)
        self.window.backgroundColor = [[LGColorParser getInstance] parseColor:windowBackgroundColor];
    
    self.statusBarIsDark = NO;
    NSString *statusBarColor = [styleMap objectForKey:@"colorPrimaryDark"];
    if(statusBarColor != nil)
    {
        UIColor *color = [[LGColorParser getInstance] parseColor:statusBarColor];

        self.statusBarIsDark = [color isDarkColor];
        if(!self.startForm.context.navController.isNavigationBarHidden)
        {
            if(self.statusBarIsDark)
                self.startForm.context.navController.navigationBar.barStyle = UIBarStyleBlack;
            else
                self.startForm.context.navController.navigationBar.barStyle = UIBarStyleDefault;
        }
    }
    //Apply styles end
    
	self.startForm.luaId = [sToppingEngine getMainForm];
	NSString *initUI = [sToppingEngine getMainUI];
    [self.window makeKeyAndVisible];
	if([initUI compare:@""] != 0)
	{
		LGView *lgview = nil;
        UIView *viewToAdd = [[[self.startForm getSupportFragmentManager] getLayoutInflaterFactory] parseXML:initUI :self.startForm.view :nil :self.startForm :&lgview];
        [self.startForm addMainView:viewToAdd];
    }
	else
	{
        [self.startForm onCreate];
	}
}

-(void)applicationWillEnterForeground:(UIApplication *)application
{
}

-(void) applicationWillResignActive:(UIApplication *)application
{
	self.onBackground = YES;
}

-(void) applicationDidEnterBackground:(UIApplication *)application
{
}

-(void)applicationDidBecomeActive:(UIApplication *)application
{
	self.onBackground = NO;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

-(BOOL)hasResourceData:(NSString *)resourcePath :(NSString *)name
{
	NSString *bundleRoot = [[NSBundle mainBundle] bundlePath];
	NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:bundleRoot error:nil];
	for(NSString *str in dirContents)
	{
		if([str compare:name] == 0)
			return YES;
	}
	
	NSString *basePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/"];
	NSString *resourcePathDirectory = [basePath stringByAppendingPathComponent:resourcePath];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if(![fileManager fileExistsAtPath:resourcePathDirectory])
		[fileManager createDirectoryAtPath:resourcePath withIntermediateDirectories:NO attributes:nil error:nil];
	NSString *resourceFile = [resourcePathDirectory stringByAppendingPathComponent:name];
	if([fileManager fileExistsAtPath:resourceFile])
		return YES;
	return NO;
}

-(BOOL)hasExternalResourceData:(NSString *)resourcePath :(NSString *)name :(BOOL)intermediate
{
	/*NSString *bundleRoot = [[NSBundle mainBundle] bundlePath];
	 NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:bundleRoot error:nil];
	 for(NSString *str in dirContents)
	 {
	 if([str compare:name] == 0)
	 return YES;
	 }*/
	
	NSString *basePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/"];
	NSString *resourcePathDirectory = [basePath stringByAppendingPathComponent:resourcePath];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if(![fileManager fileExistsAtPath:resourcePathDirectory])
		[fileManager createDirectoryAtPath:resourcePath withIntermediateDirectories:intermediate attributes:nil error:nil];
	NSString *resourceFile = [resourcePathDirectory stringByAppendingPathComponent:name];
	if([fileManager fileExistsAtPath:resourceFile])
		return YES;
	return NO;
}

@end
