#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LuaInterface.h"
#import "LuaClass.h"
#import "KeyboardHelper.h"
#import "LuaContext.h"
#import "LGView.h"

@class LGView;

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

KEYBOARD_FUNCTIONS

KEYBOARD_PROPERTIES

@property(nonatomic, retain) NSString *luaId;
@property(nonatomic, retain) LuaContext *context;
@property(nonatomic, retain) LGView *lgview;
@property(nonatomic, retain) NSString *ui;

@end
