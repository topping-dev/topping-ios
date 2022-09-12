#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LuaClass.h"
#import "LuaInterface.h"
#import "LuaLifecycle.h"

@protocol LifecycleOwner <NSObject>

-(LuaLifecycle*)getLifecycle;

@end

@interface LuaLifecycleOwner : NSObject <LuaClass, LuaInterface, LifecycleOwner>
{
}

@end
