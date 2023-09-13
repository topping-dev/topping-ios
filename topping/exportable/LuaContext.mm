#import "LuaContext.h"
#import "LuaFunction.h"
#import "LuaForm.h"
#import "LGAdapterView.h"
#import "ToppingEngine.h"
#import "LGStyleParser.h"
#import "LGValueParser.h"
#import "LGColorParser.h"
#import "IOSKotlinHelper/IOSKotlinHelper.h"
#import <Topping/Topping-Swift.h>

@implementation LuaContext

@synthesize lua_id, navController;

-(void)setup:(UIViewController*)controller :(BOOL)navigation
{
    if(navigation) {
        self.navController = [[UINavigationController alloc] initWithRootViewController:controller];

        NSString *style = [sToppingEngine getAppStyle];
        
        NSDictionary *styleMap = [[LGStyleParser getInstance] getStyle:style];
        
        NSString *windowActionBar = [styleMap objectForKey:@"windowActionBar"];
        if(windowActionBar != nil)
            self.navController.navigationBarHidden = ![[LGValueParser getInstance] getBoolValueDirect:windowActionBar];

        NSString *actionBarColor = [styleMap objectForKey:@"colorPrimary"];
        if(actionBarColor != nil)
        {
            self.navController.navigationBar.barTintColor = [[LGColorParser getInstance] parseColor:actionBarColor];
            self.navController.navigationBar.translucent = NO;
        }
        
        NSString *toolbarTextColor = [styleMap objectForKey:@"iosToolbarTextColor"];
        if(toolbarTextColor != nil)
        {
            NSDictionary *textAttributes = @{NSForegroundColorAttributeName:[[LGColorParser getInstance] parseColor:toolbarTextColor]};
            self.navController.navigationBar.titleTextAttributes = textAttributes;
        }
    }
    
    self.form = (LuaForm*)controller;
    self.packageName = [[NSBundle mainBundle] bundleIdentifier];
}

-(void)setup:(UIViewController*)controller
{
    [self setup:controller :true];
}

-(LuaForm *)getForm {
    return self.form;
}

-(void)startForm:(LuaFormIntent*)formIntent {
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
    
    InstanceMethodNoArg(getForm, LuaForm, @"getForm")
    InstanceMethodNoRet(startForm:, @[[LuaFormIntent class]], @"startForm")
        
	return dict;
}

#pragma IOSKHTContext

- (id<IOSKHTDrawable>)createLayerDrawableLayers:(IOSKHKotlinArray<id<IOSKHTDrawable>> *)layers {
    LGDrawableReturn *ldr = [[LGDrawableReturn alloc] init];
    int maxWidth;
    int maxHeight;
    for(int i = 0; i < layers.size; i++) {
        LGDrawableReturn *ldrLayer = (LGDrawableReturn*)[layers getIndex:i];
        UIImage *img = [ldrLayer getImage];
        if(img == nil)
            continue;
        maxWidth = MAX(maxWidth, [ldrLayer getImage].size.width);
        maxHeight = MAX(maxHeight, [ldrLayer getImage].size.height);
    }
    CGRect bounds = CGRectMake(0, 0, maxWidth, maxHeight);
    UIGraphicsBeginImageContext(CGSizeMake(maxWidth, maxHeight));
    for(int i = 0; i < layers.size; i++) {
        LGDrawableReturn *ldrLayer = (LGDrawableReturn*)[layers getIndex:i];
        UIImage *img = [ldrLayer getImage];
        if(img == nil)
            continue;
        UIRectFill(bounds);
        [img drawInRect:bounds];
    }
    ldr.img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return ldr;
}

- (nonnull id<IOSKHTPaint>)createPaint {
    return (id<IOSKHTPaint>)[[ToppingPaint alloc] initWithFont:nil];
}

- (nonnull id<IOSKHTView>)createView {
    return [[LGView alloc] init];
}

- (nonnull id<IOSKHTLayoutInflater>)getLayoutInflater {
    return (LuaViewInflator*)[LuaViewInflator create:self];
}

- (nonnull NSString *)getPackageName {
    return self.packageName;
}

- (nonnull id<IOSKHTResources>)getResources {
    return (id<IOSKHTResources>)[ToppingResources new];
}

- (id<IOSKHInterpolator> _Nullable)loadInterpolatorId:(nonnull NSString *)id {
    //TODO:
    return nil;
}

@end
