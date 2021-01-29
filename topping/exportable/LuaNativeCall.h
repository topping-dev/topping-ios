#import <Foundation/Foundation.h>
#import "LuaClass.h"
#import "LuaInterface.h"
#import "LuaNativeObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface LuaNativeCall : NSObject <LuaClass, LuaInterface>
{
    
}

+(LuaNativeObject*)CallClass:(NSString*)clss :(NSString*)func :(NSArray*)params;
+(LuaNativeObject*)Call:(LuaNativeObject*)obj :(NSString*)func :(NSArray*)params;

@end

NS_ASSUME_NONNULL_END
