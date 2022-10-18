#import <Foundation/Foundation.h>
#import "LuaClass.h"
#import "LuaInterface.h"

typedef enum Dispatchers
{
    DEFAULT,
    MAIN,
    UNCONFINED,
    IO
} Dispatchers;

@interface LuaDispatchers : NSObject <LuaClass>

@end
