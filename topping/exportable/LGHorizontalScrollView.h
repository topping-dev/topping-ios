#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LGFrameLayout.h"
#import "LuaContext.h"

@interface LGHorizontalScrollView : LGViewGroup <UIScrollViewDelegate>
{

}

//Lua
+(LGHorizontalScrollView*)create:(LuaContext *)context;

@end
