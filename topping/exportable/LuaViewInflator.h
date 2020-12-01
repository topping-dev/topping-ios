#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LuaClass.h"
#import "LuaInterface.h"
#import "LuaContext.h"

@class LGView;

@interface LuaViewInflator : NSObject <LuaClass, LuaInterface> 
{
	
}

+(NSObject*)Create:(LuaContext*)lc;
-(LGView*)ParseFile:(NSString*)filename :(LGView*)parent;

@end
