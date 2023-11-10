#import <Foundation/Foundation.h>
#import "LGView.h"

@interface TouchTarget : NSObject

@property(nonatomic, retain) LGView *child;
@property(nonatomic) int pointerIdBits;
@property(nonatomic, retain) TouchTarget *next;

+(TouchTarget*)obtain:(LGView*)child :(int)pointerIdBits;

@end

typedef enum {
    GROUP_FLAG_CLIP_CHILDREN = 0x1,
    GROUP_FLAG_CLIP_TO_PADDING = 0x2,
    GROUP_FLAG_INVALIDATE_REQUIRED  = 0x4,
    GROUP_FLAG_RUN_ANIMATION = 0x8,
    GROUP_FLAG_ANIMATION_DONE = 0x10,
    GROUP_FLAG_PADDING_NOT_NULL = 0x20,
    GROUP_FLAG_ANIMATION_CACHE = 0x40,
    GROUP_FLAG_OPTIMIZE_INVALIDATE = 0x80,
    GROUP_FLAG_CLEAR_TRANSFORMATION = 0x100,
    GROUP_FLAG_NOTIFY_ANIMATION_LISTENER = 0x200,
    GROUP_FLAG_USE_CHILD_DRAWING_ORDER = 0x400,
    GROUP_FLAG_SUPPORT_STATIC_TRANSFORMATIONS = 0x800,
    GROUP_FLAG_ADD_STATES_FROM_CHILDREN = 0x2000,
    GROUP_FLAG_ALWAYS_DRAWN_WITH_CACHE = 0x4000,
    GROUP_FLAG_CHILDREN_DRAWN_WITH_CACHE = 0x8000,
    GROUP_FLAG_NOTIFY_CHILDREN_ON_DRAWABLE_STATE_CHANGE = 0x10000,
    GROUP_FLAG_MASK_FOCUSABILITY = 0x60000,
    GROUP_FOCUS_BEFORE_DESCENDANTS = 0x20000,
    GROUP_FOCUS_AFTER_DESCENDANTS = 0x40000,
    GROUP_FOCUS_BLOCK_DESCENDANTS = 0x60000,
    GROUP_FLAG_DISALLOW_INTERCEPT = 0x80000,
    GROUP_FLAG_SPLIT_MOTION_EVENTS = 0x200000,
    GROUP_FLAG_PREVENT_DISPATCH_ATTACHED_TO_WINDOW = 0x400000,
    GROUP_FLAG_LAYOUT_MODE_WAS_EXPLICITLY_SET = 0x800000,
    GROUP_FLAG_IS_TRANSITION_GROUP = 0x1000000,
    GROUP_FLAG_IS_TRANSITION_GROUP_SET = 0x2000000,
    GROUP_FLAG_TOUCHSCREEN_BLOCKS_FOCUS = 0x4000000,
    GROUP_FLAG_START_ACTION_MODE_FOR_CHILD_IS_TYPED = 0x8000000,
    GROUP_FLAG_START_ACTION_MODE_FOR_CHILD_IS_NOT_TYPED = 0x10000000,
    GROUP_FLAG_SHOW_CONTEXT_MENU_WITH_COORDS = 0x20000000,
} GroupFlags;

@interface LGViewGroup : LGView <UIGestureRecognizerDelegate>

-(void)addSubview:(LGView*)val;
-(void)addSubview:(LGView*)val :(NSInteger)index;
-(void)removeSubview:(LGView*)val;
-(void)removeAllSubViews;
-(NSMutableDictionary*)getBindings;

-(int)getParentWidthSpec;
-(int)getParentHeightSpec;
-(void)measureChildWithMargins:(LGView*)child :(int)parentWidthMeasureSpec :(int)widthUsed :(int)parentHeightMeasureSpec :(int)heightUsed;
+(int)getChildMeasureSpec:(int)spec :(int)padding :(int)childDimension;
-(void)requestDisallowInterceptTouchEvent:(BOOL)disallowIntercept;

-(BOOL)getChildStaticTransformation:(LGView*)child :(Transformation*)t;

@property (nonatomic, strong) NSMutableArray *subviews;
@property (nonatomic, strong) NSMutableDictionary *subviewMap;
@property (nonatomic, retain) TouchTarget *mFirstTouchTarget;
@property (nonatomic) int mGroupFlags;
@property (nonatomic) int mLastTouchDownTime;
@property (nonatomic) int mLastTouchDownIndex;
@property (nonatomic) int mLastTouchDownX;
@property (nonatomic) int mLastTouchDownY;
@property (nonatomic) Transformation *childTransformation;

@end
