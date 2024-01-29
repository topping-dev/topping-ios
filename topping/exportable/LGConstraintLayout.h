#import <Foundation/Foundation.h>
#import "LGViewGroup.h"
#import "LGImageView.h"
#import "LGButton.h"
#import <ToppingIOSKotlinHelper/ToppingIOSKotlinHelper.h>

@interface LGConstraintImageFilterButton : LGImageView

@property (nonatomic, strong) TIOSKHImageFilterButton *wrapper;

@end

@interface LGConstraintImageFilterView : LGImageView

@property (nonatomic, strong) TIOSKHImageFilterView *wrapper;

@end

@interface LGConstraintMotionButton : LGButton

@property (nonatomic, strong) TIOSKHMotionButton *wrapper;

@end

/*
@interface LGConstraintMotionLabel : LGTextView

@property (nonatomic, strong) TIOSKHMotionLabel *wrapper;

@end*/

@interface LGConstraintBarrier : LGView

@property (nonatomic, strong) TIOSKHBarrier *wrapper;

@end

@interface LGConstraintGroup : LGView

@property (nonatomic, strong) TIOSKHGroup *wrapper;

@end

@interface LGConstraintGuideline : LGView

@property (nonatomic, strong) TIOSKHGuideline *wrapper;

@end

@interface LGConstraintPlaceholder : LGView

@property (nonatomic, strong) TIOSKHPlaceholder *wrapper;

@end

@interface LGConstraintReactiveGuide : LGView

@property (nonatomic, strong) TIOSKHReactiveGuide *wrapper;

@end

@interface LGConstraintCarousel : LGView

@property (nonatomic, strong) TIOSKHCarousel *wrapper;

@end

@interface LGConstraintCircularFlow : LGView

@property (nonatomic, strong) TIOSKHCircularFlow *wrapper;

@end

@interface LGConstraintFlow : LGView

@property (nonatomic, strong) TIOSKHFlow *wrapper;

@end

@interface LGConstraintGrid : LGView

@property (nonatomic, strong) TIOSKHGrid *wrapper;

@end

@interface LGConstraintLayer : LGView

@property (nonatomic, strong) TIOSKHLayer *wrapper;

@end

@interface LGConstraintMotionEffect : LGView

@property (nonatomic, strong) TIOSKHMotionEffect *wrapper;

@end

@interface LGConstraintMotionPlaceholder : LGView

@property (nonatomic, strong) TIOSKHMotionPlaceholder *wrapper;

@end

@interface LGConstraintLayout : LGViewGroup

+(LGConstraintLayout*)create:(LuaContext *)context;

@property (nonatomic) BOOL initComponent;
@property (nonatomic, strong) TIOSKHConstraintLayout *wrapper;

@end

@interface LGConstraintMotionLayout : LGConstraintLayout

@property (nonatomic, strong) TIOSKHMotionLayout *wrapper;

@end

