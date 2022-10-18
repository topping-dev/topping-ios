#import "LuaDispatchers.h"

@implementation LuaDispatchers

+ (NSString *)className {
    return @"LuaDispatchers";
}

+ (NSMutableDictionary *)luaMethods {
    return [NSMutableDictionary dictionary];
}

+(NSMutableDictionary *)luaStaticVars {
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[NSNumber numberWithInt:0] forKey:@"DEFAULT"];
    [dict setObject:[NSNumber numberWithInt:1] forKey:@"MAIN"];
    [dict setObject:[NSNumber numberWithInt:2] forKey:@"UNCONFINED"];
    [dict setObject:[NSNumber numberWithInt:3] forKey:@"IO"];
    return dict;
}

@end
