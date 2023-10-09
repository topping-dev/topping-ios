#import "LGButton.h"
#import "Defines.h"
#import "LGColorParser.h"
#import "LGValueParser.h"
#import "LGDrawableParser.h"
#import "LGStringParser.h"
#import "LuaFunction.h"
#import "LuaTranslator.h"
#import "UIColor+Lum.h"

@class LuaTranslator;

@implementation LGButton

//Image here?
-(int)getContentW
{
	int w = [super getContentW];
	/*if (img_base != null && w < img_base.getWidth(null)) {
		return img_base.getWidth(null);
	}*/
	return w;
}

-(int)getContentH
{
	/*if (img_base != null) {
		return img_base.getHeight(null)-4;
	}
	else {*/
	return self.fontSize * 2;
	//}
}

-(void)initProperties
{
    [super initProperties];
    
    self.fontSize = [UIFont buttonFontSize];
}

-(UIView*)createComponent
{
	UIButton *but = nil;
	if(ISNULLOREMPTY(self.android_background))
		but = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	else
		but = [UIButton buttonWithType:UIButtonTypeCustom];
	but.frame = CGRectMake(self.dX, self.dY, self.dWidth, self.dHeight);
    [but addTarget:self action:@selector(didClickButton) forControlEvents:UIControlEventTouchUpInside];
	return but;	
}

-(void)setupComponent:(UIView *)view
{
    [super setupComponent:view];
    
    UIButton *but = (UIButton*)self._view;
    but.userInteractionEnabled = YES;
    but.enabled = YES;
    but.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    but.titleLabel.numberOfLines = 0;
    but.titleLabel.textAlignment = NSTextAlignmentCenter;
    NSString *text = [[LGStringParser getInstance] getString:self.android_text];
    NSString *myNewLineStr = @"\n";
    [self setTextInternal:REPLACE(text, @"\\n", myNewLineStr)];
    if(self.colorAccent != nil)
    {
        [self setTextColor:self.colorAccent];

    }
    if(self.android_textColor != nil)
    {
        [self setTextColor:self.android_textColor];

    }
	if(self.android_background != nil)
	{
        [self setBackground:[LuaRef withValue:self.android_background]];
	}
}

/*-(void)applyStyles {
    if(self.style == nil)
        self.style = @"Theme.MaterialComponents.Button";
    
    [super applyStyles];
}*/

//Lua
+(LGButton*)create:(LuaContext *)context
{
	LGButton *lst = [[LGButton alloc] init];
    lst.lc = context;
	[lst initProperties];
	return lst;
}

- (NSString *)getText
{
    UIButton *but = (UIButton*)self._view;
    return but.currentTitle;
}

-(void)setTextInternal:(NSString *)val
{
    UIButton *but = (UIButton*)self._view;
    [but setTitle:val forState:UIControlStateNormal];
    [but setTitle:val forState:UIControlStateFocused];
    [but setTitle:val forState:UIControlStateDisabled];
    [but setTitle:val forState:UIControlStateSelected];
    [but setTitle:val forState:UIControlStateHighlighted];
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
    UIButton *but = (UIButton*)self._view;
    LGColorState *lcs = [[LGColorParser getInstance] getColorState:color];
    if(lcs != nil) {
        [but setTitleColor:[lcs getColorForState:UIControlStateNormal :[but titleColorForState:UIControlStateNormal]] forState:UIControlStateNormal];
        [but setTitleColor:[lcs getColorForState:UIControlStateFocused :[but titleColorForState:UIControlStateFocused]] forState:UIControlStateFocused];
        [but setTitleColor:[lcs getColorForState:UIControlStateDisabled :[but titleColorForState:UIControlStateDisabled]] forState:UIControlStateDisabled];
        [but setTitleColor:[lcs getColorForState:UIControlStateSelected :[but titleColorForState:UIControlStateSelected]] forState:UIControlStateSelected];
        [but setTitleColor:[lcs getColorForState:UIControlStateHighlighted :[but titleColorForState:UIControlStateHighlighted]] forState:UIControlStateHighlighted];
        [but setTitleColor:lcs.color forState:[lcs getUIControlStateFlag]];
    } else {
        UIColor *val = (UIColor*)[[LGValueParser getInstance] getValue:color];
        [but setTitleColor:val forState:UIControlStateNormal];
        [but setTitleColor:val forState:UIControlStateFocused];
        [but setTitleColor:val forState:UIControlStateDisabled];
        [but setTitleColor:val forState:UIControlStateSelected];
        [but setTitleColor:val forState:UIControlStateHighlighted];
    }
}

-(void)setTextColorRef:(LuaRef *)ref
{
    [self setTextColor:ref.idRef];
}

-(void)setBackground:(LuaRef *)ref {
    UIButton *but = (UIButton*)self._view;
    [but setBackgroundColor:[UIColor clearColor]];
    [but setOpaque:NO];
    NSObject *obj = [[LGValueParser getInstance] getValue:ref.idRef];
    if([obj isKindOfClass:[LGDrawableReturn class]])
    {
        LGDrawableReturn *ldr = (LGDrawableReturn*)obj;
        if(ldr.img != nil)
        {
            if(ldr.hasState) {
                [but setBackgroundImage:[ldr getImageForState:self._view.frame.size :UIControlStateNormal :[but backgroundImageForState:UIControlStateNormal]] forState:UIControlStateNormal];
                [but setBackgroundImage:[ldr getImageForState:self._view.frame.size :UIControlStateDisabled :[but backgroundImageForState:UIControlStateDisabled]] forState:UIControlStateDisabled];
                [but setBackgroundImage:[ldr getImageForState:self._view.frame.size :UIControlStateHighlighted :[but backgroundImageForState:UIControlStateHighlighted]] forState:UIControlStateHighlighted];
                [but setBackgroundImage:[ldr getImageForState:self._view.frame.size :UIControlStateSelected :[but backgroundImageForState:UIControlStateSelected]] forState:UIControlStateSelected];
            }
            else {
                [but setBackgroundImage:ldr.img forState:UIControlStateNormal];
                [but setBackgroundImage:ldr.img forState:UIControlStateDisabled];
                [but setBackgroundImage:ldr.img forState:UIControlStateHighlighted];
                [but setBackgroundImage:ldr.img forState:UIControlStateSelected];
            }
        }
    }
    else if([obj isKindOfClass:[UIColor class]])
    {
        self._view.backgroundColor = (UIColor*)obj;
    }
    else
    {
        self._view.backgroundColor = [UIColor clearColor];
    }
}

-(void)didClickButton
{
    if(self.ltOnClickListener != nil) {
        [self.ltOnClickListener callIn:self.lc, nil];
    }
}

-(void)setOnClickListener:(LuaTranslator *)lt
{
    self.ltOnClickListener = lt;
}

-(NSString*)GetId
{
    if(self.lua_id != nil)
        return self.lua_id;
    if(self.android_id != nil)
        return self.android_id;
    return [LGButton className];
}

+ (NSString*)className
{
	return @"LGButton";
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(create:))
										:@selector(create:) 
										:[LGButton class]
										:[NSArray arrayWithObjects:[LuaContext class], nil] 
										:[LGButton class]] 
			 forKey:@"create"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(setOnClickListener:)) :@selector(setOnClickListener:) :nil :MakeArray([LuaTranslator class]C nil)] forKey:@"setOnClickListener"];
	return dict;
}

@end
