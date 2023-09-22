#import "Lifecycle.h"
#import "LuaAll.h"
#import "LuaLifecycleObserver.h"
#import "CoroutineScope.h"
#import <ToppingIOSKotlinHelper/ToppingIOSKotlinHelper.h>
#import <Topping/Topping-Swift.h>

@implementation Lifecycle


/**
 * Returns the {@link Lifecycle.Event} that will be reported by a {@link Lifecycle}
 * leaving the specified {@link Lifecycle.State} to a lower state, or {@code null}
 * if there is no valid event that can move down from the given state.
 *
 * @param state the higher state that the returned event will transition down from
 * @return the event moving down the lifecycle phases from state
 */
+(LifecycleEvent)downFrom:(LifecycleState)state {
    switch (state) {
        case LIFECYCLESTATE_CREATED:
            return LIFECYCLEEVENT_ON_DESTROY;
        case LIFECYCLESTATE_STARTED:
            return LIFECYCLEEVENT_ON_STOP;
        case LIFECYCLESTATE_RESUMED:
            return LIFECYCLEEVENT_ON_PAUSE;
        default:
            return LIFECYCLEEVENT_NIL;
    }
}

/**
 * Returns the {@link Lifecycle.Event} that will be reported by a {@link Lifecycle}
 * entering the specified {@link Lifecycle.State} from a higher state, or {@code null}
 * if there is no valid event that can move down to the given state.
 *
 * @param state the lower state that the returned event will transition down to
 * @return the event moving down the lifecycle phases to state
 */
+(LifecycleEvent)downTo:(LifecycleState)state {
    switch (state) {
        case LIFECYCLESTATE_DESTROYED:
            return LIFECYCLEEVENT_ON_DESTROY;
        case LIFECYCLESTATE_CREATED:
            return LIFECYCLEEVENT_ON_STOP;
        case LIFECYCLESTATE_STARTED:
            return LIFECYCLEEVENT_ON_PAUSE;
        default:
            return LIFECYCLEEVENT_NIL;
    }
}

/**
 * Returns the {@link Lifecycle.Event} that will be reported by a {@link Lifecycle}
 * leaving the specified {@link Lifecycle.State} to a higher state, or {@code null}
 * if there is no valid event that can move up from the given state.
 *
 * @param state the lower state that the returned event will transition up from
 * @return the event moving up the lifecycle phases from state
 */
+(LifecycleEvent)upFrom:(LifecycleState)state {
    switch (state) {
        case LIFECYCLESTATE_INITIALIZED:
            return LIFECYCLEEVENT_ON_CREATE;
        case LIFECYCLESTATE_CREATED:
            return LIFECYCLEEVENT_ON_START;
        case LIFECYCLESTATE_STARTED:
            return LIFECYCLEEVENT_ON_RESUME;
        default:
            return LIFECYCLEEVENT_NIL;
    }
}

/**
 * Returns the {@link Lifecycle.Event} that will be reported by a {@link Lifecycle}
 * entering the specified {@link Lifecycle.State} from a lower state, or {@code null}
 * if there is no valid event that can move up to the given state.
 *
 * @param state the higher state that the returned event will transition up to
 * @return the event moving up the lifecycle phases to state
 */
+(LifecycleEvent)upTo:(LifecycleState)state {
    switch (state) {
        case LIFECYCLESTATE_CREATED:
            return LIFECYCLEEVENT_ON_CREATE;
        case LIFECYCLESTATE_STARTED:
            return LIFECYCLEEVENT_ON_START;
        case LIFECYCLESTATE_RESUMED:
            return LIFECYCLEEVENT_ON_RESUME;
        default:
            return LIFECYCLEEVENT_NIL;
    }
}

+(LifecycleState)getTargetState:(LifecycleEvent)event
{
    switch (event) {
        case LIFECYCLEEVENT_ON_CREATE:
        case LIFECYCLEEVENT_ON_STOP:
            return LIFECYCLESTATE_CREATED;
        case LIFECYCLEEVENT_ON_START:
        case LIFECYCLEEVENT_ON_PAUSE:
            return LIFECYCLESTATE_STARTED;
        case LIFECYCLEEVENT_ON_RESUME:
            return LIFECYCLESTATE_RESUMED;
        case LIFECYCLEEVENT_ON_DESTROY:
            return LIFECYCLESTATE_DESTROYED;
        case LIFECYCLEEVENT_ON_ANY:
        case LIFECYCLEEVENT_NIL:
            break;
    }
    
    return LIFECYCLESTATE_NIL;
}

+(BOOL)isAtLeast:(LifecycleState)stateSelf :(LifecycleState)targetState
{
    return stateSelf >= targetState;
}

-(void)addObserver:(id<LifecycleObserver>)observer {
    
}

-(void)removeObserver:(id<LifecycleObserver>)observer {
    
}

-(LifecycleState)getCurrentState {
    return LIFECYCLESTATE_NIL;
}

-(void)onCancel:(CancelRunBlock *)job {
    
}

-(void)onFinish:(CancelRunBlock *)job {
    
}

-(NSObject*)whenStateAtLeast:(LifecycleState)state :(NSObject* (^)(void))block {
    return [CoroutineScope withContext:MAIN :^NSObject *(CoroutineScope *scope) {
        CancelRunBlock *crb = [scope.coroutineContext objectForKey:block];
        LifecycleController *controller = [[LifecycleController alloc] initWithLifecycle:self :state :MAIN :crb];
        NSObject *res = block();
        [controller finish];
        return res;
    }];
}

-(NSObject*)whenCreated:(NSObject* (^)(void))block {
    return [self whenStateAtLeast:LIFECYCLESTATE_CREATED :block];
}

-(NSObject*)whenStarted:(NSObject* (^)(void))block {
    return [self whenStateAtLeast:LIFECYCLESTATE_STARTED :block];
}

-(NSObject*)whenResumed:(NSObject* (^)(void))block {
    return [self whenStateAtLeast:LIFECYCLESTATE_RESUMED :block];
}

-(LifecycleCoroutineScope *)getCoroutineScope {
    if(coroutineScope == nil) {
        coroutineScope = [[LifecycleCoroutineScopeImpl alloc] init];
    }
    return coroutineScope;
}

@end

@implementation LifecycleCoroutineScope

- (CancelRunBlock*)launchWhenStarted:(NSObject* (^)(void))block {
    return [self launch:^(CoroutineScope *scope) {
        [self.lifecycle whenStarted:block];
    }];
}

- (CancelRunBlock*)launchWhenCreated:(NSObject* (^)(void))block {
    return [self launch:^(CoroutineScope *scope) {
        [self.lifecycle whenCreated:block];
    }];
}

- (CancelRunBlock*)launchWhenResumed:(NSObject* (^)(void))block {
    return [self launch:^(CoroutineScope *scope) {
        [self.lifecycle whenResumed:block];
    }];
}

@end

@implementation LifecycleCoroutineScopeImpl

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.key = [NSUUID UUID].UUIDString;
        if([self.lifecycle getCurrentState] == LIFECYCLESTATE_DESTROYED) {
            ((CancelRunBlock*)self.coroutineContext).cancelBlock(true);
        }
    }
    return self;
}

-(void)registr
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if([self.lifecycle getCurrentState] >= LIFECYCLESTATE_INITIALIZED) {
            [self.lifecycle addObserver:self];
        } else {
            ((CancelRunBlock*)self.coroutineContext).cancelBlock(true);
        }
    });
}

-(void)onStateChanged:(id<LifecycleOwner>)source :(LifecycleEvent)event
{
    if([self.lifecycle getCurrentState] <= LIFECYCLESTATE_DESTROYED) {
        [self.lifecycle removeObserver:self];
        ((CancelRunBlock*)self.coroutineContext).cancelBlock(true);
    }
}

- (NSString *)getKey {
    if(self.key == nil) {
        self.key = [[NSUUID UUID] UUIDString];
    }
    return self.key;
}

@end

@implementation JobLifecycleEventObserver

- (instancetype)initWithJob:(CancelRunBlock*)job :(LifecycleState)minState
{
    self = [super init];
    if (self) {
        self.key = [NSUUID UUID].UUIDString;
        self.job = job;
        self.minState = minState;
    }
    return self;
}

-(NSString *)getKey {
    return self.key;
}

-(void)onStateChanged:(id<LifecycleOwner>)source :(LifecycleEvent)event
{
    if([[source getLifecycle] getCurrentState] == LIFECYCLESTATE_DESTROYED) {
        self.job.cancelBlock(true);
    } else if([[source getLifecycle] getCurrentState] < self.minState) {
        //It is already suspended, if it is running we cannot stop
    } else {
        self.job.runBlock();
    }
    
}

@end

@implementation LifecycleController

- (instancetype)initWithLifecycle:(Lifecycle*)lifecycle :(LifecycleState)minState :(int)queue :(CancelRunBlock*)job
{
    self = [super init];
    if (self) {
        self.lifecycle = lifecycle;
        self.minState = minState;
        self.dispatchQueue = queue;
        self.job = job;
        self.observer = [[JobLifecycleEventObserver alloc] initWithJob:self.job :self.minState];
        if([self.lifecycle getCurrentState] == LIFECYCLESTATE_DESTROYED)
        {
            [self handleDestroy:self.job];
        }
        else
        {
            [lifecycle addObserver:self.observer];
        }
    }
    return self;
}

- (void)handleDestroy:(CancelRunBlock*)job
{
    job.cancelBlock(true);
    [self finish];
}

-(void)finish {
    [self.lifecycle removeObserver:self.observer];
    //queue finish? TODO
}

@end
