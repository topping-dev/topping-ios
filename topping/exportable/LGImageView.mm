#import "LGImageView.h"
#import "Defines.h"
#import "LGDimensionParser.h"
#import "LGDrawableParser.h"
#import "LGValueParser.h"
#import "LuaFunction.h"

@implementation LGImageView

-(int)GetContentW
{
	if(self._view != nil)
	{
		UIImageView *iv = (UIImageView *)self._view;
		if(iv.image != nil)
		{
			int width = iv.image.size.width;
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
	}
	return [super GetContentW];
}

-(int)GetContentH
{
	if(self._view != nil)
	{
		UIImageView *iv = (UIImageView *)self._view;
		if(iv.image != nil)
		{
			int height = iv.image.size.height;
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
	}
	return [super GetContentH];
}

-(UIView*)CreateComponent
{
	UIImageView *iv = [[UIImageView alloc] init];
	iv.frame = CGRectMake(self.dX, self.dY, self.dWidth, self.dHeight);
	return iv;
}

-(void) SetupComponent:(UIView *)view
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
        LGDrawableReturn *ldr = [[LGDrawableParser GetInstance] ParseDrawable:self.android_src];
        [iv setImage:ldr.img];
        if(self.dWidth == 0 && self.dHeight == 0)
        {
            self.dWidth = ldr.img.size.width;
            self.dHeight = ldr.img.size.height;
        }
        if(self.dHeight == 0)
        {
            int width = self.dWidth;
            int ivWidth = ldr.img.size.width;
            int ivHeight = ldr.img.size.height;
            self.dHeight = ((float)(ivHeight * width)) / ((float)ivWidth);
        }
        if(self.dWidth == 0)
        {
            int height = self.dHeight;
            int ivWidth = ldr.img.size.width;
            int ivHeight = ldr.img.size.height;
            self.dWidth = ((float)(ivWidth * height)) / ((float)ivHeight);
        }
        iv.frame = CGRectMake(self.dX, self.dY, self.dWidth, self.dHeight);
    }
}

//Lua
+(LGImageView*)Create:(LuaContext *)context :(NSString*)lid
{
	LGImageView *liv = [[LGImageView alloc] init];
    liv.lua_id = lid;
	[liv InitProperties];
	return liv;
}

-(void)SetImage:(LuaStream*)stream
{
	NSMutableData *_data = [NSMutableData data];
	
	uint8_t buf[1024];
	
	unsigned int len = 0;
	
	NSInputStream *is = (NSInputStream*)[stream GetStream];
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

-(void)SetImageRef:(LuaRef*)ref
{
    LGDrawableReturn *ret = [[LGValueParser GetInstance] GetValue:ref.idRef];
    if(ret.img != nil)
        [((UIImageView *)self._view) setImage:ret.img];
}

-(NSString*)GetId
{
    GETID
    return [LGImageView className];
}

+ (NSString*)className
{
	return @"LGImageView";
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(Create:))
										:@selector(Create:) 
										:[LGImageView class]
										:[NSArray arrayWithObjects:[LuaContext class], [NSString class], nil] 
										:[LGImageView class]] 
			 forKey:@"Create"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetImage:)) :@selector(SetImage:) :nil :MakeArray([LuaStream class]C nil)] forKey:@"SetImage"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetImageRef:)) :@selector(SetImageRef:) :nil :MakeArray([LuaRef class]C nil)] forKey:@"SetImageRef"];
	return dict;
}

@end
