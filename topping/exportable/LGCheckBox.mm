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

-(void)initProperties
{
	[super initProperties];
    self.checkboxSize = CGSizeMake(51 + 24, 31 + 6);
}

-(int)getContentW
{
	if(self._view != nil)
	{
        return self.checkboxSize.width + [self getStringSize].width;
	}
	return self.checkboxSize.width + [super getContentW];
}

-(int)getContentH
{
	if(self._view != nil)
	{
        float val = self.checkboxSize.height;
        float stringSize = [self getStringSize].height;
        if(stringSize > val)
            val = stringSize;
        return val + [[LGDimensionParser getInstance] getDimension:@"8dp"];
	}
    return [super getContentH];
}

-(UIView*)createComponent
{
	self.checkbox = [CheckBox alloc];
    self.checkbox = [self.checkbox initWithFrame:CGRectMake(self.dX, self.dY, self.dWidth, self.checkboxSize.height)];
    
    [self.checkbox.sw addTarget:self action:@selector(didTapCheckBox:) forControlEvents:UIControlEventValueChanged];
    [self.checkbox.title addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapLabel:)]];
    
	return self.checkbox;
}

-(void) setupComponent:(UIView *)view
{
    BOOL checked = [[LGValueParser getInstance] getBoolValueDirect:self.android_checked];
    self.checkbox.sw.on = checked;
    
    self.checkbox.title.text = [[LGStringParser getInstance] getString:self.android_text];
    if(self.android_textColor != nil) {
        UIColor *textColor = [[LGColorParser getInstance] parseColor:self.android_textColor];
        self.checkbox.title.textColor = textColor;
    }
    
    if(self.colorAccent != nil) {
        UIColor *colorAccent = [[LGColorParser getInstance] parseColor:self.colorAccent];
        self.checkbox.sw.tintColor = colorAccent;
        self.checkbox.sw.onTintColor = colorAccent;
    }
    
    if(self.android_textSize != nil)
        self.checkbox.title.font = [self.checkbox.title.font fontWithSize:[[LGDimensionParser getInstance] getDimension:self.android_textSize]];
    
    if(self.checkbox.title.text != nil)
    {
        self.checkbox.frame = CGRectMake(self.dX, self.dY, self.dWidth, [self getContentH]);
    }
    
    self.checkbox.backgroundColor = [UIColor clearColor];
    self.checkbox.title.backgroundColor = [UIColor clearColor];
    
    LGView *v = [LGView new];
    [v setupComponent:view];
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
        [self.ltCheckedChanged callIn:self.lc, [NSNumber numberWithBool:self.checkbox.sw.on], nil];
    }
}

+(LGCheckBox*)create:(LuaContext *)context
{
	LGCheckBox *lst = [[LGCheckBox alloc] init];
    lst.lc = context;
	[lst initProperties];
	return lst;
}

-(NSString *)getText
{
    return self.checkbox.title.text;
}

-(void)setTextInternal:(NSString *)val
{
    [self.checkbox.title setText:val];
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
    UIColor *val = [[LGColorParser getInstance] parseColor:color];
    [self.checkbox.title setTextColor:val];
}

-(void)setTextColorRef:(LuaRef *)ref
{
    UIColor *val = (UIColor*)[[LGValueParser getInstance] getValue:ref.idRef];
    [self.checkbox.title setTextColor:val];
}

-(BOOL) isChecked
{
	return self.checkbox.sw.on;
}

-(void)setOnCheckedChangedListener:(LuaTranslator*)lt
{
    self.ltCheckedChanged = lt;
}

-(NSString*)GetId
{
    if(self.lua_id != nil)
        return self.lua_id;
    if(self.android_id != nil)
        return self.android_id;
    return [LGCheckBox className];
}

+ (NSString*)className
{
	return @"LGCheckBox";
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(create:)) 
										:@selector(create:)
										:[LGCheckBox class]
										:[NSArray arrayWithObjects:[LuaContext class], [NSString class], nil] 
										:[LGCheckBox class]] 
			 forKey:@"create"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(isChecked)) 
									   :@selector(isChecked)
									   :[LuaBool class]
									   :[NSArray arrayWithObjects:nil]]
			 forKey:@"isChecked"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(setOnCheckedChangedListener:)) :@selector(setOnCheckedChangedListener:) :nil :MakeArray([LuaTranslator class]C nil)] forKey:@"setOnCheckedChangedListener"];
	return dict;
}

@end
