#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LGButton.h"

@interface LGCompoundButton : LGTextView
{
}

+(LGCompoundButton*)Create:(LuaContext *)context;

@property(nonatomic, retain) NSString *android_checked;

@end
