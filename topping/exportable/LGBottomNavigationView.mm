#import "LGBottomNavigationView.h"
#import "Defines.h"
#import "LGColorParser.h"
#import "LGValueParser.h"
#import "LuaFunction.h"
#import "LuaTranslator.h"
#import "MaterialBottomNavigation.h"
#import "LGMenuParser.h"
#import "LGDrawableParser.h"
#import "LGStyleParser.h"
#import "UIColor+Lum.h"
#import "UIImage+Resize.h"
#import "DisplayMetrics.h"

@class LuaTranslator;

@implementation LGBottomNavigationView

- (int)getContentH
{
    CGSize size = [((MDCBottomNavigationBar*)self.bottomNav) sizeThatFits:self.parent._view.bounds.size];
    return size.height;
}

-(void)initProperties
{
    [super initProperties];
}

-(UIView *)createComponent {
    self.bottomNav = [[MDCBottomNavigationBar alloc] initWithFrame:CGRectMake(self.dX, self.dY, self.dWidth, self.dHeight)];
    
    self.items = [NSMutableArray new];
    
    return self.bottomNav;
}

-(void)setupComponent:(UIView *)view
{
    ((MDCBottomNavigationBar*)self.bottomNav).titleVisibility = MDCBottomNavigationBarTitleVisibilityAlways;
    if(self.app_labelVisibilityMode != nil) {
        if([self.app_labelVisibilityMode isEqualToString:@"auto"]) {
            ((MDCBottomNavigationBar*)self.bottomNav).titleVisibility = MDCBottomNavigationBarTitleVisibilityAlways;
        }
        else if([self.app_labelVisibilityMode isEqualToString:@"selected"]) {
            ((MDCBottomNavigationBar*)self.bottomNav).titleVisibility = MDCBottomNavigationBarTitleVisibilitySelected;
        }
        else if([self.app_labelVisibilityMode isEqualToString:@"labeled"]) {
            ((MDCBottomNavigationBar*)self.bottomNav).titleVisibility = MDCBottomNavigationBarTitleVisibilityAlways;
        }
        else if([self.app_labelVisibilityMode isEqualToString:@"unlabeled"]) {
            ((MDCBottomNavigationBar*)self.bottomNav).titleVisibility = MDCBottomNavigationBarTitleVisibilityNever;
        }
    }
    
    if(self.app_menu != nil) {
        self.items = [[LGMenuParser getInstance] getMenu:self.app_menu];
        [self GenerateMenu];
    }
    
    UIColor *colorSurface = (UIColor*)[[LGStyleParser getInstance] getStyleValue:[sToppingEngine getAppStyle] :@"colorSurface"];
    if(colorSurface != nil) {
        [((MDCBottomNavigationBar*)self.bottomNav) setBarTintColor:colorSurface];
    }
    
    ((MDCBottomNavigationBar*)self.bottomNav).delegate = self;
    
    [super setupComponent:self.bottomNav];
}

-(void)GenerateMenu {
    int count = 0;
    NSMutableArray *itemsToSet = [NSMutableArray new];
    for(LuaMenu *menu in self.items) {
        UITabBarItem *item;
        if(menu.iconRes != nil) {
            LGDrawableReturn *ldr = [[LGDrawableParser getInstance] parseDrawable:menu.iconRes.idRef];
            CGSize size = [((MDCBottomNavigationBar*)self.bottomNav) sizeThatFits:self.parent._view.bounds.size];
            UIImage *img = [ldr getImage:size];
            //TODO:Manual 20 is good?
            img = [img imageWithSizeAspect:size.height - 20];
            item = [[UITabBarItem alloc] initWithTitle:menu.title_ image:img tag:count++];
        }
        else {
            item = [[UITabBarItem alloc] initWithTitle:menu.title_ image:nil tag:count++];
        }
        UIColor *colorPrimary = (UIColor*)[[LGStyleParser getInstance] getStyleValue:[sToppingEngine getAppStyle] :@"colorPrimary"];
        if(colorPrimary != nil) {
            [item setTitleTextAttributes:@{ NSForegroundColorAttributeName : colorPrimary }
                                                         forState:UIControlStateSelected];
        }
        UIColor *colorOnSurface = (UIColor*)[[LGStyleParser getInstance] getStyleValue:[sToppingEngine getAppStyle] :@"colorOnSurface"];
        if(colorOnSurface != nil) {
            //[item setTitleTextAttributes:@{ NSForegroundColorAttributeName : [colorOnSurface changeAlphaToPercent:60] } forState:UIControlStateNormal];
        }
        [itemsToSet addObject:item];
    }
    ((MDCBottomNavigationBar*)self.bottomNav).items = itemsToSet;
}

-(void)bottomNavigationBar:(MDCBottomNavigationBar *)bottomNavigationBar didSelectItem:(UITabBarItem *)item {
    if(self.ltTabSelectedListener != nil) {
        int pos = [((MDCBottomNavigationBar*)self.bottomNav).items indexOfObject:item];
        [self.ltTabSelectedListener call:[NSNumber numberWithInt:pos]];
    }
}

-(BOOL)bottomNavigationBar:(MDCBottomNavigationBar *)bottomNavigationBar shouldSelectItem:(UITabBarItem *)item {
    if(self.ltCanSelectTab != nil) {
        int pos = [((MDCBottomNavigationBar*)self.bottomNav).items indexOfObject:item];
        return [self.ltCanSelectTab call:[NSNumber numberWithInt:pos]];
    }
    return YES;
}

+(LGBottomNavigationView*)create:(LuaContext *)context
{
    LGBottomNavigationView *lst = [[LGBottomNavigationView alloc] init];
    [lst initProperties];
    return lst;
}

-(void)setTabSelectedListener:(LuaTranslator*)lt {
    self.ltTabSelectedListener = lt;
}

-(void)setCanSelectTab:(LuaTranslator*)lt {
    self.ltCanSelectTab = lt;
}

-(NSString*)GetId
{
    if(self.lua_id != nil)
        return self.lua_id;
    if(self.android_id != nil)
        return self.android_id;
    return [LGBottomNavigationView className];
}

+ (NSString*)className
{
	return @"LGBottomNavigationView";
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    
    ClassMethod(create:, LGBottomNavigationView, @[ [LuaContext class] ], @"create", [LGBottomNavigationView class])
    
    InstanceMethodNoRet(setTabSelectedListener:, @[ [LuaTranslator class] ], @"setTabSelectedListener")
    InstanceMethodNoRet(setCanSelectTab:, @[ [LuaTranslator class] ], @"setCanSelectTab")
	
	return dict;
}

@end
