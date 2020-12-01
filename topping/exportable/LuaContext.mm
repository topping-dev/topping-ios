#import "LuaContext.h"
#import "LGAdapterView.h"
#import "ToppingEngine.h"
#import "LGStyleParser.h"
#import "LGValueParser.h"
#import "LGColorParser.h"

@implementation LuaContext

@synthesize lua_id, navController;

-(void)Setup:(UIViewController*)controller
{
	self.navController = [[UINavigationController alloc] initWithRootViewController:controller];
    NSString *style = [sToppingEngine GetAppStyle];
    
    NSDictionary *styleMap = [[LGStyleParser GetInstance] GetStyle:style];
    
    NSString *windowActionBar = [styleMap objectForKey:@"windowActionBar"];
    if(windowActionBar != nil)
        self.navController.navigationBarHidden = [[LGValueParser GetInstance] GetBoolValueDirect:windowActionBar];

    NSString *actionBarColor = [styleMap objectForKey:@"colorPrimary"];
    if(actionBarColor != nil)
    {
        self.navController.navigationBar.barTintColor = [[LGColorParser GetInstance] ParseColor:actionBarColor];
        self.navController.navigationBar.translucent = NO;
    }
    
    NSString *toolbarTextColor = [styleMap objectForKey:@"ios:toolbarTextColor"];
    if(toolbarTextColor != nil)
    {
        NSDictionary *textAttributes = @{NSForegroundColorAttributeName:[[LGColorParser GetInstance] ParseColor:toolbarTextColor]};
        self.navController.navigationBar.titleTextAttributes = textAttributes;
    }
}

-(NSString*)GetId
{
	if(self.lua_id != nil)
		return self.lua_id;
	else
		return [LuaContext className];
}

+ (NSString*)className
{
	return @"LuaContext";
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	return dict;
}

@end
