#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LGTextView.h"
#import "KeyboardHelper.h"

@interface LGEditText : LGTextView<UITextFieldDelegate, UITextViewDelegate>
{
}

+(LGEditText*)create:(LuaContext *)context;
-(void)setTextChangedListener:(LuaTranslator*)lt;
-(void)setBeforeTextChangedListener:(LuaTranslator*)lt;
-(void)setAfterTextChangedListener:(LuaTranslator*)lt;

KEYBOARD_FUNCTIONS

@property(nonatomic, strong) LuaTranslator *ltTextChangedListener, *ltBeforeTextChangedListener, *ltAfterTextChangedListener;
@property(nonatomic) bool multiLine;
@property(nonatomic, strong) CALayer *layer;

KEYBOARD_PROPERTIES

@end
