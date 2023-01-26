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

+(void)messageBox:(LuaContext*)context :(LuaRef*)title :(LuaRef*)content;
+(void)messageBoxInternal:(LuaContext*)context :(NSString*)title :(NSString*)content;
+(LuaDialog*)create:(LuaContext*)context :(int)dialogType;
-(void)setCancellable:(bool)val;
-(void)setPositiveButtonInternal:(NSString*)title :(LuaTranslator*)action;
-(void)setPositiveButton:(LuaRef*)title :(LuaTranslator*)action;
-(void)setNegativeButtonInternal:(NSString*)title :(LuaTranslator*)action;
-(void)setNegativeButton:(LuaRef*)title :(LuaTranslator*)action;
-(void)setTitle:(NSString*)title;
-(void)setTitleRef:(LuaRef*)ref;
-(void)setMessage:(NSString*)message;
-(void)setMessageRef:(LuaRef*)ref;
-(void)setProgress:(int)value;
-(void)setMax:(int)value;
-(void)setDate:(LuaDate*)date;
-(void)setDateManual:(int)day :(int)month :(int)year;
-(void)setTime:(LuaDate*)date;
-(void)setTimeManual:(int)hour :(int)minute;
-(void)show;
-(void)dismiss;
-(void)setDateSelectedListener:(LuaTranslator*)action;
-(void)setTimeSelectedListener:(LuaTranslator*)action;

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
@property(nonatomic, retain) NSString *title_;
@property(nonatomic) int progress_;
@property(nonatomic) int maximum_;
@property(nonatomic) bool cancellable_;

@end
