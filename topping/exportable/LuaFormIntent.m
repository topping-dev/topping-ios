#import "LuaFormIntent.h"
#import <ToppingIOSKotlinHelper/ToppingIOSKotlinHelper.h>
#import <Topping/Topping-Swift.h>
#import "Topping.h"

@implementation LuaFormIntent

- (instancetype)initWithBundle:(LuaBundle*)bundle
{
    self = [super init];
    if (self) {
        self.bundle = bundle;
    }
    return self;
}

- (LuaBundle *)getBundle {
    return self.bundle;
}

-(void)setFlags:(int)flags {
    self.flags_ = flags;
}

+ (NSString *)className {
    return @"LuaFormIntent";
}

+ (NSMutableDictionary *)luaMethods {
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    
    InstanceMethodNoArg(getBundle, LuaBundle, @"getBundle")
    InstanceMethodNoRet(setFlags:, @[ [LuaInt class] ], @"setFlags")
    
    return dict;
}

@end
