#import <Foundation/Foundation.h>
#import "LGViewGroup.h"
#import "LuaTranslator.h"

@interface LGTextInputLayout : LGViewGroup

+(LGTextInputLayout*)create:(LuaContext*)context;

@property (nonatomic, retain) NSString *android_hint;

@end
