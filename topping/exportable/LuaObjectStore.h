#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LuaInterface.h"
#import "LuaClass.h"

/**
 * Object store to store c objects sent and received from lua engine.
 */
@interface LuaObjectStore : NSObject<LuaClass, LuaInterface>
{
	void* obj;
}

/**
 * Object that sent and received.
 */
 @property (nonatomic) void* obj;

@end
