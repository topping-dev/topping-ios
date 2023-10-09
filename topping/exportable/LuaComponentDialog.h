#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LuaClass.h"
#import "LuaContext.h"
#import "LuaForm.h"
#import "LuaRef.h"

@class TIOSKHViewGroupLayoutParams;
@class LinearLayoutDialogController;
@protocol OnBackPressedDispatcherOwner;
@protocol SavedStateRegistryOwner;
@protocol LifecycleOwner;

@interface LuaComponentDialog : NSObject <LuaClass, LuaInterface, LifecycleOwner, OnBackPressedDispatcherOwner, SavedStateRegistryOwner>
{
    
}

@property (nonatomic, strong) LinearLayoutDialogController *controller;

@property (nonatomic, strong) LifecycleRegistry *lifecycleRegistry;
@property (nonatomic, strong) SavedStateRegistryController *savedStateRegistryController;
@property (nonatomic, strong) OnBackPressedDispatcher *onBackPressedDispatcher;

-(instancetype)initWithContext:(LuaContext*)context;
-(void)setContentViewRef:(LuaRef *)ref;
-(void)setContentView:(LGView *)view;
-(void)setContentView:(LGView *)view :(TIOSKHViewGroupLayoutParams*)params;
-(void)addContentView:(LGView *)view :(TIOSKHViewGroupLayoutParams*)params;
-(void)show;
-(void)dismiss;


@end
