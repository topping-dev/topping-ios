#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LGTextView.h"

@interface LGButton : LGTextView 
{

}

+(LGButton*)create:(LuaContext *)context;

@end
