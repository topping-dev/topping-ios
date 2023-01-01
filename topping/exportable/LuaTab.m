#import "LuaTab.h"
#import <topping/topping-Swift.h>
#import "Topping.h"
#import "LGParser.h"
#import "LuaViewInflator.h"
#import "MaterialTabs+TabBarView.h"

@implementation LuaTab

+(LuaTab*)Create {
    LuaTab *tab = [LuaTab new];
    tab.item = [[MDCTabBarItem alloc] init];
    return tab;
}

-(void)SetupComponent:(UIView *)view
{
    //TODO: exception here?
    if(self.parent != nil && [self.parent isKindOfClass:[LGTabLayout class]]) {
        self.item = [[MDCTabBarItem alloc] init];
        
        if(self.android_icon != nil) {
            ((MDCTabBarItem*)(self.item)).image = [[LGDrawableParser GetInstance] ParseDrawable:self.android_icon].img;
        }
        if(self.android_text != nil) {
            ((MDCTabBarItem*)(self.item)).title = [[LGStringParser GetInstance] GetString:self.android_text];
        }
        if(self.android_layout != nil) {
            LuaViewInflator *inflator = (LuaViewInflator*)[LuaViewInflator Create:self.lc];
            [self SetCustomView:[inflator Inflate:[LuaRef WithValue:self.android_layout] :nil]];
        }
        
        [((LGTabLayout*)self.parent) AddTab:self];
    }
}

-(void)SetText:(NSString*)text {
    ((MDCTabBarItem*)(self.item)).title = text;
}

-(void)SetTextRef:(LuaRef*)text {
    ((MDCTabBarItem*)(self.item)).title = [[LGStringParser GetInstance] GetString:text.idRef];
}

-(void)SetIcon:(LuaRef*)icon {
    ((MDCTabBarItem*)(self.item)).image = [[LGDrawableParser GetInstance] ParseDrawableRef:icon].img;
}

-(void)SetIconStream:(LuaStream*)icon {
    ((MDCTabBarItem*)(self.item)).image = [[UIImage alloc] initWithData:icon.data];
}

-(void)SetCustomView:(LGView*)view {
    self.customView = view;
    //TODO:Check this
    ((MDCTabBarItem*)(self.item)).mdc_customView = [view GetView];
}

+ (NSString *)className {
    return @"LuaTab";
}

+ (NSMutableDictionary *)luaMethods {
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    
    ClassMethodNoArg(Create, LuaTab, @"Create", [LuaTab class])
    
    InstanceMethodNoRet(SetText:, @[[NSString class]], @"SetText")
    InstanceMethodNoRet(SetTextRef:, @[[LuaRef class]], @"SetTextRef")
    InstanceMethodNoRet(SetIcon:, @[[LuaRef class]], @"SetIcon")
    InstanceMethodNoRet(SetIconStream:, @[[LuaStream class]], @"SetIconStream")
    InstanceMethodNoRet(SetCustomView:, @[[LGView class]], @"SetCustomView")
    
    return dict;
}

@end
