#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LuaClass.h"
#import "LuaInterface.h"

@interface LuaViewModelProvider : NSObject <LuaClass, LuaInterface>
{
    NSMutableDictionary *viewModelStore;
}

@end
