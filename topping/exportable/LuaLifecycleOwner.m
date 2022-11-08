#import "LuaLifecycleOwner.h"
#import "LuaAll.h"

@implementation LuaLifecycleOwner

- (Lifecycle *)getLifecycle {
    //TODO
    return nil;
}

-(NSString*)GetId
{
    return @"LuaLifecycleOwner";
}

+ (NSString*)className
{
    return @"LuaLifecycleOwner";
}

+(NSMutableDictionary*)luaMethods
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    return dict;
}

@end
