#import <Foundation/Foundation.h>
#import "LuaClass.h"
#import "LuaInterface.h"
#import "LuaNativeObject.h"

@interface LuaNativeCall : NSObject <LuaClass, LuaInterface>
{
    
}

+(LuaNativeObject*)callClass:(NSString*)clss :(NSString*)func :(NSArray*)params;
+(LuaNativeObject*)call:(LuaNativeObject*)obj :(NSString*)func :(NSArray*)params;

@end
