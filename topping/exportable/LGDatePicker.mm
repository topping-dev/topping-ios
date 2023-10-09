#import "LGDatePicker.h"
#import "Defines.h"
#import "LuaFunction.h"
#import "LuaInt.h"

@implementation LGDatePicker

-(int)getContentW
{
	return 0;
}

-(int)getContentH
{
	return 0;
}

-(UIView*)createComponent
{
	UIDatePicker *dp = [[UIDatePicker alloc] init];
	dp.frame = CGRectMake(self.dX, self.dY, self.dWidth, self.dHeight);
	return dp;
}

-(void) setupComponent:(UIView *)view
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
        self.year_ = (int)[components year];
        self.month_ = (int)[components month];
        self.day_ = (int)[components day];
        [self.ltChanged callIn:[NSNumber numberWithInt:self.day_], [NSNumber numberWithInt:self.month_], [NSNumber numberWithInt:self.year_], nil];
    }
    [self._view endEditing:YES];
}

-(void)ButCancel:(UIView *)sender
{
    if(self.ltChanged != nil)
    {
        [self.ltChanged callIn:nil, nil, nil, nil];
    }
    [self._view endEditing:YES];
}

//Lua
+(LGDatePicker*)create:(LuaContext *)context
{
	LGDatePicker *lst = [[LGDatePicker alloc] init];
    lst.lc = context;
	[lst initProperties];
	return lst;
}

+(LGDatePicker*)Create:(LuaContext *)context :(int)day :(int)month :(int)year
{
    LGDatePicker *lst = [[LGDatePicker alloc] init];
    [lst initProperties];
    return lst;
}

-(void)setOnDateChangedListener:(LuaTranslator *)lt
{
    self.ltChanged = lt;
}

-(void)show
{
    [self.hiddenTextField becomeFirstResponder];
}

-(int)getDay
{
    return self.day_;
}

-(int)getMonth
{
    return self.month_;
}

-(int)getYear
{
    return self.year_;
}

-(void)updateDate:(int)day :(int)month :(int)year
{
    self.day_ = day;
    self.month_ = month;
    self.year_ = year;
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
    return [LGDatePicker className];
}

+ (NSString*)className
{
	return @"LGDatePicker";
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(create:)) 
										:@selector(create:)
										:[LGDatePicker class]
										:[NSArray arrayWithObjects:[LuaContext class], [NSString class], nil] 
										:[LGDatePicker class]] 
			 forKey:@"create"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(show)) :@selector(show) :nil :MakeArray(nil)] forKey:@"show"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(setOnDateChangedListener:)) :@selector(setOnDateChangedListener:) :nil :MakeArray([LuaTranslator class]C nil)] forKey:@"setOnDateChangedListener"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(getDay)) :@selector(getDay) :[LuaInt class] :MakeArray(nil)] forKey:@"getDay"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(getMonth)) :@selector(getMonth) :[LuaInt class] :MakeArray(nil)] forKey:@"getMonth"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(getYear)) :@selector(getYear) :[LuaInt class] :MakeArray(nil)] forKey:@"getYear"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(updateDate:::)) :@selector(updateDate:::) :nil :MakeArray([LuaInt class]C [LuaInt class]C [LuaInt class]C nil)] forKey:@"updateDate"];
	return dict;
}

@end
