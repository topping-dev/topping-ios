#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LuaClass.h"
#import "LuaInterface.h"
#import "LuaLifecycle.h"
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

@end

@interface LuaLifecycleObserver : NSObject <LuaClass, LuaInterface, LifecycleEventObserver>
{
}

@property (nonatomic, retain) NSString *key;

@end
