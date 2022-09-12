#import "LuaLifecycleOwner.h"
#import "LuaAll.h"

@implementation LuaLifecycleOwner

- (LuaLifecycle *)getLifecycle {
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
