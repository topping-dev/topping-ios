#import "LGRadioButton.h"
#import "Defines.h"
#import "LuaFunction.h"

@implementation LGRadioButton

-(UIView*)CreateComponent
{
	return [[UIView alloc] init];
}

-(void)ComponentAddMethod:(UIView*)par :(UIView *)me
{
	[((UISegmentedControl *)par) insertSegmentWithTitle:self.android_text atIndex:[((UISegmentedControl *)par) numberOfSegments] animated:NO];
	if(self.android_checked != nil && CONTAINS(self.android_checked, @"true"))
		[((UISegmentedControl *)par) setSelectedSegmentIndex:[((UISegmentedControl *)par) numberOfSegments] - 1];
	[self resizeSegmentsToFitTitles:((UISegmentedControl *)par)];
}

-(void)resizeSegmentsToFitTitles:(UISegmentedControl*)segCtrl
{
    CGFloat totalWidths = 0;    // total of all label text widths
    NSUInteger nSegments = segCtrl.subviews.count;    
    UIView* aSegment = [segCtrl.subviews objectAtIndex:0];
    UIFont* theFont = nil;
	UIFont* customFont = nil;
	
	CGFloat spaceWidth = 0.0f;
	do
	{
		totalWidths = 0;
		if(customFont == nil)
		{
			for (UILabel* aLabel in aSegment.subviews) {
				if ([aLabel isKindOfClass:[UILabel class]]) {
					theFont = aLabel.font;
					break;
				}
			}
		}
		else
			theFont = customFont;
		
		// calculate width that all the title text takes up
		for (NSUInteger i=0; i < nSegments; i++) {
			CGFloat textWidth = [[segCtrl titleForSegmentAtIndex:i] sizeWithFont:theFont].width;
			totalWidths += textWidth;
		}
		
		// width not used up by text, its the space between labels
		spaceWidth = segCtrl.bounds.size.width - totalWidths;
		if(spaceWidth < 0)
			customFont = [theFont fontWithSize:theFont.pointSize-1];
	} while(spaceWidth < 0);
	
    // now resize the segments to accomodate text size plus 
    // give them each an equal part of the leftover space
    for (NSUInteger i=0; i < nSegments; i++) {
        // size for label width plus an equal share of the space
        CGFloat textWidth = [[segCtrl titleForSegmentAtIndex:i] sizeWithFont:theFont].width;
        // roundf??  the control leaves 1 pixel gap between segments if width 
        // is not an integer value, the roundf fixes this
        CGFloat segWidth = roundf(textWidth + (spaceWidth / nSegments));    
        [segCtrl setWidth:segWidth forSegmentAtIndex:i];
    }

	for (id segment in [segCtrl subviews]) 
	{
		for (id label in [segment subviews]) 
		{
			if ([label isKindOfClass:[UILabel class]])
			{
				if(self.android_gravity == nil)
					[label setTextAlignment:NSTextAlignmentCenter];
				else if(CONTAINS(self.android_gravity, @"left"))
					[label setTextAlignment:NSTextAlignmentLeft];
				else if(CONTAINS(self.android_gravity, @"right"))
					[label setTextAlignment:NSTextAlignmentRight];
				else if(CONTAINS(self.android_gravity, @"center"))
					[label setTextAlignment:NSTextAlignmentRight];
				
				if(customFont != nil)
					[label setFont:customFont];
				/*if(textColor != nil)
				 //[label setTextColor:[UIColor greenColor]];*/
			}
		}			
	}
}

//Lua
+(LGRadioButton*)Create:(LuaContext *)context
{
	LGRadioButton *lst = [[LGRadioButton alloc] init];
	[lst InitProperties];
	return lst;
}

-(NSString*)GetId
{
	if(self.lua_id != nil)
		return self.lua_id;
	if(self.android_tag != nil)
		return self.android_tag;
	else
		return [LGRadioButton className];
}

+ (NSString*)className
{
	return @"LGRadioButton";
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(Create::)) 
										:@selector(Create::) 
										:[LGRadioButton class]
										:[NSArray arrayWithObjects:[LuaContext class], [NSString class], nil] 
										:[LGRadioButton class]] 
			 forKey:@"Create"];
	return dict;
}
		 
@end
