//#define USE_ACTION_SHEET

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LuaInterface.h"
#import "LuaClass.h"
#import "LuaContext.h"
#import "LuaDate.h"
#import "LuaTranslator.h"
#import "LuaRef.h"

@class ActionSheetDatePicker;
@class MBProgressHUD;

@interface _NoButtonAlertControllerCover : UIView
@property (nonatomic,assign) UIAlertController *delegate;
@end

@interface _NoButtonActionSheetCover : UIView
@property (nonatomic,assign) ActionSheetDatePicker *delegate;
@end

#define DIALOG_TYPE_NORMAL 1
#define DIALOG_TYPE_PROGRESS 2
#define DIALOG_TYPE_PROGRESSINDETERMINATE 6
#define DIALOG_TYPE_DATEPICKER 8
#define DIALOG_TYPE_TIMEPICKER 16

@interface LuaDialog : NSObject<LuaClass, LuaInterface, UIAlertViewDelegate>
{
}

+(void)MessageBox:(LuaContext*)context :(NSString*)title :(NSString*)content;
+(LuaDialog*)Create:(LuaContext*)context :(int)dialogType;
-(void)SetCancellable:(bool)val;
-(void)SetPositiveButton:(NSString*)title :(LuaTranslator*)action;
-(void)SetNegativeButton:(NSString*)title :(LuaTranslator*)action;
-(void)SetTitle:(NSString*)title;
-(void)SetTitleRef:(LuaRef*)ref;
-(void)SetMessage:(NSString*)message;
-(void)SetMessageRef:(LuaRef*)ref;
-(void)SetProgress:(int)value;
-(void)SetMax:(int)value;
-(void)SetDate:(LuaDate*)date;
-(void)SetDateManual:(int)day :(int)month :(int)year;
-(void)SetTime:(LuaDate*)date;
-(void)SetTimeManual:(int)hour :(int)minute;
-(void)Show;
-(void)Dismiss;
-(void)SetDateSelectedListener:(LuaTranslator*)action;
-(void)SetTimeSelectedListener:(LuaTranslator*)action;

@property(nonatomic) int dialogType;
@property(nonatomic, retain) MBProgressHUD *progressView;
@property(nonatomic, retain) UIAlertController *alertController;
@property(nonatomic, retain) ActionSheetDatePicker *datePicker;
@property(nonatomic, retain) LuaTranslator *ltPositiveAction;
@property(nonatomic, retain) LuaTranslator *ltNegativeAction;
@property(nonatomic, retain) LuaTranslator *ltDateSelectedListener;
@property(nonatomic, retain) LuaTranslator *ltTimeSelectedListener;
@property(nonatomic) int positiveButtonId;
@property(nonatomic) int negativeButtonId;
@property(nonatomic, retain) NSString *title;
@property(nonatomic) int progress;
@property(nonatomic) int maximum;
@property(nonatomic) bool cancellable;

@end
