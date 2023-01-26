#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LuaClass.h"
#import "LuaInterface.h"
#import "OrderedDictionary.h"
#import "LuaLifecycleOwner.h"
#import "LuaLifecycleObserver.h"
#import "RunnableObjc.h"
#import "LuaTranslator.h"

@protocol Observer <NSObject>

-(void)onChanged:(NSObject*)obj;

@end

@class ObserverWrapper;

@interface LuaLiveData : NSObject <LuaClass, LuaInterface>
{
    NSMapTable *luaObserverMap;
}

-(instancetype)initWithData:(NSObject *)value;
-(void)considerNotify:(ObserverWrapper*) observer;
-(void)dispatchingValue:(ObserverWrapper*) initiator;
-(void)observe:(id<LifecycleOwner>)owner :(id<Observer>) observer;
-(void)observeForever:(id<Observer>) observer;
-(void)removeObserver:(id<Observer>) observer;
-(void)removeObservers:(id<LifecycleOwner>)owner;
-(NSObject*)getValue;
-(NSInteger)getVersion;
-(void)onActive;
-(void)onInactive;
-(BOOL)hasObservers;
-(BOOL)hasActiveObservers;
-(void)changeActiveCounter:(NSInteger)change;

+(LuaLiveData*)create;
-(void)observeLua:(LuaLifecycleOwner*) owner :(LuaTranslator*)lt;
-(void)removeObserverLua:(LuaTranslator*)lt;

@property (nonatomic, retain) NSObject *mDataLock;
@property NSInteger START_VERSION;
@property (nonatomic, retain) NSObject *NOT_SET;
@property (nonatomic, retain) MutableOrderedDictionary *mObservers;
@property NSInteger mActiveCount;
@property BOOL mChangingActiveState;
@property (nonatomic, retain) NSObject *mData;
@property (nonatomic, retain) NSObject *mPendingData;
@property NSInteger mVersion;
@property BOOL mDispatchingValue;
@property BOOL mDispatchingInvalidated;
@property (nonatomic, retain) id<RunnableObjc> mPostValueRunnable;

@end

@interface LuaMutableLiveData : LuaLiveData {
    
}

+(LuaMutableLiveData*)create;
-(void)postValue:(NSObject*)value;
-(void)setValue:(NSObject*)value;

@end

@interface ObserverWrapper : NSObject
{
}

-(BOOL)shouldBeActive;
-(BOOL)isAttachedTo:(id<LifecycleOwner>) owner;
-(void)detachObserver;
-(void)activeStateChanged:(BOOL) newActive;

@property (nonatomic, retain) LuaLiveData* myself;
@property (nonatomic, retain) id<Observer> mObserver;
@property BOOL mActive;
@property NSInteger mLastVersion;

@end

@interface LifecycleBoundObserver : ObserverWrapper <LifecycleEventObserver>

@property (nonatomic, retain) LuaLiveData *myself;
@property (nonatomic, retain) id<LifecycleOwner> mOwner;

@end

@interface AlwaysActiveObserver : ObserverWrapper

@end

@interface LuaTranslatorObserver : NSObject <Observer>

- (instancetype)initWithLuaTranslator:(LuaTranslator*) lt;

@property (nonatomic, retain) LuaTranslator *lt;

@end
