#import <Foundation/Foundation.h>
#import "LGViewGroup.h"

@class IOSKHConstraintLayout;

@interface LGConstraintLayout : LGViewGroup

+(LGConstraintLayout*)create:(LuaContext *)context;

@property (nonatomic, strong) IOSKHConstraintLayout *wrapper;

@end
