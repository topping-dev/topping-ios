#import "CommonDelegate.h"

#import "AudioUnit/AudioUnit.h"
#import "DatabaseHelper.h"
#import "DataToBeDownloaded.h"

#import "Defines.h"

#import "URLDownloader.h"

#import "LGLayoutParser.h"
#import "LuaForm.h"
#import "DisplayMetrics.h"

#import "LGStyleParser.h"
#import "LGColorParser.h"

#import "UIColor+Lum.h"

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

+ (CommonDelegate *)GetInstance
{
	if(sCommonDelegate == nil)
		sCommonDelegate = [[CommonDelegate alloc] init];
	return sCommonDelegate;
}

+(LuaForm*)GetActiveForm
{
	return sActiveForm;
}

+(void)SetActiveForm:(LuaForm *)form
{
	sActiveForm = form;
}

-(void)InitMain:(UIWindow *)windw :(UIScene *)scene
{
    [DisplayMetrics SetDensity:[[UIScreen mainScreen] scale] :1.0f];

	//[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
	self.statusBarHidden = YES;
	self.window = windw;
	
    // Override point for customization after application launch.
	self.window.rootViewController.wantsFullScreenLayout = NO;
	
	[sToppingEngine Startup];
	int height = self.window.frame.size.height;
    int sbarHeight = 0;
    if(@available(iOS 13.0, *))
    {
        sbarHeight = ((UIWindowScene*)scene).statusBarManager.statusBarFrame.size.height;
        height -= sbarHeight;
    }
    else
    {
        sbarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
        height -= sbarHeight;
    }
    
    CGFloat topPadding = 0;
    CGFloat bottomPadding = 0;
    if (@available(iOS 11.0, *)) {
        topPadding = self.window.safeAreaInsets.top;
        bottomPadding = self.window.safeAreaInsets.bottom;
    }
    height -= topPadding;
    height -= bottomPadding;
	self.startForm = [[LuaForm alloc] init];
	self.startForm.context = [[LuaContext alloc] init];
    [self.startForm.context Setup:self.startForm];
    self.window.rootViewController = self.startForm.context.navController;
    if(!self.startForm.context.navController.isNavigationBarHidden)
    {
        //Subtract nav bar
        height -= self.startForm.context.navController.navigationBar.frame.size.height;
    }
    
    //Apply styles
    NSString *style = [sToppingEngine GetAppStyle];
    NSDictionary *styleMap = [[LGStyleParser GetInstance] GetStyle:style];
    
    if (@available(iOS 13.0, *))
    {
        NSString *iosTheme = [styleMap objectForKey:@"ios:theme"];
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
        self.window.backgroundColor = [[LGColorParser GetInstance] ParseColor:windowBackgroundColor];
    
    self.statusBarIsDark = NO;
    NSString *statusBarColor = [styleMap objectForKey:@"colorPrimaryDark"];
    if(statusBarColor != nil)
    {
        UIColor *color = [[LGColorParser GetInstance] ParseColor:statusBarColor];

        UIView *statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, -sbarHeight, [UIScreen mainScreen].bounds.size.width, sbarHeight)];
        statusBarView.backgroundColor = color;
        self.statusBarIsDark = [color isDarkColor];
        if(!self.startForm.context.navController.isNavigationBarHidden)
        {
            if(self.statusBarIsDark)
                self.startForm.context.navController.navigationBar.barStyle = UIBarStyleBlack;
            else
                self.startForm.context.navController.navigationBar.barStyle = UIBarStyleDefault;
            [self.startForm.context.navController.navigationBar addSubview:statusBarView];
        }
        else
            [self.startForm.view addSubview:statusBarView];
    }
    //Apply styles end
    
    self.startForm.view.frame = CGRectMake(0, 0, self.window.frame.size.width, height);
    self.window.rootViewController.view.autoresizesSubviews = YES;
    
    [DisplayMetrics SetMasterView:self.startForm.view];
	self.startForm.luaId = [sToppingEngine GetMainForm];
	NSString *initUI = [sToppingEngine GetMainUI];
    [self.window makeKeyAndVisible];
	if([initUI compare:@""] != 0)
	{
		LGView *lgview = self.startForm.lgview;
        NSLog(@"%@", NSStringFromCGRect(self.window.rootViewController.view.frame));
        NSLog(@"%@", NSStringFromCGRect(self.startForm.view.frame));
		[self.startForm.view addSubview:[[LGLayoutParser GetInstance] ParseXML:initUI :self.startForm.view :nil :self.startForm :&lgview]];
		self.startForm.lgview = lgview;
    }
	else
	{
        [LuaForm OnFormEvent:self.startForm :FORM_EVENT_CREATE :self.startForm.context :0, nil];
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

-(BOOL)HasResourceData:(NSString *)resourcePath :(NSString *)name
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

-(BOOL)HasExternalResourceData:(NSString *)resourcePath :(NSString *)name :(BOOL)intermediate
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
