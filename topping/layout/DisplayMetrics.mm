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

+(UIView *)getMasterView
{
	return masterView;
}

+(void)setMasterView:(UIView *)view
{
	masterView = view;
}

+(CGRect)getBaseFrame
{
    return baseFrame;
}

+(void)setBaseFrame:(CGRect )frame
{
    baseFrame = frame;
}

+(float)getStatusBarHeight
{
    return statusBarHeight;
}

+(void)setStatusBarHeight:(float)height
{
    statusBarHeight = height;
}

+(float)getDensity {
    return density;
}

+(float)getScaledDensity {
    return scaledDensity;
}

+(void)setDensity:(float)d :(float)sd
{
	density = d;
	scaledDensity = sd;
}

+(float)dpToSp:(float)value {
    return value * density;
}

+(float)spToDp:(float)value {
    return value / density;
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
            return 0;

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
			if([sz compare:@"fill_parent"] == 0 || [sz compare:@"match_parent"] == 0)
				return -1;
            else if([sz compare:@"wrap_content"] == 0)
                return -2;
			return [sz intValue];
		}
	} @catch (...) {
		return -1;
	}
}

@end
