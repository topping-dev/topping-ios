#import "LuaDialog.h"
#import "Defines.h"
#import "LuaFunction.h"
#import "LuaValues.h"
#import "LuaForm.h"
#import "CommonDelegate.h"
#import "ActionSheetDatePicker.h"
#import "MBProgressHUD.h"
#import "LGValueParser.h"
#import "LuaComponentDialog.h"

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
            [self.ltDateSelectedListener callIn:[NSNumber numberWithInt:dateComponents.day], [NSNumber numberWithInt:dateComponents.month], [NSNumber numberWithInt:dateComponents.year], nil];
        }
        else if(self.dialogType == DIALOG_TYPE_TIMEPICKER && self.ltTimeSelectedListener != nil)
        {
            NSDateComponents *dateComponents = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:datePicker.date];
            [self.ltTimeSelectedListener callIn:[NSNumber numberWithInt:dateComponents.hour], [NSNumber numberWithInt:dateComponents.minute], [NSNumber numberWithInt:dateComponents.second], nil];
        }
    }
}

+(void) messageBox:(LuaContext *)context :(LuaRef *)title :(LuaRef *)content
{
    [LuaDialog messageBoxInternal:context :(NSString*)[[LGValueParser getInstance] getValue:title.idRef] :(NSString*)[[LGValueParser getInstance] getValue:content.idRef]];
}

+(void) messageBoxInternal:(LuaContext *)context :(NSString *)title :(NSString *)content
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
        popPresenter.sourceView = [[LuaForm getActiveForm].lgview getView];
        CGRect bounds = [[LuaForm getActiveForm].lgview getView].bounds;
        CGFloat x = CGRectGetMidX(bounds);
        CGFloat y = CGRectGetMidY(bounds);
        popPresenter.sourceRect = CGRectMake(x, y, 0, 0);
        popPresenter.permittedArrowDirections = UIPopoverArrowDirectionUnknown;
    }
    [[LuaForm getActiveForm] presentViewController:controller animated:YES completion:nil];
}

+(LuaDialog *) create:(LuaContext *)context :(int)dialogType
{
	LuaDialog *ld = [[LuaDialog alloc] init];
    ld.dialogType = dialogType;
    ld.maximum_ = 100;
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
            LuaForm *currentForm = [CommonDelegate getActiveForm];
            ld.datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@""
        datePickerMode:UIDatePickerModeDate selectedDate:[NSDate date] doneBlock:^(ActionSheetDatePicker *picker, id selectedDate, id origin)
            {
                //TODO fix this
                if(ld.ltPositiveAction != nil)
                    [ld.ltPositiveAction callIn:nil];
            }
        cancelBlock:^(ActionSheetDatePicker *picker)
            {
                if(ld.ltNegativeAction != nil)
                    [ld.ltNegativeAction callIn:nil];
            } origin:[currentForm view]];
            [((UIDatePicker*)ld.datePicker.pickerView) addTarget:self action:@selector(eventForPicker:) forControlEvents:UIControlEventValueChanged];
        } break;
        case DIALOG_TYPE_TIMEPICKER:
        {
            LuaForm *currentForm = [CommonDelegate getActiveForm];
            ld.datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@""
                                                          datePickerMode:UIDatePickerModeTime
                                                            selectedDate:[NSDate date]
                                                               doneBlock:^(ActionSheetDatePicker *picker, id selectedDate, id origin)
             {
                //TODO fix this
                 if(ld.ltPositiveAction != nil)
                     [ld.ltPositiveAction callIn:nil];
             }
                                             cancelBlock:^(ActionSheetDatePicker *picker)
             {
                 if(ld.ltNegativeAction != nil)
                     [ld.ltNegativeAction callIn:nil];
             } origin:[currentForm view]];
            [((UIDatePicker*)ld.datePicker.pickerView) addTarget:self action:@selector(eventForPicker:) forControlEvents:UIControlEventValueChanged];
        } break;
        case DIALOG_TYPE_CUSTOM:
        {
            ld.componentDialog = [[LuaComponentDialog alloc] initWithContext:context];
        } break;
        default:
            break;
    }
	return ld;
}

-(void)setCancellable:(bool)val
{
    self.cancellable_ = val;
}

-(void)setPositiveButtonInternal:(NSString *)title :(LuaTranslator *)action
{
    if(self.alertController != nil)
    {
        UIAlertAction *action = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(title, @"OK action")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       if(self.ltPositiveAction != nil)
                                           [self.ltPositiveAction callIn:nil];
                                   }];
        [self.alertController addAction:action];
    }
    
	self.ltPositiveAction = action;
}

-(void)setPositiveButton:(LuaRef *)title :(LuaTranslator *)action {
    [self setPositiveButtonInternal:(NSString*)[[LGValueParser getInstance] getValue:title.idRef] :action];
}

-(void)setNegativeButtonInternal:(NSString *)title :(LuaTranslator *)action
{
    if(self.alertController != nil)
    {
        UIAlertAction *action = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(title, @"Cancel action")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       if(self.ltNegativeAction != nil)
                                           [self.ltNegativeAction callIn:nil];
                                   }];
        [self.alertController addAction:action];
    }
    
	self.ltNegativeAction = action;
}

-(void)setNegativeButton:(LuaRef *)title :(LuaTranslator *)action {
    [self setNegativeButtonInternal:(NSString*)[[LGValueParser getInstance] getValue:title.idRef] :action];
}

-(void)setTitle:(NSString *)title
{
    self.title = title;
    if(self.alertController != nil)
        self.alertController.title = title;
    else if(self.datePicker != nil)
        self.datePicker.title = title;
    else if(self.progressView != nil)
        self.progressView.label.text = title;
}

-(void)setTitleRef:(LuaRef *)ref
{
    NSString *title = (NSString*)[[LGValueParser getInstance] getValue:ref.idRef];
    [self setTitle:title];
}

-(void)setMessage:(NSString *)message
{
    if(self.alertController != nil)
        self.alertController.message = message;
    else if(self.datePicker != nil)
        self.datePicker.title = message;
}

-(void)setMessageRef:(LuaRef *)ref
{
    NSString *title = (NSString*)[[LGValueParser getInstance] getValue:ref.idRef];
    [self setMessage:title];
}

-(void)setProgress:(int)value
{
    self.progress_ = value;
    if(self.progress_ > self.maximum_)
        self.progress_ = self.maximum_;
    if(self.progress_ < 0)
        self.progress_ = 0;
    if(self.progressView != nil)
        self.progressView.progress = value;
}

-(void)setMax:(int)value
{
    if(value == 0)
    {
        NSLog(@"LuaDialog: Cannot set maximum 0");
        return;
    }
    self.maximum_ = value;
    if(self.progressView != nil)
        self.progressView.progressObject.totalUnitCount = value;
}

-(void)setDate:(LuaDate *)date
{
    if(self.dialogType == DIALOG_TYPE_DATEPICKER)
    {
        [self.datePicker setValue:date.date forKey:@"selectedDate"];
    }
}

-(void)setDateManual:(int)day :(int)month :(int)year
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

-(void)setTime:(LuaDate *)date
{
    if(self.dialogType == DIALOG_TYPE_TIMEPICKER)
    {
        [self.datePicker setValue:date.date forKey:@"selectedDate"];
    }
}

-(void)setTimeManual:(int)hour :(int)minute
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

-(void)show
{
    if(self.dialogType == DIALOG_TYPE_CUSTOM)
    {
        [((LuaComponentDialog*)self.componentDialog) show];
        return;
    }
    UIViewController *rootVC = (UIViewController*)[CommonDelegate getActiveForm];
    if(self.dialogType == DIALOG_TYPE_PROGRESS)
    {
        self.progressView = [MBProgressHUD showHUDAddedTo:rootVC.view animated:YES];
        self.progressView.progress = self.progress_;
        self.progressView.mode = MBProgressHUDModeAnnularDeterminate;
        self.progressView.progressObject.completedUnitCount = self.maximum_;
    }
    if(self.alertController != nil)
    {
        [rootVC presentViewController:self.alertController animated:YES completion:nil];
    }
    else
    {
        [self.datePicker showActionSheetPicker];
    }
    if(self.cancellable_)
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

-(void)dismiss
{
    if(self.dialogType == DIALOG_TYPE_CUSTOM)
    {
        [((LuaComponentDialog*)self.componentDialog) dismiss];
        return;
    }
    if(self.alertController != nil)
        [self.alertController dismissModalViewControllerAnimated:YES];
    else
        [self.datePicker hidePickerWithCancelAction];
}

-(void)setDateSelectedListener:(LuaTranslator *)lt
{
    self.ltDateSelectedListener = lt;
}

-(void)setTimeSelectedListener:(LuaTranslator *)lt
{
    self.ltTimeSelectedListener = lt;
}

-(void)setCustomViewRef:(LuaRef *)ref {
    if(self.dialogType != DIALOG_TYPE_CUSTOM)
        return;
    
    [((LuaComponentDialog*)self.componentDialog) setContentViewRef:ref];
}

-(void)setCustomView:(LGView*)view {
    if(self.dialogType != DIALOG_TYPE_CUSTOM)
        return;
    
    [((LuaComponentDialog*)self.componentDialog) setContentView:view];
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(buttonIndex == self.positiveButtonId)
	{
		if(self.ltPositiveAction != nil)
			[self.ltPositiveAction callIn:nil];
	}
	else if(buttonIndex == self.negativeButtonId)
	{
		if(self.ltNegativeAction != nil)
			[self.ltNegativeAction callIn:nil];
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
    ClassMethodNoRet(messageBoxInternal:::, @[[LuaContext class]C [NSString class]C [NSString class]], @"messageBoxInternal", [LuaDialog class])
    ClassMethodNoRet(messageBox:::, @[[LuaContext class]C [LuaRef class]C [LuaRef class]], @"messageBox", [LuaDialog class])
    ClassMethod(create::, LuaDialog, @[[LuaContext class]C [LuaInt class]], @"create", [LuaDialog class])
    
    InstanceMethodNoRet(setCancellable:, @[[LuaBool class]], @"setCancellable")
    InstanceMethodNoRet(setPositiveButton::, @[[NSString class]C [LuaTranslator class]], @"setPositiveButton")
    InstanceMethodNoRet(setNegativeButton::, @[[NSString class]C [LuaTranslator class]], @"setNegativeButton")
    
    InstanceMethodNoRet(setTitleRef:, @[[LuaRef class]], @"setTitleRef")
    InstanceMethodNoRet(setTitle:, @[[NSString class]], @"setTitle")
    InstanceMethodNoRet(setMessageRef:, @[[LuaRef class]], @"setMessageRef")
    InstanceMethodNoRet(setMessage:, @[[NSString class]], @"setMessage")
    InstanceMethodNoRet(setProgress:, @[[LuaInt class]], @"setProgress")
    InstanceMethodNoRet(setMax:, @[[LuaInt class]], @"setMax")
    InstanceMethodNoRet(setDate:, @[[LuaDate class]], @"setDate")
    InstanceMethodNoRet(setDateManual:::, @[[LuaInt class]C [LuaInt class]C [LuaInt class]], @"setDateManual")
    InstanceMethodNoRet(setTime:, @[[LuaDate class]], @"setTime")
    InstanceMethodNoRet(setTimeManual::, @[[LuaInt class]C [LuaInt class]], @"setTimeManual")
    InstanceMethodNoRetNoArg(show, @"show")
    InstanceMethodNoRetNoArg(dismiss, @"dismiss")
    InstanceMethodNoRet(setDateSelectedListener:, @[[LuaTranslator class]], @"setDateSelectedListener")
    InstanceMethodNoRet(setTimeSelectedListener:, @[[LuaTranslator class]], @"setTimeSelectedListener")
    InstanceMethodNoRet(setCustomViewRef:, @[[LuaRef class]], @"setCustomViewRef")
    InstanceMethodNoRet(setCustomView:, @[[LGView class]], @"setCustomView")
	
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
    [dict setObject:[NSNumber numberWithInt:DIALOG_TYPE_CUSTOM] forKey:@"DIALOG_TYPE_CUSTOM"];
	return dict;
}

@end
