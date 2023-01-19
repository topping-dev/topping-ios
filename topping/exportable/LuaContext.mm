#import "LuaContext.h"
#import "LuaFunction.h"
#import "LuaForm.h"
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
        self.navController.navigationBarHidden = ![[LGValueParser GetInstance] GetBoolValueDirect:windowActionBar];

    NSString *actionBarColor = [styleMap objectForKey:@"colorPrimary"];
    if(actionBarColor != nil)
    {
        self.navController.navigationBar.barTintColor = [[LGColorParser GetInstance] ParseColor:actionBarColor];
        self.navController.navigationBar.translucent = NO;
    }
    
    NSString *toolbarTextColor = [styleMap objectForKey:@"iosToolbarTextColor"];
    if(toolbarTextColor != nil)
    {
        NSDictionary *textAttributes = @{NSForegroundColorAttributeName:[[LGColorParser GetInstance] ParseColor:toolbarTextColor]};
        self.navController.navigationBar.titleTextAttributes = textAttributes;
    }
    
    self.form = (LuaForm*)controller;
    self.packageName = [[NSBundle mainBundle] bundleIdentifier];
}

-(LuaForm *)GetForm {
    return self.form;
}

-(void)StartForm:(LuaFormIntent*)formIntent {
    formIntent.form.intent = formIntent;
    [navController pushViewController:formIntent.form animated:true];
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
    
    InstanceMethodNoArg(GetForm, LuaForm, @"GetForm")
    InstanceMethodNoRet(StartForm:, @[[LuaFormIntent class]], @"StartForm")
        
	return dict;
}

@end
