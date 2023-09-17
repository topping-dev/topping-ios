#import <Foundation/Foundation.h>
#import "LGViewGroup.h"
#import "LGImageView.h"
#import "LGButton.h"

@class IOSKHImageFilterButton;

@interface LGConstraintImageFilterButton : LGImageView

@property (nonatomic, strong) IOSKHImageFilterButton *wrapper;

@end

@class IOSKHImageFilterView;

@interface LGConstraintImageFilterView : LGImageView

@property (nonatomic, strong) IOSKHImageFilterView *wrapper;

@end

@class IOSKHMotionButton;

@interface LGConstraintMotionButton : LGButton

@property (nonatomic, strong) IOSKHMotionButton *wrapper;

@end

/*@class IOSKHMotionLabel;

@interface LGConstraintMotionLabel : LGTextView

@property (nonatomic, strong) IOSKHMotionLabel *wrapper;

@end*/

@class IOSKHBarrier;

@interface LGConstraintBarrier : LGView

@property (nonatomic, strong) IOSKHBarrier *wrapper;

@end

@class IOSKHGroup;

@interface LGConstraintGroup : LGView

@property (nonatomic, strong) IOSKHGroup *wrapper;

@end

@class IOSKHGuideline;

@interface LGConstraintGuideline : LGView

@property (nonatomic, strong) IOSKHGuideline *wrapper;

@end

@class IOSKHPlaceholder;

@interface LGConstraintPlaceholder : LGView

@property (nonatomic, strong) IOSKHPlaceholder *wrapper;

@end

@class IOSKHReactiveGuide;

@interface LGConstraintReactiveGuide : LGView

@property (nonatomic, strong) IOSKHReactiveGuide *wrapper;

@end

@class IOSKHConstraintLayout;

@interface LGConstraintLayout : LGViewGroup

+(LGConstraintLayout*)create:(LuaContext *)context;

@property (nonatomic, strong) IOSKHConstraintLayout *wrapper;

@end

@class IOSKHMotionLayout;

@interface LGConstraintMotionLayout : LGConstraintLayout

@property (nonatomic, strong) IOSKHMotionLayout *wrapper;

@end

