#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LuaContext.h"
#import "LGFrameLayout.h"

@interface LGScrollView : LGFrameLayout <UIScrollViewDelegate>
{
	
}

//Lua
+(LGScrollView*)create:(LuaContext *)context;

@end
