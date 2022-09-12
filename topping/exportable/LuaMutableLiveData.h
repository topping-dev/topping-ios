#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LuaClass.h"
#import "LuaInterface.h"
#import "OrderedDictionary.h"
#import "LuaLifecycleOwner.h"
#import "LuaLifecycleObserver.h"
#import "RunnableObjc.h"

@protocol Observer <NSObject>

-(void)onChanged:(NSObject*)obj;

@end

@class ObserverWrapper;

@interface LuaMutableLiveData : NSObject <LuaClass, LuaInterface>
{
}

-(instancetype)initWithData:(NSObject *)value;
-(void)considerNotify:(ObserverWrapper*) observer;
-(void)dispatchingValue:(ObserverWrapper*) initiator;
-(void)observe:(id<LifecycleOwner>)owner :(id<Observer>) observer;
-(void)observeForever:(id<Observer>) observer;
-(void)removeObserver:(id<Observer>) observer;
-(void)removeObservers:(id<LifecycleOwner>)owner;
-(void)postValue:(NSObject*)value;
-(void)setValue:(NSObject*)value;
-(NSObject*)getValue;
-(NSInteger)getVersion;
-(void)onActive;
-(void)onInactive;
-(BOOL)hasObservers;
-(BOOL)hasActiveObservers;
-(void)changeActiveCounter:(NSInteger)change;


@property (nonatomic, retain) NSObject *mDataLock;
@property NSInteger START_VERSION;
@property (nonatomic, retain) NSObject *NOT_SET;
@property (nonatomic, retain) OrderedDictionary *mObservers;
@property NSInteger mActiveCount;
@property BOOL mChangingActiveState;
@property NSObject *mData;
@property NSObject *mPendingData;
@property NSInteger mVersion;
@property BOOL mDispatchingValue;
@property BOOL mDispatchingInvalidated;
@property id<RunnableObjc> mPostValueRunnable;

@end

@interface ObserverWrapper : NSObject
{
}

-(BOOL)shouldBeActive;
-(BOOL)isAttachedTo:(id<LifecycleOwner>) owner;
-(void)detachObserver;
-(void)activeStateChanged:(BOOL) newActive;

@property (nonatomic, retain) LuaMutableLiveData* myself;
@property (nonatomic, retain) id<Observer> mObserver;
@property BOOL mActive;
@property NSInteger mLastVersion;

@end

@interface LifecycleBoundObserver : ObserverWrapper <LifecycleEventObserver>

@property (nonatomic, retain) LuaMutableLiveData *myself;
@property (nonatomic, retain) id<LifecycleOwner> mOwner;

@end

@interface AlwaysActiveObserver : ObserverWrapper

@end
