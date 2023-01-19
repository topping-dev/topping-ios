#import "LuaFormIntent.h"
#import <topping/topping-Swift.h>
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
    self.flags = flags;
}

+ (NSString *)className {
    return @"LuaBundle";
}

+ (NSMutableDictionary *)luaMethods {
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    
    InstanceMethodNoArg(getBundle, LuaBundle, @"getBundle")
    InstanceMethodNoRet(setFlags:, @[ [LuaInt class] ], @"setFlags")
    
    return dict;
}

@end
