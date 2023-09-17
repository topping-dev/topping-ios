#import "LGRelativeLayout.h"
#import "LuaFunction.h"
#import "Defines.h"
#import "CGRect+Ext.h"
#import "LGValueParser.h"

static NSMapTable *pool = [NSMapTable strongToStrongObjectsMapTable];

@implementation RLNode

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.dependents = [MutableOrderedDictionary new];
        self.dependencies = [NSMutableDictionary new];
    }
    return self;
}

+(RLNode*)acquire:(LGView*)view
{
    RLNode *node = [pool objectForKey:view];
    if(node == nil)
        node = [[RLNode alloc] init];
    node.view = view;
    
    [pool setObject:node forKey:view];
    
    return node;
 }

-(void)releaseV {
    [pool removeObjectForKey:self.view];
    
    self.view = nil;
    [self.dependents removeAllObjects];
    [self.dependencies removeAllObjects];
}

@end

@implementation RLDependencyGraph

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.mNodes = [NSMutableArray new];
        self.mKeyNodes = [NSMutableDictionary new];
        self.mRoots = [[NSDeque alloc] init];
    }
    return self;
}

-(void)clear {
    NSMutableArray *nodes = self.mNodes;
    int count = nodes.count;
    
    for(int i = 0; i < count; i++) {
        [[nodes objectAtIndex:i] releaseV];
    }
    [nodes removeAllObjects];
    
    [self.mKeyNodes removeAllObjects];
    [self.mRoots clear];
}

-(void)add:(LGView *)view {
    NSString *idVal = [view GetId];
    NSString *idValSimplified = (NSString*)[[LGValueParser getInstance] getValue:idVal];
    RLNode *node = [RLNode acquire:view];
    
    if(idVal != nil) {
        [self.mKeyNodes setObject:node forKey:idValSimplified];
    }
    [self.mNodes addObject:node];

}

-(NSMutableArray*)getSortedViews:(id)sorted, ... {
    NSMutableArray *sortedResult = [NSMutableArray array];
    NSMutableArray *argValues = [NSMutableArray array];
    va_list args;
    va_start(args, sorted);

    id arg = nil;
    while ((arg = va_arg(args,id))) {
        [argValues addObject:arg];
    }

    va_end(args);
    
    NSDeque *roots = [self findRoots:argValues];
    
    RLNode *node;
    while ((node = [roots pollLast]) != nil) {
        LGView *view = node.view;
        NSString *key = [view GetId];
        [sortedResult addObject:view];
        MutableOrderedDictionary *dependents = node.dependents;
        int count = dependents.count;
        for (int i = 0; i < count; i++) {
            RLNode *dependent = [dependents objectAtIndex:i];
            NSMutableDictionary *dependencies = dependent.dependencies;
            [dependencies removeObjectForKey:key];
            if (dependencies.count == 0) {
                [roots add:dependent];
            }
        }
    }
    
    return sortedResult;
}

-(NSDeque*)findRoots:(NSMutableArray*)rulesFilter {
    NSMutableDictionary *keyNodes = self.mKeyNodes;
    NSMutableArray *nodes = self.mNodes;
    int count = self.mNodes.count;
    
    for(int i = 0; i < count; i++) {
        RLNode *node = [nodes objectAtIndex:i];
        [node.dependents removeAllObjects];
        [node.dependencies removeAllObjects];
    }
    
    for(int i = 0; i < count; i++) {
        RLNode *node = [nodes objectAtIndex:i];
        NSMutableArray *rules =  node.view.rlParams.rules;
        int rulesCount = rules.count;
        
        for(int j = 0; j < rulesCount; j++) {
            int rule = [[rules objectAtIndex:j]  intValue];
            
            if(rule > 0) {
                RLNode *dependency = [self.mKeyNodes objectForKey:[NSNumber numberWithInt:rule]];
                
                if(dependency == nil || dependency == node) {
                    continue;
                }
                
                [dependency.dependents setObject:self forKey:node];
                [node.dependencies setObject:dependency forKey:[NSNumber numberWithInt:rule]];
            }
        }
    }
    
    NSDeque *roots = self.mRoots;
    [roots clear];
    
    for(int i = 0; i < count; i++) {
        RLNode *node = [self.mNodes objectAtIndex:i];
        
        if(node.dependencies.count == 0) {
            [roots add:node];
        }
    }
    
    return roots;
}

@end

@implementation LGRelativeLayoutParams

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.rules = [[NSMutableArray alloc] initWithCapacity:VERB_COUNT];
        self.initialRules = [[NSMutableArray alloc] initWithCapacity:VERB_COUNT];
        
        for(int i = 0; i < VERB_COUNT; i++) {
            [self.rules addObject:@""];
            [self.initialRules addObject:@""];
        }
    }
    return self;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"mLeft = %d, mTop = %d, mRight = %d, mBottom = %d", self.mLeft, self.mTop, self.mRight, self.mBottom];
}

-(NSString *)debugDescription {
    return [NSString stringWithFormat:@"mLeft = %d, mTop = %d, mRight = %d, mBottom = %d", self.mLeft, self.mTop, self.mRight, self.mBottom];
}

-(void)addRule:(int)verb {
    [self addRule:verb :STRUE];
}

- (void)addRule:(int)verb :(NSString*)subject {
    if(!self.mNeedsLayoutResolution && [self isRelativeRule:verb]
       && ![[self.initialRules objectAtIndex:verb] isEqualToString:@""] && [subject isEqualToString:@""]) {
        self.mNeedsLayoutResolution = true;
    }
    
    self.rules[verb] = subject;
    self.initialRules[verb] = subject;
    self.mRulesChanged = true;
}

-(void)removeRule:(int)verb {
    [self addRule:verb :@""];
}

-(int)getRule:(int)verb {
    return [self.rules[verb] intValue];
}

-(BOOL)hasRelativeRules {
    return (![self.initialRules[START_OF] isEqualToString:@""] || ![self.initialRules[END_OF] isEqualToString:@""] ||
            ![self.initialRules[ALIGN_START] isEqualToString:@""] || ![self.initialRules[ALIGN_END] isEqualToString:@""] ||
            ![self.initialRules[ALIGN_PARENT_START] isEqualToString:@""] || ![self.initialRules[ALIGN_PARENT_END] isEqualToString:@""]);
}

-(BOOL)isRelativeRule:(int)rule {
    return rule == START_OF || rule == END_OF
                        || rule == ALIGN_START || rule == ALIGN_END
                        || rule == ALIGN_PARENT_START || rule == ALIGN_PARENT_END;
}

-(void)resolveRules:(BOOL)isRtl {
    BOOL isLayoutRtl = isRtl;
    
    self.initialRules = [[NSMutableArray alloc] initWithArray:self.rules copyItems:true];
    
    if (self.mIsRtlCompatibilityMode) {
        if (![self.rules[ALIGN_START] isEqualToString:@""]) {
            if ([self.rules[ALIGN_LEFT] isEqualToString:@""]) {
                // "left" rule is not defined but "start" rule is: use the "start" rule as
                // the "left" rule
                self.rules[ALIGN_LEFT] = self.rules[ALIGN_START];
            }
            self.rules[ALIGN_START] = @"";
        }
        if (![self.rules[ALIGN_END] isEqualToString:@""]) {
            if ([self.rules[ALIGN_RIGHT] isEqualToString:@""]) {
                // "right" rule is not defined but "end" rule is: use the "end" rule as the
                // "right" rule
                self.rules[ALIGN_RIGHT] = self.rules[ALIGN_END];
            }
            self.rules[ALIGN_END] = @"";
        }
        if (![self.rules[START_OF] isEqualToString:@""]) {
            if ([self.rules[LEFT_OF] isEqualToString:@""]) {
                // "left" rule is not defined but "start" rule is: use the "start" rule as
                // the "left" rule
                self.rules[LEFT_OF] = self.rules[START_OF];
            }
            self.rules[START_OF] = @"";
        }
        if (![self.rules[END_OF] isEqualToString:@""]) {
            if ([self.rules[RIGHT_OF] isEqualToString:@""]) {
                // "right" rule is not defined but "end" rule is: use the "end" rule as the
                // "right" rule
                self.rules[RIGHT_OF] = self.rules[END_OF];
            }
            self.rules[END_OF] = @"";
        }
        if (![self.rules[ALIGN_PARENT_START] isEqualToString:@""]) {
            if ([self.rules[ALIGN_PARENT_LEFT] isEqualToString:@""]) {
                // "left" rule is not defined but "start" rule is: use the "start" rule as
                // the "left" rule
                self.rules[ALIGN_PARENT_LEFT] = self.rules[ALIGN_PARENT_START];
            }
            self.rules[ALIGN_PARENT_START] = @"";
        }
        if (![self.rules[ALIGN_PARENT_END] isEqualToString:@""]) {
            if ([self.rules[ALIGN_PARENT_RIGHT] isEqualToString:@""]) {
                // "right" rule is not defined but "end" rule is: use the "end" rule as the
                // "right" rule
                self.rules[ALIGN_PARENT_RIGHT] = self.rules[ALIGN_PARENT_END];
            }
            self.rules[ALIGN_PARENT_END] = @"";
        }
    } else {
        // JB MR1+ case
        if ((![self.rules[ALIGN_START] isEqualToString:@""] || ![self.rules[ALIGN_END] isEqualToString:@""]) &&
            (![self.rules[ALIGN_LEFT] isEqualToString:@""] || ![self.rules[ALIGN_RIGHT] isEqualToString:@""])) {
            // "start"/"end" rules take precedence over "left"/"right" rules
            self.rules[ALIGN_LEFT] = @"";
            self.rules[ALIGN_RIGHT] = @"";
        }
        if (![self.rules[ALIGN_START] isEqualToString:@""]) {
            // "start" rule resolved to "left" or "right" depending on the direction
            self.rules[isLayoutRtl ? ALIGN_RIGHT : ALIGN_LEFT] = self.rules[ALIGN_START];
            self.rules[ALIGN_START] = @"";
        }
        if (![self.rules[ALIGN_END] isEqualToString:@""]) {
            // "end" rule resolved to "left" or "right" depending on the direction
            self.rules[isLayoutRtl ? ALIGN_LEFT : ALIGN_RIGHT] = self.rules[ALIGN_END];
            self.rules[ALIGN_END] = @"";
        }
        if ((![self.rules[START_OF] isEqualToString:@""] || ![self.rules[END_OF] isEqualToString:@""]) &&
            (![self.rules[LEFT_OF] isEqualToString:@""] || ![self.rules[RIGHT_OF] isEqualToString:@""])) {
            // "start"/"end" rules take precedence over "left"/"right" rules
            self.rules[LEFT_OF] = @"";
            self.rules[RIGHT_OF] = @"";
        }
        if (![self.rules[START_OF] isEqualToString:@""]) {
            // "start" rule resolved to "left" or "right" depending on the direction
            self.rules[isLayoutRtl ? RIGHT_OF : LEFT_OF] = self.rules[START_OF];
            self.rules[START_OF] = @"";
        }
        if (![self.rules[END_OF] isEqual: @""]) {
            // "end" rule resolved to "left" or "right" depending on the direction
            self.rules[isLayoutRtl ? LEFT_OF : RIGHT_OF] = self.rules[END_OF];
            self.rules[END_OF] = @"";
        }
        if ((![self.rules[ALIGN_PARENT_START] isEqualToString:@""] || ![self.rules[ALIGN_PARENT_END] isEqualToString:@""]) &&
            (![self.rules[ALIGN_PARENT_LEFT] isEqualToString:@""] || ![self.rules[ALIGN_PARENT_RIGHT] isEqualToString:@""])) {
            // "start"/"end" rules take precedence over "left"/"right" rules
            self.rules[ALIGN_PARENT_LEFT] = @"";
            self.rules[ALIGN_PARENT_RIGHT] = @"";
        }
        if (![self.rules[ALIGN_PARENT_START] isEqualToString:@""]) {
            // "start" rule resolved to "left" or "right" depending on the direction
            self.rules[isLayoutRtl ? ALIGN_PARENT_RIGHT : ALIGN_PARENT_LEFT] = self.rules[ALIGN_PARENT_START];
            self.rules[ALIGN_PARENT_START] = @"";
        }
        if (![self.rules[ALIGN_PARENT_END] isEqualToString:@""]) {
            // "end" rule resolved to "left" or "right" depending on the direction
            self.rules[isLayoutRtl ? ALIGN_PARENT_LEFT : ALIGN_PARENT_RIGHT] = self.rules[ALIGN_PARENT_END];
            self.rules[ALIGN_PARENT_END] = @"";
        }
    }
    self.mRulesChanged = false;
    self.mNeedsLayoutResolution = false;
}

-(void)resolveLayoutDirection:(BOOL)isRtl {
    if([self shouldResolveLayoutDirection:isRtl]) {
        [self resolveRules:isRtl];
    }
}

-(BOOL)shouldResolveLayoutDirection:(BOOL)isRtl {
    return (self.mNeedsLayoutResolution || [self hasRelativeRules])
                        && (self.mRulesChanged || isRtl != [LGView isRtl]);
}

-(NSMutableArray *)getRules:(BOOL)isRtl
{
    return self.rules;
}

@end

@implementation LGRelativeLayout

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.RULES_VERTICAL = @[
            @(ABOVE), @(BELOW), @(ALIGN_BASELINE), @(ALIGN_TOP), @(ALIGN_BOTTOM)
        ];
        
        self.RULES_HORIZONTAL = @[
            @(LEFT_OF), @(RIGHT_OF), @(ALIGN_LEFT), @(ALIGN_RIGHT), @(START_OF), @(END_OF), @(ALIGN_START), @(ALIGN_END)
        ];
        
        self.gravity = GRAVITY_START | GRAVITY_TOP;
        
        self.mGraph = [RLDependencyGraph new];
        
        self.mAllowBrokenMeasureSpecs = false;
        self.mMeasureVerticalWithPaddingMargin = true;
        
        self.DEFAULT_WIDTH = 0x00010000;
    }
    return self;
}

-(void)componentAddMethod:(UIView *)par :(UIView *)me
{
    [super componentAddMethod:par :me];
}

//Lua
+(LGRelativeLayout*)create:(LuaContext *)context
{
    LGRelativeLayout *lfl = [[LGRelativeLayout alloc] init];
    [lfl initProperties];
    return lfl;
}

-(void)sortChildren {
    int count = self.subviews.count;
    if (self.mSortedVerticalChildren == nil || self.mSortedVerticalChildren.count != count) {
        self.mSortedVerticalChildren = [NSMutableArray new];
    }
    if (self.mSortedHorizontalChildren == nil || self.mSortedHorizontalChildren.count != count) {
        self.mSortedHorizontalChildren = [NSMutableArray new];
    }
    RLDependencyGraph *graph = self.mGraph;
    [graph clear];

    for (int i = 0; i < count; i++) {
        [graph add:[self.subviews objectAtIndex:i]];
    }
    self.mSortedVerticalChildren = [graph getSortedViews:self.mSortedVerticalChildren, self.RULES_VERTICAL, nil];
    self.mSortedHorizontalChildren = [graph getSortedViews:self.mSortedHorizontalChildren, self.RULES_HORIZONTAL, nil];
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
    NSLog(@"---- RelativeLayout ----\n");
    NSLog(@"\n %@", [self debugDescription:nil]);
#endif
}

- (void)resizeInternal {
    [self readWidthHeight];
    int widthSpec = [self getParentWidthSpec];
    int heightSpec = [self getParentHeightSpec];
    [self onMeasure:widthSpec :heightSpec];
}

-(void)onMeasure:(int)widthMeasureSpec :(int)heightMeasureSpec {
    if(self.mDirtyHierarchy) {
        self.mDirtyHierarchy = false;
        [self sortChildren];
    }
    
    int myWidth = -1;
    int myHeight = -1;
    int width = 0;
    int height = 0;
    int widthMode = [MeasureSpec getMode:widthMeasureSpec];
    int heightMode = [MeasureSpec getMode:heightMeasureSpec];
    int widthSize = [MeasureSpec getSize:widthMeasureSpec];
    int heightSize = [MeasureSpec getSize:heightMeasureSpec];
    // Record our dimensions if they are known;
    if (widthMode != UNSPECIFIED) {
        myWidth = widthSize;
    }
    if (heightMode != UNSPECIFIED) {
        myHeight = heightSize;
    }
    if (widthMode == EXACTLY) {
        width = myWidth;
    }
    if (heightMode == EXACTLY) {
        height = myHeight;
    }
    
    LGView *ignore = nil;
    int gravity = self.dGravity & RELATIVE_HORIZONTAL_GRAVITY_MASK;
    BOOL horizontalGravity = gravity != GRAVITY_START && gravity != 0;
    gravity = self.dGravity & VERTICAL_GRAVITY_MASK;
    BOOL verticalGravity = gravity != GRAVITY_TOP && gravity != 0;
    
    int left = INT_MAX;
    int top = INT_MAX;
    int right = INT_MAX;
    int bottom = INT_MAX;
    BOOL offsetHorizontalAxis = false;
    BOOL offsetVerticalAxis = false;
    
    if ((horizontalGravity || verticalGravity) && IS_VIEW_NO_ID(self.mIgnoreGravity)) {
        ignore = [self getViewByIdInternal:self.mIgnoreGravity];
    }
    
    BOOL isWrapContentWidth = widthMode != EXACTLY;
    BOOL isWrapContentHeight = heightMode != EXACTLY;
    
    if([LGView isRtl] && myWidth == -1) {
        myWidth = self.DEFAULT_WIDTH;
    }
    
    NSMutableArray *views = self.mSortedHorizontalChildren;
    int count = views.count;
    
    for (int i = 0; i < count; i++) {
        LGView *child = views[i];
        [child readWidthHeight];
        if ([child getVisibility] != GONE) {
            LGRelativeLayoutParams *params = child.rlParams;
            NSMutableArray *rules = [child.rlParams getRules:[LGView isRtl]];
            
            [self applyHorizontalSizeRules:child :myWidth :rules];
            [self measureChildHorizontal:child :myWidth :myHeight];
            if ([self positionChildHorizontal:child :myWidth :isWrapContentWidth]) {
                offsetHorizontalAxis = true;
            }
        }
    }
    
    views = self.mSortedVerticalChildren;
    count = views.count;
    for (int i = 0; i < count; i++) {
        LGView *child = views[i];
        if ([child getVisibility] != GONE) {
            LGRelativeLayoutParams *params = child.rlParams;
            
            [self applyVerticalSizeRules:child :myHeight :child.baseLine];
            [self measureChild:child :myWidth :myHeight];
            if ([self positionChildVertical:child :myHeight :isWrapContentHeight]) {
                offsetVerticalAxis = true;
            }
            if (isWrapContentWidth) {
                if ([LGView isRtl]) {
                    width = MAX(width, myWidth - params.mLeft + child.dMarginLeft);
                } else {
                    width = MAX(width, params.mRight + child.dMarginRight);
                }
            }
            if (isWrapContentHeight) {
                height = MAX(height, params.mBottom + child.dMarginBottom);
            }
            if (child != ignore || verticalGravity) {
                left = MIN(left, params.mLeft - child.dMarginLeft);
                top = MIN(top, params.mTop - child.dMarginTop);
            }
            if (child != ignore || horizontalGravity) {
                right = MAX(right, params.mRight + child.dMarginRight);
                bottom = MAX(bottom, params.mBottom + child.dMarginBottom);
            }
        }
    }
    
    LGView *baselineView = nil;
    for (int i = 0; i < count; i++) {
        LGView *child = views[i];
        if ([child getVisibility] != GONE) {
            if(baselineView == nil || [self compareLayoutPosition:child :baselineView] < 0) {
                baselineView = child;
            }
        }
    }
    self.mBaselineView = baselineView;
    
    if(isWrapContentWidth) {
        width += self.dPaddingRight;
        
        if(self.dWidthDimension >= 0) {
            width = MAX(width, self.dWidthDimension);
        }
        
        width = MAX(width, [self getSuggestedMinimumWidth]);
        width = [LGView resolveSize:width :self.dWidthSpec];
        
        if(offsetHorizontalAxis) {
            for (int i = 0; i < count; i++) {
                LGView *child = views[i];
                if ([child getVisibility] != GONE) {
                    LGRelativeLayoutParams *params = child.rlParams;
                    NSMutableArray *rules = [params getRules:[LGView isRtl]];
                    if (![rules[CENTER_IN_PARENT] isEqualToString:@""]
                        || ![rules[CENTER_HORIZONTAL] isEqualToString:@""]) {
                        [LGRelativeLayout centerHorizontal:child :width];
                    } else if (![rules[ALIGN_PARENT_RIGHT] isEqualToString:@""]) {
                        int childWidth = child.dWidth;
                        child.rlParams.mLeft = width - self.dPaddingRight - childWidth;
                        child.rlParams.mRight = child.rlParams.mLeft + childWidth;
                    }
                }
            }
        }
        
        if(isWrapContentHeight) {
            height += self.dPaddingBottom;
            
            if(self.dHeight > 0) {
                height = MAX(height, self.dHeight);
            }
            
            height = MAX(height, [self getSuggestedMinimumHeight]);
            height = [LGView resolveSize:height :self.dHeightSpec];
            
            if(offsetVerticalAxis) {
                for (int i = 0; i < count; i++) {
                    LGView *child = views[i];
                    if ([child getVisibility] != GONE) {
                        LGRelativeLayoutParams *params = child.rlParams;
                        NSMutableArray *rules = [params getRules:[LGView isRtl]];
                        if (![rules[CENTER_IN_PARENT] isEqualToString:@""]
                            || ![rules[CENTER_VERTICAL] isEqualToString:@""]) {
                            [LGRelativeLayout centerVertical:child :height];
                        } else if (![rules[ALIGN_PARENT_BOTTOM] isEqualToString:@""]) {
                            int childHeight = child.dHeight;
                            child.rlParams.mTop = height - self.dPaddingBottom - childHeight;
                            child.rlParams.mBottom = child.rlParams.mTop + childHeight;
                        }
                    }
                }
            }
        }
        
        if(horizontalGravity || verticalGravity) {
            CGRect selfBounds = CGRectMake(self.dPaddingLeft, self.dPaddingTop, width - self.dPaddingRight, height - self.dPaddingBottom);
            
            CGRect contentBounds = self.mContentBounds;
            LuaRect *selfBoundsRect = [[LuaRect alloc] init];
            [selfBoundsRect setCGRect:selfBounds];
            LuaRect *contentBoundsRect = [Gravity apply:self.gravity :(right - left) :(bottom - top) :selfBoundsRect :[LGView isRtl]];
            contentBounds = [contentBoundsRect getCGRect];
            self.mContentBounds = contentBounds;
            
            int horizontalOffset = CGRECT_LEFT(contentBounds) - left;
            int verticalOffset = CGRECT_TOP(contentBounds) - top;
            if(horizontalOffset != 0 || verticalOffset != 0) {
                for (int i = 0; i < count; i++) {
                    LGView *child = views[i];
                    if ([child getVisibility] != GONE && child != ignore) {
                        if (horizontalGravity) {
                            child.rlParams.mLeft += horizontalOffset;
                            child.rlParams.mRight += horizontalOffset;
                        }
                        if (verticalGravity) {
                            child.rlParams.mTop += verticalOffset;
                            child.rlParams.mBottom += verticalOffset;
                        }
                    }
                }
            }
        }
        
        if([LGView isRtl]) {
            int offsetWidth = myWidth - width;
            for (int i = 0; i < count; i++) {
                LGView *child = views[i];
                if ([child getVisibility] != GONE) {
                    child.rlParams.mLeft -= offsetWidth;
                    child.rlParams.mRight -= offsetWidth;
                }
            }
        }
        
        [self setMeasuredDimension:width :height];
    }
    [self onLayout:true :[self getLeft] :[self getTop] :[self getRight] :[self getBottom]];
}

-(int) compareLayoutPosition:(LGView*)p1 :(LGView*)p2 {
    int topDiff = p1.rlParams.mTop - p2.rlParams.mTop;
    if(topDiff != 0) {
        return topDiff;
    }
    
    return p1.rlParams.mLeft - p2.rlParams.mLeft;
}

-(void)measureChild:(LGView*)child :(int)myWidth :(int)myHeight {
    int childWidthMeasureSpec = [self getChildMeasureSpec:child.rlParams.mLeft
                                 :child.rlParams.mRight :child.dWidthDimension :child.dMarginLeft :child.dMarginRight
            :self.dPaddingLeft :self.dPaddingRight
            :myWidth];
    int childHeightMeasureSpec = [self getChildMeasureSpec:child.rlParams.mTop
            :child.rlParams.mBottom :child.dHeightDimension :child.dMarginTop :child.dMarginBottom :self.dPaddingTop :self.dPaddingBottom :myHeight];
    [child measure:childWidthMeasureSpec :childHeightMeasureSpec];
}

-(void)measureChildHorizontal:(LGView *)child :(int)myWidth :(int)myHeight {
    int childWidthMeasureSpec = [self getChildMeasureSpec:child.rlParams.mLeft :child.rlParams.mRight :child.dWidthDimension :child.dMarginLeft :child.dMarginRight :self.dPaddingLeft :self.dPaddingRight :myWidth];
    
    int childHeightMeasureSpec;
    
    if (myHeight < 0 && !self.mAllowBrokenMeasureSpecs) {
        if (child.dHeightDimension >= 0) {
            childHeightMeasureSpec = [MeasureSpec makeMeasureSpec:child.dHeightDimension :EXACTLY];
        } else {
            // Negative values in a mySize/myWidth/myWidth value in
            // RelativeLayout measurement is code for, "we got an
            // unspecified mode in the RelativeLayout's measure spec."
            // Carry it forward.
            childHeightMeasureSpec = [MeasureSpec makeMeasureSpec:0 :UNSPECIFIED];
        }
    } else {
        int maxHeight;
        if (self.mMeasureVerticalWithPaddingMargin) {
            maxHeight = MAX(0, myHeight - self.dPaddingTop - self.dPaddingBottom
                    - child.dMarginTop - child.dMarginBottom);
        } else {
            maxHeight = MAX(0, myHeight);
        }
        int heightMode;
        if(child.dHeightDimension == MATCH_PARENT) {
            heightMode = EXACTLY;
        }
        else {
            heightMode = AT_MOST;
        }
        childHeightMeasureSpec = [MeasureSpec makeMeasureSpec:maxHeight :heightMode];
    }
    
    [child measure:childWidthMeasureSpec :childHeightMeasureSpec];
}

-(int) getChildMeasureSpec:(int)childStart :(int)childEnd
            :(int)childSize  :(int)startMargin :(int)endMargin :(int)startPadding
            :(int)endPadding :(int)mySize {
    int childSpecMode = 0;
    int childSpecSize = 0;
    // Negative values in a mySize value in RelativeLayout
    // measurement is code for, "we got an unspecified mode in the
    // RelativeLayout's measure spec."
    bool isUnspecified = mySize < 0;
    if (isUnspecified && !self.mAllowBrokenMeasureSpecs) {
        if (childStart != VALUE_NOT_SET && childEnd != VALUE_NOT_SET) {
            // Constraints fixed both edges, so child has an exact size.
            childSpecSize = MAX(0, childEnd - childStart);
            childSpecMode = EXACTLY;
        } else if (childSize >= 0) {
            // The child specified an exact size.
            childSpecSize = childSize;
            childSpecMode = EXACTLY;
        } else {
            // Allow the child to be whatever size it wants.
            childSpecSize = 0;
            childSpecMode = UNSPECIFIED;
        }
        return [MeasureSpec makeMeasureSpec:childSpecSize :childSpecMode];
    }
    // Figure out start and end bounds.
    int tempStart = childStart;
    int tempEnd = childEnd;
    // If the view did not express a layout constraint for an edge, use
    // view's margins and our padding
    if (tempStart == VALUE_NOT_SET) {
        tempStart = startPadding + startMargin;
    }
    if (tempEnd == VALUE_NOT_SET) {
        tempEnd = mySize - endPadding - endMargin;
    }
    // Figure out maximum size available to this view
    int maxAvailable = tempEnd - tempStart;
    if (childStart != VALUE_NOT_SET && childEnd != VALUE_NOT_SET) {
        // Constraints fixed both edges, so child must be an exact size.
        childSpecMode = isUnspecified ? UNSPECIFIED : EXACTLY;
        childSpecSize = MAX(0, maxAvailable);
    } else {
        if (childSize >= 0) {
            // Child wanted an exact size. Give as much as possible.
            childSpecMode = EXACTLY;
            if (maxAvailable >= 0) {
                // We have a maximum size in this dimension.
                childSpecSize = MIN(maxAvailable, childSize);
            } else {
                // We can grow in this dimension.
                childSpecSize = childSize;
            }
        } else if (childSize == MATCH_PARENT) {
            // Child wanted to be as big as possible. Give all available
            // space.
            childSpecMode = isUnspecified ? UNSPECIFIED : EXACTLY;
            childSpecSize = MAX(0, maxAvailable);
        } else if (childSize == WRAP_CONTENT) {
            // Child wants to wrap content. Use AT_MOST to communicate
            // available space if we know our max size.
            if (maxAvailable >= 0) {
                // We have a maximum size in this dimension.
                childSpecMode = AT_MOST;
                childSpecSize = maxAvailable;
            } else {
                // We can grow in this dimension. Child can be as big as it
                // wants.
                childSpecMode = UNSPECIFIED;
                childSpecSize = 0;
            }
        }
    }
    return [MeasureSpec makeMeasureSpec:childSpecSize :childSpecMode];
}

-(BOOL) positionChildHorizontal:(LGView*) child :(int)myWidth
            :(BOOL)wrapContent {
    NSMutableArray *rules = [child.rlParams getRules:[LGView isRtl]];
    if (child.rlParams.mLeft == VALUE_NOT_SET && child.rlParams.mRight != VALUE_NOT_SET) {
        // Right is fixed, but left varies
        child.rlParams.mLeft = child.rlParams.mRight - child.dWidth;
    } else if (child.rlParams.mLeft != VALUE_NOT_SET && child.rlParams.mRight == VALUE_NOT_SET) {
        // Left is fixed, but right varies
        child.rlParams.mRight = child.rlParams.mLeft + child.dWidth;
    } else if (child.rlParams.mLeft == VALUE_NOT_SET && child.rlParams.mRight == VALUE_NOT_SET) {
        // Both left and right vary
        if (![rules[CENTER_IN_PARENT] isEqualToString:@""]
            || ![rules[CENTER_HORIZONTAL] isEqualToString:@""]) {
            if (!wrapContent) {
                [LGRelativeLayout centerHorizontal:child :myWidth];
            } else {
                [self positionAtEdge:child :myWidth];
            }
            return true;
        } else {
            // This is the default case. For RTL we start from the right and for LTR we start
            // from the left. This will give LEFT/TOP for LTR and RIGHT/TOP for RTL.
            [self positionAtEdge:child :myWidth];
        }
    }
    return ![rules[ALIGN_PARENT_END] isEqualToString:@""];
}

-(void)positionAtEdge:(LGView*) child :(int) myWidth {
    if ([LGView isRtl]) {
        child.rlParams.mRight = myWidth - self.dPaddingRight - child.dMarginRight;
        child.rlParams.mLeft = child.rlParams.mRight - child.dWidth;
    } else {
        child.rlParams.mLeft = self.dPaddingLeft + child.dMarginLeft;
        child.rlParams.mRight = child.rlParams.mLeft + child.dWidth;
    }
}

-(bool) positionChildVertical:(LGView*) child :(int)myHeight :(bool) wrapContent {
    NSMutableArray *rules = child.rlParams.rules;
    if (child.rlParams.mTop == VALUE_NOT_SET && child.rlParams.mBottom != VALUE_NOT_SET) {
        // Bottom is fixed, but top varies
        child.rlParams.mTop = child.rlParams.mBottom - child.dHeight;
    } else if (child.rlParams.mTop != VALUE_NOT_SET && child.rlParams.mBottom == VALUE_NOT_SET) {
        // Top is fixed, but bottom varies
        child.rlParams.mBottom = child.rlParams.mTop + child.dHeight;
    } else if (child.rlParams.mTop == VALUE_NOT_SET && child.rlParams.mBottom == VALUE_NOT_SET) {
        // Both top and bottom vary
        if (![rules[CENTER_IN_PARENT] isEqualToString:@""]
            || ![rules[CENTER_VERTICAL] isEqualToString:@""]) {
            if (!wrapContent) {
                [LGRelativeLayout centerVertical:child :myHeight];
            } else {
                child.rlParams.mTop = self.dPaddingTop + child.dMarginTop;
                child.rlParams.mBottom = child.rlParams.mTop + child.dHeight;
            }
            return true;
        } else {
            child.rlParams.mTop = self.dPaddingTop + child.dMarginTop;
            child.rlParams.mBottom = child.rlParams.mTop + child.dHeight;
        }
    }
    return ![rules[ALIGN_PARENT_BOTTOM] isEqualToString:@""];
}

-(void)applyHorizontalSizeRules:(LGView*)child :(int)myWidth :(NSMutableArray*) rules {
    LGRelativeLayoutParams *anchorParams;
    // VALUE_NOT_SET indicates a "soft requirement" in that direction. For example:
    // left=10, right=VALUE_NOT_SET means the view must start at 10, but can go as far as it
    // wants to the right
    // left=VALUE_NOT_SET, right=10 means the view must end at 10, but can go as far as it
    // wants to the left
    // left=10, right=20 means the left and right ends are both fixed
    child.rlParams.mLeft = VALUE_NOT_SET;
    child.rlParams.mRight = VALUE_NOT_SET;
    LGView *anchor = [self getRelatedView:rules :LEFT_OF];
    anchorParams = anchor.rlParams;
    if (anchorParams != nil) {
        child.rlParams.mRight = anchorParams.mLeft - (anchor.dMarginLeft + child.dMarginRight);
    } else if (child.rlParams.alignWithParent && ![rules[LEFT_OF] isEqualToString:@""]) {
        if (myWidth >= 0) {
            child.rlParams.mRight = myWidth - self.dPaddingRight - child.dMarginRight;
        }
    }
    anchor = [self getRelatedView:rules :RIGHT_OF];
    anchorParams = anchor.rlParams;
    if (anchorParams != nil) {
        child.rlParams.mLeft = anchorParams.mRight + (anchor.dMarginRight + child.dMarginLeft);
    } else if (child.rlParams.alignWithParent && ![rules[RIGHT_OF] isEqualToString:@""]) {
        child.rlParams.mLeft = self.dPaddingLeft + child.dMarginLeft;
    }
    anchor = [self getRelatedView:rules :ALIGN_LEFT];
    anchorParams = anchor.rlParams;
    if (anchorParams != nil) {
        child.rlParams.mLeft = anchorParams.mLeft + child.dMarginLeft;
    } else if (child.rlParams.alignWithParent && ![rules[ALIGN_LEFT] isEqualToString:@""]) {
        child.rlParams.mLeft = self.dPaddingLeft + child.dMarginLeft;
    }
    anchor = [self getRelatedView:rules :ALIGN_RIGHT];
    anchorParams = anchor.rlParams;
    if (anchorParams != nil) {
        child.rlParams.mRight = anchorParams.mRight - child.dMarginRight;
    } else if (child.rlParams.alignWithParent && ![rules[ALIGN_RIGHT] isEqualToString:@""]) {
        if (myWidth >= 0) {
            child.rlParams.mRight = myWidth - self.dPaddingRight - child.dMarginRight;
        }
    }
    if (![rules[ALIGN_PARENT_LEFT] isEqualToString:@""]) {
        child.rlParams.mLeft = self.dPaddingLeft + child.dMarginLeft;
    }
    if (![rules[ALIGN_PARENT_RIGHT] isEqualToString:@""]) {
        if (myWidth >= 0) {
            child.rlParams.mRight = myWidth - self.dPaddingRight - child.dMarginRight;
        }
    }
}

-(void) applyVerticalSizeRules:(LGView*) child :(int)myHeight :(int)myBaseline {
    NSMutableArray *rules = child.rlParams.rules;
    // Baseline alignment overrides any explicitly specified top or bottom.
    int baselineOffset = [self getRelatedViewBaselineOffset:rules];
    if (baselineOffset != -1) {
        if (myBaseline != -1) {
            baselineOffset -= myBaseline;
        }
        child.rlParams.mTop = baselineOffset;
        child.rlParams.mBottom = VALUE_NOT_SET;
        return;
    }
    LGRelativeLayoutParams *anchorParams;
    child.rlParams.mTop = VALUE_NOT_SET;
    child.rlParams.mBottom = VALUE_NOT_SET;
    LGView *anchor = [self getRelatedView:rules :ABOVE];
    anchorParams = anchor.rlParams;
    if (anchorParams != nil) {
        child.rlParams.mBottom = anchorParams.mTop - (anchor.dMarginTop +
                child.dMarginBottom);
    } else if (child.rlParams.alignWithParent && ![rules[ABOVE] isEqualToString:@""]) {
        if (myHeight >= 0) {
            child.rlParams.mBottom = myHeight - self.dPaddingBottom - child.dMarginBottom;
        }
    }
    anchor = [self getRelatedView:rules :BELOW];
    anchorParams = anchor.rlParams;
    if (anchorParams != nil) {
        child.rlParams.mTop = anchorParams.mBottom + (anchor.dMarginBottom +
                child.dMarginTop);
    } else if (child.rlParams.alignWithParent && ![rules[BELOW] isEqualToString:@""]) {
        child.rlParams.mTop = self.dPaddingTop + child.dMarginTop;
    }
    anchor = [self getRelatedView:rules :ALIGN_TOP];
    anchorParams = anchor.rlParams;
    if (anchorParams != nil) {
        child.rlParams.mTop = anchorParams.mTop + child.dMarginTop;
    } else if (child.rlParams.alignWithParent && ![rules[ALIGN_TOP] isEqualToString:@""]) {
        child.rlParams.mTop = self.dPaddingTop + child.dMarginTop;
    }
    anchor = [self getRelatedView:rules :ALIGN_BOTTOM];
    anchorParams = anchor.rlParams;
    if (anchorParams != nil) {
        child.rlParams.mBottom = anchorParams.mBottom - child.dMarginBottom;
    } else if (child.rlParams.alignWithParent && ![rules[ALIGN_BOTTOM] isEqualToString:@""]) {
        if (myHeight >= 0) {
            child.rlParams.mBottom = myHeight - self.dPaddingBottom - child.dMarginBottom;
        }
    }
    if (![rules[ALIGN_PARENT_TOP] isEqualToString:@""]) {
        child.rlParams.mTop = self.dPaddingTop + child.dMarginTop;
    }
    if (![rules[ALIGN_PARENT_BOTTOM] isEqualToString:@""]) {
        if (myHeight >= 0) {
            child.rlParams.mBottom = myHeight - self.dPaddingBottom - child.dMarginBottom;
        }
    }
}

-(LGView*) getRelatedView:(NSMutableArray*)rules :(int)relation {
    NSString *idVal = rules[relation];
    if (!IS_VIEW_NO_ID(idVal)) {
        RLNode *node = [self.mGraph.mKeyNodes objectForKey:idVal];
        if (node == nil) return nil;
        LGView *v = node.view;
        // Find the first non-GONE view up the chain
        while ([v getVisibility] == GONE) {
            rules = [v.rlParams getRules:[LGView isRtl]];
            node = [self.mGraph.mKeyNodes objectForKey:rules[relation]];
            if (node == nil || v == node.view) return nil;
            v = node.view;
        }
        return v;
    }
    return nil;
}

-(int) getRelatedViewBaselineOffset:(NSMutableArray*) rules {
    LGView *v = [self getRelatedView:rules :ALIGN_BASELINE];
    if (v != nil) {
        int baseline = v.baseLine;
        if (baseline != -1) {
            if(v.rlParams != nil) {
                return v.rlParams.mTop + baseline;
            }
        }
    }
    return -1;
}

+(void)centerHorizontal:(LGView*) child :(int)myWidth {
    int childWidth = child.dWidth;
    int left = (myWidth - childWidth) / 2;
    child.rlParams.mLeft = left;
    child.rlParams.mRight = left + childWidth;
}

+(void)centerVertical:(LGView*) child :(int)myHeight {
    int childHeight = child.dHeight;
    int top = (myHeight - childHeight) / 2;
    child.rlParams.mTop = top;
    child.rlParams.mBottom = top + childHeight;
}

-(void)onLayout:(bool)changed :(int) l :(int) t :(int) r :(int) b {
    //  The layout has actually already been performed and the positions
    //  cached.  Apply the cached values to the children.
    int count = self.subviews.count;
    for (int i = 0; i < count; i++) {
        LGView *child = self.subviews[i];
        if ([child getVisibility] != GONE) {
            [child layout:child.rlParams.mLeft :child.rlParams.mTop :child.rlParams.mRight :child.rlParams.mBottom];
        }
    }
}

-(void)createLayoutParams:(LGView*)child {
    child.rlParams = [LGRelativeLayoutParams new];
    if(child.android_layout_alignWithParentIfMissing != nil) {
        NSString *alignWithParentIfMissing = (NSString*)[[LGValueParser getInstance] getValue:child.android_layout_alignWithParentIfMissing];
        child.rlParams.alignWithParent = SSTOB(alignWithParentIfMissing);
    }
    if(child.android_layout_toLeftOf != nil) {
        child.rlParams.rules[LEFT_OF] = [[LGValueParser getInstance] getValue:child.android_layout_toLeftOf];
    }
    if(child.android_layout_toRightOf != nil) {
        child.rlParams.rules[RIGHT_OF] = [[LGValueParser getInstance] getValue:child.android_layout_toRightOf];
    }
    if(child.android_layout_above != nil) {
        child.rlParams.rules[ABOVE] = [[LGValueParser getInstance] getValue:child.android_layout_above];
    }
    if(child.android_layout_below != nil) {
        child.rlParams.rules[BELOW] = [[LGValueParser getInstance] getValue:child.android_layout_below];
    }
    if(child.android_layout_alignBaseline != nil) {
        child.rlParams.rules[ALIGN_BASELINE] = [[LGValueParser getInstance] getValue:child.android_layout_alignBaseline];
    }
    if(child.android_layout_alignLeft != nil) {
        child.rlParams.rules[ALIGN_LEFT] = [[LGValueParser getInstance] getValue:child.android_layout_alignLeft];
    }
    if(child.android_layout_alignTop != nil) {
        child.rlParams.rules[ALIGN_TOP] = [[LGValueParser getInstance] getValue:child.android_layout_alignTop];
    }
    if(child.android_layout_alignRight != nil) {
        child.rlParams.rules[ALIGN_RIGHT] = [[LGValueParser getInstance] getValue:child.android_layout_alignRight];
    }
    if(child.android_layout_alignBottom != nil) {
        child.rlParams.rules[ALIGN_BOTTOM] = [[LGValueParser getInstance] getValue:child.android_layout_alignBottom];
    }
    if(child.android_layout_alignParentLeft != nil) {
        NSString *val = (NSString*)[[LGValueParser getInstance] getValue:child.android_layout_alignParentLeft];
        child.rlParams.rules[ALIGN_PARENT_LEFT] = SSTOB(val) ? STRUE : @"";
    }
    if(child.android_layout_alignParentTop != nil) {
        NSString *val = (NSString*)[[LGValueParser getInstance] getValue:child.android_layout_alignParentTop];
        child.rlParams.rules[ALIGN_PARENT_TOP] = SSTOB(val) ? STRUE : @"";
    }
    if(child.android_layout_alignParentRight != nil) {
        NSString *val = (NSString*)[[LGValueParser getInstance] getValue:child.android_layout_alignParentRight];
        child.rlParams.rules[ALIGN_PARENT_RIGHT] = SSTOB(val) ? STRUE : @"";
    }
    if(child.android_layout_alignParentBottom != nil) {
        NSString *val = (NSString*)[[LGValueParser getInstance] getValue:child.android_layout_alignParentBottom];
        child.rlParams.rules[ALIGN_PARENT_BOTTOM] = SSTOB(val) ? STRUE : @"";
    }
    if(child.android_layout_centerInParent != nil) {
        NSString *val = (NSString*)[[LGValueParser getInstance] getValue:child.android_layout_centerInParent];
        child.rlParams.rules[CENTER_IN_PARENT] = SSTOB(val) ? STRUE : @"";
    }
    if(child.android_layout_centerHorizontal != nil) {
        NSString *val = (NSString*)[[LGValueParser getInstance] getValue:child.android_layout_centerHorizontal];
        child.rlParams.rules[CENTER_HORIZONTAL] = SSTOB(val) ? STRUE : @"";
    }
    if(child.android_layout_centerVertical != nil) {
        NSString *val = (NSString*)[[LGValueParser getInstance] getValue:child.android_layout_centerVertical];
        child.rlParams.rules[CENTER_VERTICAL] = SSTOB(val) ? STRUE : @"";
    }
    if(child.android_layout_toStartOf != nil) {
        child.rlParams.rules[ALIGN_BOTTOM] = [[LGValueParser getInstance] getValue:child.android_layout_toStartOf];
    }
    if(child.android_layout_toEndOf != nil) {
        child.rlParams.rules[END_OF] = [[LGValueParser getInstance] getValue:child.android_layout_toEndOf];
    }
    if(child.android_layout_alignStart != nil) {
        child.rlParams.rules[ALIGN_START] = [[LGValueParser getInstance] getValue:child.android_layout_alignStart];
    }
    if(child.android_layout_alignEnd != nil) {
        child.rlParams.rules[ALIGN_END] = [[LGValueParser getInstance] getValue:child.android_layout_alignEnd];
    }
    if(child.android_layout_alignParentStart != nil) {
        NSString *val = (NSString*)[[LGValueParser getInstance] getValue:child.android_layout_alignParentStart];
        child.rlParams.rules[ALIGN_PARENT_START] = SSTOB(val) ? STRUE : @"";
    }
    if(child.android_layout_alignParentEnd != nil) {
        NSString *val = (NSString*)[[LGValueParser getInstance] getValue:child.android_layout_alignParentEnd];
        child.rlParams.rules[ALIGN_PARENT_END] = SSTOB(val) ? STRUE : @"";
    }
    child.rlParams.mRulesChanged = true;
    child.rlParams.initialRules = [[NSMutableArray alloc] initWithArray:child.rlParams.rules copyItems:true];
}

-(void)addSubview:(LGView *)val {
    self.mDirtyHierarchy = true;
    [self createLayoutParams:val];
    [super addSubview:val];
}

- (void)addSubview:(LGView *)val :(NSInteger)index {
    self.mDirtyHierarchy = true;
    [self createLayoutParams:val];
    [super addSubview:val :index];
}

-(void)removeSubview:(LGView *)val {
    self.mDirtyHierarchy = true;
    [super removeSubview:val];
}

- (void)removeAllSubViews {
    self.mDirtyHierarchy = true;
    [super removeAllSubViews];
}

-(NSString*)GetId
{
    if(self.lua_id != nil)
        return self.lua_id;
    if(self.android_id != nil)
        return self.android_id;
    return [LGRelativeLayout className];
}

+ (NSString*)className
{
    return @"LGRelativeLayout";
}

+(NSMutableDictionary*)luaMethods
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(create:))
                                        :@selector(create:)
                                        :[LGRelativeLayout class]
                                        :[NSArray arrayWithObjects:[LuaContext class], [NSString class], nil]
                                        :[LGRelativeLayout class]]
             forKey:@"create"];
    return dict;
}

@end
