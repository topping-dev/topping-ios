#import "LGViewGroup.h"
#import "Defines.h"

@implementation LGViewGroup

- (void)InitProperties
{
    [super InitProperties];
    
    self.subviews = [[NSMutableArray alloc] init];
}

-(void)AddSubview:(LGView*)val
{
    if(val != nil)
    {
        val.parent = self;
        [self.subviews addObject:val];
    }
    /*else
        NSLog(@"Null child");*/
}

-(void)ClearSubviews
{
    [self.subviews removeAllObjects];
}

-(void)ClearDimensions
{
    [super ClearDimensions];
    for(LGView *w in self.subviews)
        [w ClearDimensions];
}

-(LGView *)GetViewById:(NSString *)lId
{
    if([[self GetId] compare:lId] == 0)
       return self;
    else
    {
        for(LGView *v in self.subviews)
        {
            LGView *a = [v GetViewById:lId];
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
        [w Resize];
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

@end
