#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LuaInterface.h"
#import "LuaClass.h"
#import "KeyboardHelper.h"
#import "LuaContext.h"
#import "LuaViewModelProvider.h"
#import "LuaLifecycleOwner.h"
#import "LifecycleRegistry.h"
#import "LGView.h"
#import "ILuaForm.h"

@class LGView;
@class LGToolbar;
@class FragmentController;
@class FragmentManager;
@class FragmentHostCallback;
@class ViewModelStore;
@class SavedStateRegistryController;
@class OnBackPressedDispatcher;
@class LuaFormOnBackPressedDispatcher;
@class LuaLifecycle;
@class LuaRef;
@protocol ViewModelStoreOwner;

@interface LuaForm : UIViewController <LuaClass, LuaInterface, ViewModelStoreOwner>
{
}

- (instancetype)initWithContext:(LuaContext *)context;

+(LuaNativeObject*)Create:(LuaContext*)context :(LuaRef*)luaId;
+(LuaNativeObject*)CreateWithUI:(LuaContext*)context :(LuaRef*)luaId :(LuaRef *)ui;
+(LuaForm*)GetActiveForm;
-(LuaContext*)GetContext;
-(LGView*)GetViewById:(LuaRef*)lId;
-(LGView*)GetViewByIdInternal:(NSString*)sId;
-(NSDictionary*)GetBindings;
-(LGView*)GetView;
-(void)SetView:(LGView*)v;
-(void)SetViewXML:(LuaRef *)xml;
-(void)SetTitle:(NSString *)str;
-(void)SetTitleRef:(LuaRef *)str;
-(void)Close;

-(BOOL)isChangingConfigurations;
-(void)onBackPressed;

-(ViewModelStore*)getViewModelStore;

-(FragmentManager*)getSupportFragmentManager;
-(void)markFragmentsCreated;
-(Lifecycle*)getLifecycle;
-(LuaLifecycle*)getLifecycleInner;

-(void)AddMainView:(UIView*)viewToAdd;

KEYBOARD_FUNCTIONS

KEYBOARD_PROPERTIES

@property(nonatomic, retain) NSString *luaId;
@property(nonatomic, retain) LuaContext *context;
@property(nonatomic, retain) LuaFormIntent *intent;

@property(nonatomic, retain) LGView *lgview;
@property(nonatomic, retain) LGToolbar *toolbar;
@property(nonatomic, retain) LuaRef *ui;
@property(nonatomic, retain) LuaViewModelProvider *viewModelProvider;
@property(nonatomic, retain) LuaLifecycleOwner *lifecycleOwner;
@property(nonatomic, retain) LifecycleRegistry *lifecycleRegistry;
@property(nonatomic, retain) FragmentController *mFragments;
@property(nonatomic, retain) ViewModelStore *viewModelStore;
@property(nonatomic, retain) SavedStateRegistryController *savedStateRegistryController;
@property(nonatomic, retain) OnBackPressedDispatcher *onBackPressedDispatcher;
@property(nonatomic) BOOL mCreated;
@property(nonatomic) BOOL mResumed;
@property(nonatomic) BOOL mStopped;
@property(nonatomic) BOOL createCalled;
@property(nonatomic) BOOL rootConstraintsSet;
@property (nonatomic, retain) ILuaForm *kotlinInterface;

@end
