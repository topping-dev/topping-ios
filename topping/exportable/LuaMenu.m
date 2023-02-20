#import "LuaMenu.h"
#import <topping/topping-Swift.h>
#import "Topping.h"
#import "LGParser.h"
#import "LuaViewInflator.h"
#import "MaterialTabs+TabBarView.h"

@implementation LuaMenu

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.visible = true;
        self.enabled = true;
    }
    return self;
}

+(LuaTab*)create {
    LuaTab *tab = [LuaTab new];
    tab.item = [[MDCTabBarItem alloc] init];
    return tab;
}

-(void)setTitle:(NSString*)text {
    self.title_ = text;
}

-(void)setTitleRef:(LuaRef*)text {
    self.title_ = [[LGStringParser getInstance] getString:text.idRef];
}

-(void)setIcon:(LuaRef*)icon {
    self.iconRes = icon;
}

-(void)setIntent:(LuaTranslator *)lt {
    
}

+ (NSString *)className {
    return @"LuaMenu";
}

+ (NSMutableDictionary *)luaMethods {
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    
    ClassMethodNoArg(create, LuaTab, @"create", [LuaTab class])
    
    InstanceMethodNoRet(setText:, @[[NSString class]], @"setText")
    InstanceMethodNoRet(setTextRef:, @[[LuaRef class]], @"setTextRef")
    InstanceMethodNoRet(setIcon:, @[[LuaRef class]], @"setIcon")
    
    return dict;
}

@end
