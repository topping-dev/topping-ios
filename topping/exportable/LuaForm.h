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
@class FragmentController;
@class FragmentManager;
@class FragmentHostCallback;
@class ViewModelStore;
@class SavedStateRegistryController;
@class OnBackPressedDispatcher;
@class LuaFormOnBackPressedDispatcher;

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

@interface LuaForm : UIViewController <LuaClass, LuaInterface>
{
}

+(void)RegisterFormEvent:(NSString *)luaId :(int)event :(LuaTranslator *)lt;
+(BOOL)OnFormEvent:(NSObject*)pGui :(int)EventType :(LuaContext*)lc :(int)ArgCount, ...;
+(void)Create:(LuaContext*)context :(NSString*)luaId;
+(void)CreateWithUI:(LuaContext*)context :(NSString*)luaId :(NSString *)ui;
+(NSObject*)CreateForTab:(LuaContext *)context :(NSString*)luaId;
+(LuaForm*)GetActiveForm;
-(LuaContext*)GetContext;
-(LGView*)GetViewById:(NSString*)lId;
-(LGView*)GetView;
-(void)SetView:(LGView*)v;
-(void)SetViewXML:(NSString *)xml;
-(void)SetTitle:(NSString *)str;
-(void)Close;

-(BOOL)isChangingConfigurations;
-(void)onBackPressed;

-(ViewModelStore*)getViewModelStore;

-(FragmentManager*)getSupportFragmentManager;
-(void)markFragmentsCreated;

KEYBOARD_FUNCTIONS

KEYBOARD_PROPERTIES

@property(nonatomic, retain) NSString *luaId;
@property(nonatomic, retain) LuaContext *context;
@property(nonatomic, retain) LGView *lgview;
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

@end
