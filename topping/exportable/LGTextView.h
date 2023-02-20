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

-(NSMutableArray*) buildLineBreaks:(NSString *)textVal;

-(CGSize)getStringSize;
-(void)resizeOnText;

//Lua
+(LGTextView*)create:(LuaContext *)context;
-(NSString *)getText;
-(void)setTextInternal:(NSString *)val;
-(void)setText:(LuaRef *)ref;
-(void)setTextColor:(NSString *)color;
-(void)setTextColorRef:(LuaRef *)ref;

@property(nonatomic, retain) NSString *android_autoLink;
@property(nonatomic, retain) NSString *android_autoText;
@property(nonatomic, retain) NSString *android_capitalize;
@property(nonatomic, retain) NSString *android_cursorVisible;
@property(nonatomic, retain) NSString *android_digits;
@property(nonatomic, retain) NSString *android_drawableBottom;
@property(nonatomic, retain) NSString *android_drawableLeft;
@property(nonatomic, retain) NSString *android_drawablePadding;
@property(nonatomic, retain) NSString *android_drawableRight;
@property(nonatomic, retain) NSString *android_drawableTop;
@property(nonatomic, retain) NSString *android_editable;
@property(nonatomic, retain) NSString *android_hint;
@property(nonatomic, retain) NSString *android_inputMethod;
@property(nonatomic, retain) NSString *android_inputType;
@property(nonatomic, retain) NSString *android_lines;
@property(nonatomic, retain) NSString *android_linksClickable;
@property(nonatomic, retain) NSString *android_maxLength;
@property(nonatomic, retain) NSString *android_maxLines;
@property(nonatomic, retain) NSString *android_minLines;
@property(nonatomic, retain) NSString *android_numeric;
@property(nonatomic, retain) NSString *android_password;
@property(nonatomic, retain) NSString *android_phoneNumber;
@property(nonatomic, retain) NSString *android_scrollHorizontally;
@property(nonatomic, retain) NSString *android_selectAllOnFocus;
@property(nonatomic, retain) NSString *android_shadowColor;
@property(nonatomic, retain) NSString *android_shadowDx;
@property(nonatomic, retain) NSString *android_shadowDy;
@property(nonatomic, retain) NSString *android_shadowRadius;
@property(nonatomic, retain) NSString *android_singleLine;
@property(nonatomic, retain) NSString *android_text;
@property(nonatomic, retain) NSString *android_textAppearance;
@property(nonatomic, retain) NSString *android_textColor;
@property(nonatomic, retain) NSString *android_textColorHighlight;
@property(nonatomic, retain) NSString *android_textColorHint;
@property(nonatomic, retain) NSString *android_textColorLink;
@property(nonatomic, retain) NSString *android_textScaleX;
@property(nonatomic, retain) NSString *android_textSize;
@property(nonatomic, retain) NSString *android_textStyle;
@property(nonatomic, retain) NSString *android_typeface;
@property(nonatomic, retain) NSString *android_fontFamily;

@property(nonatomic) float fontSize;
@property(nonatomic, strong) UIFont *font;
@property(nonatomic) CGSize stringSize;
@property(nonatomic) UIEdgeInsets insets;

@end
