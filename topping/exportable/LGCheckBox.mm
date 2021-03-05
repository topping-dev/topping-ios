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
    self.checkboxSize = CGSizeMake([[LGDimensionParser GetInstance] GetDimension:@"8dp"], [[LGDimensionParser GetInstance] GetDimension:@"8dp"]);
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
	self.checkbox = [BEMCheckBoxText alloc];
    self.checkbox.checkboxSize = self.checkboxSize;
    self.checkbox.checkboxTextInset = UIEdgeInsetsMake(0, self.checkboxSize.width + [[LGDimensionParser GetInstance] GetDimension:@"4dp"], 0, 0);
    self.checkbox = [self.checkbox initWithFrame:CGRectMake(self.dX, self.dY, self.dWidth, self.checkboxSize.height)];
    self.checkbox.checkbox.boxType = BEMBoxTypeSquare;
    
	return self.checkbox;
}

-(void) SetupComponent:(UIView *)view
{
    BOOL checked = [[LGValueParser GetInstance] GetBoolValueDirect:self.android_checked];
    self.checkbox.checkbox.on = checked;
    self.checkbox.checkbox.delegate = self;
    
    self.checkbox.text = [[LGStringParser GetInstance] GetString:self.android_text];
    UIColor *textColor = [[LGColorParser GetInstance] ParseColor:self.android_textColor];
    if(textColor == nil)
        textColor = (UIColor*)[[LGStyleParser GetInstance] GetStyleValue:@"android:textColor" :[sToppingEngine GetAppStyle]];
    self.checkbox.textColor = textColor;
    UIColor *colorAccent = [[LGColorParser GetInstance] ParseColor:self.colorAccent];
    if(colorAccent == nil)
        colorAccent = textColor;
    self.checkbox.checkbox.onTintColor = colorAccent;
    self.checkbox.checkbox.onCheckColor = colorAccent;
    
    if(self.android_textSize != nil)
        self.checkbox.font = [self.checkbox.font fontWithSize:[[LGDimensionParser GetInstance] GetDimension:self.android_textSize]];
    
    if(self.checkbox.text != nil)
    {
        self.checkbox.frame = CGRectMake(self.dX, self.dY, self.dWidth, [self GetContentH]);
    }
    
    LGView *v = [LGView new];
    [v SetupComponent:view];
    v = nil;
}

-(void)didTapCheckBox:(BEMCheckBox *)checkBox
{
    if(self.ltCheckedChanged != nil)
    {
        [self.ltCheckedChanged CallIn:self.lc, [NSNumber numberWithBool:self.checkbox.checkbox.on], nil];
    }
}

//Lua
+(LGCheckBox*)Create:(LuaContext *)context
{
	LGCheckBox *lst = [[LGCheckBox alloc] init];
	[lst InitProperties];
	return lst;
}

-(BOOL) IsChecked
{
	return self.checkbox.checkbox.on;
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
