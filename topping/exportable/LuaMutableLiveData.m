#import "LuaMutableLiveData.h"
#import "LuaAll.h"
#import "LuaThread.h"
#import <Topping/Topping-Swift.h>

@implementation ObserverWrapper

-(instancetype)initWithLiveData:(LuaMutableLiveData*)livedata :(id<Observer>) observer {
    self = [super init];
    self.myself = livedata;
    self.mObserver = observer;
    self.mLastVersion = -1;
    return self;
}

-(BOOL)shouldBeActive {
    return false;
}

-(BOOL)isAttachedTo:(id<LifecycleOwner>)owner {
    return false;
}

-(void)detachObserver {
    
}

-(void)activeStateChanged:(BOOL)newActive {
    if(newActive == self.mActive) {
        return;
    }
    
    self.mActive = newActive;
    [self.myself changeActiveCounter:self.mActive ? 1 : -1];
    if(self.mActive) {
        [self.myself dispatchingValue:self];
    }
}

@end

@implementation LifecycleBoundObserver

-(instancetype)initWithLiveData:(LuaMutableLiveData*)livedata :(id<LifecycleOwner>)owner :(id<Observer>)observer {
    self = [super initWithLiveData:livedata :observer];
    self.myself = livedata;
    self.mOwner = owner;
    return self;
}

-(BOOL)shouldBeActive {
    return [LuaLifecycle isAtLeast:[[self.mOwner getLifecycle] getCurrentState] :LIFECYCLESTATE_STARTED];
}

- (void)onStateChanged:(id<LifecycleOwner>)source :(LifecycleEvent)event {
    LifecycleState currentState = [[self.mOwner getLifecycle] getCurrentState];
    if(currentState == LIFECYCLESTATE_DESTROYED) {
        [self.myself removeObserver:self.mObserver];
        return;
    }
    
    LifecycleState prevState = LIFECYCLESTATE_NIL;
    while(prevState != currentState) {
        prevState = currentState;
        [self activeStateChanged:[self shouldBeActive]];
        currentState = [[self.mOwner getLifecycle] getCurrentState];
    }
}

- (BOOL)isAttachedTo:(id<LifecycleOwner>)owner {
    return self.mOwner = owner;
}

- (void)detachObserver {
    [[self.mOwner getLifecycle] removeObserver:self];
}

@end

@implementation AlwaysActiveObserver

-(instancetype)initWithLiveData:(LuaMutableLiveData*)livedata :(id<Observer>) observer {
    self = [super initWithLiveData:livedata :observer];
    return self;
}

-(BOOL)shouldBeActive {
    return true;
}

@end

@implementation LuaMutableLiveData

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.mDataLock = [NSObject new];
        self.START_VERSION = -1;
        self.NOT_SET = [NSObject new];
        self.mData = self.NOT_SET;
        self.mObservers = [[OrderedDictionary alloc] init];
        self.mActiveCount = 0;
        self.mPendingData = self.NOT_SET;
        self.mVersion = self.START_VERSION;
    }
    return self;
}

-(instancetype)initWithData:(NSObject *)value {
    self = [self init];
    self.mData = value;
    self.mVersion = self.START_VERSION + 1;
    return self;
}

-(void)considerNotify:(ObserverWrapper *)observer {
    if(!observer.mActive)
        return;
    
    if(![observer shouldBeActive]) {
        [observer activeStateChanged:false];
        return;
    }
    if(observer.mLastVersion >= self.mVersion) {
        return;
    }
    observer.mLastVersion = self.mVersion;
    [observer.mObserver onChanged:self.mData];
}

-(void)dispatchingValue:(ObserverWrapper *)initiator {
    if(self.mDispatchingValue) {
        self.mDispatchingInvalidated = true;
        return;
    }
    self.mDispatchingValue = true;
    do {
        self.mDispatchingValue = false;
        if(initiator != nil) {
            [self considerNotify:initiator];
            initiator = nil;
        }
        else {
            for(id key in [self.mObservers keyEnumerator]) {
                [self considerNotify:[self.mObservers objectForKey:key]];
                if(self.mDispatchingInvalidated) {
                    break;
                }
            }
        }
    } while(self.mDispatchingInvalidated);
    self.mDispatchingValue = false;
}

-(void)observe:(id<LifecycleOwner>)owner :(id<Observer>)observer {
    if([[owner getLifecycle] getCurrentState] == LIFECYCLESTATE_DESTROYED) {
        return;
    }
    LifecycleBoundObserver *wrapper = [[LifecycleBoundObserver alloc] initWithLiveData:self :owner :observer];
    ObserverWrapper *existing = [self.mObservers putIfAbsent:observer :wrapper];
    if(existing != nil && ![existing isAttachedTo:owner]) {
        //Excep?
        return;
    }
    if(existing != nil) {
        return;
    }
    [[owner getLifecycle] addObserver:wrapper];
}

-(void)observeForever:(id<Observer>)observer {
    AlwaysActiveObserver *wrapper = [[AlwaysActiveObserver alloc] initWithLiveData:self :observer];
    ObserverWrapper *existing = [self.mObservers putIfAbsent:observer :wrapper];
    if([existing isKindOfClass:[LifecycleBoundObserver class]]) {
        //Excep?
        return;
    }
    if(existing != nil) {
        return;
    }
    [wrapper activeStateChanged:true];
}

-(void)removeObserver:(id<Observer>)observer {
    ObserverWrapper *removed = [self.mObservers remove:observer];
    if(removed == nil) {
        return;
    }
    [removed detachObserver];
    [removed activeStateChanged:false];
}

-(void)removeObservers:(id<LifecycleOwner>)owner {
    for(id key in [self.mObservers keyEnumerator]) {
        ObserverWrapper *val = [self.mObservers objectForKey:key];
        if([val isAttachedTo:owner]) {
            [self removeObserver:key];
        }
    }
}

-(void)postValue:(NSObject *)value {
    BOOL postTask;
    @synchronized (self.mDataLock) {
        postTask = self.mPendingData == self.NOT_SET;
        self.mPendingData = value;
    }
    if(!postTask) {
        return;
    }
    LuaMutableLiveData *myself = self;
    [LuaThread RunOnUIThreadInternal:^{
        [myself.mPostValueRunnable run];
    }];
}

-(void)setValue:(NSObject *)value {
    self.mVersion++;
    self.mData = value;
    [self dispatchingValue:nil];
}

-(NSObject *)getValue {
    NSObject* data = self.mData;
    if(data != self.NOT_SET) {
        return data;
    }
    return nil;
}

-(NSInteger)getVersion {
    return self.mVersion;
}

- (void)onActive {
    
}

- (void)onInactive {
    
}

- (BOOL)hasObservers {
    return self.mObservers.count > 0;
}

-(void)changeActiveCounter:(NSInteger)change {
    NSInteger previousActiveCount = self.mActiveCount;
    self.mActiveCount += change;
    if(self.mChangingActiveState) {
        return;
    }
    self.mChangingActiveState = true;
    @try {
        while(previousActiveCount != self.mActiveCount) {
            BOOL needToCallActive = previousActiveCount == 0 && self.mActiveCount > 0;
            BOOL needToCallInactive = previousActiveCount > 0 && self.mActiveCount == 0;
            previousActiveCount = self.mActiveCount;
            if(needToCallActive) {
                [self onActive];
            } else if(needToCallInactive) {
                [self onInactive];
            }
        }
    } @catch (NSException *exception) {
        
    } @finally {
        self.mChangingActiveState = false;
    }
}

-(NSString*)GetId
{
    return @"LuaMutableLiveData";
}

+ (NSString*)className
{
    return @"LuaMutableLiveData";
}

+(NSMutableDictionary*)luaMethods
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    return dict;
}

@end
