#import "LGViewGroup.h"
#import "Defines.h"
#import "LuaFunction.h"
#import "LGValueParser.h"
#import "IOSKotlinHelper/IOSKotlinHelper.h"
#import "Swizzlean.h"

@implementation LGViewGroup

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
    }
    
    [self callTMethod:@"onViewAdded" :val, nil];
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
    }
    
    [self callTMethod:@"onViewAdded" :val, nil];
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
        [self callTMethod:@"onViewRemoved" :val, nil];
    }
}

-(void)removeAllSubViews {
    for(LGView *subview in self.subviews)
    {
        [self removeSubview:subview];
        [self callTMethod:@"onViewRemoved" :subview, nil];
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

    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(getBindings)) :@selector(getBindings) :nil :MakeArray(nil)] forKey:@"getBindings"];
    return dict;
}

#pragma IOSKHTView Start

-(void)swizzleFunctionFuncName:(NSString *)funcName block_:(id  _Nullable (^)(id<IOSKHTView> _Nonnull, IOSKHKotlinArray<id> * _Nonnull))block
{
    [self.methodEventMap setObject:block forKey:funcName];
}

-(void)addViewView:(id<IOSKHTView>)view param:(IOSKHViewGroupLayoutParams *)param {
    [self addSubview:(LGView*)view];
}

- (void)dispatchDrawCanvas:(id<IOSKHTCanvas>)canvas {
    
}

- (id<IOSKHTView>)getChildAtIndex:(int32_t)index {
    return [self.subviews objectAtIndex:index];
}

-(int32_t)getChildCount {
    return (int32_t)self.subviews.count;
}

-(void)onViewAddedView:(id<IOSKHTView>)view {
    
}

@end
