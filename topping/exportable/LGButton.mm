#import "LGButton.h"
#import "Defines.h"
#import "LGColorParser.h"
#import "LGValueParser.h"
#import "LuaFunction.h"
#import "LuaTranslator.h"

@class LuaTranslator;

@implementation LGButton

//Image here?
-(int)GetContentW
{
	int w = [super GetContentW];
	/*if (img_base != null && w < img_base.getWidth(null)) {
		return img_base.getWidth(null);
	}*/
	return w;
}

-(int)GetContentH
{
	/*if (img_base != null) {
		return img_base.getHeight(null)-4;
	}
	else {*/
	return self.fontSize * 2;
	//}
}

-(void)InitProperties
{
    [super InitProperties];
    
    self.fontSize = [UIFont buttonFontSize];
}

-(UIView*)CreateComponent
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

-(void)SetupComponent:(UIView *)view
{
    [super SetupComponent:view];
    
    UIButton *but = (UIButton*)self._view;
    but.userInteractionEnabled = YES;
    but.enabled = YES;
    but.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    but.titleLabel.numberOfLines = 0;
    but.titleLabel.textAlignment = NSTextAlignmentCenter;
    NSString *myNewLineStr = @"\n";
    self.android_text = REPLACE(self.android_text, @"\\n", myNewLineStr);
	[but setTitle:self.android_text forState:UIControlStateNormal];
	[but setTitle:self.android_text forState:UIControlStateSelected];
	[but setTitle:self.android_text forState:UIControlStateDisabled];
	[but setTitle:self.android_text forState:UIControlStateHighlighted];
    if(self.colorAccent != nil)
    {
        UIColor *color = [[LGColorParser GetInstance] ParseColor:self.colorAccent];
        [but setTitleColor:color forState:UIControlStateNormal];
        [but setTitleColor:color forState:UIControlStateSelected];
        [but setTitleColor:color forState:UIControlStateDisabled];
        [but setTitleColor:color forState:UIControlStateHighlighted];

    }
    if(self.android_textColor != nil)
    {
        UIColor *color = [[LGColorParser GetInstance] ParseColor:self.android_textColor];
        [but setTitleColor:color forState:UIControlStateNormal];
        [but setTitleColor:color forState:UIControlStateSelected];
        [but setTitleColor:color forState:UIControlStateDisabled];
        [but setTitleColor:color forState:UIControlStateHighlighted];

    }
	if(self.backgroundImage != nil)
	{
		[but setBackgroundColor:[UIColor clearColor]];
        [but setOpaque:NO];
		[but setBackgroundImage:self.backgroundImage forState:UIControlStateNormal];
		[but setBackgroundImage:self.backgroundImage forState:UIControlStateDisabled];
		[but setBackgroundImage:self.backgroundImage forState:UIControlStateHighlighted];
		[but setBackgroundImage:self.backgroundImage forState:UIControlStateDisabled];
	}
}

//Lua
+(LGButton*)Create:(LuaContext *)context
{
	LGButton *lst = [[LGButton alloc] init];
	[lst InitProperties];
	return lst;
}

- (NSString *)GetText
{
    UIButton *but = (UIButton*)self._view;
    return but.currentTitle;
}

-(void)SetTextInternal:(NSString *)val
{
    UIButton *but = (UIButton*)self._view;
    [but setTitle:val forState:UIControlStateNormal];
    [but setTitle:val forState:UIControlStateFocused];
    [but setTitle:val forState:UIControlStateDisabled];
    [but setTitle:val forState:UIControlStateSelected];
    [but setTitle:val forState:UIControlStateHighlighted];
    self.android_text = val;
    [self ResizeOnText];
}

-(void)SetText:(LuaRef *)ref
{
    NSString *val = (NSString*)[[LGValueParser GetInstance] GetValue:ref.idRef];
    [self SetTextInternal:val];
}

-(void)SetTextColor:(LuaRef *)ref
{
    UIColor *val = (UIColor*)[[LGValueParser GetInstance] GetValue:ref.idRef];
    UIButton *but = (UIButton*)self._view;
    [but setTitleColor:val forState:UIControlStateNormal];
    [but setTitleColor:val forState:UIControlStateFocused];
    [but setTitleColor:val forState:UIControlStateDisabled];
    [but setTitleColor:val forState:UIControlStateSelected];
    [but setTitleColor:val forState:UIControlStateHighlighted];
}

-(void)didClickButton
{
    if(self.ltOnClickListener != nil) {
        [self.ltOnClickListener CallIn:self.lc, nil];
    }
}

-(void)SetOnClickListener:(LuaTranslator *)lt
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
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(Create:))
										:@selector(Create:) 
										:[LGButton class]
										:[NSArray arrayWithObjects:[LuaContext class], [NSString class], nil] 
										:[LGButton class]] 
			 forKey:@"Create"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetOnClickListener:)) :@selector(SetOnClickListener:) :nil :MakeArray([LuaTranslator class]C nil)] forKey:@"SetOnClickListener"];
	return dict;
}

@end
