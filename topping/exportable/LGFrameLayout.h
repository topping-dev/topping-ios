#import <Foundation/Foundation.h>
#import "LGViewGroup.h"

@interface LGFrameLayout : LGViewGroup

+(LGFrameLayout*)create:(LuaContext *)context;

@property (nonatomic, strong) NSMutableArray *lgViewConstraintToAddList;
@property (nonatomic, strong) NSLayoutConstraint *widthConstraint, *heightConstraint;

@end
