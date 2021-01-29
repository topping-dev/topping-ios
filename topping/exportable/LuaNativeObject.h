#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LuaInterface.h"
#import "LuaClass.h"

/**
 * Object store to store c objects sent and received from lua engine.
 */
@interface LuaNativeObject : NSObject<LuaClass, LuaInterface>
{
	NSObject* obj;
}

/**
 * Object that sent and received.
 */
@property (nonatomic, retain) NSObject* obj;

@end
