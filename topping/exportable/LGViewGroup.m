#import "LGViewGroup.h"
#import "Defines.h"
#import "LuaFunction.h"
#import "LGValueParser.h"

@implementation TouchTarget

+(TouchTarget *)obtain:(LGView *)child :(int)pointerIdBits {
    if(child == nil)
        @throw [NSException new];
    
    TouchTarget *target = [TouchTarget new];
    target.child = child;
    target.pointerIdBits = pointerIdBits;
    
    return target;
}

@end

@implementation LGViewGroup

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.childTransformation = [Transformation new];
    }
    return self;
}

- (void)initProperties
{
    [super initProperties];
    
    self.subviews = [NSMutableArray array];
    self.subviewMap = [NSMutableDictionary dictionary];
}

-(void)addSubview:(LGView*)val
{
    if(val != nil)
    {
        val.parent = self;
        [self.subviews addObject:val];
        if(val.android_id != nil || val.lua_id != nil)
            [self.subviewMap setObject:val forKey:[val GetId]];
        
        [self callTMethod:@"onViewAdded" :nil :val, nil];
        [val resolveLayoutDirection];
        if([self isAttachedToWindow]) {
            [val onAttachedToWindow];
        }
    }
}

-(void)addSubview:(LGView*)val :(NSInteger)index
{
    if(index == -1) {
        [self addSubview:val];
        return;
    }
    if(val != nil)
    {
        val.parent = self;
        [self.subviews insertObject:val atIndex:index];
        if(val.android_id != nil || val.lua_id != nil)
            [self.subviewMap setObject:val forKey:[val GetId]];
        
        [self callTMethod:@"onViewAdded" :nil :val, nil];
        [val resolveLayoutDirection];
        if([self isAttachedToWindow]) {
            [val onAttachedToWindow];
        }
    }
}

-(void)removeSubview:(LGView*)val
{
    if(val != nil)
    {
        [self.subviews removeObject:val];
        if(val.android_id != nil || val.lua_id != nil)
            [self.subviewMap removeObjectForKey:[val GetId]];
        [val._view removeFromSuperview];
        val.parent = nil;
        [self resize];
        [self callTMethod:@"onViewRemoved" :nil :val, nil];
        [val onDetachedFromWindow];
    }
}

-(void)removeAllSubViews {
    for(LGView *subview in self.subviews)
    {
        [self removeSubview:subview];
        [self callTMethod:@"onViewRemoved" :nil :subview, nil];
        [subview callTMethod:@"onDetachedFromWindow" :nil :nil];
    }
    [self resizeAndInvalidate];
}

-(void)clearDimensions
{
    [super clearDimensions];
    for(LGView *w in self.subviews)
        [w clearDimensions];
}

-(LGView *)getViewById:(LuaRef*)lId
{
    NSString *sId = (NSString*)[[LGValueParser getInstance] getValue: lId.idRef];
    return [self getViewByIdInternal:sId];
}

-(LGView *)getViewByIdInternal:(NSString *)sId
{
    if([[self GetId] compare:sId] == 0)
       return self;
    else
    {
        for(LGView *v in self.subviews)
        {
            LGView *a = [v getViewByIdInternal:sId];
            if(a != nil)
                return a;
        }
    }
    return nil;
}

-(void)resize
{
    [super resize];
    for(LGView *w in self.subviews)
        [w resizeAndInvalidate];
    [super resize];
}

/*-(void)readWidthHeight {
    [super readWidthHeight];
    for(LGView *subView in self.subviews) {
        [subView readWidthHeight];
    }
    [super readWidthHeight];
}*/

-(void)onMeasure:(int)widthMeasureSpec :(int)heightMeasureSpec {
    [super onMeasure:widthMeasureSpec :heightMeasureSpec];
    for(LGView *subView in self.subviews) {
        [subView readWidthHeight];
        [subView onMeasure:widthMeasureSpec :heightMeasureSpec];
    }
}

//getRootMeasureSpec(int windowSize, int measurement, int privateFlags) {
-(int)getParentWidthSpec
{
    int widthSpec = 0;
    if(self.parent != nil) {
        widthSpec = self.parent.dWidthSpec;
    } else {
        return [MeasureSpec makeMeasureSpec:self.lc.form.view.frame.size.width :EXACTLY];
    }
    return widthSpec;
}

//getRootMeasureSpec(int windowSize, int measurement, int privateFlags) {
-(int)getParentHeightSpec
{
    int heightSpec = 0;
    if(self.parent != nil) {
        heightSpec = self.parent.dHeightSpec;
    } else {
        return [MeasureSpec makeMeasureSpec:self.lc.form.view.frame.size.height :EXACTLY];
    }
    return heightSpec;
}

-(float)findParentMatchParentWidth:(LGView*)view {
    if(view.parent != nil) {
        if(view.parent.dWidth != 0)
            return view.parent.dWidth;
        else
            return [self findParentMatchParentWidth:view.parent];
    }
    else
        return view.lc.form.view.frame.size.width;
}

-(int)getContentW
{
    if ([self.subviews count] > 0) {
        int maxX = 0;
        for (LGView *v in self.subviews)
        {
            [v readWidthHeight];
            int width_w_margin = 0;
            if(v.dVisibility == GONE) {
                width_w_margin = 0;
            }
            else if([v isKindOfClass:[LGViewGroup class]])
                width_w_margin = [v getContentW];
            else if(v.dWidthDimension == WRAP_CONTENT)
                width_w_margin = [v getContentW] + v.dMarginLeft + v.dMarginRight;
            else {
                if(v.dWidth == 0
                   && ([v.android_layout_width compare:@"fill_parent"] == 0 ||
                       [v.android_layout_width compare:@"match_parent"] == 0)) {
                    v.dWidth = [self findParentMatchParentWidth:v];
                }
                width_w_margin = v.dWidth + v.dMarginLeft + v.dMarginRight;
            }
            width_w_margin += self.dPaddingLeft + self.dPaddingRight;
            if (v.dX + width_w_margin > maxX)
                maxX = v.dX + width_w_margin;
        }
        return maxX;
    }
    else
        return 0;
}

-(int)getContentH
{
    if ([self.subviews count] > 0) {
        int maxY = 0;
        for (LGView *v in self.subviews)
        {
            [v readWidthHeight];
            int height_w_margin = 0;
            if(v.dVisibility == GONE) {
                height_w_margin = 0;
            }
            else if([v isKindOfClass:[LGViewGroup class]])
                height_w_margin = [v getContentH];
            else if(v.dHeightDimension == WRAP_CONTENT)
                height_w_margin = [v getContentH] + v.dMarginTop + v.dMarginBottom;
            else
                height_w_margin = v.dHeight + v.dMarginTop + v.dMarginBottom;
            if (v.dY + height_w_margin > maxY)
                maxY = v.dY + height_w_margin;
        }
        return maxY;
    }
    else
        return 0;
}

-(void)reduceWidth:(int)share
{
    for(LGView *w in self.subviews)
    {
        [w reduceWidth:share];
    }
    [super reduceWidth:share];
}

-(void)reduceHeight:(int)share
{
    for(LGView *w in [self subviews])
    {
        [w reduceHeight:share];
    }
    [super reduceHeight:share];
}

-(void)configChange
{
    for(LGView *w in [self subviews])
    {
        [w configChange];
    }
    [super configChange];
}

-(void)measureChildren:(int)widthMeasureSpec :(int)heightMeasureSpec {
    int size = self.subviews.count;
    NSMutableArray *children = self.subviews;
    for (int i = 0; i < size; ++i) {
        LGView *child = [children objectAtIndex:i];
        if(child.dVisibility != GONE) {
            [self measureChild:child :widthMeasureSpec :heightMeasureSpec];
        }
    }
}

-(void)measureChild:(LGView*)child :(int)parentWidthMeasureSpec :(int)parentHeightMeasureSpec
{
    int childWidthMeasureSpec = [LGViewGroup getChildMeasureSpec:parentWidthMeasureSpec :self.dPaddingLeft + self.dPaddingRight :self.dWidthDimension];
    int childHeightMeasureSpec = [LGViewGroup getChildMeasureSpec:parentHeightMeasureSpec
                                                          :self.dPaddingTop + self.dPaddingBottom  :self.dHeightDimension];
    [child measure:childWidthMeasureSpec :childHeightMeasureSpec];
}
    
-(void)measureChildWithMargins:(LGView*)child :(int)parentWidthMeasureSpec :(int)widthUsed :(int)parentHeightMeasureSpec :(int)heightUsed {
    int childWidthMeasureSpec = [LGViewGroup getChildMeasureSpec:parentWidthMeasureSpec
                                                         :self.dPaddingLeft + self.dPaddingRight + child.dMarginLeft + child.dMarginRight
                                 + widthUsed :child.dWidthDimension];
    int childHeightMeasureSpec = [LGViewGroup getChildMeasureSpec:parentHeightMeasureSpec :self.dPaddingTop + self.dPaddingBottom + child.dMarginTop + child.dMarginBottom
                                  + heightUsed :child.dHeightDimension];
    [child measure:childWidthMeasureSpec :childHeightMeasureSpec];
}
    
+(int)getChildMeasureSpec:(int)spec :(int)padding :(int)childDimension {
    int specMode = [MeasureSpec getMode:spec];
    int specSize = [MeasureSpec getSize:spec];
    int size = MAX(0, specSize - padding);
    int resultSize = 0;
    int resultMode = 0;
    switch (specMode) {
    // Parent has imposed an exact size on us
    case EXACTLY:
        if (childDimension >= 0) {
            resultSize = childDimension;
            resultMode = EXACTLY;
        } else if (childDimension == MATCH_PARENT) {
            // Child wants to be our size. So be it.
            resultSize = size;
            resultMode = EXACTLY;
        } else if (childDimension == WRAP_CONTENT) {
            // Child wants to determine its own size. It can't be
            // bigger than us.
            resultSize = size;
            resultMode = AT_MOST;
        }
        break;
    // Parent has imposed a maximum size on us
    case AT_MOST:
        if (childDimension >= 0) {
            // Child wants a specific size... so be it
            resultSize = childDimension;
            resultMode = EXACTLY;
        } else if (childDimension == MATCH_PARENT) {
            // Child wants to be our size, but our size is not fixed.
            // Constrain child to not be bigger than us.
            resultSize = size;
            resultMode = AT_MOST;
        } else if (childDimension == WRAP_CONTENT) {
            // Child wants to determine its own size. It can't be
            // bigger than us.
            resultSize = size;
            resultMode = AT_MOST;
        }
        break;
    // Parent asked to see how big we want to be
    case UNSPECIFIED:
        if (childDimension >= 0) {
            // Child wants a specific size... let them have it
            resultSize = childDimension;
            resultMode = EXACTLY;
        } else if (childDimension == MATCH_PARENT) {
            // Child wants to be our size... find out how big it should
            // be
            resultSize = 0;//View.sUseZeroUnspecifiedMeasureSpec ? 0 : size;
            resultMode = UNSPECIFIED;
        } else if (childDimension == WRAP_CONTENT) {
            // Child wants to determine its own size.... find out how
            // big it should be
            resultSize = 0;//View.sUseZeroUnspecifiedMeasureSpec ? 0 : size;
            resultMode = UNSPECIFIED;
        }
        break;
    }
    //noinspection ResourceType
    return [MeasureSpec makeMeasureSpec:resultSize :resultMode];
}

-(NSString *)debugDescription:(NSString *)val
{
    NSString *retVal = [super debugDescription:val];
    NSString *valValue = val;
    for(LGView *w in self.subviews)
    {
        retVal = FUAPPEND(retVal, [w debugDescription:APPEND(valValue, @"--")], NULL);
    }
    
    return retVal;
}

-(NSMutableDictionary *)onSaveInstanceState {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    for(LGView *w in self.subviews)
    {
        [dict addEntriesFromDictionary:[w onSaveInstanceState]];
    }
    
    return dict;
}

-(void)viewDidLayoutSubviews {
    for(LGView *w in self.subviews)
    {
        [w viewDidLayoutSubviews];
    }
}

-(BOOL)getChildStaticTransformation:(LGView *)child :(Transformation *)t {
    return false;
}

-(void)resetTouchState {
    [self clearTouchTargets];
    [LGViewGroup resetCancelNextUpFlag:self];
}

+(BOOL)resetCancelNextUpFlag:(LGView*)view {
    return false;
}

-(void)clearTouchTargets {
    TouchTarget *target = self.mFirstTouchTarget;
    if(target != nil) {
        do {
            TouchTarget *next = target.next;
            target = nil;
        } while(target != nil);
        self.mFirstTouchTarget = nil;
    }
}

-(void)cancelAndClearTouchTargets:(TIOSKHMotionEvent *)event {
    if(self.mFirstTouchTarget != nil) {
        BOOL syntheticEvent = false;
        if(event == nil) {
            long now = [[NSDate new] timeIntervalSince1970] * 1000;
            event = [[TIOSKHMotionEvent companion] obtainDownTime:now eventTime:now action:TIOSKHMotionEvent.companion.ACTION_CANCEL x:0 y:0 metaState:0];
            event.source = TIOSKHAINPUT_SOURCE.ainputSourceTouchscreen.value;
            syntheticEvent = true;
        }
        
        for(TouchTarget *target = self.mFirstTouchTarget; target != nil; target = target.next) {
            [LGViewGroup resetCancelNextUpFlag:target.child];
            [self dispatchTransformedTouchEvent:event :true :target.child :target.pointerIdBits];
        }
        [self clearTouchTargets];
    }
}

-(TouchTarget*)getTouchTarget:(LGView*)child {
    for(TouchTarget *target = self.mFirstTouchTarget; target != nil; target = target.next) {
        if(target.child == child) {
            return target;
        }
    }
    return nil;
}

-(TouchTarget*)addTouchTarget:(LGView*)child :(int)pointerIdBits {
    TouchTarget *target = [TouchTarget obtain:child :pointerIdBits];
    target.next = self.mFirstTouchTarget;
    self.mFirstTouchTarget = target;
    return target;
}

-(void)removePointersFromTouchTargets:(int)pointerIdBits {
    TouchTarget *predecessor = nil;
    TouchTarget *target = self.mFirstTouchTarget;
    while (target != nil) {
        TouchTarget *next = target.next;
        if((target.pointerIdBits & pointerIdBits) != 0) {
            target.pointerIdBits &= ~pointerIdBits;
            if(target.pointerIdBits == 0) {
                if(predecessor == nil) {
                    self.mFirstTouchTarget = next;
                } else {
                    predecessor.next = next;
                }
                target = next;
                continue;
            }
        }
        predecessor = target;
        target = next;
    }
}

-(void)cancelTouchTarget:(LGView*) view {
    TouchTarget *predecessor = nil;
    TouchTarget *target = self.mFirstTouchTarget;
    while (target != nil) {
        TouchTarget *next = target.next;
        if (target.child == view) {
            if (predecessor == nil) {
                self.mFirstTouchTarget = next;
            } else {
                predecessor.next = next;
            }
            long now = [[NSDate new] timeIntervalSince1970] * 1000;
            TIOSKHMotionEvent *event = [TIOSKHMotionEvent.companion obtainDownTime:now eventTime:now action:TIOSKHMotionEvent.companion.ACTION_CANCEL x:0 y:0 metaState:0];
            event.source = TIOSKHAINPUT_SOURCE.ainputSourceTouchscreen.value;
            [view dispatchTouchEvent:event];
            return;
        }
        predecessor = target;
        target = next;
    }
}

-(BOOL)dispatchTransformedTouchEvent:(TIOSKHMotionEvent*)event :(BOOL)cancel :(LGView*) child :(int)desiredPointerIdBits {
    BOOL handled = false;
    
    int oldAction = event.action;
    if (cancel || oldAction == TIOSKHMotionEvent.companion.ACTION_CANCEL) {
        event.action = TIOSKHMotionEvent.companion.ACTION_CANCEL;
        if (child == nil) {
            handled = [super dispatchTouchEvent:event];
        } else {
            handled = [child dispatchTouchEvent:event];
        }
        event.action = oldAction;
        return handled;
    }
    // Calculate the number of pointers to deliver.
    int oldPointerIdBits = event.pointerIdBits;
    int newPointerIdBits = oldPointerIdBits & desiredPointerIdBits;
    // If for some reason we ended up in an inconsistent state where it looks like we
    // might produce a motion event with no pointers in it, then drop the event.
    if (newPointerIdBits == 0) {
        return false;
    }
    // If the number of pointers is the same and we don't need to perform any fancy
    // irreversible transformations, then we can reuse the motion event for this
    // dispatch as long as we are careful to revert any changes we make.
    // Otherwise we need to make a copy.
    TIOSKHMotionEvent *transformedEvent;
    if (newPointerIdBits == oldPointerIdBits) {
        //TODO?
        /*if (child == nil || child.hasIdentityMatrix()) {
            if (child == nil) {
                handled = super.dispatchTouchEvent(event);
            } else {
                final float offsetX = mScrollX - child.mLeft;
                final float offsetY = mScrollY - child.mTop;
                event.offsetLocation(offsetX, offsetY);
                handled = child.dispatchTouchEvent(event);
                event.offsetLocation(-offsetX, -offsetY);
            }
            return handled;
        }*/
        if(child == nil) {
            handled = [super dispatchTouchEvent:event];
            return handled;
        }
        transformedEvent = [TIOSKHMotionEvent.companion obtainOther:event];
    }
    else {
        transformedEvent = [event splitIdBits:newPointerIdBits];
    }
    // Perform any necessary transformations and dispatch.
    if (child == nil) {
        handled = [super dispatchTouchEvent:transformedEvent];
    } else {
        float offsetX = self.mScrollX - child.getMLeft;
        float offsetY = self.mScrollY - child.getMTop;
        [transformedEvent offsetLocationDeltaX:offsetX deltaY:offsetY];
        /*if (! child.hasIdentityMatrix()) {
            transformedEvent.transform(child.getInverseMatrix());
        }*/
        handled = [child dispatchTouchEvent:transformedEvent];
    }
    return handled;
}

-(NSMutableArray*)buildOrderedChildList {
    return nil;
    //return self.subviews;
}

-(NSMutableArray*)buildTouchDispatchChildList {
    return [self buildOrderedChildList];
}

-(BOOL)dispatchTouchEvent:(TIOSKHMotionEvent *)event {
    BOOL handled = false;
    int action = event.action;
    int actionMasked = action & TIOSKHMotionEvent.companion.ACTION_MASK;
    
    if(actionMasked == TIOSKHMotionEvent.companion.ACTION_DOWN) {
        [self cancelAndClearTouchTargets:event];
        [self resetTouchState];
    }
    
    BOOL intercepted;
    if(actionMasked == TIOSKHMotionEvent.companion.ACTION_DOWN
       && self.mFirstTouchTarget != nil) {
        BOOL disallowIntercept = (self.mGroupFlags & GROUP_FLAG_DISALLOW_INTERCEPT) != 0;
        intercepted = [self onInterceptTouchEvent:event];
        event.action = action;
    } else {
        intercepted = true;
    }
    
    BOOL cancelled = [LGViewGroup resetCancelNextUpFlag:self] || actionMasked == TIOSKHMotionEvent.companion.ACTION_CANCEL;
    
    BOOL isMouseEvent = event.source == TIOSKHAINPUT_SOURCE.ainputSourceMouse.value;
    BOOL split = (self.mGroupFlags & GROUP_FLAG_SPLIT_MOTION_EVENTS) != 0 && !isMouseEvent;
    
    TouchTarget *newTouchTarget;
    BOOL alreadyDispatchedToNewTouchTarget = false;
    if(!cancelled && !intercepted) {
        if(actionMasked == TIOSKHMotionEvent.companion.ACTION_DOWN
           || (split && actionMasked == TIOSKHMotionEvent.companion.ACTION_POINTER_DOWN)
           || actionMasked == TIOSKHMotionEvent.companion.ACTION_HOVER_MOVE)
        {
            int actionIndex = event.actionIndex;
            int idBitsToAssign = split ? 1 << [event getPointerIdPointerIndex:actionIndex] : -1;
            
            [self removePointersFromTouchTargets:idBitsToAssign];
            
            int childCount = self.subviews.count;
            if(newTouchTarget == nil && childCount != 0) {
                float x = [event getX];
                float y = [event getY];
                NSMutableArray *preorderedList = [self buildTouchDispatchChildList];
                for(int i = 0; i < childCount; i++) {
                    int childIndex = i; //[self getAndVerifyPreorderIndex]
                    LGView *child = self.subviews[i];
                    newTouchTarget = [self getTouchTarget:child];
                    if(newTouchTarget != nil) {
                        newTouchTarget.pointerIdBits |= idBitsToAssign;
                        break;
                    }
                    
                    [LGViewGroup resetCancelNextUpFlag:child];
                    if([self dispatchTransformedTouchEvent:event :false :child :idBitsToAssign]) {
                        self.mLastTouchDownTime = event.downTime;
                        if(preorderedList != nil) {
                            /*for(int j = 0; j < childCount; j++) {
                                if(self.subviews[j] != )
                            }*/
                        } else {
                            self.mLastTouchDownIndex = childIndex;
                        }
                        self.mLastTouchDownX = x;
                        self.mLastTouchDownY = y;
                        newTouchTarget = [self addTouchTarget:child :idBitsToAssign];
                        alreadyDispatchedToNewTouchTarget = true;
                        break;
                    }
                    
                    if(preorderedList != nil) [preorderedList removeAllObjects];
                }
                
                if(newTouchTarget == nil && self.mFirstTouchTarget != nil) {
                    newTouchTarget = self.mFirstTouchTarget;
                    while (newTouchTarget.next != nil) {
                        newTouchTarget = newTouchTarget.next;
                    }
                    newTouchTarget.pointerIdBits |= idBitsToAssign;
                }
            }
        }
        
        if(self.mFirstTouchTarget == nil) {
            handled = [self dispatchTransformedTouchEvent:event :cancelled :nil :-1];
        } else {
            TouchTarget *predecessor = nil;
            TouchTarget *target = self.mFirstTouchTarget;
            while (target != nil) {
                TouchTarget *next = target.next;
                if(alreadyDispatchedToNewTouchTarget && target == newTouchTarget) {
                    handled = true;
                } else {
                    BOOL cancelChild = [LGViewGroup resetCancelNextUpFlag:target.child] || intercepted;
                    if([self dispatchTransformedTouchEvent:event :cancelChild :target.child :target.pointerIdBits]) {
                        handled = true;
                    }
                    if(cancelChild) {
                        if(predecessor == nil) {
                            self.mFirstTouchTarget = next;
                        } else {
                            predecessor.next = next;
                        }
                        //target.recycle
                        target = next;
                        continue;
                    }
                }
                predecessor = target;
                target = next;
            }
        }
        
        if(cancelled
           || actionMasked == TIOSKHMotionEvent.companion.ACTION_UP
           || actionMasked == TIOSKHMotionEvent.companion.ACTION_HOVER_MOVE) {
            [self resetTouchState];
        } else if(split && actionMasked == TIOSKHMotionEvent.companion.ACTION_POINTER_UP) {
            int actionIndex = event.actionIndex;
            int idBitsToRemove = 1 << [event getPointerIdPointerIndex:actionIndex];
            [self removePointersFromTouchTargets:idBitsToRemove];
        }
    }
    
    return handled;
}

-(BOOL)onInterceptTouchEvent:(TIOSKHMotionEvent *)event {
    NSNumber *num = [NSNumber numberWithBool:false];
    [self callTMethod:@"onInterceptTouchEvent" :&num :event, nil];
    return [num boolValue];
}

-(void)requestDisallowInterceptTouchEvent:(BOOL)disallowIntercept {
    if(disallowIntercept == ((self.mGroupFlags & GROUP_FLAG_DISALLOW_INTERCEPT) != 0)) {
        return;
    }
    
    if(disallowIntercept) {
        self.mGroupFlags |= GROUP_FLAG_DISALLOW_INTERCEPT;
    } else {
        self.mGroupFlags &= ~GROUP_FLAG_DISALLOW_INTERCEPT;
    }
    
    if(self.parent != nil && [self.parent isKindOfClass:[LGViewGroup class]]) {
        [((LGViewGroup*)self.parent) requestDisallowInterceptTouchEvent:disallowIntercept];
    }
}

- (void)onConfigurationChanged:(Configuration *)configuration {
    for(LGView *view in self.subviews) {
        [view onConfigurationChanged:configuration];
    }
}

-(BOOL)drawChild:(id<TIOSKHTCanvas>)canvas :(LGView *)child :(long)drawingTime {
    return [child draw:canvas :self :drawingTime];
}

-(NSDictionary*)getBindings
{
    return self.subviewMap;
}

-(NSString*)GetId
{
    if(self.lua_id != nil)
        return self.lua_id;
    if(self.android_id != nil)
        return self.android_id;
    return [LGView className];
}

+ (NSString*)className
{
    return @"LGViewGroup";
}

+(NSMutableDictionary*)luaMethods
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];

    InstanceMethodNoArg(getBindings, NSDictionary, @"getBindings")
    InstanceMethodNoRet(addSubview:, @[[LGView class]], @"addView")
    InstanceMethodNoRet(removeSubview:, @[[LGView class]], @"removeView")
    
    return dict;
}

#pragma TIOSKHTView Start

-(void)swizzleFunctionFuncName:(NSString *)funcName block_:(id  _Nullable (^)(id<TIOSKHTView> _Nonnull, TIOSKHKotlinArray<id> * _Nonnull))block
{
    [self.methodEventMap setObject:block forKey:funcName];
}

-(void)addViewView:(id<TIOSKHTView>)view param:(TIOSKHViewGroupLayoutParams *)param {
    [view setLayoutParamsParams:param];
    [self addSubview:(LGView*)view];
}

- (void)onAttachedToWindow {
    [super onAttachedToWindow];
    for(LGView *subview in self.subviews) {
        [subview onAttachedToWindow];
    }
}

- (void)onDetachedFromWindow {
    [super onDetachedFromWindow];
    for(LGView *subview in self.subviews) {
        [subview onDetachedFromWindow];
    }
}

- (void)dispatchDrawCanvas:(id<TIOSKHTCanvas>)canvas {
    int childrenCount = self.subviews.count;
    NSMutableArray *children = self.subviews;
    int flags = self.mGroupFlags;
    /*if ((flags & FLAG_RUN_ANIMATION) != 0 && canAnimate()) {
        for (int i = 0; i < childrenCount; i++) {
            final View child = children[i];
            if ((child.mViewFlags & VISIBILITY_MASK) == VISIBLE) {
                final LayoutParams params = child.getLayoutParams();
                attachLayoutAnimationParameters(child, params, i, childrenCount);
                bindLayoutAnimation(child);
            }
        }
        final LayoutAnimationController controller = mLayoutAnimationController;
        if (controller.willOverlap()) {
            mGroupFlags |= FLAG_OPTIMIZE_INVALIDATE;
        }
        controller.start();
        mGroupFlags &= ~FLAG_RUN_ANIMATION;
        mGroupFlags &= ~FLAG_ANIMATION_DONE;
        if (mAnimationListener != null) {
            mAnimationListener.onAnimationStart(controller.getAnimation());
        }
    }*/
    /*int clipSaveCount = 0;
    BOOL clipToPadding = (flags & CLIP_TO_PADDING_MASK) == CLIP_TO_PADDING_MASK;
    if (clipToPadding) {
        clipSaveCount = canvas.save(Canvas.CLIP_SAVE_FLAG);
        canvas.clipRect(mScrollX + mPaddingLeft, mScrollY + mPaddingTop,
                mScrollX + mRight - mLeft - mPaddingRight,
                mScrollY + mBottom - mTop - mPaddingBottom);
    }*/
    // We will draw our child's animation, let's reset the flag
    self.dPrivateFlags &= ~PFLAG_DRAW_ANIMATION;
    self.mGroupFlags &= ~GROUP_FLAG_INVALIDATE_REQUIRED;
    BOOL more = false;
    //long drawingTime = getDrawingTime();
    long drawingTime = 0;
    [canvas enableZ];
    //int transientCount = mTransientIndices == null ? 0 : mTransientIndices.size();
    int transientCount = 0;
    int transientIndex = transientCount != 0 ? 0 : -1;
    // Only use the preordered list if not HW accelerated, since the HW pipeline will do the
    // draw reordering internally
    NSMutableArray *preorderedList = [self buildOrderedChildList];
    //final boolean customOrder = preorderedList == null && isChildrenDrawingOrderEnabled();
    BOOL customOrder = false;
    for (int i = 0; i < childrenCount; i++) {
        /*while (transientIndex >= 0 && mTransientIndices.get(transientIndex) == i) {
            final View transientChild = mTransientViews.get(transientIndex);
            if ((transientChild.mViewFlags & VISIBILITY_MASK) == VISIBLE ||
                    transientChild.getAnimation() != null) {
                more |= drawChild(canvas, transientChild, drawingTime);
            }
            transientIndex++;
            if (transientIndex >= transientCount) {
                transientIndex = -1;
            }
        }*/
        /*int childIndex = getAndVerifyPreorderedIndex(childrenCount, i, customOrder);
        LGView *child = getAndVerifyPreorderedView(preorderedList, children, childIndex);*/
        LGView *child = [preorderedList objectAtIndex:i];
        //if ((child.mViewFlags & VISIBILITY_MASK) == VISIBLE || child.getAnimation() != null) {
        if(child.dVisibility == VISIBLE) {
            more |= [self drawChild:canvas :child :drawingTime];
        }
    }
    /*while (transientIndex >= 0) {
        // there may be additional transient views after the normal views
        final View transientChild = mTransientViews.get(transientIndex);
        if ((transientChild.mViewFlags & VISIBILITY_MASK) == VISIBLE ||
                transientChild.getAnimation() != null) {
            more |= drawChild(canvas, transientChild, drawingTime);
        }
        transientIndex++;
        if (transientIndex >= transientCount) {
            break;
        }
    }*/
    if (preorderedList != nil) [preorderedList removeAllObjects];
    // Draw any disappearing views that have animations
    /*if (mDisappearingChildren != null) {
        final ArrayList<View> disappearingChildren = mDisappearingChildren;
        final int disappearingCount = disappearingChildren.size() - 1;
        // Go backwards -- we may delete as animations finish
        for (int i = disappearingCount; i >= 0; i--) {
            final View child = disappearingChildren.get(i);
            more |= drawChild(canvas, child, drawingTime);
        }
    }*/
    [canvas disableZ];
    /*if (clipToPadding) {
        canvas.restoreToCount(clipSaveCount);
    }*/
    // mGroupFlags might have been updated by drawChild()
    flags = self.mGroupFlags;
    if ((flags & GROUP_FLAG_INVALIDATE_REQUIRED) == GROUP_FLAG_INVALIDATE_REQUIRED) {
        [self invalidate];
    }
    /*if ((flags & FLAG_ANIMATION_DONE) == 0 && (flags & FLAG_NOTIFY_ANIMATION_LISTENER) == 0 &&
            mLayoutAnimationController.isDone() && !more) {
        // We want to erase the drawing cache and notify the listener after the
        // next frame is drawn because one extra invalidate() is caused by
        // drawChild() after the animation is over
        mGroupFlags |= FLAG_NOTIFY_ANIMATION_LISTENER;
        final Runnable end = new Runnable() {
           @Override
           public void run() {
               notifyAnimationListener();
           }
        };
        post(end);
    }*/
}

- (id<TIOSKHTView>)getChildAtIndex:(int32_t)index {
    return [self.subviews objectAtIndex:index];
}

-(int32_t)getChildCount {
    return (int32_t)self.subviews.count;
}

- (int32_t)getChildMeasureSpecSpec:(int32_t)spec padding:(int32_t)padding dimension:(int32_t)dimension {
    return [LGViewGroup getChildMeasureSpec:spec :padding :dimension];
}

@end
