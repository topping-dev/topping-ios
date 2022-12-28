#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LuaInterface.h"
#import "LuaClass.h"
#import "LuaContext.h"
#import "LuaRef.h"

@interface LuaToast : NSObject<LuaClass, LuaInterface>
{
	
}

+(void)ShowInternal:(LuaContext*)context :(NSString*)text :(int) duration;
+(void)Show:(LuaContext*)context :(LuaRef*)text :(int) duration;

@end
