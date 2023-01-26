#import "LuaLifecycleObserver.h"
#import "LuaAll.h"

@implementation LifecycleEventObserverO

-(instancetype)initWithObject:(NSObject *)obj {
    self = [self init];
    self.myself = obj;
    return self;
}

-(void)onStateChanged:(id<LifecycleOwner>)source :(LifecycleEvent)event {
    self.onStateChangedO(source, event);
}

@end

@implementation LifecycleObserver

- (NSString *)getKey {
    if(self.key == nil)
        self.key = [[[NSUUID alloc] init] UUIDString];
    return self.key;
}

-(void)onStateChanged:(id<LifecycleOwner>)source :(LifecycleEvent)event {

}

@end

@implementation DefaultLifecycleObserver

- (void)onCreate:(id<LifecycleOwner>)owner {
    
}

- (void)onDestroy:(id<LifecycleOwner>)owner {
    
}

- (void)onPause:(id<LifecycleOwner>)owner {
    
}

- (void)onResume:(id<LifecycleOwner>)owner {
    
}

- (void)onStart:(id<LifecycleOwner>)owner {
    
}

- (void)onStop:(id<LifecycleOwner>)owner {
    
}

@end

@implementation LuaLifecycleObserver

+(LuaLifecycleObserver*)create:(LuaTranslator*)lt
{
    LuaLifecycleObserver *llo = [LuaLifecycleObserver new];
    llo.lt = lt;
    return llo;
}

-(void)onCreate:(id<LifecycleOwner>)owner {
    [self.lt call:[[LuaNativeObject alloc] initWithObject:owner] :[NSNumber numberWithInt:0]];
}

-(void)onDestroy:(id<LifecycleOwner>)owner {
    [self.lt call:[[LuaNativeObject alloc] initWithObject:owner] :[NSNumber numberWithInt:1]];
}

-(void)onPause:(id<LifecycleOwner>)owner {
    [self.lt call:[[LuaNativeObject alloc] initWithObject:owner] :[NSNumber numberWithInt:2]];
}

-(void)onResume:(id<LifecycleOwner>)owner {
    [self.lt call:[[LuaNativeObject alloc] initWithObject:owner] :[NSNumber numberWithInt:3]];
}

-(void)onStart:(id<LifecycleOwner>)owner {
    [self.lt call:[[LuaNativeObject alloc] initWithObject:owner] :[NSNumber numberWithInt:4]];
}

-(void)onStop:(id<LifecycleOwner>)owner {
    [self.lt call:[[LuaNativeObject alloc] initWithObject:owner] :[NSNumber numberWithInt:5]];
}

-(NSString*)GetId
{
    return @"LuaLifecycleObserver";
}

+ (NSString*)className
{
    return @"LuaLifecycleObserver";
}

+(NSMutableDictionary *)luaStaticVars {
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[NSNumber numberWithInt:0] forKey:@"ON_CREATE"];
    [dict setObject:[NSNumber numberWithInt:1] forKey:@"ON_DESTROY"];
    [dict setObject:[NSNumber numberWithInt:2] forKey:@"ON_RESUME"];
    [dict setObject:[NSNumber numberWithInt:3] forKey:@"ON_PAUSE"];
    [dict setObject:[NSNumber numberWithInt:4] forKey:@"ON_START"];
    [dict setObject:[NSNumber numberWithInt:5] forKey:@"ON_STOP"];
    return dict;
}

+(NSMutableDictionary*)luaMethods
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    
    ClassMethod(create:, LuaLifecycleObserver, MakeArray([LuaTranslator class]C nil), @"create", [LuaLifecycleObserver class]);
    
    return dict;
}

@end
