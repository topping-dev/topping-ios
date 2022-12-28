#import "LGViewGroup.h"
#import "Defines.h"
#import "LuaFunction.h"
#import "LGValueParser.h"

@implementation LGViewGroup

- (void)InitProperties
{
    [super InitProperties];
    
    self.subviews = [NSMutableArray array];
    self.subviewMap = [NSMutableDictionary dictionary];
}

-(void)AddSubview:(LGView*)val
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

-(void)AddSubview:(LGView*)val :(NSInteger)index
{
    if(index == -1) {
        [self AddSubview:val];
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

-(void)RemoveSubview:(LGView*)val
{
    if(val != nil)
    {
        [self.subviews removeObject:val];
        if(val.android_id != nil || val.lua_id != nil)
            [self.subviewMap removeObjectForKey:[val GetId]];
        [val._view removeFromSuperview];
        val.parent = nil;
        [self Resize];
    }
}

-(void)ClearSubviews
{
    for(LGView *w in self.subviews)
        [w._view removeFromSuperview];
    [self.subviews removeAllObjects];
    [self Resize];
}

-(void)ClearDimensions
{
    [super ClearDimensions];
    for(LGView *w in self.subviews)
        [w ClearDimensions];
}

-(LGView *)GetViewById:(LuaRef*)lId
{
    NSString *sId = (NSString*)[[LGValueParser GetInstance] GetValue: lId.idRef];
    return [self GetViewByIdInternal:sId];
}

-(LGView *)GetViewByIdInternal:(NSString *)sId
{
    if([[self GetId] compare:sId] == 0)
       return self;
    else
    {
        for(LGView *v in self.subviews)
        {
            LGView *a = [v GetViewByIdInternal:sId];
            if(a != nil)
                return a;
        }
    }
    return nil;
}

-(void)Resize
{
    [super Resize];
    for(LGView *w in self.subviews)
        [w ResizeAndInvalidate];
    [super Resize];
}

-(int)GetContentW
{
    if ([self.subviews count] > 0) {
        int maxX = 0;
        for (LGView *v in self.subviews)
        {
            int width_w_margin = 0;
            if([v isKindOfClass:[LGViewGroup class]])
                width_w_margin = [v GetContentW];
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

-(int)GetContentH
{
    if ([self.subviews count] > 0) {
        int maxY = 0;
        for (LGView *v in self.subviews)
        {
            int height_w_margin = 0;
            if([v isKindOfClass:[LGViewGroup class]])
                height_w_margin = [v GetContentH];
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

-(void)ReduceWidth:(int)share
{
    for(LGView *w in self.subviews)
    {
        [w ReduceWidth:share];
    }
    [super ReduceWidth:share];
}

-(void)ReduceHeight:(int)share
{
    for(LGView *w in [self subviews])
    {
        [w ReduceHeight:share];
    }
    [super ReduceHeight:share];
}

-(void)ConfigChange
{
    for(LGView *w in [self subviews])
    {
        [w ConfigChange];
    }
    [super ConfigChange];
}

-(NSString *)DebugDescription:(NSString *)val
{
    NSString *retVal = [super DebugDescription:val];
    NSString *valValue = val;
    for(LGView *w in self.subviews)
    {
        retVal = FUAPPEND(retVal, [w DebugDescription:APPEND(valValue, @"--")], NULL);
    }
    
    return retVal;
}

-(void)viewDidLayoutSubviews {
    for(LGView *w in self.subviews)
    {
        [w viewDidLayoutSubviews];
    }
}

-(NSDictionary*)GetBindings
{
    return self.subviewMap;
}

+(NSMutableDictionary*)luaMethods
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];

    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(GetBindings)) :@selector(GetBindings) :nil :MakeArray(nil)] forKey:@"GetBindings"];
    return dict;
}

@end
