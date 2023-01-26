#import "LGViewGroup.h"
#import "Defines.h"
#import "LuaFunction.h"
#import "LGValueParser.h"

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
    /*else
        NSLog(@"Null child");*/
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
    /*else
        NSLog(@"Null child");*/
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
    }
}

-(void)removeAllSubViews {
    for(LGView *subview in self.subviews)
    {
        [self removeSubview:subview];
    }
}

-(void)clearSubviews
{
    for(LGView *w in self.subviews)
        [w._view removeFromSuperview];
    [self.subviews removeAllObjects];
    [self resize];
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

-(int)getContentW
{
    if ([self.subviews count] > 0) {
        int maxX = 0;
        for (LGView *v in self.subviews)
        {
            int width_w_margin = 0;
            if([v isKindOfClass:[LGViewGroup class]])
                width_w_margin = [v getContentW];
            else
                width_w_margin = v.dWidth + v.dMarginLeft + v.dMarginRight;
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
            int height_w_margin = 0;
            if([v isKindOfClass:[LGViewGroup class]])
                height_w_margin = [v getContentH];
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

+(NSMutableDictionary*)luaMethods
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];

    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(getBindings)) :@selector(getBindings) :nil :MakeArray(nil)] forKey:@"getBindings"];
    return dict;
}

@end
