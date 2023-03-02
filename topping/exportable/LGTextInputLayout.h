#import <Foundation/Foundation.h>
#import "LGViewGroup.h"
#import "LuaTranslator.h"

@interface LGTextInputLayout : LGViewGroup

+(LGTextInputLayout*)create:(LuaContext*)context;

@end
