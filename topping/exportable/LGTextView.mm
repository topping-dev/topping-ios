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
    NSDictionary *dict = [[LGStyleParser GetInstance] GetStyle:name];
    if(dict != nil)
    {
        ltva.color = [[LGColorParser GetInstance] ParseColor:dict[@"android:textColor"]];
//        ltva.font = [[android:fontFamily	]]
        ltva.textSize = [[LGDimensionParser GetInstance] GetDimension:dict[@"android:textSize"]];
    }
    return ltva;
}

@end

@implementation LGTextView

-(void)InitProperties
{
	[super InitProperties];
    
    self.stringSize = CGSizeZero;
    int val = [[LGDimensionParser GetInstance] GetDimension:@"4dp"];
    self.insets = UIEdgeInsetsMake(val, val * 2, val * 2, val / 2);

    self.fontSize = [UIFont labelFontSize];
}

-(void)Resize
{
	[super Resize];
	if (self.android_textSize != nil && [self.android_textSize length] > 0)
	{
		self.fontSize = [[LGDimensionParser GetInstance] GetDimension:self.android_textSize];
	}
}

-(void)ResizeOnText
{
    self.stringSize = CGSizeZero;
    LGView *parentTop = self.parent;
    while(parentTop.parent != nil)
        parentTop = parentTop.parent;
    
    [parentTop ClearDimensions];
    [parentTop Resize];
    //[parentTop DebugDescription:@"\n"];
}

-(CGSize)GetStringSize
{
    if(!CGSizeEqualToSize(self.stringSize, CGSizeZero))
        return self.stringSize;
    
    NSString *text = self.android_text;
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
                style = [LGFontParser ParseTextStyle:[[LGStringParser GetInstance] GetString:self.android_textStyle]];
            }
            LGFontReturn *lfr = [[LGFontParser GetInstance] GetFont:self.android_fontFamily];
            LGFontData *lfd = [lfr.fontMap objectForKey:[NSNumber numberWithInt:style]];
            if(lfd != nil)
                self.font = [UIFont fontWithName:lfd.fontName size:self.fontSize];
        }
    }
    
    /*NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName:font}];

    CTFramesetterRef ref = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attrString);
    CGSize size = CTFramesetterSuggestFrameSizeWithConstraints(ref, CFRangeMake(0, 0), nil, CGSizeMake(MAXFLOAT, MAXFLOAT), nil);
    return size;*/

    CGSize val = [text boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.font} context:nil].size;
    
    return val;
    
//    return [text sizeWithAttributes:@{NSFontAttributeName: font}];
}

-(int)GetContentW
{
    int l = [self GetStringSize].width + self.dPaddingLeft + self.dPaddingRight + self.insets.left + self.insets.right;
	if (l > [DisplayMetrics GetMasterView].frame.size.width)
		l = [DisplayMetrics GetMasterView].frame.size.width - self.dX;
    l += 1;
	return l;
}

-(int)GetContentH
{
    CGSize textSize = [self GetStringSize];
    int th = textSize.height;
	NSMutableArray *texts = [self BuildLineBreaks:self.android_text];
    NSUInteger mult = texts.count;
    if(mult == 0)
        mult = 1;
    if(self.android_minLines != nil && [self.android_minLines intValue] > 0 && mult < [self.android_minLines intValue])
        mult = [self.android_minLines intValue];
        
	int h = (mult * th) + self.dPaddingTop + self.dPaddingBottom + self.insets.top + self.insets.bottom;
	return h;
}

-(NSMutableArray*) BuildLineBreaks:(NSString *)textVal
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

-(UIView*)CreateComponent
{
	UILabelPadding *lab = [UILabelPadding new];
    lab.insets = self.insets;
	lab.frame = CGRectMake(self.dX, self.dY, self.dWidth, self.dHeight);
	return lab;
}

-(void) SetupComponent:(UIView *)view
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
                    style = [LGFontParser ParseTextStyle:[[LGStringParser GetInstance] GetString:self.android_textStyle]];
                }
                LGFontReturn *lfr = [[LGFontParser GetInstance] GetFont:self.android_fontFamily];
                LGFontData *lfd = [lfr.fontMap objectForKey:[NSNumber numberWithInt:style]];
                if(lfd != nil)
                    self.font = [UIFont fontWithName:lfd.fontName size:self.fontSize];
            }
        }
    }
    
    if([self._view isKindOfClass:[UILabelPadding class]])
    {
        UILabelPadding *lab = (UILabelPadding*)self._view;
        lab.lineBreakMode = NSLineBreakByTruncatingTail;
        lab.text = [[LGStringParser GetInstance] GetString:self.android_text];
        if(self.colorAccent != nil)
            lab.textColor = [[LGColorParser GetInstance] ParseColor:self.colorAccent];
        if(self.android_textColor != nil)
            lab.textColor = [[LGColorParser GetInstance] ParseColor:self.android_textColor];
        
        if(self.android_textColorHighlight != nil)
            lab.highlightedTextColor = [[LGColorParser GetInstance] ParseColor:self.android_textColorHighlight];
        
        if(self.android_textSize != nil)
            lab.font = [lab.font fontWithSize:[[LGDimensionParser GetInstance] GetDimension:self.android_textSize]];
        
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
    
    [super SetupComponent:view];
}

//Lua
+(LGTextView*)Create:(LuaContext *)context
{
	LGTextView *lst = [[LGTextView alloc] init];
	[lst InitProperties];
	return lst;
}

-(NSString *)GetText
{
	UILabel *field = (UILabel*)self._view;
	return [field text];
}

-(void)SetText:(NSString *)val
{
    UILabel *field = (UILabel*)self._view;
	[field setText:val];
    self.android_text = val;
	[self ResizeOnText];
}

-(void)SetTextRef:(LuaRef *)ref
{
    NSString *val = (NSString*)[[LGValueParser GetInstance] GetValue:ref.idRef];
    [self SetText:val];
}

-(void)SetTextColor:(NSString *)color
{
	UILabel *field = (UILabel*)self._view;
	[field setTextColor:[[LGColorParser GetInstance] ParseColor:color]];
}

-(void)SetTextColorRef:(LuaRef *)ref
{
    UILabel *field = (UILabel*)self._view;
    UIColor *val = (UIColor*)[[LGValueParser GetInstance] GetValue:ref.idRef];
    [field setTextColor:val];
}

-(NSString*)GetId
{
    if(self.lua_id != nil)
        return self.lua_id;
    if(self.android_id != nil)
        return self.android_id;
    if(self.android_tag != nil)
        return self.android_tag;
    return [LGTextView className];
}

+ (NSString*)className
{
	return @"LGTextView";
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(Create:)) 
										:@selector(Create:)
										:[LGTextView class]
										:[NSArray arrayWithObjects:[LuaContext class], [NSString class], nil] 
										:[LGTextView class]] 
			 forKey:@"Create"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetText:)) 
									   :@selector(SetText:)
									   :nil
									   :MakeArray([NSString class]C nil)]
			 forKey:@"SetText"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetTextRef:))
                              :@selector(SetTextRef:)
                              :nil
                              :MakeArray([LuaRef class]C nil)]
             forKey:@"SetTextRef"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetTextColor:)) 
									   :@selector(SetTextColor:)
									   :nil
									   :MakeArray([NSString class]C nil)]
			 forKey:@"SetTextColor"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetTextColorRef:))
                                       :@selector(SetTextColorRef:)
                                       :nil
                                       :MakeArray([LuaRef class]C nil)]
             forKey:@"SetTextColorRef"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(GetText)) 
									   :@selector(GetText)
									   :[NSString class]
									   :MakeArray(nil)]
			 forKey:@"GetText"];
	return dict;
}


@end
