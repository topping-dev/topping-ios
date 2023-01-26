#import "LGLinearLayout.h"
#import "Defines.h"
#import "LuaFunction.h"

@implementation LGLinearLayout

-(void)initProperties
{
	[super initProperties];
	
	self.android_weightSum = [NSNumber numberWithFloat:-1.0f];
	
	self.layout = YES;
}

-(void)resize
{
	[super resize];
	[self resizeInternal];
	//NSLog(@"\n %@", [self DebugDescription:nil]);
	BOOL vertical = YES;
	if(self.android_orientation != nil)
		vertical = [self.android_orientation compare:@"vertical"] == 0;
    [super resize];
	//[super AfterResize:vertical];
#ifdef DEBUG_DESCRIPTION
	NSLog(@"\n %@", [self DebugDescription:nil]);
#endif
}

-(void)resizeInternal
{
	int y = 0;
	int x = 0;
	NSMutableArray *with_weight = [[NSMutableArray alloc] init];
	int max_base = 0;
	int max_base_bottom = 0;
    int max_base_right = 0;
	
	BOOL vertical = [self.android_orientation compare:@"vertical"] == 0;
	
//	NSLog(@"Resize Internal for %@ with parent %@", [[self class] description], self.parent == nil ? @"nil" : [[self.parent class] description]);
	for (LGView *w in self.subviews) 
	{
		if (!vertical) 
		{
			if (!(w.layout))
			{
				if (![w containsAttribute:@"android:layout_gravity" :@"bottom"] ||
					([self.android_layout_gravity compare:@"top"] != 0 && [self.android_layout_gravity compare:@"bottom"] == 0))
				{
					if (w.baseLine > max_base) 
					{
						max_base = w.baseLine;
					}
				}
				else 
				{
					if (w.dHeight - w.baseLine > max_base_bottom) 
					{
						max_base_bottom = w.dHeight - w.baseLine;
					}
				}
			}
		}
        else
        {
            if (!(w.layout))
			{
				if ((w.dLayoutGravity & GRAVITY_END) == 0 || (self.dLayoutGravity & GRAVITY_END) > 0)
				{
					if (w.baseLine > max_base)
					{
						max_base = w.baseLine;
					}
				}
				else
				{
					if (w.dWidth - w.baseLine > max_base_bottom)
					{
						max_base_right = w.dWidth - w.baseLine;
					}
				}
			}
        }
		
		if(w.android_layout_weight != nil)
		{
			[with_weight addObject:w];
		}
		
		if (vertical)
		{
			y += w.dHeight + w.dMarginTop + w.dMarginBottom;
			x += w.dMarginLeft + w.dMarginRight;
		}
		else
		{
			x += w.dWidth + w.dMarginLeft + w.dMarginRight;
			y += w.dMarginTop + w.dMarginBottom;
		}
	}
	self.extra = 0;
	self.percentGone = 0;
	if (vertical) 
	{
		self.extra = self.dHeight - y;
	}
	else 
	{
		self.extra = self.dWidth - x;
	}
	/*if(self.extra < 0)
		self.extra == 0;*/
	x = 0;
	y = self.dPaddingTop;
    
	LGView *lastw;
	for (LGView *w in self.subviews) 
	{
		lastw = w;
		int share = [self calculateShare:w.android_layout_weight];
		if (vertical) 
		{
			if (self.dLayoutGravity & GRAVITY_END)
				x = self.dWidth - w.dWidth - w.dMarginRight;
            else if(w.dLayoutGravity & GRAVITY_END)
                x = self.dWidth - w.dWidth - w.dMarginRight;
			else if (w.dLayoutGravity & GRAVITY_CENTER_HORIZONTAL || w.dLayoutGravity & GRAVITY_CENTER)
            {
				x = self.dWidth/2 - w.dWidth/2;
            }
            else if (self.dGravity & GRAVITY_CENTER_HORIZONTAL || self.dGravity & GRAVITY_CENTER)
            {
                x = self.dWidth/2 - w.dWidth/2;
            }
			else
				x = w.dMarginLeft + self.dPaddingLeft;
		}
		else
		{
			if (CONTAINS(self.android_layout_gravity, @"bottom"))
				y = self.dHeight - max_base_bottom - w.baseLine;
			else if ([self.android_layout_gravity compare:@"center_vertical"] == 0 || [self.android_layout_gravity compare:@"center"] == 0)
				y = self.dHeight/2 - w.baseLine;
			else  
			{
				if (w.layout) 
				{
					y = /*w.dPaddingTop +*/ w.dMarginTop;
				}
				else 
				{
					y = max_base - w.baseLine /*+ w.dPaddingTop*/;
				}
			}
		}
		
		NSObject *hasWeight = [w hasAttribute:@"android:layout_weight"];
        y += w.dMarginTop;
        x += w.dMarginLeft;
        w.dX = x;
        w.dY = y;
        if(hasWeight != nil)
        {
            y += w.dMarginBottom;
            x += w.dMarginRight;
        }
		
		if ([with_weight count] == 0)
		{
			if (vertical) 
			{
				if ([self.android_layout_gravity compare:@"bottom"] == 0)
				{
					w.dY = y + self.extra;
				}
			}
			else if ([self.android_layout_gravity compare:@"right"] == 0
                     || [self.android_layout_gravity compare:@"end"] == 0)
			{
				w.dX = x + self.extra;
			}
		}
		if (vertical) 
		{
            int lastY = y;
			y += w.dHeight + w.dMarginBottom;
			if([with_weight containsObject:w])
			{
				y += share;
				w.dHeight += share;
			}
            /*else if([w.android_layout_height compare:@"fill_parent"] == 0 ||
            [w.android_layout_height compare:@"match_parent"] == 0)
            {
                w.dHeight -= lastY;
            }*/
		}
		else 
		{
			x += w.dWidth + w.dMarginRight;
			if ([with_weight containsObject:w]) 
			{
				x += share;
                
                if([w isKindOfClass:[LGViewGroup class]] && [((LGViewGroup*)w).subviews count] > 0)
                {
                    for(LGView *wsub in ((LGViewGroup*)w).subviews)
                    {
                        [wsub reduceWidth:share];
                    }
                }
                else
                    w.dWidth += share;
			}
		}
        
        [w readWidthHeight];
	}
	//Fix pixels
	if(self.percentGone != 0)
	{
		if(vertical)
			lastw.dHeight += 1;
		else
			lastw.dWidth += 1;
	}
}

-(int)calculateShare:(NSNumber *)prop
{
	@try
	{
		if(prop == nil)
			return 0;
		float share = [prop floatValue];
		float total = [self.android_weightSum floatValue];
		if (total == -1) {
			total = [self sumWeights];
		}
		float percent = (total - share) / total;
        if(percent == 0)
            percent = 1;
		double res = floor(percent * self.extra);
		double real = percent * self.extra;
		self.percentGone += real - res;
		return (int)res;
	} 
	@catch (...) 
	{
	}
	return 0;
}

-(float)sumWeights
{
	float sum = 0;
	for (LGView *w in self.subviews) 
	{
		NSNumber *prop = (NSNumber*)[w hasAttribute:@"android:layout_weight"];
		if (prop == nil)
		{
			continue;
		}
		@try 
		{
			sum += [prop floatValue];
		} 
		@catch (...) {
			
		}
	}
	return sum;
}

-(int)getCalculatedWidth
{
    int calcW = 0;
    for(LGView *w in [self subviews])
    {
        BOOL vertical = YES;
        if(self.android_orientation != nil)
            vertical = [self.android_orientation compare:@"vertical"] == 0;
        
        if(!vertical)
            calcW += [w getCalculatedWidth];
        else
        {
            int width = [w getCalculatedWidth];
            if(width > calcW)
                calcW = width;
        }
    }
    return calcW + [super getCalculatedWidth];
}

-(int)getCalculatedHeight
{
    int calcH = 0;
    for(LGView *w in [self subviews])
    {
        BOOL vertical = YES;
        if(self.android_orientation != nil)
            vertical = [self.android_orientation compare:@"vertical"] == 0;
        
        if(vertical)
            calcH += [w getCalculatedHeight];
        else
        {
            int height = [w getCalculatedHeight];
            if(height > calcH)
                calcH = height;
        }
    }
    return calcH + [super getCalculatedHeight];
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
