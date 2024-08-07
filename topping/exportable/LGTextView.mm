#import <CoreText/CoreText.h>

#import "LG.h"
#import "LGTextView.h"
#import "Defines.h"
#import "DisplayMetrics.h"
#import "LGColorParser.h"
#import "CommonDelegate.h"
#import "LGStringParser.h"
#import "LGStyleParser.h"
#import "UILabelPadding.h"
#import "LGValueParser.h"
#import "LGFontParser.h"

@implementation LuaTextViewAppearance

+(LuaTextViewAppearance *)Parse:(NSString *)name
{
    LuaTextViewAppearance *ltva = [[LuaTextViewAppearance alloc] init];
    NSDictionary *dict = [[LGStyleParser getInstance] getStyle:name];
    if(dict != nil)
    {
        ltva.color = [[LGColorParser getInstance] parseColor:dict[@"android:textColor"]];
//        ltva.font = [[android:fontFamily	]]
        ltva.textSize = [[LGDimensionParser getInstance] getDimension:dict[@"android:textSize"]];
    }
    return ltva;
}

@end

@implementation LGTextView

-(void)initProperties
{
	[super initProperties];
    
    self.stringSize = CGSizeZero;
    int val = [[LGDimensionParser getInstance] getDimension:@"1dp"];
    self.insets = UIEdgeInsetsMake(val, val * 2, val * 2, val / 2);

    self.fontSize = [UIFont labelFontSize];
}

-(void)resize
{
	[super resize];
	if (self.android_textSize != nil && [self.android_textSize length] > 0)
	{
		self.fontSize = [[LGDimensionParser getInstance] getDimension:self.android_textSize];
	}
}

-(void)resizeOnText
{
    self.stringSize = CGSizeZero;
    LGView *parentTop = self.parent;
    while(parentTop.parent != nil)
        parentTop = parentTop.parent;
    
    //[parentTop clearDimensions];
    self.layout = true;
    [parentTop resize];
}

-(CGSize)getStringSize
{
    NSString *text = [self getText];
    if(text == nil || COMPARE(text, @""))
        text = @"R";
    
    if(self.font == nil)
    {
        self.font = [UIFont systemFontOfSize:self.fontSize];
        if(self.android_fontFamily != nil)
        {
            int style = FONT_STYLE_NORMAL;
            if(self.android_textStyle != nil)
            {
                style = [LGFontParser parseTextStyle:[[LGStringParser getInstance] getString:self.android_textStyle]];
            }
            LGFontReturn *lfr = [[LGFontParser getInstance] getFont:self.android_fontFamily];
            LGFontData *lfd = [lfr.fontMap objectForKey:[NSNumber numberWithInt:style]];
            if(lfd != nil)
                self.font = [UIFont fontWithName:lfd.fontName size:self.fontSize];
        }
    }

    CGSize val = [text boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.font} context:nil].size;
    
    return val;
}

-(int)getContentW
{
    int l = [self getStringSize].width + self.dPaddingLeft + self.dPaddingRight + self.insets.left + self.insets.right;
    l += 1;
	return l;
}

-(int)getContentH
{
    CGSize textSize = [self getStringSize];
    int th = textSize.height;
	NSMutableArray *texts = [self buildLineBreaks:self.android_text];
    NSUInteger mult = texts.count;
    if(mult == 0)
        mult = 1;
    if(self.android_minLines != nil && [self.android_minLines intValue] > 0 && mult < [self.android_minLines intValue])
        mult = [self.android_minLines intValue];
        
	int h = (mult * th) + self.dPaddingTop + self.dPaddingBottom + self.insets.top + self.insets.bottom;
	return h;
}

-(NSMutableArray*) buildLineBreaks:(NSString *)textVal
{
	NSMutableArray *res = [[NSMutableArray alloc] init];
	if (textVal == nil) 
	{
		return res;
	}
	NSString *str = textVal;
	NSUInteger ix;
	do 
	{
		NSRange searchRange;
		searchRange.location=(unsigned int)'\n';
		searchRange.length=1;
		NSRange foundRange = [str rangeOfCharacterFromSet:[NSCharacterSet characterSetWithRange:searchRange]];
		ix = foundRange.location;
		NSString *txt = str;
		if (foundRange.location != NSNotFound && foundRange.length > 0)
		{
			txt = [str substringWithRange:NSMakeRange(0, ix)];
			str = [str substringFromIndex:ix + 1];
		}
		int widthL = self.dWidth;
		if (widthL < 0) 
		{
			[res addObject:txt];
			return res;
		}
		
		NSUInteger l = [txt length];
		while (l > widthL) 
		{
			int bk = 1;
			while ([[txt substringWithRange:NSMakeRange(0, bk)] length] < widthL) bk++;
			bk--;
			if (bk == 0) 
			{
				return res;
			}
			NSString *sub = [txt substringWithRange:NSMakeRange(0, bk)];
			[res addObject:sub];
			txt = [txt substringFromIndex:bk];
			l = [txt length];
		}
		[res addObject:txt];
	} while (ix != NSNotFound);
	return res;
}

-(UIView*)createComponent
{
	UILabelPadding *lab = [UILabelPadding new];
    lab.insets = self.insets;
	lab.frame = CGRectMake(self.dX, self.dY, self.dWidth, self.dHeight);
	return lab;
}

-(void) setupComponent:(UIView *)view
{
    if(self.font == nil)
    {
        self.font = [UIFont systemFontOfSize:self.fontSize];
        if(self.android_fontFamily != nil)
        {
            self.font = [UIFont systemFontOfSize:self.fontSize];
            if(self.android_fontFamily != nil)
            {
                int style = FONT_STYLE_NORMAL;
                if(self.android_textStyle != nil)
                {
                    style = [LGFontParser parseTextStyle:[[LGStringParser getInstance] getString:self.android_textStyle]];
                }
                LGFontReturn *lfr = [[LGFontParser getInstance] getFont:self.android_fontFamily];
                LGFontData *lfd = [lfr.fontMap objectForKey:[NSNumber numberWithInt:style]];
                if(lfd != nil)
                    self.font = [UIFont fontWithName:lfd.fontName size:self.fontSize];
            }
        }
    }
    
    if([self._view isKindOfClass:[UILabelPadding class]])
    {
        UILabelPadding *lab = (UILabelPadding*)self._view;
        lab.lineBreakMode = NSLineBreakByClipping;
        lab.text = [[LGStringParser getInstance] getString:self.android_text];
        if(self.colorAccent != nil)
            lab.textColor = [[LGColorParser getInstance] parseColor:self.colorAccent];
        if(self.android_textColor != nil)
            lab.textColor = [[LGColorParser getInstance] parseColor:self.android_textColor];
        
        if(self.android_textColorHighlight != nil)
            lab.highlightedTextColor = [[LGColorParser getInstance] parseColor:self.android_textColorHighlight];
        
        if(self.android_textSize != nil)
            lab.font = [lab.font fontWithSize:[[LGDimensionParser getInstance] getDimension:self.android_textSize]];
        
        if(self.dGravity & GRAVITY_START)
            [lab setTextAlignment:NSTextAlignmentLeft];
        else if(self.dGravity & GRAVITY_END)
            [lab setTextAlignment:NSTextAlignmentRight];
        else if(self.dGravity & GRAVITY_CENTER)
            [lab setTextAlignment:NSTextAlignmentCenter];
        
        lab.insets = UIEdgeInsetsMake(lab.insets.left + self.dPaddingLeft, lab.insets.top + self.dPaddingTop, self.insets.bottom + self.dPaddingBottom, self.insets.right + self.dPaddingRight);
        
        lab.font = self.font;
    }
    else if([self._view isKindOfClass:[UITextView class]])
    {
        ((UITextView*)self._view).font = self.font;
    }
    else if([self._view isKindOfClass:[UITextField class]])
    {
        ((UITextField*)self._view).font = self.font;
    }
    else if([self._view isKindOfClass:[UIButton class]])
    {
        ((UIButton*)self._view).titleLabel.font = self.font;
    }
    
    [super setupComponent:view];
}

//Lua
+(LGTextView*)create:(LuaContext *)context
{
	LGTextView *lst = [[LGTextView alloc] init];
    lst.lc = context;
	[lst initProperties];
	return lst;
}

-(NSString *)getText
{
	UILabel *field = (UILabel*)self._view;
	return [field text];
}

-(void)setTextInternal:(NSString *)val
{
    UILabel *field = (UILabel*)self._view;
	[field setText:val];
    self.android_text = val;
	[self resizeOnText];
}

-(void)setText:(LuaRef *)ref
{
    NSString *val = (NSString*)[[LGValueParser getInstance] getValue:ref.idRef];
    [self setTextInternal:val];
}

-(void)setTextColor:(NSString *)color
{
	UILabel *field = (UILabel*)self._view;
    UIColor *val = (UIColor*)[[LGValueParser getInstance] getValue:color];
    [field setTextColor:val];
}

-(void)setTextColorRef:(LuaRef *)ref
{
    [self setTextColor:ref.idRef];
}

-(NSString*)GetId
{
    if(self.lua_id != nil)
        return self.lua_id;
    if(self.android_id != nil)
        return self.android_id;
    return [LGTextView className];
}

+ (NSString*)className
{
	return @"LGTextView";
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(create:)) 
										:@selector(create:)
										:[LGTextView class]
										:[NSArray arrayWithObjects:[LuaContext class], nil] 
										:[LGTextView class]] 
			 forKey:@"create"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(setTextInternal:))
									   :@selector(setTextInternal:)
									   :nil
									   :MakeArray([NSString class]C nil)]
			 forKey:@"setText"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(setText:))
                              :@selector(setText:)
                              :nil
                              :MakeArray([LuaRef class]C nil)]
             forKey:@"setTextRef"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(setTextColor:))
									   :@selector(setTextColor:)
									   :nil
									   :MakeArray([NSString class]C nil)]
			 forKey:@"setTextColor"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(setTextColorRef:))
                                       :@selector(setTextColorRef:)
                                       :nil
                                       :MakeArray([LuaRef class]C nil)]
             forKey:@"setTextColorRef"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(getText))
									   :@selector(getText)
									   :[NSString class]
									   :MakeArray(nil)]
			 forKey:@"getText"];
	return dict;
}


@end
