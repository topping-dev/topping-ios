#import "LuaMenu.h"
#import <topping/topping-Swift.h>
#import "Topping.h"
#import "LGParser.h"
#import "LuaViewInflator.h"
#import "MaterialTabs+TabBarView.h"

@implementation LuaMenu

+(LuaTab*)Create {
    LuaTab *tab = [LuaTab new];
    tab.item = [[MDCTabBarItem alloc] init];
    return tab;
}

-(void)SetTitle:(NSString*)text {
    self.title = text;
}

-(void)SetTitleRef:(LuaRef*)text {
    self.title = [[LGStringParser GetInstance] GetString:text.idRef];
}

-(void)SetIcon:(LuaRef*)icon {
    self.iconRes = icon;
}

-(void)SetIntent:(LuaTranslator *)lt {
    
}

+ (NSString *)className {
    return @"LuaMenu";
}

+ (NSMutableDictionary *)luaMethods {
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    
    ClassMethodNoArg(Create, LuaTab, @"Create", [LuaTab class])
    
    InstanceMethodNoRet(SetText:, @[[NSString class]], @"SetText")
    InstanceMethodNoRet(SetTextRef:, @[[LuaRef class]], @"SetTextRef")
    InstanceMethodNoRet(SetIcon:, @[[LuaRef class]], @"SetIcon")
    
    return dict;
}

@end
