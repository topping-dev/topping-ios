#import "LuaMenu.h"
#import <ToppingIOSKotlinHelper/ToppingIOSKotlinHelper.h>
#import <Topping/Topping-Swift.h>
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

+(LuaMenu*)create:(LuaContext*)lc :(LuaRef*)idVal {
    LuaTab *tab = [LuaTab new];
    tab.item = [[MDCTabBarItem alloc] init];
    return tab;
}

-(LuaRef*)getItemId {
    return self.idVal;
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
