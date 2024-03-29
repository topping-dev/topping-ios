#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LuaInterface.h"
#import "LuaClass.h"
#import "LuaRef.h"

@class ILuaForm;
@class LuaForm;
@class ILuaFragment;
@class LuaFragment;

typedef enum UIEvents
{
    UI_EVENT_CREATE,
    UI_EVENT_VIEW_CREATE,
    UI_EVENT_FRAGMENT_CREATE_VIEW,
    UI_EVENT_FRAGMENT_VIEW_CREATED,
    UI_EVENT_RESUME,
    UI_EVENT_PAUSE,
    UI_EVENT_DESTROY,
    UI_EVENT_UPDATE,
    UI_EVENT_PAINT,
    UI_EVENT_MOUSEDOWN,
    UI_EVENT_MOUSEUP,
    UI_EVENT_MOUSEMOVE,
    UI_EVENT_KEYDOWN,
    UI_EVENT_KEYUP,
    UI_EVENT_NFC,
    UI_EVENT_COUNT
} UIEvents;

@interface LuaEvent : NSObject <LuaClass, LuaInterface>
{
}

+(void)registerUIEvent:(LuaRef *)luaId :(int)event :(LuaTranslator *)lt;
+(void)registerForm:(NSString*)name :(LuaTranslator*)ltInit;
+(ILuaForm*)getFormInstance:(NSString*)name :(LuaForm*)fragment;
+(void)registerFragment:(NSString*)name :(LuaTranslator*)ltInit;
+(ILuaFragment*)getFragmentInstance:(NSString*)name :(LuaFragment*)fragment;
+(NSObject*)onUIEvent:(NSObject<LuaInterface>*)pGui :(int)EventType :(LuaContext*)lc :(int)ArgCount, ...;

@end
