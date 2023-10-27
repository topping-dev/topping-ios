#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LuaClass.h"
#import "LuaInterface.h"
#import "Lifecycle.h"
#import "LuaLifecycleOwner.h"

@protocol LifecycleObserver <NSObject>

@end

@protocol LifecycleEventObserver <LifecycleObserver>

-(NSString*)getKey;

-(void)onStateChanged:(id<LifecycleOwner>)source :(LifecycleEvent) event;

@end

@interface LifecycleEventObserverO : NSObject <LifecycleEventObserver>

-(instancetype)initWithObject:(NSObject*)obj;

@property (nonatomic, copy) void (^onStateChangedO)(id<LifecycleOwner>, LifecycleEvent);
@property (nonatomic, retain) NSObject *myself;
@property (nonatomic, retain) NSString *key;

@end

@interface LifecycleObserver : NSObject <LifecycleEventObserver>
{
}

@property (nonatomic, retain) NSString *key;

@end

@protocol FullLifecycleObserver <LifecycleObserver>

-(void) onCreate:(id<LifecycleOwner>) owner;
-(void) onStart:(id<LifecycleOwner>) owner;
-(void) onResume:(id<LifecycleOwner>) owner;
-(void) onPause:(id<LifecycleOwner>) owner;
-(void) onStop:(id<LifecycleOwner>) owner;
-(void) onDestroy:(id<LifecycleOwner>) owner;

@end

@protocol DefaultLifecycleObserver <FullLifecycleObserver>

@end

@interface LuaLifecycleObserver : NSObject <LuaClass, LuaInterface, DefaultLifecycleObserver>

+(LuaLifecycleObserver*)create:(LuaTranslator*)lt;

@property (nonatomic, retain) LuaTranslator *lt;

@end
