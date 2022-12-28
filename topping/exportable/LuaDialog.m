#import "LuaDialog.h"
#import "Defines.h"
#import "LuaFunction.h"
#import "LuaValues.h"
#import "LuaForm.h"
#import "CommonDelegate.h"
#import "ActionSheetDatePicker.h"
#import "MBProgressHUD.h"
#import "LGValueParser.h"

@implementation _NoButtonAlertControllerCover
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    CGPoint locationPoint = [[touches anyObject] locationInView:self.superview];
    CGRect frameToCalculate = self.delegate.view.frame;
    /*if([_delegate.subviews count] > 0)
    {
        //frameToCalculate = ((UIView*)[_delegate.subviews objectAtIndex:0]).frame;
    }*/
    BOOL val = CGRectContainsPoint(frameToCalculate, locationPoint);
    if(!val)
    {
        [self removeFromSuperview];
        [self.delegate dismissModalViewControllerAnimated:YES];
    }
    [super touchesEnded:touches withEvent:event];
}
@end

@implementation _NoButtonActionSheetCover
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    CGPoint locationPoint = [[touches anyObject] locationInView:self.superview];
    CGRect frameToCalculate = self.delegate.pickerView.frame;
    /*if([_delegate.subviews count] > 0)
     {
     //frameToCalculate = ((UIView*)[_delegate.subviews objectAtIndex:0]).frame;
     }*/
    BOOL val = CGRectContainsPoint(frameToCalculate, locationPoint);
    if(!val)
    {
        [self removeFromSuperview];
        [self.delegate hidePickerWithCancelAction];
    }
    [super touchesEnded:touches withEvent:event];
}
@end

@implementation LuaDialog

- (void)eventForPicker:(id)sender
{
    if(!sender)
        return;
    if ([sender isKindOfClass:[UIDatePicker class]])
    {
       
        UIDatePicker *datePicker = (UIDatePicker *)sender;
        NSCalendar *calendar = [NSCalendar currentCalendar];
        if(self.dialogType == DIALOG_TYPE_DATEPICKER && self.ltDateSelectedListener != nil)
        {
            NSDateComponents *dateComponents = [calendar components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:datePicker.date];
            [self.ltDateSelectedListener CallIn:[NSNumber numberWithInt:dateComponents.day], [NSNumber numberWithInt:dateComponents.month], [NSNumber numberWithInt:dateComponents.year], nil];
        }
        else if(self.dialogType == DIALOG_TYPE_TIMEPICKER && self.ltTimeSelectedListener != nil)
        {
            NSDateComponents *dateComponents = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:datePicker.date];
            [self.ltTimeSelectedListener CallIn:[NSNumber numberWithInt:dateComponents.hour], [NSNumber numberWithInt:dateComponents.minute], nil];
        }
    }
}

+(void) MessageBox:(LuaContext *)context :(LuaRef *)title :(LuaRef *)content
{
    [LuaDialog MessageBoxInternal:context :(NSString*)[[LGValueParser GetInstance] GetValue:title.idRef] :(NSString*)[[LGValueParser GetInstance] GetValue:content.idRef]];
}

+(void) MessageBoxInternal:(LuaContext *)context :(NSString *)title :(NSString *)content
{
    UIAlertController *controller = [[UIAlertController alloc] init];
    controller.title = title;
    controller.message = content;
    UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", nil) style:UIAlertActionStyleDefault handler:nil];
    [controller addAction:action];
    if(IS_IPAD) {
        [controller setModalPresentationStyle:UIModalPresentationPopover];

        UIPopoverPresentationController *popPresenter = [controller
                                                      popoverPresentationController];
        popPresenter.sourceView = [[LuaForm GetActiveForm].lgview GetView];
        CGRect bounds = [[LuaForm GetActiveForm].lgview GetView].bounds;
        CGFloat x = CGRectGetMidX(bounds);
        CGFloat y = CGRectGetMidY(bounds);
        popPresenter.sourceRect = CGRectMake(x, y, 0, 0);
        popPresenter.permittedArrowDirections = UIPopoverArrowDirectionUnknown;
    }
    [[LuaForm GetActiveForm] presentViewController:controller animated:YES completion:nil];
}

+(LuaDialog *) Create:(LuaContext *)context :(int)dialogType
{
	LuaDialog *ld = [[LuaDialog alloc] init];
    ld.dialogType = dialogType;
    ld.maximum = 100;
    ld.cancellable = YES;
    switch (dialogType)
    {
        case DIALOG_TYPE_NORMAL:
        {
            ld.alertController = [UIAlertController alertControllerWithTitle:@"" message:nil preferredStyle:UIAlertControllerStyleAlert];
        } break;
        case DIALOG_TYPE_PROGRESS:
        {
        } break;
        case DIALOG_TYPE_PROGRESSINDETERMINATE:
        {
        } break;
        case DIALOG_TYPE_DATEPICKER:
        {
            LuaForm *currentForm = [CommonDelegate GetActiveForm];
            ld.datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@""
        datePickerMode:UIDatePickerModeDate selectedDate:[NSDate date] doneBlock:^(ActionSheetDatePicker *picker, id selectedDate, id origin)
            {
                //TODO fix this
                if(ld.ltPositiveAction != nil)
                    [ld.ltPositiveAction CallIn:nil];
            }
        cancelBlock:^(ActionSheetDatePicker *picker)
            {
                if(ld.ltNegativeAction != nil)
                    [ld.ltNegativeAction CallIn:nil];
            } origin:[currentForm view]];
            [((UIDatePicker*)ld.datePicker.pickerView) addTarget:self action:@selector(eventForPicker:) forControlEvents:UIControlEventValueChanged];
        } break;
        case DIALOG_TYPE_TIMEPICKER:
        {
            LuaForm *currentForm = [CommonDelegate GetActiveForm];
            ld.datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@""
                                                          datePickerMode:UIDatePickerModeTime
                                                            selectedDate:[NSDate date]
                                                               doneBlock:^(ActionSheetDatePicker *picker, id selectedDate, id origin)
             {
                //TODO fix this
                 if(ld.ltPositiveAction != nil)
                     [ld.ltPositiveAction CallIn:nil];
             }
                                             cancelBlock:^(ActionSheetDatePicker *picker)
             {
                 if(ld.ltNegativeAction != nil)
                     [ld.ltNegativeAction CallIn:nil];
             } origin:[currentForm view]];
            [((UIDatePicker*)ld.datePicker.pickerView) addTarget:self action:@selector(eventForPicker:) forControlEvents:UIControlEventValueChanged];
        } break;
        default:
            break;
    }
	return ld;
}

-(void)SetCancellable:(bool)val
{
    self.cancellable = val;
}

-(void)SetPositiveButtonInternal:(NSString *)title :(LuaTranslator *)action
{
    if(self.alertController != nil)
    {
        UIAlertAction *action = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(title, @"OK action")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       if(self.ltPositiveAction != nil)
                                           [self.ltPositiveAction CallIn:nil];
                                   }];
        [self.alertController addAction:action];
    }
    
	self.ltPositiveAction = action;
}

-(void)SetPositiveButton:(LuaRef *)title :(LuaTranslator *)action {
    [self SetPositiveButtonInternal:(NSString*)[[LGValueParser GetInstance] GetValue:title.idRef] :action];
}

-(void)SetNegativeButtonInternal:(NSString *)title :(LuaTranslator *)action
{
    if(self.alertController != nil)
    {
        UIAlertAction *action = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(title, @"Cancel action")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       if(self.ltNegativeAction != nil)
                                           [self.ltNegativeAction CallIn:nil];
                                   }];
        [self.alertController addAction:action];
    }
    
	self.ltNegativeAction = action;
}

-(void)SetNegativeButton:(LuaRef *)title :(LuaTranslator *)action {
    [self SetNegativeButtonInternal:(NSString*)[[LGValueParser GetInstance] GetValue:title.idRef] :action];
}

-(void)SetTitle:(NSString *)title
{
    self.title = title;
    if(self.alertController != nil)
        self.alertController.title = title;
    else if(self.datePicker != nil)
        self.datePicker.title = title;
    else if(self.progressView != nil)
        self.progressView.label.text = title;
}

-(void)SetTitleRef:(LuaRef *)ref
{
    NSString *title = (NSString*)[[LGValueParser GetInstance] GetValue:ref.idRef];
    [self SetTitle:title];
}

-(void)SetMessage:(NSString *)message
{
    if(self.alertController != nil)
        self.alertController.message = message;
    else if(self.datePicker != nil)
        self.datePicker.title = message;
}

-(void)SetMessageRef:(LuaRef *)ref
{
    NSString *title = (NSString*)[[LGValueParser GetInstance] GetValue:ref.idRef];
    [self SetMessage:title];
}

-(void)SetProgress:(int)value
{
    self.progress = value;
    if(self.progress > self.maximum)
        self.progress = self.maximum;
    if(self.progress < 0)
        self.progress = 0;
    if(self.progressView != nil)
        self.progressView.progress = value;
}

-(void)SetMax:(int)value
{
    if(value == 0)
    {
        NSLog(@"LuaDialog: Cannot set maximum 0");
        return;
    }
    self.maximum = value;
    if(self.progressView != nil)
        self.progressView.progressObject.totalUnitCount = value;
}

-(void)SetDate:(LuaDate *)date
{
    if(self.dialogType == DIALOG_TYPE_DATEPICKER)
    {
        [self.datePicker setValue:date.date forKey:@"selectedDate"];
    }
}

-(void)SetDateManual:(int)day :(int)month :(int)year
{
    if(self.dialogType == DIALOG_TYPE_DATEPICKER)
    {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *dateComponents = [calendar components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:[NSDate date]];
        [dateComponents setDay:day];
        [dateComponents setMonth:month];
        [dateComponents setYear:year];
        [self.datePicker setValue:[calendar dateFromComponents:dateComponents] forKey:@"selectedDate"];
    }
}

-(void)SetTime:(LuaDate *)date
{
    if(self.dialogType == DIALOG_TYPE_TIMEPICKER)
    {
        [self.datePicker setValue:date.date forKey:@"selectedDate"];
    }
}

-(void)SetTimeManual:(int)hour :(int)minute
{
    if(self.dialogType == DIALOG_TYPE_TIMEPICKER)
    {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *dateComponents = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:[NSDate date]];
        [dateComponents setHour:hour];
        [dateComponents setMinute:minute];
        [self.datePicker setValue:[calendar dateFromComponents:dateComponents] forKey:@"selectedDate"];
    }
}

-(void)Show
{
    UIViewController *rootVC = (UIViewController*)[CommonDelegate GetActiveForm];
    if(self.dialogType == DIALOG_TYPE_PROGRESS)
    {
        self.progressView = [MBProgressHUD showHUDAddedTo:rootVC.view animated:YES];
        self.progressView.progress = self.progress;
        self.progressView.mode = MBProgressHUDModeAnnularDeterminate;
        self.progressView.progressObject.completedUnitCount = self.maximum;
    }
    if(self.alertController != nil)
    {
        [rootVC presentViewController:self.alertController animated:YES completion:nil];
    }
    else
    {
        [self.datePicker showActionSheetPicker];
    }
    if(self.cancellable)
    {
        if(self.alertController != nil)
        {
            _NoButtonAlertControllerCover *cover = [[_NoButtonAlertControllerCover alloc] initWithFrame:[UIScreen mainScreen].bounds];
            cover.userInteractionEnabled = YES;
            cover.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:.01];
            cover.delegate = self.alertController;
            [self.alertController.view.superview addSubview:cover];
            [self.alertController.view.superview bringSubviewToFront:self.alertController.view];
        }
        else
        {
            _NoButtonActionSheetCover *cover = [[_NoButtonActionSheetCover alloc] initWithFrame:[UIScreen mainScreen].bounds];
            cover.userInteractionEnabled = YES;
            cover.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:.01];
            cover.delegate = self.datePicker;
            [self.datePicker.pickerView.superview addSubview:cover];
            [self.datePicker.pickerView.superview bringSubviewToFront:self.datePicker.pickerView];
        }
    }
}

-(void)Dismiss
{
    if(self.alertController != nil)
        [self.alertController dismissModalViewControllerAnimated:YES];
    else
        [self.datePicker hidePickerWithCancelAction];
}

-(void)SetDateSelectedListener:(LuaTranslator *)lt
{
    self.ltDateSelectedListener = lt;
}

-(void)SetTimeSelectedListener:(LuaTranslator *)lt
{
    self.ltTimeSelectedListener = lt;
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(buttonIndex == self.positiveButtonId)
	{
		if(self.ltPositiveAction != nil)
			[self.ltPositiveAction CallIn:nil];
	}
	else if(buttonIndex == self.negativeButtonId)
	{
		if(self.ltNegativeAction != nil)
			[self.ltNegativeAction CallIn:nil];
	}
}

-(NSString*)GetId
{
	return @"LuaDialog"; 
}

+ (NSString*)className
{
	return @"LuaDialog";
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    ClassMethodNoRet(MessageBoxInternal:::, @[[LuaContext class]C [NSString class]C [NSString class]], @"MessageBoxInternal", [LuaDialog class])
    ClassMethodNoRet(MessageBox:::, @[[LuaContext class]C [LuaRef class]C [LuaRef class]], @"MessageBox", [LuaDialog class])
    ClassMethod(Create::, LuaDialog, @[[LuaContext class]C [LuaInt class]], @"Create", [LuaDialog class])
    
    InstanceMethodNoRet(SetCancellable:, @[[LuaBool class]], @"SetCancellable")
    InstanceMethodNoRet(SetPositiveButton::, @[[NSString class]C [LuaTranslator class]], @"SetPositiveButton")
    InstanceMethodNoRet(SetNegativeButton::, @[[NSString class]C [LuaTranslator class]], @"SetNegativeButton")
    
    InstanceMethodNoRet(SetTitleRef:, @[[LuaRef class]], @"SetTitleRef")
    InstanceMethodNoRet(SetTitle:, @[[NSString class]], @"SetTitle")
    InstanceMethodNoRet(SetMessageRef:, @[[LuaRef class]], @"SetMessageRef")
    InstanceMethodNoRet(SetMessage:, @[[NSString class]], @"SetMessage")
    InstanceMethodNoRet(SetProgress:, @[[LuaInt class]], @"SetProgress")
    InstanceMethodNoRet(SetMax:, @[[LuaInt class]], @"SetMax")
    InstanceMethodNoRet(SetDate:, @[[LuaDate class]], @"SetDate")
    InstanceMethodNoRet(SetDateManual:::, @[[LuaInt class]C [LuaInt class]C [LuaInt class]], @"SetDateManual")
    InstanceMethodNoRet(SetTime:, @[[LuaDate class]], @"SetTime")
    InstanceMethodNoRet(SetTimeManual::, @[[LuaInt class]C [LuaInt class]], @"SetTimeManual")
    InstanceMethodNoRetNoArg(Show, @"Show")
    InstanceMethodNoRetNoArg(Dismiss, @"Dismiss")
    InstanceMethodNoRet(SetDateSelectedListener:, @[[LuaTranslator class]], @"SetDateSelectedListener")
    InstanceMethodNoRet(SetTimeSelectedListener:, @[[LuaTranslator class]], @"SetTimeSelectedListener")
	
	return dict;
}

+(NSMutableDictionary *)luaStaticVars
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	[dict setObject:[NSNumber numberWithInt:DIALOG_TYPE_NORMAL] forKey:@"DIALOG_TYPE_NORMAL"];
	[dict setObject:[NSNumber numberWithInt:DIALOG_TYPE_PROGRESS] forKey:@"DIALOG_TYPE_PROGRESS"];
	[dict setObject:[NSNumber numberWithInt:DIALOG_TYPE_PROGRESSINDETERMINATE] forKey:@"DIALOG_TYPE_PROGRESSINDETERMINATE"];
    [dict setObject:[NSNumber numberWithInt:DIALOG_TYPE_DATEPICKER] forKey:@"DIALOG_TYPE_DATEPICKER"];
    [dict setObject:[NSNumber numberWithInt:DIALOG_TYPE_TIMEPICKER] forKey:@"DIALOG_TYPE_TIMEPICKER"];
	return dict;
}

@end
