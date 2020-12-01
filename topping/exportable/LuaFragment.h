#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LuaInterface.h"
#import "LuaClass.h"
#import "KeyboardHelper.h"
#import "LuaContext.h"
#import "LGView.h"

@class LGView;

@interface LuaFragment : NSObject <LuaClass, LuaInterface>
{
}

+(void)Create:(LuaContext*)context :(NSString*)luaId;
+(void)CreateWithUI:(LuaContext*)context :(NSString*)luaId :(NSString *)ui;
-(LuaContext*)GetContext;
-(LGView*)GetViewById:(NSString*)lId;
-(LGView*)GetView;
-(void)SetView:(LGView*)v;
-(void)SetViewId:(NSString*)luaId;
-(void)SetViewXML:(NSString *)xml;
-(void)SetTitle:(NSString *)str;
-(void)Close;
-(BOOL)IsInitialized;

KEYBOARD_FUNCTIONS

KEYBOARD_PROPERTIES

@property(nonatomic, retain) NSString *luaId;
@property(nonatomic, retain) LuaContext *context;
@property(nonatomic, retain) LGView *lgview;
@property(nonatomic, retain) NSString *ui;
@property(nonatomic, retain) UIView *view;

@end
