#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LuaClass.h"
#import "LuaInterface.h"
#import "LuaCoroutineScope.h"

@protocol LifecycleObserver;
@protocol LifecycleEventObserver;
@class LuaLifecycleObserver;
@class LifecycleCoroutineScope;
@class CancelRunBlock;

typedef NS_ENUM(NSInteger, LifecycleEvent)
{
    LIFECYCLEEVENT_NIL,
    /**
     * Constant for onCreate event of the {@link LifecycleOwner}.
     */
    LIFECYCLEEVENT_ON_CREATE,
    /**
     * Constant for onStart event of the {@link LifecycleOwner}.
     */
    LIFECYCLEEVENT_ON_START,
    /**
     * Constant for onResume event of the {@link LifecycleOwner}.
     */
    LIFECYCLEEVENT_ON_RESUME,
    /**
     * Constant for onPause event of the {@link LifecycleOwner}.
     */
    LIFECYCLEEVENT_ON_PAUSE,
    /**
     * Constant for onStop event of the {@link LifecycleOwner}.
     */
    LIFECYCLEEVENT_ON_STOP,
    /**
     * Constant for onDestroy event of the {@link LifecycleOwner}.
     */
    LIFECYCLEEVENT_ON_DESTROY,
    /**
     * An {@link Event Event} constant that can be used to match all events.
     */
    LIFECYCLEEVENT_ON_ANY
};

typedef NS_ENUM(NSInteger, LifecycleState) {
    LIFECYCLESTATE_NIL,
    /**
     * Destroyed state for a LifecycleOwner. After this event, this Lifecycle will not dispatch
     * any more events. For instance, for an {@link android.app.Activity}, this state is reached
     * <b>right before</b> Activity's {@link android.app.Activity#onDestroy() onDestroy} call.
     */
    LIFECYCLESTATE_DESTROYED,

    /**
     * Initialized state for a LifecycleOwner. For an {@link android.app.Activity}, this is
     * the state when it is constructed but has not received
     * {@link android.app.Activity#onCreate(android.os.Bundle) onCreate} yet.
     */
    LIFECYCLESTATE_INITIALIZED,

    /**
     * Created state for a LifecycleOwner. For an {@link android.app.Activity}, this state
     * is reached in two cases:
     * <ul>
     *     <li>after {@link android.app.Activity#onCreate(android.os.Bundle) onCreate} call;
     *     <li><b>right before</b> {@link android.app.Activity#onStop() onStop} call.
     * </ul>
     */
    LIFECYCLESTATE_CREATED,

    /**
     * Started state for a LifecycleOwner. For an {@link android.app.Activity}, this state
     * is reached in two cases:
     * <ul>
     *     <li>after {@link android.app.Activity#onStart() onStart} call;
     *     <li><b>right before</b> {@link android.app.Activity#onPause() onPause} call.
     * </ul>
     */
    LIFECYCLESTATE_STARTED,

    /**
     * Resumed state for a LifecycleOwner. For an {@link android.app.Activity}, this state
     * is reached after {@link android.app.Activity#onResume() onResume} is called.
     */
    LIFECYCLESTATE_RESUMED
};

@interface Lifecycle : NSObject
{
    LifecycleCoroutineScope *coroutineScope;
}

+(LifecycleEvent)downFrom:(LifecycleState)state;
+(LifecycleEvent)downTo:(LifecycleState)state;
+(LifecycleEvent)upFrom:(LifecycleState)state;
+(LifecycleEvent)upTo:(LifecycleState)state;
+(LifecycleState)GetTargetState:(LifecycleEvent)event;
+(BOOL)isAtLeast:(LifecycleState)stateSelf :(LifecycleState)targetState;
-(LifecycleState)getCurrentState;
-(void)addObserver:(id<LifecycleObserver>)observer;
-(void)removeObserver:(id<LifecycleObserver>)observer;
-(LifecycleCoroutineScope*)getCoroutineScope;

@end

@interface CoroutineScope : NSObject

@property (nonatomic, retain) NSObject *coroutineContext;

@end

@interface LifecycleCoroutineScope : CoroutineScope

-(CancelRunBlock*)launchWhenCreated:(void (^)(void))block;
-(CancelRunBlock*)launchWhenStarted:(void (^)(void))block;
-(CancelRunBlock*)launchWhenResumed:(void (^)(void))block;

@property (nonatomic, retain) Lifecycle* lifecycle;

@end

@interface LifecycleCoroutineScopeImpl : LifecycleCoroutineScope <LifecycleEventObserver>

@property (nonatomic, retain) NSString *key;

@end

@interface JobLifecycleEventObserver : NSObject<LifecycleEventObserver>

@property (nonatomic, retain) NSString *key;
@property (nonatomic, retain) CancelRunBlock *job;
@property int minState;

@end

@interface LifecycleController : NSObject

- (instancetype)initWithLifecycle:(Lifecycle*)lifecycle :(int)minState :(dispatch_queue_t)queue :(CancelRunBlock*)job;
- (void)handleDestroy:(CancelRunBlock*)job;
- (void)finish;

@property (nonatomic, retain) Lifecycle* lifecycle;
@property int minState;
@property (nonatomic, retain) dispatch_queue_t dispatchQueue;
@property (nonatomic, retain) CancelRunBlock *job;
@property (nonatomic, retain) JobLifecycleEventObserver *observer;

@end
