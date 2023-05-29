#import "LuaLifecycleOwner.h"
#import "LuaAll.h"

@implementation LuaLifecycleOwner

- (instancetype)initWithLifecycleOwner:(id<LifecycleOwner>)owner
{
    self = [super init];
    if (self) {
        self.lifecycleOwner = owner;
    }
    return self;
}

- (Lifecycle *)getLifecycle {
    return [self.lifecycleOwner getLifecycle];
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
