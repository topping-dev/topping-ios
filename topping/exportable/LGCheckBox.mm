#import "LGCheckBox.h"
#import "Defines.h"
#import "LuaFunction.h"
#import "LGStringParser.h"
#import "LGValueParser.h"
#import "LGDimensionParser.h"
#import "LGColorParser.h"
#import "LuaTranslator.h"
#import "LuaValues.h"

@implementation LGCheckBox

-(void)InitProperties
{
	[super InitProperties];
    self.checkboxSize = CGSizeMake([[LGDimensionParser GetInstance] GetDimension:@"18dp"], [[LGDimensionParser GetInstance] GetDimension:@"18dp"]);
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
        return self.checkboxSize.height + [self GetStringSize].height;
	}
    return [super GetContentH];
}

-(UIView*)CreateComponent
{
	self.checkbox = [BEMCheckBoxText new];    
	self.checkbox.frame = CGRectMake(self.dX, self.dY, self.dWidth, self.checkboxSize.height);
    self.checkbox.checkboxTextInset = UIEdgeInsetsMake(0, self.checkboxSize.width + [[LGDimensionParser GetInstance] GetDimension:@"4dp"], 0, 0);
    self.checkbox.boxType = BEMBoxTypeSquare;
    
	return self.checkbox;
}

-(void) SetupComponent:(UIView *)view
{
    BOOL checked = [[LGValueParser GetInstance] GetBoolValueDirect:self.android_checked];
    self.checkbox.on = checked;
    self.checkbox.delegate = self;
    
    self.checkbox.text = [[LGStringParser GetInstance] GetString:self.android_text];
    self.checkbox.textColor = [[LGColorParser GetInstance] ParseColor:self.android_textColor];
    UIColor *colorAccent = [[LGColorParser GetInstance] ParseColor:self.colorAccent];
    self.checkbox.onTintColor = colorAccent;
    self.checkbox.onCheckColor = colorAccent;
    
    if(self.android_textSize != nil)
        self.checkbox.font = [self.checkbox.label.font fontWithSize:[[LGDimensionParser GetInstance] GetDimension:self.android_textSize]];
    
    LGView *v = [LGView new];
    [v SetupComponent:view];
    v = nil;
}

-(void)didTapCheckBox:(BEMCheckBox *)checkBox
{
    if(self.ltCheckedChanged != nil)
    {
        [self.ltCheckedChanged CallIn:self.lc, [NSNumber numberWithBool:self.checkbox.on], nil];
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
	return self.checkbox.on;
}

-(void)SetOnCheckedChangedListener:(LuaTranslator*)lt
{
    self.ltCheckedChanged = lt;
}

-(NSString*)GetId
{
	if(self.lua_id != nil)
		return self.lua_id;
	if(self.android_tag != nil)
		return self.android_tag;
	else
		return [LGCheckBox className];
}

+ (NSString*)className
{
	return @"LGCheckBox";
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(Create::)) 
										:@selector(Create::) 
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
