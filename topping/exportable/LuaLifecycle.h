#import <Foundation/Foundation.h>

#import "LuaClass.h"
#import "Lifecycle.h"
#import "LuaCoroutineScope.h"
#import "LuaForm.h"
#import "LuaFragment.h"
#import "LuaLifecycleObserver.h"
#import "LuaTranslator.h"

@interface LuaLifecycle : NSObject <LuaClass>

+(LuaLifecycle*)createForm:(LuaForm*)form;
+(LuaLifecycle*)createFragment:(LuaFragment*)fragment;

- (instancetype)initWithLifecycle:(Lifecycle*)lifecycle :(LuaCoroutineScope*)scope;

-(void)addObserver:(LuaLifecycleObserver*)observer;
-(void)removeObserver:(LuaLifecycleObserver*)observer;
-(void)launch:(LuaTranslator*)lt;
-(void)launchDispatcher:(int)dispatcher :(LuaTranslator*)lt;

@property (nonatomic, retain) Lifecycle *lifecycle;
@property (nonatomic, retain) LuaCoroutineScope *scope;

@end
