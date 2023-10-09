#import "LGProgressBar.h"
#import "DisplayMetrics.h"
#import "Defines.h"
#import "UIBufferedProgressBar.h"
#import "LGDimensionParser.h"
#import "LGDrawableParser.h"
#import "LuaFunction.h"
#import "LuaValues.h"
#import "MaterialActivityIndicator.h"

@implementation LGProgressBar

-(int)getContentW
{
	[super getContentW];
	int width = self.dWidth;
    BOOL horizontalProgress = NO;
    if(self.iosHorizontalProgress != nil)
        horizontalProgress = [self.iosHorizontalProgress boolValue];
    if(!horizontalProgress && width == 0)
    {
        MDCActivityIndicator *temp = [MDCActivityIndicator new];
        width = [[LGDimensionParser getInstance] getDimension:[NSString stringWithFormat:@"%dpx", (int)temp.radius]];
    }
	if(self.android_maxWidth != nil)
	{
		int maxW = [[LGDimensionParser getInstance] getDimension:self.android_maxWidth];
		if(maxW < width)
			return maxW;
		else
			return width;
	}
	return width;
}

-(int)getContentH
{
	[super getContentH];
	int height = self.dHeight;
    if(height == 0)
    {
        BOOL horizontalProgress = NO;
        if(self.iosHorizontalProgress != nil)
            horizontalProgress = [self.iosHorizontalProgress boolValue];
        
        if(horizontalProgress)
            height = [[LGDimensionParser getInstance] getDimension:@"5px"];
        else
        {
            MDCActivityIndicator *temp = [MDCActivityIndicator new];
            height = [[LGDimensionParser getInstance] getDimension:[NSString stringWithFormat:@"%dpx", (int)temp.radius]];
        }
    }
	if(self.android_maxHeight != nil)
	{
		int maxH = [[LGDimensionParser getInstance] getDimension:self.android_maxHeight];
		if(maxH < height)
			return maxH;
		else
			return height;
	}
	return height;
}

-(UIView*)createComponent
{
    BOOL horizontalProgress = NO;
    if(self.iosHorizontalProgress != nil)
        horizontalProgress = [self.iosHorizontalProgress boolValue];

    self.horizontal = horizontalProgress;
    if(horizontalProgress)
    {
        UIBufferedProgressBar *pv = [[UIBufferedProgressBar alloc] init];
        pv.frame = CGRectMake(self.dX, self.dY, self.dWidth, self.dHeight);
        if(self.android_indeterminate)
            pv.indeterminate = [self.android_indeterminate boolValue];
        if(self.android_indeterminateBehavior != nil)
            pv.indeterminateBehaviour = [self.android_indeterminateBehavior intValue];
        if(self.android_indeterminateDuration != nil)
            pv.indeterminateDuration = [self.android_indeterminateDuration doubleValue];
        
        if(self.android_max != nil)
            pv.progressMax = [self.android_max intValue];
        if(self.android_progress != nil)
            pv.progressValue = [self.android_progress intValue];
        
        if(self.android_progressDrawable != nil)
        {
            LGDrawableReturn *ret = [[LGDrawableParser getInstance] parseDrawable:self.android_progressDrawable];
            if(ret != nil)
                pv.progressImage = ret.img;
        }
            
        
        if(self.android_secondaryProgress != nil)
            pv.secondaryProgress = [self.android_secondaryProgress intValue];
            
        return pv;
    }
    else
    {
        BOOL smallProgress = YES;
        BOOL darkProgress = NO;
        self.maxProgress = 100;
        if(self.iosSmallProgress != nil)
            smallProgress = [self.iosSmallProgress boolValue];
        if(self.iosDarkProgress != nil)
            darkProgress = [self.iosDarkProgress boolValue];
        
        
        MDCActivityIndicator *pv = [[MDCActivityIndicator alloc] init];
        pv.frame = CGRectMake(self.dX, self.dY, self.dWidth, self.dHeight);
         if(self.android_indeterminate)
            pv.indicatorMode = MDCActivityIndicatorModeIndeterminate;
        else
            pv.indicatorMode = MDCActivityIndicatorModeDeterminate;
        
        [pv startAnimating];
         
        if(self.android_max != nil)
            self.maxProgress = [self.android_max intValue];
        if(self.android_progress != nil)
            [pv setProgress:[self.android_progress floatValue] / (float)self.maxProgress animated:NO];
        if(smallProgress)
            pv.radius = [[LGDimensionParser getInstance] getDimension:@"6px"];
        if(darkProgress)
            pv.cycleColors = @[ UIColor.whiteColor ];
        
        return pv;
    }
}

-(void)componentAddMethod:(UIView *)par :(UIView *)me
{
    [super componentAddMethod:par :me];
    
    BOOL horizontalProgress = NO;
    if(self.iosHorizontalProgress != nil)
        horizontalProgress = [self.iosHorizontalProgress boolValue];
    
    if(!horizontalProgress)
        [((MDCActivityIndicator*)self._view) startAnimating];
}

//Lua
+(LGProgressBar*)create:(LuaContext *)context
{
	LGProgressBar *lst = [[LGProgressBar alloc] init];
    lst.lc = context;
	[lst initProperties];
	return lst;
}

-(void)setProgress:(int)progress
{
    if(self.horizontal)
    {
        UIBufferedProgressBar *pb = ((UIBufferedProgressBar*)self._view);
        [pb setProgressValue:progress];
    }
    else
    {
        MDCActivityIndicator *pb = ((MDCActivityIndicator*)self._view);
        [pb setProgress:((float)progress) / ((float)self.maxProgress) animated:NO];
    }
}

-(void)setMax:(int)max
{
    if(self.horizontal)
    {
        UIBufferedProgressBar *pb = ((UIBufferedProgressBar*)self._view);
        [pb setProgressMax:max];
    }
    else
    {
        MDCActivityIndicator *pb = ((MDCActivityIndicator*)self._view);
        [pb setProgress:((float)pb.progress * (float)self.maxProgress) / ((float)max) animated:NO];
        self.maxProgress = max;
    }
}

-(void)setIndeterminate:(bool)val
{
    if(self.horizontal)
    {
        UIBufferedProgressBar *pb = ((UIBufferedProgressBar*)self._view);
        [pb setIndeterminate:val];
    }
    else
    {
        MDCActivityIndicator *pb = ((MDCActivityIndicator*)self._view);
        if(val)
            pb.indicatorMode = MDCActivityIndicatorModeIndeterminate;
        else
            pb.indicatorMode = MDCActivityIndicatorModeDeterminate;
    }
}

-(NSString*)GetId
{
    if(self.lua_id != nil)
        return self.lua_id;
    if(self.android_id != nil)
        return self.android_id;
    return [LGProgressBar className];
}

+ (NSString*)className
{
	return @"LGProgressBar";
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(create:)) 
										:@selector(create:)
										:[LGProgressBar class]
										:[NSArray arrayWithObjects:[LuaContext class], [NSString class], nil] 
										:[LGProgressBar class]] 
			 forKey:@"create"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(setProgress:)) :@selector(setProgress:) :nil :MakeArray([LuaInt class]C nil)] forKey:@"setProgress"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(setMax:)) :@selector(setMax:) :nil :MakeArray([LuaInt class]C nil)] forKey:@"setMax"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(setIndeterminate:)) :@selector(setIndeterminate:) :nil :MakeArray([LuaBool class]C nil)] forKey:@"setIndeterminate"];
    
	return dict;
}

@end
