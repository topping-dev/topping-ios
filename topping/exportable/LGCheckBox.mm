#import "LGCheckBox.h"
#import "Defines.h"
#import "LuaFunction.h"
#import "LGStringParser.h"
#import "LGValueParser.h"
#import "LGDimensionParser.h"
#import "LGColorParser.h"
#import "LGStyleParser.h"
#import "LuaTranslator.h"
#import "LuaValues.h"

@implementation LGCheckBox

-(void)InitProperties
{
	[super InitProperties];
    self.checkboxSize = CGSizeMake(51 + 24, 31 + 6);
}

-(int)GetContentW
{
	if(self._view != nil)
	{
        return self.checkboxSize.width + [self GetStringSize].width;
	}
	return self.checkboxSize.width + [super GetContentW];
}

-(int)GetContentH
{
	if(self._view != nil)
	{
        float val = self.checkboxSize.height;
        float stringSize = [self GetStringSize].height;
        if(stringSize > val)
            val = stringSize;
        return val + [[LGDimensionParser GetInstance] GetDimension:@"8dp"];
	}
    return [super GetContentH];
}

-(UIView*)CreateComponent
{
	self.checkbox = [CheckBox alloc];
    self.checkbox = [self.checkbox initWithFrame:CGRectMake(self.dX, self.dY, self.dWidth, self.checkboxSize.height)];
    
    [self.checkbox.sw addTarget:self action:@selector(didTapCheckBox:) forControlEvents:UIControlEventValueChanged];
    [self.checkbox.title addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapLabel:)]];
    
	return self.checkbox;
}

-(void) SetupComponent:(UIView *)view
{
    BOOL checked = [[LGValueParser GetInstance] GetBoolValueDirect:self.android_checked];
    self.checkbox.sw.on = checked;
    
    self.checkbox.title.text = [[LGStringParser GetInstance] GetString:self.android_text];
    UIColor *textColor = [[LGColorParser GetInstance] ParseColor:self.android_textColor];
    if(textColor == nil)
        textColor = (UIColor*)[[LGStyleParser GetInstance] GetStyleValue:@"android:textColor" :[sToppingEngine GetAppStyle]];
    self.checkbox.title.textColor = textColor;
    UIColor *colorAccent = [[LGColorParser GetInstance] ParseColor:self.colorAccent];
    if(colorAccent == nil)
        colorAccent = textColor;
    self.checkbox.sw.tintColor = colorAccent;
    self.checkbox.sw.onTintColor = colorAccent;
    
    if(self.android_textSize != nil)
        self.checkbox.title.font = [self.checkbox.title.font fontWithSize:[[LGDimensionParser GetInstance] GetDimension:self.android_textSize]];
    
    if(self.checkbox.title.text != nil)
    {
        self.checkbox.frame = CGRectMake(self.dX, self.dY, self.dWidth, [self GetContentH]);
    }
    
    LGView *v = [LGView new];
    [v SetupComponent:view];
    v = nil;
}

-(void)didTapLabel:(CheckBox *)checkBox
{
    [self.checkbox.sw setOn:!self.checkbox.sw.isOn animated:YES];
    [self didTapCheckBox:checkBox];
}

-(void)didTapCheckBox:(CheckBox *)checkBox
{
    if(self.ltCheckedChanged != nil)
    {
        [self.ltCheckedChanged CallIn:self.lc, [NSNumber numberWithBool:self.checkbox.sw.on], nil];
    }
}

//Lua
+(LGCheckBox*)Create:(LuaContext *)context
{
	LGCheckBox *lst = [[LGCheckBox alloc] init];
	[lst InitProperties];
	return lst;
}

-(NSString *)GetText
{
    return self.checkbox.title.text;
}

-(void)SetText:(NSString *)val
{
    [self.checkbox.title setText:val];
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
    UIColor *val = [[LGColorParser GetInstance] ParseColor:color];
    [self.checkbox.title setTextColor:val];
}

-(void)SetTextColorRef:(LuaRef *)ref
{
    UIColor *val = (UIColor*)[[LGValueParser GetInstance] GetValue:ref.idRef];
    [self.checkbox.title setTextColor:val];
}

-(BOOL) IsChecked
{
	return self.checkbox.sw.on;
}

-(void)SetOnCheckedChangedListener:(LuaTranslator*)lt
{
    self.ltCheckedChanged = lt;
}

-(NSString*)GetId
{
    if(self.lua_id != nil)
        return self.lua_id;
    if(self.android_id != nil)
        return self.android_id;
    if(self.android_tag != nil)
        return self.android_tag;
    return [LGCheckBox className];
}

+ (NSString*)className
{
	return @"LGCheckBox";
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(Create:)) 
										:@selector(Create:)
										:[LGCheckBox class]
										:[NSArray arrayWithObjects:[LuaContext class], [NSString class], nil] 
										:[LGCheckBox class]] 
			 forKey:@"Create"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(IsChecked)) 
									   :@selector(IsChecked)
									   :[LuaBool class]
									   :[NSArray arrayWithObjects:nil]]
			 forKey:@"IsChecked"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetOnCheckedChangedListener:)) :@selector(SetOnCheckedChangedListener:) :nil :MakeArray([LuaTranslator class]C nil)] forKey:@"SetOnCheckedChangedListener"];
	return dict;
}

@end
