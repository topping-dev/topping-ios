#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LGFrameLayout.h"
#import "LuaContext.h"

@interface LGHorizontalScrollView : LGViewGroup
{

}

//Lua
+(LGHorizontalScrollView*)create:(LuaContext *)context;

@end
