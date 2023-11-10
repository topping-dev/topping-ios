#import "LGImageView.h"
#import "Defines.h"
#import "LGDimensionParser.h"
#import "LGDrawableParser.h"
#import "LGValueParser.h"
#import "LuaFunction.h"
#import <Topping/Topping-Swift.h>

@implementation LGImageView

-(int)getContentW
{
	if(self._view != nil)
	{
		UIImageView *iv = (UIImageView *)self._view;
		if(iv.image != nil)
		{
			int width = iv.image.size.width;
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
	}
	return [super getContentW];
}

-(int)getContentH
{
	if(self._view != nil)
	{
		UIImageView *iv = (UIImageView *)self._view;
		if(iv.image != nil)
		{
			int height = iv.image.size.height;
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
	}
	return [super getContentH];
}

-(UIView*)createComponent
{
	UIImageView *iv = [[UIImageView alloc] init];
	iv.frame = CGRectMake(self.dX, self.dY, self.dWidth, self.dHeight);
	return iv;
}

-(void) setupComponent:(UIView *)view
{
	UIImageView *iv = (UIImageView*)self._view;
	if(self.android_scaleType != nil)
	{
		if(COMPARE(self.android_scaleType, @"fitXY")
		   || COMPARE(self.android_scaleType, @"matrix"))
			[iv setContentMode:UIViewContentModeScaleToFill];
		else if(COMPARE(self.android_scaleType, @"fitStart"))
			[iv setContentMode:UIViewContentModeScaleAspectFit/* | UIViewContentModeTopLeft*/];
		else if(COMPARE(self.android_scaleType, @"fitCenter"))
			[iv setContentMode:UIViewContentModeScaleAspectFit/* | UIViewContentModeCenter*/];
		else if(COMPARE(self.android_scaleType, @"fitStart"))
			[iv setContentMode:UIViewContentModeScaleAspectFit/* | UIViewContentModeBottomRight*/];
		else if(COMPARE(self.android_scaleType, @"center"))
			[iv setContentMode:UIViewContentModeCenter];
		else if(COMPARE(self.android_scaleType, @"centerInside"))
			[iv setContentMode:/*UIViewContentModeCenter | */UIViewContentModeScaleAspectFit];
		else if(COMPARE(self.android_scaleType, @"centerCrop"))
			[iv setContentMode:/*UIViewContentModeCenter | */UIViewContentModeScaleAspectFill];
	}
	
	if(self.android_src != nil)
    {
        for(UIView *subview in self._view.subviews) {
            [subview removeFromSuperview];
        }
        [self setImageRef:[LuaRef withValue:self.android_src]];
    }
}

//Lua
+(LGImageView*)create:(LuaContext *)context :(NSString*)lid
{
	LGImageView *liv = [[LGImageView alloc] init];
    liv.lc = context;
    [liv SetId:lid];
	[liv initProperties];
	return liv;
}

-(void)setImage:(LuaStream*)stream
{
	NSMutableData *_data = [NSMutableData data];
	
	uint8_t buf[1024];
	
	NSInteger len = 0;
	
	NSInputStream *is = (NSInputStream*)[stream getStream];
	while([is hasBytesAvailable])
	{
		len = [is read:buf maxLength:1024];
		
		if(len)
		{
			[_data appendBytes:(const void *)buf length:len];
		}
	}
	[((UIImageView *)self._view) setImage:[UIImage imageWithData:_data]];
}

-(void)setImageDrawable:(LGDrawableReturn*)ldr {
    UIImageView *iv = ((UIImageView *)self._view);
    if(ldr == nil)
    {
        iv.image = nil;
        self.ldr = nil;
        return;
    }
    CGSize size = CGSizeZero;
    VectorView *vv = nil;
    for(UIView *subView in self._view.subviews) {
        [subView removeFromSuperview];
    }
    if(ldr.vector != nil) {
        VectorTheme *theme = [[VectorTheme alloc] initWithColor:[UIColor blackColor]];
        vv = [[VectorView alloc] initWithTheme:theme resources:theme];
        VectorDrawable *drawable = (VectorDrawable*)ldr.vector;
        vv.drawable = drawable;
        [self._view addSubview:vv];
        size = CGSizeMake(drawable.baseWidth, drawable.baseHeight);
    }
    else {
        [iv setImage:ldr.img];
        size = ldr.img.size;
    }
    if(self.dWidth == 0 && self.dHeight == 0)
    {
        self.dWidth = size.width;
        self.dHeight = size.height;
    }
    if(self.dHeight == 0)
    {
        int width = self.dWidth;
        int ivWidth = size.width;
        int ivHeight = size.height;
        self.dHeight = ((float)(ivHeight * width)) / ((float)ivWidth);
    }
    if(self.dWidth == 0)
    {
        int height = self.dHeight;
        int ivWidth = size.width;
        int ivHeight = size.height;
        self.dWidth = ((float)(ivWidth * height)) / ((float)ivHeight);
    }
    iv.frame = CGRectMake(self.dX, self.dY, self.dWidth, self.dHeight);
    if(vv != nil) {
        vv.frame = CGRectMake(0, 0, self.dWidth, self.dHeight);
    }
    self.ldr = ldr;
}

-(void)setImageRef:(LuaRef*)ref
{
    LGDrawableReturn *ldr = (LGDrawableReturn*)[[LGValueParser getInstance] getValue:ref.idRef];
    [self setImageDrawable:ldr];
}

-(NSString*)GetId
{
    if(self.lua_id != nil)
        return self.lua_id;
    if(self.android_id != nil)
        return self.android_id;
    return [LGImageView className];
}

+ (NSString*)className
{
	return @"LGImageView";
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(create:))
										:@selector(create:) 
										:[LGImageView class]
										:[NSArray arrayWithObjects:[LuaContext class], [NSString class], nil] 
										:[LGImageView class]] 
			 forKey:@"create"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(setImage:)) :@selector(setImage:) :nil :MakeArray([LuaStream class]C nil)] forKey:@"setImage"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(setImageRef:)) :@selector(setImageRef:) :nil :MakeArray([LuaRef class]C nil)] forKey:@"setImageRef"];
	return dict;
}

#pragma TIOSKHTView

- (void)setImageDrawableDrawable:(id<TIOSKHTDrawable> _Nullable)drawable {
    LGDrawableReturn *ldr = (LGDrawableReturn *)drawable;
    [self setImageDrawable:ldr];
}

- (void)setImageResourceResourceId:(nonnull NSString *)resourceId {
    [self setImageRef:[LuaRef withValue:resourceId]];
}

- (void)clearColorFilter {
    if(self.orgImage != nil) {
        ((UIImageView*)self._view).image = self.orgImage;
        self.orgImage = nil;
    }
}

-(id<TIOSKHTDrawable>)getDrawable {
    return (id<TIOSKHTDrawable>)self.ldr;
}

-(void)setColorFilterColorMatrixColorFilter:(TIOSKHColorMatrixColorFilter *)colorMatrixColorFilter {
    //https://developer.android.com/reference/android/graphics/ColorMatrix
    UIImageView *iv = (UIImageView*)self._view;
    if(self.orgImage == nil)
        self.orgImage = iv.image;
    
    TIOSKHColorMatrix *matrix = [[TIOSKHColorMatrix alloc] init];
    [colorMatrixColorFilter getColorMatrixColorMatrix:matrix];
    TIOSKHKotlinFloatArray *arr = matrix.array;
    
    // Make the input image recipe
    CIImage *inputImage = [CIImage imageWithCGImage:iv.image.CGImage];

    // Make the filter
    CIFilter *colorMatrixFilter = [CIFilter filterWithName:@"CIColorMatrix"];
    [colorMatrixFilter setDefaults];
    [colorMatrixFilter setValue:inputImage forKey:kCIInputImageKey];
    [colorMatrixFilter setValue:[CIVector vectorWithX:[arr getIndex:0] Y:[arr getIndex:1] Z:[arr getIndex:2] W:[arr getIndex:3]] forKey:@"inputRVector"];
    [colorMatrixFilter setValue:[CIVector vectorWithX:[arr getIndex:5] Y:[arr getIndex:6] Z:[arr getIndex:7] W:[arr getIndex:8]] forKey:@"inputGVector"];
    [colorMatrixFilter setValue:[CIVector vectorWithX:[arr getIndex:10] Y:[arr getIndex:11] Z:[arr getIndex:12] W:[arr getIndex:13]] forKey:@"inputBVector"];
    [colorMatrixFilter setValue:[CIVector vectorWithX:[arr getIndex:15] Y:[arr getIndex:16] Z:[arr getIndex:17] W:[arr getIndex:18]] forKey:@"inputAVector"];

    // Get the output image recipe
    CIImage *outputImage = [colorMatrixFilter outputImage];

    // Create the context and instruct CoreImage to draw the output image recipe into a CGImage
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgimg = [context createCGImage:outputImage fromRect:[outputImage extent]];
    
    iv.image = [UIImage imageWithCGImage:cgimg];
}

-(void)setImageMatrixImageMatrix:(TIOSKHSkikoMatrix33 *)imageMatrix {
    CGAffineTransform matrix;
    matrix.a = [imageMatrix getIndex:0];
    matrix.b = [imageMatrix getIndex:1];
    matrix.c = [imageMatrix getIndex:3];
    matrix.d = [imageMatrix getIndex:4];
    matrix.tx = [imageMatrix getIndex:6];
    matrix.ty = [imageMatrix getIndex:7];
    
    self._view.transform = matrix;
}

-(void)setImageResourceResId:(NSString *)resId {
    [self setImageRef:[LuaRef withValue:resId]];
}

-(void)setScaleTypeScaleType:(TIOSKHScaleType *)scaleType {
    UIImageView *iv = (UIImageView*)self._view;
    
    if(scaleType == TIOSKHScaleType.fitXy
       || scaleType == TIOSKHScaleType.matrix)
        [iv setContentMode:UIViewContentModeScaleToFill];
    else if(scaleType == TIOSKHScaleType.fitStart)
        [iv setContentMode:UIViewContentModeScaleAspectFit];
    else if(scaleType == TIOSKHScaleType.fitCenter)
        [iv setContentMode:UIViewContentModeScaleAspectFit];
    else if(scaleType == TIOSKHScaleType.fitEnd)
        [iv setContentMode:UIViewContentModeScaleAspectFit];
    else if(scaleType == TIOSKHScaleType.center)
        [iv setContentMode:UIViewContentModeCenter];
    else if(scaleType == TIOSKHScaleType.centerInside)
        [iv setContentMode:UIViewContentModeScaleAspectFit];
    else if(scaleType == TIOSKHScaleType.centerCrop)
        [iv setContentMode:UIViewContentModeScaleAspectFill];
}

@end
