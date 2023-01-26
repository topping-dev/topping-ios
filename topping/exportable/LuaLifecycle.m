#import "LuaLifecycle.h"
#import "LuaFunction.h"

@implementation LuaLifecycle

- (instancetype)initWithLifecycle:(Lifecycle*)lifecycle :(LuaCoroutineScope*)scope
{
    self = [super init];
    if (self) {
        self.lifecycle = lifecycle;
        self.scope = scope;
    }
    return self;
}

+ (LuaLifecycle*)createForm:(LuaForm*)form {
    return [[LuaLifecycle alloc] initWithLifecycle:[form getLifecycle] :[[LuaCoroutineScope alloc] initWithScope:[[form getLifecycle] getCoroutineScope]]];
}

+ (LuaLifecycle*)createFragment:(LuaFragment*)fragment {
    return [[LuaLifecycle alloc] initWithLifecycle:[fragment getLifecycle] :[[LuaCoroutineScope alloc] initWithScope:[[fragment getLifecycle] getCoroutineScope]]];
}

-(void)addObserver:(LuaLifecycleObserver *)observer {
    [self.lifecycle addObserver:observer];
}

-(void)removeObserver:(LuaLifecycleObserver *)observer {
    [self.lifecycle removeObserver:observer];
}

-(void)launch:(LuaTranslator *)lt {
    [self.scope launch:lt];
}

-(void)launchDispatcher:(int)dispatcher :(LuaTranslator *)lt {
    [self.scope launchDispatcher:dispatcher :lt];
}

+ (NSString *)className {
    return @"LuaLifecycle";
}

+ (NSMutableDictionary *)luaMethods {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    InstanceMethodNoRet(addObserver:, MakeArray([LuaLifecycleObserver class]C nil), @"addObserver")
    InstanceMethodNoRet(removeObserver:, MakeArray([LuaLifecycleObserver class]C nil), @"removeObserver")
    InstanceMethodNoRet(launch:, MakeArray([LuaTranslator class]C nil), @"launch")
    InstanceMethodNoRet(launchDispatcher::, MakeArray([LuaInt class]C [LuaTranslator class]C nil), @"launchDispatcher")
    
    return dict;
}

@end
