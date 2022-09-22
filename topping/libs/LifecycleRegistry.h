#ifndef LifecycleRegistry_h
#define LifecycleRegistry_h

#import <Foundation/Foundation.h>
#import "LuaLifecycle.h"
#import "LuaLifecycleOwner.h"
#import "OrderedDictionary.h"
#import "LuaLifecycleObserver.h"

@interface ObserverWithState : NSObject

-(void)dispatchEvent:(id<LifecycleOwner>)owner :(LifecycleEvent)event;

@property LifecycleState state;
@property (nonatomic, retain) LuaLifecycleObserver *observer;

@end

@interface LifecycleRegistry : LuaLifecycle

-(id) initWithOwner:(id<LifecycleOwner>)owner;
-(void)handleLifecycleEvent:(LifecycleEvent) event;
-(void)setCurrentState:(LifecycleState)state;

+(LifecycleState)min:(LifecycleState)state1 :(LifecycleState)state2;

/**
 * Custom list that keeps observers and can handle removals / additions during traversal.
 *
 * Invariant: at any moment of time for observer1 & observer2:
 * if addition_order(observer1) < addition_order(observer2), then
 * state(observer1) >= state(observer2),
 */
@property (nonatomic, retain) MutableOrderedDictionary* mObserverMap;
/**
 * Current state
 */
@property LifecycleState mState;
/**
 * The provider that owns this Lifecycle.
 * Only WeakReference on LifecycleOwner is kept, so if somebody leaks Lifecycle, they won't leak
 * the whole Fragment / Activity. However, to leak Lifecycle object isn't great idea neither,
 * because it keeps strong references on all other listeners, so you'll leak all of them as
 * well.
 */
@property (nonatomic, retain) id<LifecycleOwner> mLifecycleOwner;

@property int mAddingObserverCounter;

@property BOOL mHandlingEvent;
@property BOOL mNewEventOccurred;

// we have to keep it for cases:
// void onStart() {
//     mRegistry.removeObserver(this);
//     mRegistry.add(newObserver);
// }
// newObserver should be brought only to CREATED state during the execution of
// this onStart method. our invariant with mObserverMap doesn't help, because parent observer
// is no longer in the map.
@property (nonatomic, retain) NSMutableArray* mParentStates;
@property BOOL mEnforceMainThread;

@end

#endif /* LifecycleRegistry_h */
