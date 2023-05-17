#import "LGComboBox.h"
#import "ToppingEngine.h"
#import "LG.h"
#import "Defines.h"
#import "UILabelPadding.h"
#import <QuartzCore/QuartzCore.h>
#import "ActionSheetPicker.h"

@class LuaTranslator;

@implementation ComboData

-(NSString*)description
{
    return self.name;
}

@end

@implementation LGComboBox

-(UIView*)createComponent
{
    UIView *view = [super createComponent];
	
	if(self.comboArray == nil)
		self.comboArray = [NSMutableArray array];
    
    return view;
}

-(void)setupComponent:(UIView *)view
{
    self._view.userInteractionEnabled = YES;
    [self._view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(comboBoxClicked)]];
    if(self.multiLine)
    {
        UITextView *field = (UITextView*)self._view;
        field.editable = false;
    }
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return NO;
}

//Lua
+(LGComboBox*)create:(LuaContext *)context
{
	LGComboBox *lst = [[LGComboBox alloc] init];
	[lst initProperties];
	return lst;
}

-(void) addItem:(NSString *)name :(NSObject *)value
{
	ComboData *d = [[ComboData alloc] init];
	d.name = name;
	d.tag = value;
	[self.comboArray addObject:d];
    
    if(((UILabelPadding*)self._view).text == nil && self.comboArray.count > 0)
        ((UILabelPadding*)self._view).text = [[self.comboArray objectAtIndex:0] description];
}

-(void) setItems:(NSMutableDictionary *)values
{
    [self.comboArray removeAllObjects];
    for(NSString *key in values.allKeys)
    {
        [self addItem:[values objectForKey:key] :key];
    }
}

-(void) showCancel:(int)value
{
    self.showCancel = value == 1;
}

-(NSString *) getSelectedName
{
	if(self.selected != nil)
		return self.selected.name;
	return nil;
}

-(NSObject *) getSelectedTag
{
	if(self.selected != nil)
		return self.selected.tag;
	return nil;
}

-(void)setSelectedIndex:(int)index
{
    if(index < 0 || index >= self.comboArray.count)
        return;
    
    ComboData *d = [self.comboArray objectAtIndex:index];
    ((UILabelPadding*)self._view).text = [d description];
    
    if(self.ltCBoxValueChanged == nil)
    {
        [self.ltCBoxValueChanged callIn:self.lc, d.name, d.tag, nil];
    }
}

-(void)setOnComboChangedListener:(LuaTranslator*)lt
{
    self.ltCBoxValueChanged = lt;
}

-(void) comboBoxClicked
{
    ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        ComboData *d = [self.comboArray objectAtIndex:selectedIndex];
        ((UILabelPadding*)self._view).text = [d description];
        self.selected = d;
        if(self.ltCBoxValueChanged != nil)
        {
            [self.ltCBoxValueChanged callIn:self.lc, d.name, d.tag, nil];
        }
    };

    ActionStringCancelBlock cancel = nil;
    if(self.showCancel)
    {
        cancel = ^(ActionSheetStringPicker *picker)
        {
            if(self.ltCBoxValueChanged != nil)
            {
                [self.ltCBoxValueChanged callIn:self.lc, nil, nil, nil];
            }
        };
    }

    [ActionSheetStringPicker showPickerWithTitle:@"" rows:self.comboArray initialSelection:0 doneBlock:done cancelBlock:cancel origin:self._view];
}

-(NSString*)GetId
{
    if(self.lua_id != nil)
        return self.lua_id;
    if(self.android_id != nil)
        return self.android_id;
    return [LGComboBox className];
}

+ (NSString*)className
{
	return @"LGComboBox";
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(create:))
										:@selector(create:) 
										:[LGComboBox class]
										:[NSArray arrayWithObjects:[LuaContext class], [NSString class], nil] 
										:[LGComboBox class]] 
			 forKey:@"create"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(addItem::)) :@selector(addItem::) :nil :MakeArray([NSString class]C [NSObject class]C nil)] forKey:@"addItem"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(setItems:)) :@selector(setItems:) :nil :MakeArray([NSMutableDictionary class]C nil)] forKey:@"setItems"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(showCancel:)) :@selector(showCancel:) :nil :MakeArray([LuaInt class]C nil)] forKey:@"showCancel"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(getSelectedName)) :@selector(getSelectedName) :[NSString class] :MakeArray(nil)] forKey:@"getSelectedName"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(getSelectedTag)) :@selector(getSelectedTag) :[NSObject class] :MakeArray(nil)] forKey:@"getSelectedTag"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(setSelectedIndex:)) :@selector(setSelectedIndex:) :nil :MakeArray([LuaInt class]C nil)] forKey:@"setSelectedIndex"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(setOnComboChangedListener:)) :@selector(setOnComboChangedListener:) :nil :MakeArray([LuaTranslator class]C nil)] forKey:@"setOnComboChangedListener"];
	
	return dict;
}

@end
