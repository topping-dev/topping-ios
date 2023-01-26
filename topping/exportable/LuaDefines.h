#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LuaInterface.h"
#import "LuaClass.h"

/**
 * Object store to store c objects sent and received from lua engine.
 */
@interface LuaDefines : NSObject<LuaClass, LuaInterface>
{
}

+(NSString*)getHumanReadableDate:(int)value;

@end
