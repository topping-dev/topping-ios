#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LGEditText.h"

@interface LGTextInputEditText : LGEditText
{
}

+(LGTextInputEditText*)create:(LuaContext *)context;
-(void)setOnDropdownClickListemer:(LuaTranslator*)lt;

@property(nonatomic, retain) NSString *parentStyle;
@property(nonatomic) int editTextType;

@property(nonatomic) BOOL isOpen;
@property(nonatomic, retain) UIImage *upArrow, *downArrow;
@property(nonatomic, retain) LuaTranslator *ltOnDropdownClickListener;

@property(nonatomic, strong) NSString *app_boxStrokeColor;
@property(nonatomic, strong) NSString *app_boxStrokeWidthFocused;
@property(nonatomic, strong) NSString *app_boxStrokeWidth;
@property(nonatomic, strong) NSString *app_startIconDrawable;
@property(nonatomic, strong) NSString *app_startIconTint;
@property(nonatomic, strong) NSString *app_startIconCheckable;
@property(nonatomic, strong) NSString *app_hintTextColor;
@property(nonatomic, strong) NSString *app_hintTextAppearance;
@property(nonatomic, strong) NSString *app_endIconMode;
@property(nonatomic, strong) NSString *app_endIconTint;
@property(nonatomic, strong) NSString *app_endIconDrawable;
@property(nonatomic, strong) NSString *app_endIconContentDescription;
@property(nonatomic, strong) NSString *app_endIconCheckable;
@property(nonatomic, strong) NSString *app_errorIconDrawable;
@property(nonatomic, strong) NSString *app_errorIconTint;
@property(nonatomic, strong) NSString *app_helperTextEnabled;
@property(nonatomic, strong) NSString *app_helperText;
@property(nonatomic, strong) NSString *app_helperTextColor;
@property(nonatomic, strong) NSString *app_helperTextAppearance;

@end
