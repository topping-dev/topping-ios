#import "LuaTab.h"
#import <ToppingIOSKotlinHelper/ToppingIOSKotlinHelper.h>
#import <Topping/Topping-Swift.h>
#import "Topping.h"
#import "LGParser.h"
#import "LuaViewInflator.h"
#import "MaterialTabs+TabBarView.h"

@implementation LuaTab

+(LuaTab*)create {
    LuaTab *tab = [LuaTab new];
    tab.item = [[MDCTabBarItem alloc] init];
    return tab;
}

-(void)setupComponent:(UIView *)view
{
    //TODO: exception here?
    if(self.parent != nil && [self.parent isKindOfClass:[LGTabLayout class]]) {
        self.item = [[MDCTabBarItem alloc] init];
        
        if(self.android_icon != nil) {
            ((MDCTabBarItem*)(self.item)).image = [[LGDrawableParser getInstance] parseDrawable:self.android_icon].img;
        }
        if(self.android_text != nil) {
            ((MDCTabBarItem*)(self.item)).title = [[LGStringParser getInstance] getString:self.android_text];
        }
        if(self.android_layout != nil) {
            LuaViewInflator *inflator = (LuaViewInflator*)[LuaViewInflator create:self.lc];
            [self setCustomView:[inflator inflate:[LuaRef withValue:self.android_layout] :nil]];
        }
        
        [((LGTabLayout*)self.parent) addTab:self];
    }
}

-(void)setText:(NSString*)text {
    ((MDCTabBarItem*)(self.item)).title = text;
}

-(void)setTextRef:(LuaRef*)text {
    ((MDCTabBarItem*)(self.item)).title = [[LGStringParser getInstance] getString:text.idRef];
}

-(void)setIcon:(LuaRef*)icon {
    ((MDCTabBarItem*)(self.item)).image = [[LGDrawableParser getInstance] parseDrawableRef:icon].img;
}

-(void)setIconStream:(LuaStream*)icon {
    ((MDCTabBarItem*)(self.item)).image = [[UIImage alloc] initWithData:icon.data];
}

-(void)setCustomView:(LGView*)view {
    self.customView = view;
    //TODO:Check this
    ((MDCTabBarItem*)(self.item)).mdc_customView = [view getView];
}

+ (NSString *)className {
    return @"LuaTab";
}

+ (NSMutableDictionary *)luaMethods {
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    
    ClassMethodNoArg(create, LuaTab, @"create", [LuaTab class])
    
    InstanceMethodNoRet(setText:, @[[NSString class]], @"setText")
    InstanceMethodNoRet(setTextRef:, @[[LuaRef class]], @"setTextRef")
    InstanceMethodNoRet(setIcon:, @[[LuaRef class]], @"setIcon")
    InstanceMethodNoRet(setIconStream:, @[[LuaStream class]], @"setIconStream")
    InstanceMethodNoRet(setCustomView:, @[[LGView class]], @"setCustomView")
    
    return dict;
}

@end
