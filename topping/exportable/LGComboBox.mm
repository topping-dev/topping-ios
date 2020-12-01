#import "LGComboBox.h"
#import "ToppingEngine.h"
#import "LG.h"
#import "Defines.h"
#import "UILabelPadding.h"
#import <QuartzCore/QuartzCore.h>
#import <ActionSheetPicker_3_0/ActionSheetPicker.h>

@class LuaTranslator;

@implementation Data

-(NSString*)description
{
    return self.name;
}

@end

@implementation LGComboBox

-(UIView*)CreateComponent
{
    UIView *view = [super CreateComponent];
	
	if(self.comboArray == nil)
		self.comboArray = [NSMutableArray array];
    
    return view;
}

-(void)SetupComponent:(UIView *)view
{
    self._view.userInteractionEnabled = YES;
    [self._view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(comboBoxClicked)]];
}

//Lua
+(LGComboBox*)Create:(LuaContext *)context
{
	LGComboBox *lst = [[LGComboBox alloc] init];
	[lst InitProperties];
	return lst;
}

-(void) AddComboItem:(NSString *)name :(NSObject *)value
{
	Data *d = [[Data alloc] init];
	d.name = name;
	d.tag = value;
	[self.comboArray addObject:d];
    
    if(((UILabelPadding*)self._view).text == nil && self.comboArray.count > 0)
        ((UILabelPadding*)self._view).text = [[self.comboArray objectAtIndex:0] description];
}

-(void) ShowCancel:(int)value
{
    self.showCancel = value == 1;
}

-(NSString *) GetSelectedName
{
	if(self.selected != nil)
		return self.selected.name;
	return nil;
}

-(NSObject *) GetSelectedTag
{
	if(self.selected != nil)
		return self.selected.tag;
	return nil;
}

-(void)SetSelected:(int)index
{
    if(index < 0 || index >= self.comboArray.count)
        return;
    
    Data *d = [self.comboArray objectAtIndex:index];
    ((UILabelPadding*)self._view).text = [d description];
    
    if(self.ltCBoxValueChanged == nil)
    {
        [self.ltCBoxValueChanged CallIn:self.lc, d.name, d.tag, nil];
    }
}

-(void)SetOnComboChangedListener:(LuaTranslator*)lt
{
    self.ltCBoxValueChanged = lt;
}

-(void) comboBoxClicked
{
    ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        Data *d = [self.comboArray objectAtIndex:selectedIndex];
        ((UILabelPadding*)self._view).text = [d description];
        self.selected = d;
        if(self.ltCBoxValueChanged != nil)
        {
            [self.ltCBoxValueChanged CallIn:self.lc, d.name, d.tag, nil];
        }
    };

    ActionStringCancelBlock cancel = nil;
    if(self.showCancel)
    {
        cancel = ^(ActionSheetStringPicker *picker)
        {
            if(self.ltCBoxValueChanged != nil)
            {
                [self.ltCBoxValueChanged CallIn:self.lc, nil, nil, nil];
            }
        };
    }

    [ActionSheetStringPicker showPickerWithTitle:@"" rows:self.comboArray initialSelection:0 doneBlock:done cancelBlock:cancel origin:self._view];
}

-(NSString*)GetId
{
	if(self.lua_id != nil)
		return self.lua_id;
	if(self.android_tag != nil)
		return self.android_tag;
	else
		return [LGComboBox className];
}

+ (NSString*)className
{
	return @"LGComboBox";
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(Create::)) 
										:@selector(Create::) 
										:[LGComboBox class]
										:[NSArray arrayWithObjects:[LuaContext class], [NSString class], nil] 
										:[LGComboBox class]] 
			 forKey:@"Create"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(AddComboItem::)) :@selector(AddComboItem::) :nil :MakeArray([NSString class]C [NSObject class]C nil)] forKey:@"AddComboItem"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(ShowCancel:)) :@selector(ShowCancel:) :nil :MakeArray([LuaInt class]C nil)] forKey:@"ShowCancel"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(GetSelectedName)) :@selector(GetSelectedName) :[NSString class] :MakeArray(nil)] forKey:@"GetSelectedName"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(GetSelectedTag)) :@selector(GetSelectedTag) :[NSObject class] :MakeArray(nil)] forKey:@"GetSelectedTag"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetSelected:)) :@selector(SetSelected:) :nil :MakeArray([LuaInt class]C nil)] forKey:@"SetSelected"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetOnComboChangedListener:)) :@selector(SetOnComboChangedListener:) :nil :MakeArray([LuaTranslator class]C nil)] forKey:@"SetOnComboChangedListener"];
	
	return dict;
}

@end
