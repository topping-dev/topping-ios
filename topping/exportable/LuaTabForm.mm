#import "LuaTabForm.h"
#import "LuaFunction.h"
#import "CommonDelegate.h"
#import "DisplayMetrics.h"
#import "Defines.h"
#import "LuaForm.h"
#import "LuaStream.h"

@implementation LuaTabForm

@synthesize context, luaId, tabController, localViewControllersArray, localLGViewControllersArray;

+(LuaTabForm *) Create:(LuaContext*)context :(NSString *)luaId
{
	LuaTabForm *tabHost = [[LuaTabForm alloc] init];
	tabHost.context = context;
	tabHost.luaId = luaId;
	tabHost.localViewControllersArray = [[NSMutableArray alloc] init];
	tabHost.localLGViewControllersArray = [[NSMutableArray alloc] init];
	tabHost.tabController = [[UITabBarController alloc] init];
	UIView *masterview = [[UIView alloc] init];
	UINavigationController *navCont = [[UINavigationController alloc] init];
	int navHeight = navCont.navigationBar.frame.size.height;
	int diffHeight = tabHost.tabController.view.frame.size.height - tabHost.tabController.tabBar.frame.size.height - navHeight;
	if(![CommonDelegate GetInstance].statusBarHidden)
		diffHeight -= [[UIApplication sharedApplication] statusBarFrame].size.height;
	masterview.frame = CGRectMake(tabHost.tabController.view.frame.origin.x, tabHost.tabController.view.frame.origin.y, tabHost.tabController.view.frame.size.width, diffHeight);
	[DisplayMetrics SetMasterView:masterview];
	return tabHost;
}

-(void) AddTab:(LuaForm *)form :(NSString *)title :(LuaStream *)image :(LuaRef*)ui
{
	form.context.navController =[[UINavigationController alloc]initWithRootViewController:form];
	form.context.navController.tabBarItem.title=title;
	form.context.navController.tabBarItem.image=[UIImage imageWithData:[image GetData]];
	[form SetViewXML:ui];
	[self.localViewControllersArray addObject:form.context.navController];
	[self.localLGViewControllersArray addObject:form];
}

-(void) AddTabStream:(LuaForm *)form :(NSString *)title :(LuaStream *)image :(LGView*)ui
{
	form.context.navController =[[UINavigationController alloc]initWithRootViewController:form];
	form.context.navController.tabBarItem.title=title;
	form.context.navController.tabBarItem.image=[UIImage imageWithData:[image GetData]];
	[form SetView:ui];
	[self.localViewControllersArray addObject:form.context.navController];
	[self.localLGViewControllersArray addObject:form];
}

-(void) AddTabSrc:(LuaForm *)form :(NSString *)title :(NSString*)path :(NSString *)image :(LuaRef*)ui
{
	form.context.navController =[[UINavigationController alloc]initWithRootViewController:form];
	form.context.navController.tabBarItem.title=title;
	form.context.navController.tabBarItem.image=[UIImage imageNamed:image];
	[form SetViewXML:ui];
	[self.localViewControllersArray addObject:form.context.navController];
	[self.localLGViewControllersArray addObject:form];	
}

-(void) AddTabSrcStream:(LuaForm *)form :(NSString *)title :(NSString*)path :(NSString *)image :(LGView*)ui
{
	form.context.navController =[[UINavigationController alloc]initWithRootViewController:form];
	form.context.navController.tabBarItem.title=title;
	form.context.navController.tabBarItem.image=[UIImage imageNamed:image];
	[form SetView:ui];
	[self.localViewControllersArray addObject:form.context.navController];
	[self.localLGViewControllersArray addObject:form];	
}

-(void)Setup:(LuaForm*)form
{
	self.tabController.viewControllers = localViewControllersArray;
	self.tabController.view.autoresizingMask==(UIViewAutoresizingFlexibleHeight);
	
	//[self.window addSubview:self.tabController.view];
	[self.tabController setDelegate:self];
	
	self.tabController.view.frame = [[UIScreen mainScreen] applicationFrame];
	[[CommonDelegate GetInstance].window addSubview:self.tabController.view];
}

-(NSString*)GetId
{
	if(luaId == nil)
		return @"LuaTabForm";
	return luaId;
}

+ (NSString*)className
{
	return @"LuaTabForm";
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(Create::)) 
										:@selector(Create::) 
										:[LuaTabForm class]
										:[NSArray arrayWithObjects:[LuaContext class], [NSString class], nil] 
										:[LuaTabForm class]] 
			 forKey:@"Create"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], NSSelectorFromString(@"AddTab::::")) 
									   :NSSelectorFromString(@"AddTab::::") 
									   :nil 
									   :MakeArray([LuaForm class]C [NSString class]C [LuaStream class]C [LuaRef class]C nil)]
			 forKey:@"AddTab"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], NSSelectorFromString(@"AddTabStream::::")) :NSSelectorFromString(@"AddTabStream::::") :nil :MakeArray([LuaForm class]C [NSString class]C [LuaStream class]C [LGView class]C nil)] forKey:@"AddTabStream"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], NSSelectorFromString(@"AddTabSrc:::::")) :NSSelectorFromString(@"AddTabSrc:::::") :nil :MakeArray([LuaForm class]C [NSString class]C [NSString class]C [NSString class]C [LuaRef class]C nil)] forKey:@"AddTabSrc"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], NSSelectorFromString(@"AddTabSrcStream:::::")) :NSSelectorFromString(@"AddTabSrcStream:::::") :nil :MakeArray([LuaForm class]C [NSString class]C [NSString class]C [NSString class]C [LGView class]C nil)] forKey:@"AddTabSrcStream"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(Setup:)) :@selector(Setup:) :nil :MakeArray([LuaForm class] C nil)] forKey:@"Setup"];
	return dict;
}


@end
