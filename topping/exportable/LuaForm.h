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

typedef enum FormEvents
{
    FORM_EVENT_CREATE,
    FORM_EVENT_RESUME,
    FORM_EVENT_PAUSE,
    FORM_EVENT_DESTROY,
    FORM_EVENT_UPDATE,
    FORM_EVENT_PAINT,
    FORM_EVENT_MOUSEDOWN,
    FORM_EVENT_MOUSEUP,
    FORM_EVENT_MOUSEMOVE,
    FORM_EVENT_KEYDOWN,
    FORM_EVENT_KEYUP,
    FORM_EVENT_NFC,
    FORM_EVENT_COUNT
} FormEvents;

@interface LuaForm : UIViewController <LuaClass, LuaInterface, ViewModelStoreOwner>
{
}

- (instancetype)initWithContext:(LuaContext *)context;

+(void)RegisterFormEventRef:(LuaRef *)luaId :(int)event :(LuaTranslator *)lt;
+(void)RegisterFormEvent:(NSString *)luaId :(int)event :(LuaTranslator *)lt;
+(BOOL)OnFormEvent:(NSObject*)pGui :(int)EventType :(LuaContext*)lc :(int)ArgCount, ...;
+(void)Create:(LuaContext*)context :(NSString*)luaId;
+(void)CreateWithUI:(LuaContext*)context :(NSString*)luaId :(NSString *)ui;
+(NSObject*)CreateForTab:(LuaContext *)context :(NSString*)luaId;
+(LuaForm*)GetActiveForm;
-(LuaContext*)GetContext;
-(LGView*)GetViewById:(LuaRef*)lId;
-(LGView*)GetViewByIdInternal:(NSString*)sId;
-(NSDictionary*)GetBindings;
-(LGView*)GetView;
-(void)SetView:(LGView*)v;
-(void)SetViewXML:(NSString *)xml;
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

@property(nonatomic, retain) LGView *lgview;
@property(nonatomic, retain) LGToolbar *toolbar;
@property(nonatomic, retain) NSString *ui;
@property(nonatomic, retain) LuaViewModelProvider *viewModelProvider;
@property(nonatomic, retain) LuaLifecycleOwner *lifecycleOwner;
@property(nonatomic, retain) LifecycleRegistry *lifecycleRegistry;
@property(nonatomic, retain) FragmentController *mFragments;
@property(nonatomic, retain) FragmentManager *fragmentManager;
@property(nonatomic, retain) ViewModelStore *viewModelStore;
@property(nonatomic, retain) SavedStateRegistryController *savedStateRegistryController;
@property(nonatomic, retain) OnBackPressedDispatcher *onBackPressedDispatcher;
@property(nonatomic) BOOL mCreated;
@property(nonatomic) BOOL mResumed;
@property(nonatomic) BOOL mStopped;
@property(nonatomic) BOOL createCalled;
@property(nonatomic) BOOL rootConstraintsSet;

@end
