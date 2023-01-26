#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LuaInterface.h"
#import "LuaClass.h"
#import "LuaContext.h"
#import "LuaRef.h"

@interface LuaToast : NSObject<LuaClass, LuaInterface>
{
	
}

+(void)showInternal:(LuaContext*)context :(NSString*)text :(int) duration;
+(void)show:(LuaContext*)context :(LuaRef*)text :(int) duration;

@end
