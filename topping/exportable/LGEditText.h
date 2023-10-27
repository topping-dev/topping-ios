#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LGTextView.h"
#import "KeyboardHelper.h"

typedef enum
{
    IME_OPTION_DEFAULT = 0,
    IME_OPTION_NONE = 1,
    IME_OPTION_GO = 2,
    IME_OPTION_SEARCH = 3,
    IME_OPTION_SEND = 4,
    IME_OPTION_PREVIOUS = 5,
    IME_OPTION_NEXT = 6,
    IME_OPTION_DONE = 7
} IME_OPTION;

@interface LGEditText : LGTextView<UITextFieldDelegate, UITextViewDelegate>
{
}

+(LGEditText*)create:(LuaContext *)context;
-(void)setTextChangedListener:(LuaTranslator*)lt;
-(void)setBeforeTextChangedListener:(LuaTranslator*)lt;
-(void)setAfterTextChangedListener:(LuaTranslator*)lt;
-(void)setImeOption:(IME_OPTION)option;
-(void)setSelection:(int)start :(int)end;

KEYBOARD_FUNCTIONS

@property(nonatomic, strong) LuaTranslator *ltTextChangedListener, *ltBeforeTextChangedListener, *ltAfterTextChangedListener;
@property(nonatomic) bool multiLine;
@property(nonatomic, strong) CALayer *layer;
@property(nonatomic, strong) void (^imeAction)(void);

KEYBOARD_PROPERTIES

@end
