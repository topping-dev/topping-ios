#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LGButton.h"

@interface LGCompoundButton : LGButton
{
}

+(LGCompoundButton*)Create:(LuaContext *)context;

@property(nonatomic, retain) NSString *android_checked;

@end
