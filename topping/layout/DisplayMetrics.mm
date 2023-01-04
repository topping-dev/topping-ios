#import "DisplayMetrics.h"
#import "LGDimensionParser.h"

static float density=1.0f;
static float scaledDensity=1.0f;
static float xdpi=160;
static float ydpi=160;

static float MM_TO_IN = 0.0393700787f;
static float PT_TO_IN = 1/72.0f;

static UIView *masterView;
static CGRect baseFrame;
static float statusBarHeight;

@implementation DisplayMetrics

+(UIView *)GetMasterView
{
	return masterView;
}

+(void)SetMasterView:(UIView *)view
{
	masterView = view;
}

+(CGRect)GetBaseFrame
{
    return baseFrame;
}

+(void)SetBaseFrame:(CGRect )frame
{
    baseFrame = frame;
}

+(float)GetStatusBarHeight
{
    return statusBarHeight;
}

+(void)SetStatusBarHeight:(float)height
{
    statusBarHeight = height;
}

+(void)SetDensity:(float)d :(float)sd
{
	density = d;
	scaledDensity = sd;
}

+(float)dpToSp:(float)value {
    return value / density;
}

+(float)spToDp:(float)value {
    return value * density;
}

+(int)readSize:(NSString*)sz
{
	if (sz == nil)
		return -1;
	@try {
		float size;
		/*NSNumber *dimen = [[LGDimensionParser GetInstance] GetDimension:sz];
		if(dimen != nil)
			return [dimen intValue];*/
        
        if([sz compare:@"0dp"] == 0 || [sz compare:@"0dip"] == 0)
            return -1;

        if ([sz hasSuffix:@"dip"])
			size = [[sz substringToIndex:[sz length] - 3] floatValue];
		else
			size = [[sz substringToIndex:[sz length] - 2] floatValue];
		
		if ([sz hasSuffix:@"px"]) {
			return (int)size;
		}
		else if ([sz hasSuffix:@"in"]) {
			return (int)(size*xdpi);
		}
		else if ([sz hasSuffix:@"mm"]) {
			return (int)(size*MM_TO_IN*xdpi);
		}
		else if ([sz hasSuffix:@"pt"]) {
			return (int)(size*PT_TO_IN*xdpi);
		}
		else if ([sz hasSuffix:@"dp"] || [sz hasSuffix:@"dip"]) {
			return (int)(size*density);
		}
		else if ([sz hasSuffix:@"sp"]) {
			return (int)(size*scaledDensity);
		}
		else {
			if([sz compare:@"fill_parent"] == 0 || [sz compare:@"wrap_content"] == 0 || [sz compare:@"match_parent"] == 0)
				return -1;
			return [sz intValue];
		}
	} @catch (...) {
		return -1;
	}
}

@end
