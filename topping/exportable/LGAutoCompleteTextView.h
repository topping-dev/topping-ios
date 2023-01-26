#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LGEditText.h"

@interface LGAutoCompleteTextView : LGEditText
{
}

+(LGAutoCompleteTextView*)create:(LuaContext *)context;

@end
