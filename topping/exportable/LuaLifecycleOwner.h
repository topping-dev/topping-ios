#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LuaClass.h"
#import "LuaInterface.h"
#import "Lifecycle.h"

@protocol LifecycleOwner <NSObject>

-(Lifecycle*)getLifecycle;

@end

@interface LuaLifecycleOwner : NSObject <LuaClass, LuaInterface, LifecycleOwner>
{
}

@end
