#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LGView.h"
#import "LuaRef.h"

@interface LuaTextViewAppearance : NSObject

+(LuaTextViewAppearance*)Parse:(NSString*)name;

@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic) CGFloat textSize;

@end

@interface LGTextView : LGView <UITextFieldDelegate>
{
}

-(NSMutableArray*) BuildLineBreaks:(NSString *)textVal;

-(CGSize)GetStringSize;
-(void)ResizeOnText;

//Lua
+(LGTextView*)Create:(LuaContext *)context;
-(NSString *)GetText;
-(void)SetText:(NSString *)val;
-(void)SetTextRef:(LuaRef *)ref;
-(void)SetTextColor:(NSString *)color;

@property(nonatomic, retain) NSNumber *android_autoLink;
@property(nonatomic, retain) NSNumber *android_autoText;
@property(nonatomic, retain) NSNumber *android_capitalize;
@property(nonatomic, retain) NSNumber *android_cursorVisible;
@property(nonatomic, retain) NSNumber *android_digits;
@property(nonatomic, retain) NSNumber *android_drawableBottom;
@property(nonatomic, retain) NSNumber *android_drawableLeft;
@property(nonatomic, retain) NSNumber *android_drawablePadding;
@property(nonatomic, retain) NSNumber *android_drawableRight;
@property(nonatomic, retain) NSNumber *android_drawableTop;
@property(nonatomic, retain) NSNumber *android_editable;
@property(nonatomic, retain) NSNumber *android_height;
@property(nonatomic, retain) NSString *android_hint;
@property(nonatomic, retain) NSString *android_inputMethod;
@property(nonatomic, retain) NSString *android_inputType;
@property(nonatomic, retain) NSNumber *android_lines;
@property(nonatomic, retain) NSNumber *android_linksClickable;
@property(nonatomic, retain) NSNumber *android_maxHeight;
@property(nonatomic, retain) NSNumber *android_maxLength;
@property(nonatomic, retain) NSNumber *android_maxLines;
@property(nonatomic, retain) NSNumber *maxWidth;
@property(nonatomic, retain) NSNumber *android_minLines;
@property(nonatomic, retain) NSNumber *android_numeric;
@property(nonatomic, retain) NSNumber *android_password;
@property(nonatomic, retain) NSNumber *android_phoneNumber;
@property(nonatomic, retain) NSNumber *android_scrollHorizontally;
@property(nonatomic, retain) NSNumber *android_selectAllOnFocus;
@property(nonatomic, retain) NSNumber *android_shadowColor;
@property(nonatomic, retain) NSNumber *android_shadowDx;
@property(nonatomic, retain) NSNumber *android_shadowDy;
@property(nonatomic, retain) NSNumber *android_shadowRadius;
@property(nonatomic, retain) NSNumber *android_singleLine;
@property(nonatomic, retain) NSString *android_text;
@property(nonatomic, retain) NSString *android_textAppearance;
@property(nonatomic, retain) NSString *android_textColor;
@property(nonatomic, retain) NSString *android_textColorHighlight;
@property(nonatomic, retain) NSString *android_textColorHint;
@property(nonatomic, retain) NSString *android_textColorLink;
@property(nonatomic, retain) NSNumber *android_textScaleX;
@property(nonatomic, retain) NSString *android_textSize;
@property(nonatomic, retain) NSNumber *android_textStyle;
@property(nonatomic, retain) NSString *android_typeface;
@property(nonatomic, retain) NSString *android_width;
@property(nonatomic, retain) NSString *android_fontFamily;

@property(nonatomic) float fontSize;
@property(nonatomic) CGSize stringSize;
@property(nonatomic) UIEdgeInsets insets;

@end
