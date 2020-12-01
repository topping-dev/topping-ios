#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LGTextView.h"
#import "KeyboardHelper.h"

@interface LGEditText : LGTextView<UITextFieldDelegate, UITextViewDelegate>
{
}

+(LGEditText*)Create:(LuaContext *)context;
-(void)SetTextChangedListener:(LuaTranslator*)lt;
-(void)SetBeforeTextChangedListener:(LuaTranslator*)lt;
-(void)SetAfterTextChangedListener:(LuaTranslator*)lt;

KEYBOARD_FUNCTIONS

@property(nonatomic) LuaTranslator *ltTextChangedListener, *ltBeforeTextChangedListener, *ltAfterTextChangedListener;
@property(nonatomic) bool multiLine;

KEYBOARD_PROPERTIES

@end
