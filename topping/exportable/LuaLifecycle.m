#import "LuaLifecycle.h"
#import "LuaAll.h"
#import "LuaLifecycleObserver.h"

@implementation LuaLifecycle


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

+(LifecycleState)GetTargetState:(LifecycleEvent)event
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

-(NSString*)GetId
{
    return @"LuaLifecycle";
}

+ (NSString*)className
{
    return @"LuaLifecycle";
}

+(NSMutableDictionary*)luaMethods
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    return dict;
}

@end
