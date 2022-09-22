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

@implementation LuaLifecycleObserver

- (NSString *)getKey {
    if(self.key == nil)
        self.key = [[[NSUUID alloc] init] UUIDString];
    return self.key;
}

-(void)onStateChanged:(id<LifecycleOwner>)source :(LifecycleEvent)event {

}

-(NSString*)GetId
{
    return @"LuaLifecycleObserver";
}

+ (NSString*)className
{
    return @"LuaLifecycleObserver";
}

+(NSMutableDictionary*)luaMethods
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    return dict;
}

@end
