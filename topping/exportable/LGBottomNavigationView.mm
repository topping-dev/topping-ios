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

- (int)GetContentH
{
    CGSize size = [((MDCBottomNavigationBar*)self.bottomNav) sizeThatFits:self.parent._view.bounds.size];
    return size.height;
}

-(void)InitProperties
{
    [super InitProperties];
}

-(UIView *)CreateComponent {
    self.bottomNav = [[MDCBottomNavigationBar alloc] initWithFrame:CGRectMake(self.dX, self.dY, self.dWidth, self.dHeight)];
    
    self.items = [NSMutableArray new];
    
    return self.bottomNav;
}

-(void)SetupComponent:(UIView *)view
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
        self.items = [[LGMenuParser GetInstance] GetMenu:self.app_menu];
        [self GenerateMenu];
    }
    
    UIColor *colorSurface = (UIColor*)[[LGStyleParser GetInstance] GetStyleValue:[sToppingEngine GetAppStyle] :@"colorSurface"];
    if(colorSurface != nil) {
        [((MDCBottomNavigationBar*)self.bottomNav) setBarTintColor:colorSurface];
    }
    
    ((MDCBottomNavigationBar*)self.bottomNav).delegate = self;
    
    [super SetupComponent:self.bottomNav];
}

-(void)GenerateMenu {
    int count = 0;
    NSMutableArray *itemsToSet = [NSMutableArray new];
    for(LuaMenu *menu in self.items) {
        UITabBarItem *item;
        if(menu.iconRes != nil) {
            LGDrawableReturn *ldr = [[LGDrawableParser GetInstance] ParseDrawable:menu.iconRes.idRef];
            CGSize size = [((MDCBottomNavigationBar*)self.bottomNav) sizeThatFits:self.parent._view.bounds.size];
            UIImage *img = [ldr GetImage:size];
            //TODO:Manual 20 is good?
            img = [img imageWithSizeAspect:size.height - 20];
            item = [[UITabBarItem alloc] initWithTitle:menu.title image:img tag:count++];
        }
        else {
            item = [[UITabBarItem alloc] initWithTitle:menu.title image:nil tag:count++];
        }
        UIColor *colorPrimary = (UIColor*)[[LGStyleParser GetInstance] GetStyleValue:[sToppingEngine GetAppStyle] :@"colorPrimary"];
        if(colorPrimary != nil) {
            [item setTitleTextAttributes:@{ NSForegroundColorAttributeName : colorPrimary }
                                                         forState:UIControlStateSelected];
        }
        UIColor *colorOnSurface = (UIColor*)[[LGStyleParser GetInstance] GetStyleValue:[sToppingEngine GetAppStyle] :@"colorOnSurface"];
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
        [self.ltTabSelectedListener Call:[NSNumber numberWithInt:pos]];
    }
}

-(BOOL)bottomNavigationBar:(MDCBottomNavigationBar *)bottomNavigationBar shouldSelectItem:(UITabBarItem *)item {
    if(self.ltCanSelectTab != nil) {
        int pos = [((MDCBottomNavigationBar*)self.bottomNav).items indexOfObject:item];
        return [self.ltCanSelectTab Call:[NSNumber numberWithInt:pos]];
    }
    return YES;
}

+(LGBottomNavigationView*)Create:(LuaContext *)context
{
    LGBottomNavigationView *lst = [[LGBottomNavigationView alloc] init];
    [lst InitProperties];
    return lst;
}

-(void)SetTabSelectedListener:(LuaTranslator*)lt {
    self.ltTabSelectedListener = lt;
}

-(void)SetCanSelectTab:(LuaTranslator*)lt {
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
    
    ClassMethod(Create:, LGBottomNavigationView, @[ [LuaContext class] ], @"Create", [LGBottomNavigationView class])
    
    InstanceMethodNoRet(SetTabSelectedListener:, @[ [LuaTranslator class] ], @"SetTabSelectedListener")
    InstanceMethodNoRet(SetCanSelectTab:, @[ [LuaTranslator class] ], @"SetCanSelectTab")
	
	return dict;
}

@end
