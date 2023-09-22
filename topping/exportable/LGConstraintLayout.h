#import <Foundation/Foundation.h>
#import "LGViewGroup.h"
#import "LGImageView.h"
#import "LGButton.h"

@class TIOSKHImageFilterButton;

@interface LGConstraintImageFilterButton : LGImageView

@property (nonatomic, strong) TIOSKHImageFilterButton *wrapper;

@end

@class TIOSKHImageFilterView;

@interface LGConstraintImageFilterView : LGImageView

@property (nonatomic, strong) TIOSKHImageFilterView *wrapper;

@end

@class TIOSKHMotionButton;

@interface LGConstraintMotionButton : LGButton

@property (nonatomic, strong) TIOSKHMotionButton *wrapper;

@end

/*@class TIOSKHMotionLabel;

@interface LGConstraintMotionLabel : LGTextView

@property (nonatomic, strong) TIOSKHMotionLabel *wrapper;

@end*/

@class TIOSKHBarrier;

@interface LGConstraintBarrier : LGView

@property (nonatomic, strong) TIOSKHBarrier *wrapper;

@end

@class TIOSKHGroup;

@interface LGConstraintGroup : LGView

@property (nonatomic, strong) TIOSKHGroup *wrapper;

@end

@class TIOSKHGuideline;

@interface LGConstraintGuideline : LGView

@property (nonatomic, strong) TIOSKHGuideline *wrapper;

@end

@class TIOSKHPlaceholder;

@interface LGConstraintPlaceholder : LGView

@property (nonatomic, strong) TIOSKHPlaceholder *wrapper;

@end

@class TIOSKHReactiveGuide;

@interface LGConstraintReactiveGuide : LGView

@property (nonatomic, strong) TIOSKHReactiveGuide *wrapper;

@end

@class TIOSKHCarousel;

@interface LGConstraintCarousel : LGView

@property (nonatomic, strong) TIOSKHCarousel *wrapper;

@end

@class TIOSKHCircularFlow;

@interface LGConstraintCircularFlow : LGView

@property (nonatomic, strong) TIOSKHCircularFlow *wrapper;

@end

@class TIOSKHFlow;

@interface LGConstraintFlow : LGView

@property (nonatomic, strong) TIOSKHFlow *wrapper;

@end

@class TIOSKHGrid;

@interface LGConstraintGrid : LGView

@property (nonatomic, strong) TIOSKHGrid *wrapper;

@end

@class TIOSKHLayer;

@interface LGConstraintLayer : LGView

@property (nonatomic, strong) TIOSKHLayer *wrapper;

@end

@class TIOSKHMotionEffect;

@interface LGConstraintMotionEffect : LGView

@property (nonatomic, strong) TIOSKHMotionEffect *wrapper;

@end

@class TIOSKHMotionPlaceholder;

@interface LGConstraintMotionPlaceholder : LGView

@property (nonatomic, strong) TIOSKHMotionPlaceholder *wrapper;

@end

@class TIOSKHConstraintLayout;

@interface LGConstraintLayout : LGViewGroup

+(LGConstraintLayout*)create:(LuaContext *)context;

@property (nonatomic) BOOL initComponent;
@property (nonatomic, strong) TIOSKHConstraintLayout *wrapper;

@end

@class TIOSKHMotionLayout;

@interface LGConstraintMotionLayout : LGConstraintLayout

@property (nonatomic, strong) TIOSKHMotionLayout *wrapper;

@end

