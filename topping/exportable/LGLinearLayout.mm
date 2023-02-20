#import "LGLinearLayout.h"
#import "Defines.h"
#import "LuaFunction.h"
#import "LGValueParser.h"
#import "math.h"

@implementation LGLinearLayout

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.mMaxAscent = [@[[NSNumber numberWithInt:-1], [NSNumber numberWithInt:-1], [NSNumber numberWithInt:-1], [NSNumber numberWithInt:-1]] mutableCopy];
        self.mMaxDescent = [@[[NSNumber numberWithInt:-1], [NSNumber numberWithInt:-1], [NSNumber numberWithInt:-1], [NSNumber numberWithInt:-1]] mutableCopy];
    }
    return self;
}

-(void)setupComponent:(UIView *)view {
    [super setupComponent:view];
    
    self.mWeightSum = 1;
    if(self.android_weightSum != nil) {
        self.mWeightSum = STOF((NSString*)[[LGValueParser getInstance] getValue:self.android_weightSum]);
    }
    
    self.layout = YES;
    self.mBaseAligned = true;
    if(self.android_baseAligned != nil) {
        self.mBaseAligned = SSTOB(self.android_baseAligned);
    }
    self.mBaselineAlignedChildIndex = -1;
    if(self.android_baseAlignedChildIndex != nil) {
        self.mBaselineAlignedChildIndex = STOI(self.android_baseAlignedChildIndex);
    }
    if(self.android_measureWithLargestChild != nil) {
        self.mUseLargestChild = SSTOB(self.android_measureWithLargestChild);
    }
    self.mBaselineChildTop = 0;
    self.sRemeasureWeightedChildren = true;
    self.mAllowInconsistentMeasurement = true;
    
    self.orientation = VERTICAL;
    if(self.android_orientation != nil) {
        if([self.android_orientation isEqualToString:@"horizontal"]) {
            self.orientation = HORIZONTAL;
        }
    }
}

-(int)getBaseLine
{
    if (self.mBaselineAlignedChildIndex < 0) {
        return -1;
    }
    if (self.subviews.count <= self.mBaselineAlignedChildIndex) {
        return -1;
    }
    LGView *child = [self.subviews objectAtIndex:self.mBaselineAlignedChildIndex];
    int childBaseline = child.baseLine;
    if (childBaseline == -1) {
        return -1;
    }
    // TODO: This should try to take into account the virtual offsets
    // (See getNextLocationOffset and getLocationOffset)
    // We should add to childTop:
    // sum([getNextLocationOffset(getChildAt(i)) / i < mBaselineAlignedChildIndex])
    // and also add:
    // getLocationOffset(child)
    int childTop = self.mBaselineChildTop;
    if (self.orientation == VERTICAL) {
        int majorGravity = self.dGravity & VERTICAL_GRAVITY_MASK;
        if (majorGravity != GRAVITY_TOP) {
           switch (majorGravity) {
               case GRAVITY_BOTTOM:
                   childTop = self.mBottom - self.mTop - self.dPaddingBottom - self.mTotalLength;
                   break;
               case GRAVITY_CENTER_VERTICAL:
                   childTop += ((self.mBottom - self.mTop - self.dPaddingTop - self.dPaddingBottom) -
                           self.mTotalLength) / 2;
                   break;
           }
        }
    }
    return childTop + child.dMarginTop + childBaseline;
}

-(int)getParentWidthSpec
{
    int widthSpec = 0;
    if(self.parent != nil) {
        widthSpec = self.parent.dWidthSpec;
    } else {
        switch (self.dWidthDimension) {
            case MATCH_PARENT:
                widthSpec = [MeasureSpec makeMeasureSpec:self.dWidth :EXACTLY];
                break;
            case WRAP_CONTENT:
                widthSpec = [MeasureSpec makeMeasureSpec:self.dWidth :AT_MOST];
                break;
            default:
                widthSpec = [MeasureSpec makeMeasureSpec:self.dWidth :EXACTLY];
                break;
        }
    }
    return widthSpec;
}

-(int)getParentHeightSpec
{
    int heightSpec = 0;
    if(self.parent != nil) {
        heightSpec = self.parent.dHeightSpec;
    } else {
        switch (self.dWidthDimension) {
            case MATCH_PARENT:
                heightSpec = [MeasureSpec makeMeasureSpec:self.dHeight :EXACTLY];
                break;
            case WRAP_CONTENT:
                heightSpec = [MeasureSpec makeMeasureSpec:self.dHeight :AT_MOST];
                break;
            default:
                heightSpec = [MeasureSpec makeMeasureSpec:self.dHeight :EXACTLY];
                break;
        }
    }
    return heightSpec;
}

-(void)resize
{
    if(!self.widthSpecSet) {
        self.dWidthSpec = [self getParentWidthSpec];
        self.widthSpecSet = true;
    }
    if(!self.heightSpecSet) {
        self.dHeightSpec = [self getParentHeightSpec];
        self.heightSpecSet = true;
    }
    //[super resize];
    [self resizeInternal];
	//NSLog(@"\n %@", [self DebugDescription:nil]);
	/*BOOL vertical = YES;
	if(self.android_orientation != nil)
		vertical = [self.android_orientation compare:@"vertical"] == 0;
    [super resize];*/
	//[super AfterResize:vertical];
#ifdef DEBUG_DESCRIPTION
	NSLog(@"\n %@", [self debugDescription:nil]);
#endif
}

-(BOOL)hasDividerBeforeChildAt:(int)index {
    return false;
}

-(LGView*)getVirtualChildAt:(int)index {
    return [self.subviews objectAtIndex:index];
}

-(int)measureNullChild:(int)i {
    return 0;
}

-(int)getLocationOffset:(LGView*)child {
    return 0;
}

-(BOOL)allViewsAreGoneBefore:(int) childIndex {
    for (int i = childIndex - 1; i >= 0; i--) {
        LGView *child = [self.subviews objectAtIndex:childIndex];
        if (child != nil && child.dVisibility != GONE) {
            return false;
        }
    }
    return true;
}

-(BOOL)allViewsAreGoneAfter:(int) childIndex {
    int count = self.subviews.count;
    for (int i = childIndex + 1; i < count; i++) {
        LGView *child = [self.subviews objectAtIndex:i];
        if (child != nil && child.dVisibility != GONE) {
            return false;
        }
    }
    return true;
}

-(int)getChildrenSkipCount:(LGView*)child :(int)index {
    return 0;
}

-(int)getNextLocationOffset:(LGView*) child {
    return 0;
}

-(void)measureChildBeforeLayout:(LGView*)child :(int)childIndex :(int)widthMeasureSpec :(int)totalWidth :(int)heightMeasureSpec :(int)totalHeight
{
    [self measureChildWithMargins:child :widthMeasureSpec :totalWidth :heightMeasureSpec :totalHeight];
}

-(void)onMeasure:(int)widthMeasureSpec :(int)heightMeasureSpec {
    if(self.orientation == VERTICAL) {
        [self resizeInternalVertical:widthMeasureSpec :heightMeasureSpec];
        [self layoutVertical];
    }
    else {
        [self resizeInternalHorizontal:widthMeasureSpec :heightMeasureSpec];
        [self layoutHorizontal];
    }
}

-(void)resizeInternal
{
    [self readWidthHeight];
    int widthSpec = [self getParentWidthSpec];
    int heightSpec = [self getParentHeightSpec];
    if(self.orientation == VERTICAL) {
        [self resizeInternalVertical:widthSpec :heightSpec];
        [self layoutVertical];
    }
    else {
        [self resizeInternalHorizontal:widthSpec :heightSpec];
        [self layoutVertical];
    }
}

-(void)layoutVertical {
    int paddingLeft = self.dPaddingLeft;
    
    int childTop;
    int childLeft;
    
    // Where right end of child should go
    int width = self.right - self.left;
    int childRight = width - self.dPaddingRight;
    
    // Space available for child
    int childSpace = width - self.dPaddingLeft - self.dPaddingRight;
    
    int count = self.subviews.count;
    
    int majorGravity = self.dGravity & VERTICAL_GRAVITY_MASK;
    int minorGravity = self.dGravity & RELATIVE_HORIZONTAL_GRAVITY_MASK;
    
    switch (majorGravity) {
       case GRAVITY_BOTTOM:
           // mTotalLength contains the padding already
           childTop = self.dPaddingTop + self.bottom - self.top - self.mTotalLength;
           break;
           // mTotalLength contains the padding already
       case GRAVITY_CENTER_VERTICAL:
           childTop = self.dPaddingTop + (self.bottom - self.top - self.mTotalLength) / 2;
           break;
       case GRAVITY_TOP:
       default:
           childTop = self.dPaddingTop;
           break;
    }
    for (int i = 0; i < count; i++) {
        LGView *child = [self getVirtualChildAt:i];
        if (child == nil) {
            childTop += [self measureNullChild:i];
        } else if (child.dVisibility != GONE) {
            int childWidth = child.dWidth;
            int childHeight = child.dHeight;
            int gravity = child.dGravity;
            if (gravity < 0) {
                gravity = minorGravity;
            }
            int absoluteGravity = [Gravity getAbsoluteGravity:gravity];
            switch (absoluteGravity & HORIZONTAL_GRAVITY_MASK) {
                case GRAVITY_CENTER_HORIZONTAL:
                    childLeft = paddingLeft + ((childSpace - childWidth) / 2)
                            + child.dMarginLeft - child.dMarginRight;
                    break;
                case GRAVITY_RIGHT:
                    childLeft = childRight - childWidth - child.dMarginRight;
                    break;
                case GRAVITY_LEFT:
                default:
                    childLeft = paddingLeft + child.dMarginLeft;
                    break;
            }
            if ([self hasDividerBeforeChildAt:i]) {
                childTop += self.mDividerHeight;
            }
            childTop += child.dMarginTop;
            child.dX = childLeft;
            child.dY = childTop + [self getLocationOffset:child];
            child.dWidth = childWidth;
            child.dHeight = childHeight;
            childTop += childHeight + child.dMarginBottom + [self getNextLocationOffset:child];
            
            i += [self getChildrenSkipCount:child :i];
        }
    }
}

-(void)layoutHorizontal {
    BOOL isLayoutRtl = [LGView isRtl];
    int paddingTop = self.dPaddingTop;
    
    int childTop = 0;
    int childLeft = 0;
    
    // Where bottom of child should go
    int height = self.bottom - self.top;
    int childBottom = height - self.dPaddingBottom;
    
    // Space available for child
    int childSpace = height - self.dPaddingTop - self.dPaddingBottom;
    
    int count = self.subviews.count;
    
    int majorGravity = self.dGravity & RELATIVE_HORIZONTAL_GRAVITY_MASK;
    int minorGravity = self.dGravity & VERTICAL_GRAVITY_MASK;
    
    BOOL baselineAligned = self.mBaseAligned;
    
    NSMutableArray *maxAscent = self.mMaxAscent;
    NSMutableArray *maxDescent = self.mMaxDescent;
    
    switch ([Gravity getAbsoluteGravity:majorGravity]) {
       case GRAVITY_RIGHT:
           // mTotalLength contains the padding already
           childLeft = self.dPaddingLeft + self.right - self.left - self.mTotalLength;
           break;
           // mTotalLength contains the padding already
       case GRAVITY_CENTER_HORIZONTAL:
            childLeft = self.dPaddingLeft + (self.right - self.left - self.mTotalLength) / 2;
           break;
       case GRAVITY_LEFT:
       default:
           childLeft = self.dPaddingLeft;
           break;
    }
    
    int start = 0;
    int dir = 1;
    //In case of RTL, start drawing from the last child.
    if (isLayoutRtl) {
        start = count - 1;
        dir = -1;
    }
    
    for (int i = 0; i < count; i++) {
        int childIndex = start + dir * i;
        LGView *child = [self getVirtualChildAt:childIndex];
        if (child == nil) {
            childTop += [self measureNullChild:i];
        } else if (child.dVisibility != GONE) {
            int childWidth = child.dWidth;
            int childHeight = child.dHeight;
            int childBaseline = -1;
            
            if(baselineAligned && child.dHeightDimension != MATCH_PARENT) {
                childBaseline = child.baseLine;
            }
            
            int gravity = child.dGravity;
            if (gravity < 0) {
                gravity = minorGravity;
            }
            
            switch (gravity & VERTICAL_GRAVITY_MASK) {
                case GRAVITY_TOP:
                    childTop = paddingTop + child.dMarginTop;
                    if(childBaseline != -1) {
                        childTop += [[maxAscent objectAtIndex:1] intValue] - childBaseline;
                    }
                    break;
                case GRAVITY_CENTER_VERTICAL:
                    childTop = self.dPaddingTop + ((childSpace - childHeight) / 2)
                    + child.dMarginTop - child.dMarginBottom;
                    break;
                case GRAVITY_BOTTOM:
                    childTop = childBottom - childHeight - child.dMarginBottom;
                    if (childBaseline != -1) {
                        int descent = child.dHeight - childBaseline;
                        childTop -= ([[maxDescent objectAtIndex:2] intValue] - descent);
                    }
                    break;
                default:
                    childTop = paddingTop;
                    break;
            }
            
            if ([self hasDividerBeforeChildAt:i]) {
                childLeft += self.mDividerWidth;
            }
            
            childLeft += child.dMarginLeft;
            child.dX = childLeft + [self getLocationOffset:child];
            child.dY = childTop;
            child.dWidth = childWidth;
            child.dHeight = childHeight;
            
            childLeft += childWidth + child.dMarginRight + [self getNextLocationOffset:child];
            
            i += [self getChildrenSkipCount:child :childIndex];
        }
    }
}

-(void)resizeInternalVertical:(int)widthSpec :(int)heightSpec {
    [self readWidthHeight];
    self.mTotalLength = 0;
    int maxWidth = 0;
    int childState = 0;
    int alternativeMaxWidth = 0;
    int weightedMaxWidth = 0;
    BOOL allFillParent = true;
    float totalWeight = 0;
    
    int count = self.subviews.count;
    
    int widthMode = [MeasureSpec getMode:widthSpec];
    int heightMode = [MeasureSpec getMode:heightSpec];
    
    BOOL matchWidth = false;
    BOOL skippedMeasure = false;
    
    int baselineChildIndex = self.mBaselineAlignedChildIndex;
    BOOL useLargestChild = self.mUseLargestChild;
    
    int largestChildHeight = 0;
    
    // See how tall everyone is. Also remember max width.
    for (int i = 0; i < count; ++i) {
        LGView *child = [self getVirtualChildAt:i];
        [child readWidthHeight];
        
        if (child == nil) {
            self.mTotalLength += [self measureNullChild:i];
            continue;
        }
        
        if (child.dVisibility == GONE) {
           i += [self getChildrenSkipCount:child :i];
           continue;
        }
        
        if ([self hasDividerBeforeChildAt:i]) {
            self.mTotalLength += self.mDividerHeight;
        }
        
        float weight = 0;
        if(child.android_layout_weight != nil) {
            weight = STOF((NSString*)[[LGValueParser getInstance] getValue:child.android_layout_weight]);
        }
        totalWeight += weight;
        
        if (heightMode == EXACTLY && child.dHeightDimension == 0 && weight > 0) {
            // Optimization: don't bother measuring children who are only
            // laid out using excess space. These views will get measured
            // later if we have space to distribute.
            int totalLength = self.mTotalLength;
            self.mTotalLength = MAX(totalLength, totalLength + self.dMarginTop + self.dMarginBottom);
            skippedMeasure = true;
        } else {
            int oldHeight = INT_MIN;
            
            if(child.dHeightDimension == 0 && weight > 0) {
                // heightMode is either UNSPECIFIED or AT_MOST, and this
                // child wanted to stretch to fill available space.
                // Translate that to WRAP_CONTENT so that it does not end up
                // with a height of 0
                oldHeight = 0;
                child.dHeightDimension = WRAP_CONTENT;
            }
            
            // Determine how big this child would like to be. If this or
            // previous children have given a weight, then we allow it to
            // use all available space (and we will shrink things later
            // if needed).
            [self measureChildBeforeLayout:child :i :widthSpec :0 :heightSpec :totalWeight == 0 ? self.mTotalLength : 0];
            
            if (oldHeight != INT_MIN) {
                child.dHeightDimension = oldHeight;
            }
            
            int childHeight = child.dHeight;
            int totalLength = self.mTotalLength;
            self.mTotalLength = MAX(totalLength, totalLength + childHeight + child.dMarginTop +
                   child.dMarginBottom + [self getNextLocationOffset:child]);
            if (useLargestChild) {
                largestChildHeight = MAX(childHeight, largestChildHeight);
            }
        }
        /**
         * If applicable, compute the additional offset to the child's baseline
         * we'll need later when asked {@link #getBaseline}.
         */
        if ((baselineChildIndex >= 0) && (baselineChildIndex == i + 1)) {
           self.mBaselineChildTop = self.mTotalLength;
        }
        // if we are trying to use a child index for our baseline, the above
        // book keeping only works if there are no children above it with
        // weight.  fail fast to aid the developer.
        if (i < baselineChildIndex && weight > 0) {
            return;
        }
        
        BOOL matchWidthLocally = false;
        if (widthMode != EXACTLY && child.dWidthDimension == MATCH_PARENT) {
            // The width of the linear layout will scale, and at least one
            // child said it wanted to match our width. Set a flag
            // indicating that we need to remeasure at least that view when
            // we know our width.
            matchWidth = true;
            matchWidthLocally = true;
        }
        
        int margin = child.dMarginLeft + child.dMarginRight;
        int measuredWidth = child.dWidth + margin;
        maxWidth = MAX(maxWidth, measuredWidth);
        childState = [LGView combineMeasuredStates:childState :[child getMeasuredState]];
        
        allFillParent = allFillParent && child.dWidthDimension == MATCH_PARENT;
        if (weight > 0) {
            /*
             * Widths of weighted Views are bogus if we end up
             * remeasuring, so keep them separate.
             */
            weightedMaxWidth = MAX(weightedMaxWidth,
                    matchWidthLocally ? margin : measuredWidth);
        } else {
            alternativeMaxWidth = MAX(alternativeMaxWidth,
                    matchWidthLocally ? margin : measuredWidth);
        }
        
        i += [self getChildrenSkipCount:child :i];
    }
    
    if (useLargestChild &&
            (heightMode == AT_MOST || heightMode == UNSPECIFIED)) {
        self.mTotalLength = 0;
        
        for (int i = 0; i < count; ++i) {
            LGView *child = [self getVirtualChildAt:i];
            
            if (child == nil) {
                self.mTotalLength += [self measureNullChild:i];
                continue;
            }
            
            if (child.dVisibility == GONE) {
                i += [self getChildrenSkipCount:child :i];
                continue;
            }
            
            // Account for negative margins
            int totalLength = self.mTotalLength;
            self.mTotalLength = MAX(totalLength, totalLength + largestChildHeight +
                    child.dMarginTop + child.dMarginBottom + [self getNextLocationOffset:child]);
        }
    }
    
    // Add in our padding
    self.mTotalLength += self.dPaddingTop + self.dPaddingBottom;
    
    int heightSize = self.mTotalLength;
    
    // Check against our minimum height
    heightSize = MAX(heightSize, [self getSuggestedMinimumHeight]);
    
    // Reconcile our calculated size with the heightMeasureSpec
    int heightSizeAndState = [LGView resolveSizeAndState:heightSize :heightSpec :0];
    heightSize = heightSizeAndState & MEASURED_SIZE_MASK;
    
    // Either expand children with weight to take up available space or
    // shrink them if they extend beyond our current bounds. If we skipped
    // measurement on any children, we need to measure them now.
    int delta = heightSize - self.mTotalLength;
    if (skippedMeasure
            || (delta != 0 && totalWeight > 0.0f)) {
        float weightSum = self.mWeightSum > 0.0f ? self.mWeightSum : totalWeight;
        
        self.mTotalLength = 0;
        
        for (int i = 0; i < count; ++i) {
            LGView *child = [self getVirtualChildAt:i];
            
            if (child == nil || child.dVisibility == GONE) {
                continue;
            }
            
            float weight = 0;
            if(child.android_layout_weight != nil) {
                weight = STOF((NSString*)[[LGValueParser getInstance] getValue:child.android_layout_weight]);
            }
            float childExtra = weight;
            if (childExtra > 0) {
                int share = (int) (childExtra * delta / weightSum);
                weightSum -= childExtra;
                delta -= share;
                
                int childWidthMeasureSpec = [LGViewGroup getChildMeasureSpec:widthSpec :self.dPaddingLeft + self.dPaddingRight + child.dMarginLeft + child.dMarginRight :child.dWidthDimension];
                
                // TODO: Use a field like lp.isMeasured to figure out if this
                // child has been previously measured
                if((child.dHeightDimension != 0) || (heightMode != EXACTLY)) {
                    // child was measured once already above...
                    // base new measurement on stored values
                    int childHeight = child.dWidth + share;
                    if(childHeight < 0) {
                        childHeight = 0;
                    }
                    
                    [child measure:childWidthMeasureSpec :[MeasureSpec makeMeasureSpec:childHeight :EXACTLY]];
                } else {
                    // child was skipped in the loop above.
                    // Measure for this first time here
                    [child measure:childWidthMeasureSpec
                            :[MeasureSpec makeMeasureSpec:share > 0 ? share : 0 :EXACTLY]];
                }
                
                childState = [LGView combineMeasuredStates:childState :[child getMeasuredState]
                        & (MEASURED_STATE_MASK
                           >> MEASURED_HEIGHT_STATE_SHIFT)];
            }
            
            int margin = child.dMarginLeft + child.dMarginRight;
            int measuredWidth = child.dWidth + margin;
            maxWidth = MAX(maxWidth, measuredWidth);
            
            BOOL matchWidthLocally = widthMode != EXACTLY &&
                    child.dWidthDimension == MATCH_PARENT;
            
            alternativeMaxWidth = MAX(alternativeMaxWidth,
                    matchWidthLocally ? margin : measuredWidth);
            
            allFillParent = allFillParent && child.dWidthDimension == MATCH_PARENT;
            
            int totalLength = self.mTotalLength;
            self.mTotalLength = MAX(totalLength, totalLength + child.dHeight +
                    child.dMarginTop + child.dMarginBottom + [self getNextLocationOffset:child]);
        }
        // Add in our padding
        self.mTotalLength += self.dPaddingTop + self.dPaddingBottom;
        // TODO: Should we recompute the heightSpec based on the new total length?
    } else {
        alternativeMaxWidth = MAX(alternativeMaxWidth,
                                       weightedMaxWidth);
        
        // We have no limit, so make all weighted views as tall as the largest child.
        // Children will have already been measured once.
        if (useLargestChild && heightMode != EXACTLY) {
            for (int i = 0; i < count; i++) {
                LGView *child = [self getVirtualChildAt:i];
                
                if (child == nil || child.dVisibility == GONE) {
                    continue;
                }
                
                float weight = 0;
                if(child.android_layout_weight != nil) {
                    weight = STOF((NSString*)[[LGValueParser getInstance] getValue:child.android_layout_weight]);
                }
                
                float childExtra = weight;
                if (childExtra > 0) {
                    [child measure:[MeasureSpec makeMeasureSpec:child.dWidth :EXACTLY] :[MeasureSpec makeMeasureSpec:largestChildHeight :EXACTLY]];
                }
            }
        }
    }
    
    if (!allFillParent && widthMode != EXACTLY) {
        maxWidth = alternativeMaxWidth;
    }
    
    maxWidth += self.dPaddingLeft + self.dPaddingRight;
    
    // Check against our minimum width
    maxWidth = MAX(maxWidth, [self getSuggestedMinimumWidth]);
    
    [self setMeasuredDimension:[LGView resolveSizeAndState:maxWidth :widthSpec :childState] :heightSizeAndState];
    
    if (matchWidth) {
        [self forceUniformWidth:count :heightSpec];
    }
}

-(void)forceUniformWidth:(int)count :(int)heightMeasureSpec {
    // Pretend that the linear layout has an exact size.
    int uniformMeasureSpec = [MeasureSpec makeMeasureSpec:self.dWidth :EXACTLY];
    for (int i = 0; i< count; ++i) {
       LGView *child = [self getVirtualChildAt:i];
       if (child != nil && child.dVisibility != GONE) {
           if (child.dWidthDimension == MATCH_PARENT) {
               // Temporarily force children to reuse their old measured height
               // FIXME: this may not be right for something like wrapping text?
               int oldHeight = child.dHeightDimension;
               child.dHeightDimension = child.dHeight;
               // Remeasue with new dimensions
               [self measureChildWithMargins:child :uniformMeasureSpec :0 :heightMeasureSpec :0];
               child.dHeightDimension = oldHeight;
           }
       }
    }
}


-(void)resizeInternalHorizontal:(int)widthSpec :(int)heightSpec {
    int INDEX_CENTER_VERTICAL = 0;
    int INDEX_TOP = 1;
    int INDEX_BOTTOM = 2;
    int INDEX_FILL = 3;
    
    [self readWidthHeight];
    self.mTotalLength = 0;
    int maxHeight = 0;
    int childState = 0;
    int alternativeMaxHeight = 0;
    int weightedMaxHeight = 0;
    BOOL allFillParent = true;
    float totalWeight = 0;
    
    int count = self.subviews.count;
    
    int widthMode = [MeasureSpec getMode:widthSpec];
    int heightMode = [MeasureSpec getMode:heightSpec];
    
    BOOL matchHeight = false;
    BOOL skippedMeasure = false;
    
    if (self.mMaxAscent == nil || self.mMaxDescent == nil) {
        self.mMaxAscent = [[NSMutableArray alloc] initWithCapacity:4];
        self.mMaxDescent = [[NSMutableArray alloc] initWithCapacity:4];
    }
    
    NSMutableArray *maxAscent = self.mMaxAscent;
    NSMutableArray *maxDescent = self.mMaxDescent;
    
    maxAscent[INDEX_CENTER_VERTICAL] = maxAscent[INDEX_TOP] = maxAscent[INDEX_BOTTOM] = maxAscent[INDEX_FILL] = [NSNumber numberWithInt:-1];
    maxDescent[INDEX_CENTER_VERTICAL] = maxDescent[INDEX_TOP] = maxDescent[INDEX_BOTTOM] = maxDescent[INDEX_FILL] = [NSNumber numberWithInt:-1];
    
    BOOL baselineAligned = self.mBaseAligned;
    BOOL useLargestChild = self.mUseLargestChild;
    
    BOOL isExactly = widthMode == EXACTLY;
    
    int largestChildWidth = 0;
    
    // See how tall everyone is. Also remember max width.
    for (int i = 0; i < count; ++i) {
        LGView *child = [self getVirtualChildAt:i];
        [child readWidthHeight];
        
        if (child == nil) {
            self.mTotalLength += [self measureNullChild:i];
            continue;
        }
        
        if (child.dVisibility == GONE) {
           i += [self getChildrenSkipCount:child :i];
           continue;
        }
        
        if ([self hasDividerBeforeChildAt:i]) {
            self.mTotalLength += self.mDividerWidth;
        }
        
        float weight = 0;
        if(child.android_layout_weight != nil) {
            weight = STOF((NSString*)[[LGValueParser getInstance] getValue:child.android_layout_weight]);
        }
        totalWeight += weight;
        
        if (widthMode == EXACTLY && child.dWidthDimension == 0 && weight > 0) {
            // Optimization: don't bother measuring children who are only
            // laid out using excess space. These views will get measured
            // later if we have space to distribute.
            if(isExactly) {
                self.mTotalLength = child.dMarginLeft + child.dMarginRight;
            } else {
                int totalLength = self.mTotalLength;
                self.mTotalLength = MAX(totalLength, totalLength + self.dMarginLeft + self.dMarginRight);
            }
            
            // Baseline alignment requires to measure widgets to obtain the
            // baseline offset (in particular for TextViews). The following
            // defeats the optimization mentioned above. Allow the child to
            // use as much space as it wants because we can shrink things
            // later (and re-measure).
            if (baselineAligned) {
                int freeSpec = [MeasureSpec makeMeasureSpec:0 :UNSPECIFIED];
                [child measure:freeSpec :freeSpec];
            } else {
                skippedMeasure = true;
            }
        } else {
            int oldWidth = INT_MIN;
            
            if(child.dWidthDimension == 0 && weight > 0) {
                // heightMode is either UNSPECIFIED or AT_MOST, and this
                // child wanted to stretch to fill available space.
                // Translate that to WRAP_CONTENT so that it does not end up
                // with a height of 0
                oldWidth = 0;
                child.dWidthDimension = WRAP_CONTENT;
            }
            
            // Determine how big this child would like to be. If this or
            // previous children have given a weight, then we allow it to
            // use all available space (and we will shrink things later
            // if needed).
            [self measureChildBeforeLayout:child :i :widthSpec :totalWeight == 0 ? self.mTotalLength : 0 :heightSpec :0];
            
            if (oldWidth != INT_MIN) {
                child.dWidthDimension = oldWidth;
            }
            
            int childWidth = child.dWidth;
            if(isExactly) {
                self.mTotalLength += childWidth + child.dMarginLeft + child.dMarginRight +
                                            [self getNextLocationOffset:child];
            } else {
                int totalLength = self.mTotalLength;
                self.mTotalLength = MAX(totalLength, totalLength + childWidth + child.dMarginLeft +
                                        child.dMarginRight + [self getNextLocationOffset:child]);
            }
            
            if (useLargestChild) {
                largestChildWidth = MAX(childWidth, largestChildWidth);
            }
        }
        
        BOOL matchHeightLocally = false;
        if (heightMode != EXACTLY && child.dHeightDimension == MATCH_PARENT) {
            // The width of the linear layout will scale, and at least one
            // child said it wanted to match our width. Set a flag
            // indicating that we need to remeasure at least that view when
            // we know our width.
            matchHeight = true;
            matchHeightLocally = true;
        }
        
        int margin = child.dMarginTop + child.dMarginBottom;
        int childHeight = child.dHeight + margin;
        childState = [LGView combineMeasuredStates:childState :[child getMeasuredState]];
        
        if(baselineAligned) {
            int childBaseline = child.baseLine;
            if(childBaseline != -1) {
                // Translates the child's vertical gravity into an index
                // in the range 0..VERTICAL_GRAVITY_COUNT
                int gravity = (child.dGravity < 0 ? self.dGravity : child.dGravity)
                        & VERTICAL_GRAVITY_MASK;
                int index = ((gravity >> AXIS_Y_SHIFT)
                        & ~AXIS_SPECIFIED) >> 1;

                int maxAscentIndex = [[maxAscent objectAtIndex:index] intValue];
                int maxDescentIndex = [[maxDescent objectAtIndex:index] intValue];
                int maxAscentMax = MAX(maxAscentIndex, childBaseline);
                int maxDescentMax = MAX(maxDescentIndex, childHeight - childBaseline);
                [maxAscent setObject:[NSNumber numberWithInt:maxAscentMax] atIndexedSubscript:index];
                [maxDescent setObject:[NSNumber numberWithInt:maxDescentMax] atIndexedSubscript:index];
            }
        }
        
        maxHeight = MAX(maxHeight, childHeight);
        
        allFillParent = allFillParent && child.dHeightDimension == MATCH_PARENT;
        if (weight > 0) {
            /*
             * Widths of weighted Views are bogus if we end up
             * remeasuring, so keep them separate.
             */
            weightedMaxHeight = MAX(weightedMaxHeight,
                    matchHeightLocally ? margin : childHeight);
        } else {
            alternativeMaxHeight = MAX(alternativeMaxHeight,
                    matchHeightLocally ? margin : childHeight);
        }
        
        i += [self getChildrenSkipCount:child :i];
    }
    
    if(self.mTotalLength > 0 && [self hasDividerBeforeChildAt:count]) {
        self.mTotalLength += self.mDividerWidth;
    }
    
    int maxAscentTop = [[maxAscent objectAtIndex:INDEX_TOP] intValue];
    int maxAscentCenterVertical = [[maxAscent objectAtIndex:INDEX_CENTER_VERTICAL] intValue];
    int maxAscentBottom = [[maxAscent objectAtIndex:INDEX_BOTTOM] intValue];
    int maxAscentFill = [[maxAscent objectAtIndex:INDEX_FILL] intValue];
    int maxDescentTop = [[maxDescent objectAtIndex:INDEX_TOP] intValue];
    int maxDescentCenterVertical = [[maxDescent objectAtIndex:INDEX_CENTER_VERTICAL] intValue];
    int maxDescentBottom = [[maxDescent objectAtIndex:INDEX_BOTTOM] intValue];
    int maxDescentFill = [[maxDescent objectAtIndex:INDEX_FILL] intValue];
    if(maxAscentTop != -1
       || maxAscentCenterVertical != -1
       || maxAscentBottom != -1
       || maxAscentFill != -1) {
        
        int ascent = MAX(maxAscentFill, MAX(maxAscentCenterVertical, MAX(maxAscentTop, maxAscentBottom)));
        int descent = MAX(maxDescentFill, MAX(maxDescentCenterVertical, MAX(maxDescentTop, maxDescentBottom)));
        
        maxHeight = MAX(maxHeight, ascent + descent);
    }
    
    if (useLargestChild &&
            (widthMode == AT_MOST || widthMode == UNSPECIFIED)) {
        self.mTotalLength = 0;
        
        for (int i = 0; i < count; ++i) {
            LGView *child = [self getVirtualChildAt:i];
            
            if (child == nil) {
                self.mTotalLength += [self measureNullChild:i];
                continue;
            }
            
            if (child.dVisibility == GONE) {
                i += [self getChildrenSkipCount:child :i];
                continue;
            }
            
            if(isExactly) {
                self.mTotalLength = largestChildWidth + child.dMarginLeft + child.dMarginRight + [self getNextLocationOffset:child];
            }
            else {
                int totalLength = self.mTotalLength;
                self.mTotalLength = MAX(totalLength, totalLength + largestChildWidth +
                        child.dMarginLeft + child.dMarginRight + [self getNextLocationOffset:child]);
            }
        }
    }
    
    // Add in our padding
    self.mTotalLength += self.dPaddingTop + self.dPaddingBottom;
    
    int widthSize = self.mTotalLength;
    
    // Check against our minimum height
    widthSize = MAX(widthSize, [self getSuggestedMinimumWidth]);
    
    // Reconcile our calculated size with the heightMeasureSpec
    int widthSizeAndState = [LGView resolveSizeAndState:widthSize :widthSpec :0];
    widthSize = widthSizeAndState & MEASURED_SIZE_MASK;
    
    // Either expand children with weight to take up available space or
    // shrink them if they extend beyond our current bounds. If we skipped
    // measurement on any children, we need to measure them now.
    int delta = widthSize - self.mTotalLength;
    if (skippedMeasure
            || (delta != 0 && totalWeight > 0.0f)) {
        float weightSum = self.mWeightSum > 0.0f ? self.mWeightSum : totalWeight;
        
        maxAscent[0] = maxAscent[1] = maxAscent[2] = maxAscent[3] = [NSNumber numberWithInt:-1];
        maxDescent[0] = maxDescent[1] = maxDescent[2] = maxDescent[3] = [NSNumber numberWithInt:-1];
        maxHeight = -1;
        
        self.mTotalLength = 0;
        
        for (int i = 0; i < count; ++i) {
            LGView *child = [self getVirtualChildAt:i];
            
            if (child == nil || child.dVisibility == GONE) {
                continue;
            }
            
            float weight = 0;
            if(child.android_layout_weight != nil) {
                weight = STOF((NSString*)[[LGValueParser getInstance] getValue:child.android_layout_weight]);
            }
            float childExtra = weight;
            if (childExtra > 0) {
                int share = (int) (childExtra * delta / weightSum);
                weightSum -= childExtra;
                delta -= share;
                
                int childHeightMeasureSpec = [LGViewGroup getChildMeasureSpec:heightSpec :self.dPaddingTop + self.dPaddingBottom + child.dMarginTop + child.dMarginBottom :child.dHeightDimension];
                
                // TODO: Use a field like lp.isMeasured to figure out if this
                // child has been previously measured
                if((child.dWidthDimension != 0) || (widthMode != EXACTLY)) {
                    // child was measured once already above...
                    // base new measurement on stored values
                    int childWidth = child.dWidth + share;
                    if(childWidth < 0) {
                        childWidth = 0;
                    }
                    
                    [child measure:[MeasureSpec makeMeasureSpec:childWidth :EXACTLY] :childHeightMeasureSpec];
                } else {
                    // child was skipped in the loop above.
                    // Measure for this first time here
                    [child measure:[MeasureSpec makeMeasureSpec:share > 0 ? share : 0 :EXACTLY]
                            :childHeightMeasureSpec];
                }
                
                childState = [LGView combineMeasuredStates:childState :[child getMeasuredState]
                        & MEASURED_STATE_MASK];
            }
            
            if(isExactly) {
                self.mTotalLength += child.dWidth + child.dMarginLeft + child.dMarginRight +
                                            [self getNextLocationOffset:child];
            } else {
                int totalLength = self.mTotalLength;
                self.mTotalLength = MAX(totalLength, totalLength + child.dWidth +
                        child.dMarginLeft + child.dMarginRight + [self getNextLocationOffset:child]);
            }
            
            BOOL matchHeightLocally = heightMode != EXACTLY &&
                    child.dHeightDimension == MATCH_PARENT;
            
            int margin = child.dMarginTop + child.dMarginBottom;
            int childHeight = child.dHeight + margin;
            maxHeight = MAX(maxHeight, childHeight);
            alternativeMaxHeight = MAX(alternativeMaxHeight,
                    matchHeightLocally ? margin : childHeight);
            
            allFillParent = allFillParent && child.dHeightDimension == MATCH_PARENT;
            
            if(baselineAligned) {
                int childBaseline = child.baseLine;
                if(child.baseLine != -1) {
                    // Translates the child's vertical gravity into an index in the range 0..2
                    int gravity = (child.dGravity < 0 ? self.dGravity : child.dGravity)
                            & VERTICAL_GRAVITY_MASK;
                    int index = ((gravity >> AXIS_Y_SHIFT)
                            & ~AXIS_SPECIFIED) >> 1;
                    
                    int maxAscentIndex = [[maxAscent objectAtIndex:index] intValue];
                    int maxDescentIndex = [[maxDescent objectAtIndex:index] intValue];
                    [maxAscent setObject:[NSNumber numberWithInt:MAX(maxAscentIndex, childBaseline)] atIndexedSubscript:index];
                    [maxDescent setObject:[NSNumber numberWithInt:MAX(maxDescentIndex, childHeight - childBaseline)] atIndexedSubscript:index];
                }
            }
        }
        // Add in our padding
        self.mTotalLength += self.dPaddingLeft + self.dPaddingRight;
        // TODO: Should we update widthSize with the new total length?

        // Check mMaxAscent[INDEX_TOP] first because it maps to Gravity.TOP,
        // the most common case
        int maxAscentTop = [[maxAscent objectAtIndex:INDEX_TOP] intValue];
        int maxAscentCenterVertical = [[maxAscent objectAtIndex:INDEX_CENTER_VERTICAL] intValue];
        int maxAscentBottom = [[maxAscent objectAtIndex:INDEX_BOTTOM] intValue];
        int maxAscentFill = [[maxAscent objectAtIndex:INDEX_FILL] intValue];
        int maxDescentTop = [[maxDescent objectAtIndex:INDEX_TOP] intValue];
        int maxDescentCenterVertical = [[maxDescent objectAtIndex:INDEX_CENTER_VERTICAL] intValue];
        int maxDescentBottom = [[maxDescent objectAtIndex:INDEX_BOTTOM] intValue];
        int maxDescentFill = [[maxDescent objectAtIndex:INDEX_FILL] intValue];
        if(maxAscentTop != -1
           || maxAscentCenterVertical != -1
           || maxAscentBottom != -1
           || maxAscentFill != -1) {
            
            int ascent = MAX(maxAscentFill, MAX(maxAscentCenterVertical, MAX(maxAscentTop, maxAscentBottom)));
            int descent = MAX(maxDescentFill, MAX(maxDescentCenterVertical, MAX(maxDescentTop, maxDescentBottom)));
            
            maxHeight = MAX(maxHeight, ascent + descent);
        }
    } else {
        alternativeMaxHeight = MAX(alternativeMaxHeight,
                                       weightedMaxHeight);
        
        // We have no limit, so make all weighted views as tall as the largest child.
        // Children will have already been measured once.
        if (useLargestChild && widthMode != EXACTLY) {
            for (int i = 0; i < count; i++) {
                LGView *child = [self getVirtualChildAt:i];
                
                if (child == nil || child.dVisibility == GONE) {
                    continue;
                }
                
                float weight = 0;
                if(child.android_layout_weight != nil) {
                    weight = STOF((NSString*)[[LGValueParser getInstance] getValue:child.android_layout_weight]);
                }
                
                float childExtra = weight;
                if (childExtra > 0) {
                    [child measure:[MeasureSpec makeMeasureSpec:largestChildWidth :EXACTLY] :[MeasureSpec makeMeasureSpec:child.dHeight :EXACTLY]];
                }
            }
        }
    }
    
    if (!allFillParent && heightMode != EXACTLY) {
        maxHeight = alternativeMaxHeight;
    }
    
    maxHeight += self.dPaddingTop + self.dPaddingBottom;
    
    // Check against our minimum width
    maxHeight = MAX(maxHeight, [self getSuggestedMinimumHeight]);
    
    [self setMeasuredDimension:widthSizeAndState | (childState & MEASURED_STATE_MASK) :[LGView resolveSizeAndState:maxHeight :heightSpec :(childState << MEASURED_HEIGHT_STATE_SHIFT)]];
    
    if (matchHeight) {
        [self forceUniformHeight:count :heightSpec];
    }
}

-(void)forceUniformHeight:(int)count :(int)widthMeasureSpec {
    // Pretend that the linear layout has an exact size. This is the measured height of
    // ourselves. The measured height should be the max height of the children, changed
    // to accommodate the heightMeasureSpec from the parent
    int uniformMeasureSpec = [MeasureSpec makeMeasureSpec:self.dHeight :EXACTLY];
    for (int i = 0; i < count; ++i) {
        LGView *child = [self getVirtualChildAt:i];
        if (child.dVisibility != GONE) {
            if (child.dHeightDimension == MATCH_PARENT) {
                // Temporarily force children to reuse their old measured width
                // FIXME: this may not be right for something like wrapping text?
                int oldWidth = child.dWidthDimension;
                child.dWidthDimension = child.dWidth;

                // Remeasure with new dimensions
                [self measureChildWithMargins:child :widthMeasureSpec :0 :uniformMeasureSpec :0];
                child.dWidthDimension = oldWidth;
            }
        }
    }
}

//Lua
+(LGLinearLayout*)create:(LuaContext *)context
{
	LGLinearLayout *lst = [[LGLinearLayout alloc] init];
	[lst initProperties];
	return lst;
}

-(NSString*)GetId
{
    if(self.lua_id != nil)
        return self.lua_id;
    if(self.android_id != nil)
        return self.android_id;
    return [LGLinearLayout className];
}

+ (NSString*)className
{
	return @"LGLinearLayout";
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(create:)) 
										:@selector(create:)
										:[LGLinearLayout class]
										:[NSArray arrayWithObjects:[LuaContext class], [NSString class], nil] 
										:[LGLinearLayout class]] 
			 forKey:@"create"];
	return dict;
}

@end
