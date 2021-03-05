#import "LGDatePicker.h"
#import "Defines.h"
#import "LuaFunction.h"
#import "LuaInt.h"

@implementation LGDatePicker

-(int)GetContentW
{
	return 0;
}

-(int)GetContentH
{
	return 0;
}

-(UIView*)CreateComponent
{
	UIDatePicker *dp = [[UIDatePicker alloc] init];
	dp.frame = CGRectMake(self.dX, self.dY, self.dWidth, self.dHeight);
	return dp;
}

-(void) SetupComponent:(UIView *)view
{
	UIDatePicker *cb = (UIDatePicker*)self._view;
    self.hiddenTextField = [[UITextField alloc] init];
    self.hiddenTextField.hidden = YES;
    [cb addSubview:self.hiddenTextField];
    cb.datePickerMode = UIDatePickerModeDate;
    UIToolbar *tb = [[UIToolbar alloc] init];
    [tb sizeToFit];
    
    //TODO:Translate this
    UIBarButtonItem *butOk = [[UIBarButtonItem alloc] initWithTitle:@"Ok" style:UIBarButtonItemStyleDone target:self action:@selector(ButOk:)];
    UIBarButtonItem *butSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *butCancel = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(ButCancel:)];
    [tb setItems:@[butOk, butSpace, butCancel]];
    
    self.hiddenTextField.inputAccessoryView = tb;
    self.hiddenTextField.inputView = cb;
}

-(void)ButOk:(UIView *)sender
{
    UIDatePicker *cb = (UIDatePicker*)self._view;
    if(self.ltChanged != nil)
    {
        NSDateComponents *components = [cb.calendar components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:cb.date];
        self.year = [components year];
        self.month = [components month];
        self.day = [components day];
        [self.ltChanged CallIn:[NSNumber numberWithInt:self.day], [NSNumber numberWithInt:self.month], [NSNumber numberWithInt:self.year], nil];
    }
    [self._view endEditing:YES];
}

-(void)ButCancel:(UIView *)sender
{
    if(self.ltChanged != nil)
    {
        [self.ltChanged CallIn:nil, nil, nil, nil];
    }
    [self._view endEditing:YES];
}

//Lua
+(LGDatePicker*)Create:(LuaContext *)context
{
	LGDatePicker *lst = [[LGDatePicker alloc] init];
	[lst InitProperties];
	return lst;
}

+(LGDatePicker*)Create:(LuaContext *)context :(int)day :(int)month :(int)year
{
    LGDatePicker *lst = [[LGDatePicker alloc] init];
    [lst InitProperties];
    return lst;
}

-(void)SetOnDateChangedListener:(LuaTranslator *)lt
{
    self.ltChanged = lt;
}

-(void)Show
{
    [self.hiddenTextField becomeFirstResponder];
}

-(int)GetDay
{
    return self.day;
}

-(int)GetMonth
{
    return self.month;
}

-(int)GetYear
{
    return self.year;
}

-(void)UpdateDate:(int)day :(int)month :(int)year
{
    self.day = day;
    self.month = month;
    self.year = year;
    UIDatePicker *cb = (UIDatePicker*)self._view;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear fromDate:[NSDate date]];
    components.day = day;
    components.month = month;
    components.year = year;
    [cb setDate:[calendar dateFromComponents:components]];
}

-(NSString*)GetId
{
    if(self.lua_id != nil)
        return self.lua_id;
    if(self.android_id != nil)
        return self.android_id;
    if(self.android_tag != nil)
        return self.android_tag;
    return [LGDatePicker className];
}

+ (NSString*)className
{
	return @"LGDatePicker";
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(Create:)) 
										:@selector(Create:)
										:[LGDatePicker class]
										:[NSArray arrayWithObjects:[LuaContext class], [NSString class], nil] 
										:[LGDatePicker class]] 
			 forKey:@"Create"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(Show)) :@selector(Show) :nil :MakeArray(nil)] forKey:@"Show"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetOnDateChangedListener:)) :@selector(SetOnDateChangedListener:) :nil :MakeArray([LuaTranslator class]C nil)] forKey:@"SetOnDateChangedListener"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(GetDay)) :@selector(GetDay) :[LuaInt class] :MakeArray(nil)] forKey:@"GetDay"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(GetMonth)) :@selector(GetMonth) :[LuaInt class] :MakeArray(nil)] forKey:@"GetMonth"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(GetYear)) :@selector(GetYear) :[LuaInt class] :MakeArray(nil)] forKey:@"GetYear"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(UpdateDate:::)) :@selector(UpdateDate:::) :nil :MakeArray([LuaInt class]C [LuaInt class]C [LuaInt class]C nil)] forKey:@"UpdateDate"];
	return dict;
}

@end
