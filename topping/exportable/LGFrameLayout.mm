#import "LGFrameLayout.h"
#import "LuaFunction.h"
#import "Defines.h"

@implementation LGFrameLayout

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.mMatchParentChildren = [NSMutableArray array];
    }
    return self;
}

-(void)initComponent:(UIView *)view :(LuaContext *)lc
{
    [super initComponent:view :lc];
    
//    self.widthConstraint = [self._view.widthAnchor constraintEqualToConstant:self.dWidth];
//    self.widthConstraint.active = YES;
//    self.heightConstraint = [self._view.heightAnchor constraintEqualToConstant:self.dHeight];
//    self.heightConstraint.active = YES;
//
//    self.lgViewConstraintToAddList = [NSMutableArray array];
//
//    NSMutableArray *constraintArr = [NSMutableArray array];
//
//    for(LGView *w in self.subviews)
//    {
//        if(w._view == nil)
//            continue;
//
//        w._view.translatesAutoresizingMaskIntoConstraints = NO;
//        [constraintArr addObject:[w._view.widthAnchor constraintEqualToConstant:w.dWidth - self.dPaddingLeft]];
//        [constraintArr addObject:[w._view.heightAnchor constraintEqualToConstant:w.dHeight - self.dPaddingTop]];
//
//        if(/*self.dGravity & GRAVITY_START
//            ||*/ w.dLayoutGravity & GRAVITY_START)
//        {
//            [constraintArr addObject:[w._view.leadingAnchor constraintEqualToAnchor:self._view.leadingAnchor constant:w.dMarginLeft + self.dPaddingLeft]];
//        }
//        else if (/*self.dGravity & GRAVITY_END
//            ||*/ w.dLayoutGravity & GRAVITY_END)
//        {
//            [constraintArr addObject:[w._view.trailingAnchor constraintEqualToAnchor:self._view.trailingAnchor constant:-w.dMarginRight - self.dPaddingRight]];
//        }
//
//        if(/*self.dGravity & GRAVITY_TOP
//           ||*/ w.dLayoutGravity & GRAVITY_TOP)
//        {
//            [constraintArr addObject:[w._view.topAnchor constraintEqualToAnchor:self._view.topAnchor constant:w.dMarginTop + self.dPaddingTop]];
//        }
//        else if (/*self.dGravity & GRAVITY_BOTTOM
//            ||*/ w.dLayoutGravity & GRAVITY_BOTTOM)
//        {
//            [constraintArr addObject:[w._view.bottomAnchor constraintEqualToAnchor:self._view.bottomAnchor constant:-w.dMarginBottom - self.dPaddingBottom]];
//        }
//
//        if(/*self.dGravity & GRAVITY_CENTER_HORIZONTAL
//           ||*/ w.dLayoutGravity & GRAVITY_CENTER_HORIZONTAL)
//        {
//            [constraintArr addObject:[w._view.centerXAnchor constraintEqualToAnchor:self._view.centerXAnchor constant:w.dMarginRight - w.dMarginLeft]];
//        }
//        if(/*self.dGravity & GRAVITY_CENTER_VERTICAL
//           ||*/ w.dLayoutGravity & GRAVITY_CENTER_VERTICAL)
//        {
//            [constraintArr addObject:[w._view.centerYAnchor constraintEqualToAnchor:self._view.centerYAnchor constant:w.dMarginBottom - w.dMarginTop]];
//        }
//        [self._view bringSubviewToFront:w._view];
//    }
//
//    [NSLayoutConstraint activateConstraints:constraintArr];
//
//    [self._view layoutIfNeeded];
}

-(void)addConstraintsToView:(LGView*)w
{
    NSMutableArray *constraintArr = [NSMutableArray array];
    
    if(w._view == nil)
        return;
    
    w._view.translatesAutoresizingMaskIntoConstraints = NO;
    [constraintArr addObject:[w._view.widthAnchor constraintEqualToConstant:w.dWidth - self.dPaddingLeft]];
    [constraintArr addObject:[w._view.heightAnchor constraintEqualToConstant:w.dHeight - self.dPaddingTop]];
    
    if(self.dGravity & GRAVITY_START
        || w.dLayoutGravity & GRAVITY_START)
    {
        [constraintArr addObject:[w._view.leadingAnchor constraintEqualToAnchor:self._view.leadingAnchor constant:w.dMarginLeft + self.dPaddingLeft]];
    }
    else if (self.dGravity & GRAVITY_END
        || w.dLayoutGravity & GRAVITY_END)
    {
        [constraintArr addObject:[w._view.trailingAnchor constraintEqualToAnchor:self._view.trailingAnchor constant:-w.dMarginRight - self.dPaddingRight]];
    }
    
    if(self.dGravity & GRAVITY_TOP
       || w.dLayoutGravity & GRAVITY_TOP)
    {
        [constraintArr addObject:[w._view.topAnchor constraintEqualToAnchor:self._view.topAnchor constant:w.dMarginTop + self.dPaddingTop]];
    }
    else if (self.dGravity & GRAVITY_BOTTOM
        || w.dLayoutGravity & GRAVITY_BOTTOM)
    {
        [constraintArr addObject:[w._view.bottomAnchor constraintEqualToAnchor:self._view.bottomAnchor constant:-w.dMarginBottom - self.dPaddingBottom]];
    }
    
    if(self.dGravity & GRAVITY_CENTER_HORIZONTAL
       || w.dLayoutGravity & GRAVITY_CENTER_HORIZONTAL)
    {
        [constraintArr addObject:[w._view.centerXAnchor constraintEqualToAnchor:self._view.centerXAnchor constant:w.dMarginRight - w.dMarginLeft]];
    }
    if(self.dGravity & GRAVITY_CENTER_VERTICAL
       || w.dLayoutGravity & GRAVITY_CENTER_VERTICAL)
    {
        [constraintArr addObject:[w._view.centerYAnchor constraintEqualToAnchor:self._view.centerYAnchor constant:w.dMarginBottom - w.dMarginTop]];
    }
    [self._view bringSubviewToFront:w._view];
    
    [NSLayoutConstraint activateConstraints:constraintArr];
}

-(int)getPaddingLeftWithForeground {
    return self.dPaddingLeft;
}

-(int)getPaddingTopWithForeground {
    return self.dPaddingTop;
}

-(int)getPaddingRightWithForeground {
    return self.dPaddingRight;
}

-(int)getPaddingBottomWithForeground {
    return self.dPaddingBottom;
}

- (void)onMeasure:(int)widthMeasureSpec :(int)heightMeasureSpec {
    int count = self.subviews.count;
    
    BOOL measureMatchParentChildren =
    [MeasureSpec getMode:widthMeasureSpec] != EXACTLY ||
    [MeasureSpec getMode:heightMeasureSpec] != EXACTLY;
    
    [self.mMatchParentChildren removeAllObjects];
    int maxHeight = 0;
    int maxWidth = 0;
    int childState = 0;
    for (int i = 0; i < count; i++) {
        LGView *child = [self.subviews objectAtIndex:i];
        [child readWidthHeight];
        if (self.mMeasureAllChildren || child.dVisibility != GONE) {
            [self measureChildWithMargins:child :widthMeasureSpec :0 :heightMeasureSpec :0];
            maxWidth = MAX(maxWidth,
                    child.dWidth + child.dMarginLeft + child.dMarginRight);
            maxHeight = MAX(maxHeight,
                    child.dHeight + child.dMarginTop + child.dMarginBottom);
            childState = [LGViewGroup combineMeasuredStates:childState :[child getMeasuredState]];
            if (measureMatchParentChildren) {
                if (child.dWidthDimension == MATCH_PARENT ||
                        child.dHeightDimension == MATCH_PARENT) {
                    [self.mMatchParentChildren addObject:child];
                }
            }
        }
    }
    // Account for padding too
    maxWidth += [self getPaddingLeftWithForeground] + [self getPaddingRightWithForeground];
    maxHeight += [self getPaddingTopWithForeground] + [self getPaddingBottomWithForeground];
    // Check against our minimum height and width
    maxHeight = MAX(maxHeight, [self getSuggestedMinimumHeight]);
    maxWidth = MAX(maxWidth, [self getSuggestedMinimumWidth]);
    // Check against our foreground's minimum height and width
    //TODO:?
    /*final Drawable drawable = getForeground();
    if (drawable != null) {
        maxHeight = Math.max(maxHeight, drawable.getMinimumHeight());
        maxWidth = Math.max(maxWidth, drawable.getMinimumWidth());
    }*/
    [self setMeasuredDimension:[LGView resolveSizeAndState:maxWidth :widthMeasureSpec :childState] :[LGView resolveSizeAndState:maxHeight :heightMeasureSpec :childState << MEASURED_HEIGHT_STATE_SHIFT]];
    count = self.mMatchParentChildren.count;
    if (count > 1) {
        for (int i = 0; i < count; i++) {
            LGView *child = [self.mMatchParentChildren objectAtIndex:i];
            int childWidthMeasureSpec;
            if (child.dWidthDimension == MATCH_PARENT) {
                int width = MAX(0, self.dWidth
                        - [self getPaddingLeftWithForeground] - [self getPaddingRightWithForeground]
                        - child.dMarginLeft - child.dMarginRight);
                childWidthMeasureSpec = [MeasureSpec makeMeasureSpec:
                        width :EXACTLY];
            } else {
                childWidthMeasureSpec = [LGViewGroup getChildMeasureSpec:widthMeasureSpec :[self getPaddingLeftWithForeground] + [self getPaddingRightWithForeground] + child.dMarginLeft + child.dMarginRight :child.dWidthDimension];
            }
            int childHeightMeasureSpec;
            if (child.dHeightDimension == MATCH_PARENT) {
                int height = MAX(0, child.dHeight - [self getPaddingTopWithForeground] - [self getPaddingBottomWithForeground] - child.dMarginTop - child.dMarginBottom);
                childHeightMeasureSpec = [MeasureSpec makeMeasureSpec:
                        height :EXACTLY];
            } else {
                childHeightMeasureSpec = [LGViewGroup getChildMeasureSpec:heightMeasureSpec :[self getPaddingTopWithForeground] + [self getPaddingBottomWithForeground] + child.dMarginTop + child.dMarginBottom :child.dHeightDimension];
            }
            [child measure:childWidthMeasureSpec :childHeightMeasureSpec];
        }
    }
    [self layoutChildren:[self getLeft] :[self getTop] :[self getRight] :[self getBottom]];
}

- (void)resize {
//    i//f(!self.widthSpecSet) {
        self.dWidthSpec = [self getParentWidthSpec];
        self.widthSpecSet = true;
//    //}
    //if(!self.heightSpecSet) {
        self.dHeightSpec = [self getParentHeightSpec];
        self.heightSpecSet = true;
//    }
    [self resizeInternal];
#ifdef DEBUG_DESCRIPTION
    NSLog(@"---- FrameLayout ----\n");
    NSLog(@"\n %@", [self debugDescription:nil]);
#endif
}

- (void)resizeInternal {
    [self readWidthHeight];
    int widthSpec = [self getParentWidthSpec];
    int heightSpec = [self getParentHeightSpec];
    [self onMeasure:widthSpec :heightSpec];
}
    
-(void)layoutChildren:(int)left :(int)top :(int)right :(int)bottom {
    int count = self.subviews.count;
    int parentLeft = [self getPaddingLeftWithForeground];
    int parentRight = right - left - [self getPaddingRightWithForeground];
    int parentTop = [self getPaddingTopWithForeground];
    int parentBottom = bottom - top - [self getPaddingBottomWithForeground];
    
    int DEFAULT_CHILD_GRAVITY = GRAVITY_TOP | GRAVITY_START;
    
    for (int i = 0; i < count; i++) {
        LGView *child = [self.subviews objectAtIndex:i];
        if (child.dVisibility != GONE) {
            int width = child.dWidth;
            int height = child.dHeight;
            int childLeft;
            int childTop;
            int gravity = child.dLayoutGravityDimen;
            if (gravity == -1) {
                gravity = DEFAULT_CHILD_GRAVITY;
            }
            int absoluteGravity = [Gravity getAbsoluteGravity:gravity];
            int verticalGravity = gravity & VERTICAL_GRAVITY_MASK;
            switch (absoluteGravity & HORIZONTAL_GRAVITY_MASK) {
                case GRAVITY_CENTER_HORIZONTAL:
                    childLeft = parentLeft + (parentRight - parentLeft - width) / 2 +
                    child.dMarginLeft - child.dMarginRight;
                    break;
                case GRAVITY_RIGHT:
                    //if (!forceLeftGravity) {
                        childLeft = parentRight - width - child.dMarginRight;
                        break;
                    //}
                case GRAVITY_LEFT:
                default:
                    childLeft = parentLeft + child.dMarginLeft;
            }
            switch (verticalGravity) {
                case GRAVITY_TOP:
                    childTop = parentTop + child.dMarginTop;
                    break;
                case GRAVITY_CENTER_VERTICAL:
                    childTop = parentTop + (parentBottom - parentTop - height) / 2 +
                    child.dMarginTop - child.dMarginBottom;
                    break;
                case GRAVITY_BOTTOM:
                    childTop = parentBottom - height - child.dMarginBottom;
                    break;
                default:
                    childTop = parentTop + child.dMarginTop;
            }
            child.dX = childLeft;
            child.dY = childTop;
            child.dWidth = childLeft + width;
            child.dHeight = childTop + height;
            [child layout:childLeft :childTop :childLeft + width :childTop + height];
        }
    }
}

//Lua
+(LGFrameLayout*)create:(LuaContext *)context
{
    LGFrameLayout *lfl = [[LGFrameLayout alloc] init];
    [lfl initProperties];
    return lfl;
}

-(NSString*)GetId
{
    if(self.lua_id != nil)
        return self.lua_id;
    if(self.android_id != nil)
        return self.android_id;
    return [LGFrameLayout className];
}

+ (NSString*)className
{
    return @"LGFrameLayout";
}

+(NSMutableDictionary*)luaMethods
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(create:))
                                        :@selector(create:)
                                        :[LGFrameLayout class]
                                        :[NSArray arrayWithObjects:[LuaContext class], [NSString class], nil]
                                        :[LGFrameLayout class]]
             forKey:@"create"];
    return dict;
}

@end
