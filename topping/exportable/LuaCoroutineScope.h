#import <Foundation/Foundation.h>
#import "LuaClass.h"
#import "LuaInterface.h"
#import "LuaTranslator.h"
#import "LuaValues.h"

@interface LuaCoroutineScope : NSObject <LuaClass>

-(void)launch:(LuaTranslator*)lt;
-(void)launchDispatcher:(int)dispatcher :(LuaTranslator*)lt;

@end
