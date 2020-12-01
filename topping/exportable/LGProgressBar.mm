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

-(int)GetContentW
{
	[super GetContentW];
	int width = self.dWidth;
    BOOL horizontalProgress = NO;
    if(self.ios_horizontalProgress != nil)
        horizontalProgress = [self.ios_horizontalProgress boolValue];
    if(!horizontalProgress && width == 0)
    {
        MDCActivityIndicator *temp = [MDCActivityIndicator new];
        width = [[LGDimensionParser GetInstance] GetDimension:[NSString stringWithFormat:@"%ddp", (int)temp.radius]];
    }
	if(self.android_maxWidth != nil)
	{
		int maxW = [[LGDimensionParser GetInstance] GetDimension:self.android_maxWidth];
		if(maxW < width)
			return maxW;
		else
			return width;
	}
	return width;
}

-(int)GetContentH
{
	[super GetContentH];
	int height = self.dHeight;
    if(height == 0)
    {
        BOOL horizontalProgress = NO;
        if(self.ios_horizontalProgress != nil)
            horizontalProgress = [self.ios_horizontalProgress boolValue];
        
        if(horizontalProgress)
            height = [[LGDimensionParser GetInstance] GetDimension:@"5dp"];
        else
        {
            MDCActivityIndicator *temp = [MDCActivityIndicator new];
            height = [[LGDimensionParser GetInstance] GetDimension:[NSString stringWithFormat:@"%ddp", (int)temp.radius]];
        }
    }
	if(self.android_maxHeight != nil)
	{
		int maxH = [[LGDimensionParser GetInstance] GetDimension:self.android_maxHeight];
		if(maxH < height)
			return maxH;
		else
			return height;
	}
	return height;
}

-(UIView*)CreateComponent
{
    BOOL horizontalProgress = NO;
    if(self.ios_horizontalProgress != nil)
        horizontalProgress = [self.ios_horizontalProgress boolValue];

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
            LGDrawableReturn *ret = [[LGDrawableParser GetInstance] ParseDrawable:self.android_progressDrawable];
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
        if(self.ios_smallProgress != nil)
            smallProgress = [self.ios_smallProgress boolValue];
        if(self.ios_darkProgress != nil)
            darkProgress = [self.ios_darkProgress boolValue];
        
        
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
            pv.radius = [[LGDimensionParser GetInstance] GetDimension:@"6dp"];
        if(darkProgress)
            pv.cycleColors = @[ UIColor.whiteColor ];
        
        return pv;
    }
}

-(void)ComponentAddMethod:(UIView *)par :(UIView *)me
{
    [super ComponentAddMethod:par :me];
    
    BOOL horizontalProgress = NO;
    if(self.ios_horizontalProgress != nil)
        horizontalProgress = [self.ios_horizontalProgress boolValue];
    
    if(!horizontalProgress)
        [((MDCActivityIndicator*)self._view) startAnimating];
}

//Lua
+(LGProgressBar*)Create:(LuaContext *)context
{
	LGProgressBar *lst = [[LGProgressBar alloc] init];
	[lst InitProperties];
	return lst;
}

-(void)SetProgress:(int)progress
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

-(void)SetMax:(int)max
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

-(void)SetIndeterminate:(bool)val
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
	if(self.android_tag != nil)
		return self.android_tag;
	else
		return [LGProgressBar className];
}

+ (NSString*)className
{
	return @"LGProgressBar";
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(Create::)) 
										:@selector(Create::) 
										:[LGProgressBar class]
										:[NSArray arrayWithObjects:[LuaContext class], [NSString class], nil] 
										:[LGProgressBar class]] 
			 forKey:@"Create"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetProgress:)) :@selector(SetProgress:) :nil :MakeArray([LuaInt class]C nil)] forKey:@"SetProgress"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetMax:)) :@selector(SetMax:) :nil :MakeArray([LuaInt class]C nil)] forKey:@"SetMax"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetIndeterminate:)) :@selector(SetIndeterminate:) :nil :MakeArray([LuaBool class]C nil)] forKey:@"SetIndeterminate"];
    
	return dict;
}

@end
