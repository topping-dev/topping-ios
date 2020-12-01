#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LuaInterface.h"
#import "LuaClass.h"
#import "LuaContext.h"

@interface LuaToast : NSObject<LuaClass, LuaInterface>
{
	
}

+(void)Show:(LuaContext*)context :(NSString*)text :(int) duration;

@end
