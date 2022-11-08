#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LuaClass.h"
#import "LuaContext.h"
#import "LuaForm.h"
#import "LuaRef.h"

@class LuaForm;
@class LuaFragment;
@protocol LuaInterface;
@class NavController;
@class LuaNavController;

typedef NS_ENUM(NSInteger, VISIBILITY)
{
	VISIBLE,
	INVISIBILE,
	GONE
};

enum LAYOUTDIMENSION
{
	FILL_PARENT = -1,
	WRAP_CONTENT = -2
};

enum GRAVITY
{
    GRAVITY_LEFT = 0x1,
    GRAVITY_START = 0x1,
    GRAVITY_RIGHT = 0x2,
    GRAVITY_END = 0x2,
    GRAVITY_TOP = 0x4,
    GRAVITY_BOTTOM = 0x8,
    GRAVITY_CENTER_VERTICAL = 0x10,
    GRAVITY_CENTER_HORIZONTAL = 0x20,
    GRAVITY_CENTER = (GRAVITY_CENTER_VERTICAL | GRAVITY_CENTER_HORIZONTAL)
};

@interface LGView : NSObject <LuaClass, LuaInterface>
{
    NSArray *propertyNameCache;
}

-(void)InitProperties;
-(BOOL)SetAttributeValue:(NSString*) name :(NSString*) value;
-(void)ApplyStyles;

-(void)AddSelfToParent:(UIView*)par :(LuaForm*)cont;
-(void)AddSelfToParentNoSetup:(UIView *)par :(LuaForm*)cont;
-(UIView*)CreateComponent;
-(void)InitComponent:(UIView *)view :(LuaContext *)lc;
-(void)SetupComponent:(UIView *)view;
-(void)ComponentAddMethod:(UIView*)par :(UIView *)me;

//Positioning
-(void)ClearDimensions;
-(void)Resize;
-(void)ResizeAndInvalidate;
-(void)ReadWidth;
-(void)ReadHeight;
-(void)ReadWidthHeight;
-(void)ResizeInternal;
-(void)AfterResize:(BOOL)vertical;
-(int)GetContentW;
-(int)GetContentH;
-(NSObject*)HasAttribute:(NSString *)key;
-(BOOL)ContainsAttribute:(NSString *)key :(NSObject *)val;

-(void)ReduceWidth:(int)share;
-(void)ReduceHeight:(int)share;
-(int)GetCalculatedHeight;
-(int)GetCalculatedWidth;
-(NSString *) DebugDescription:(NSString *)val;

-(NSArray*)allPropertyNames;

//Lua
-(UIView*)GetView;
+(LGView*)Create:(LuaContext *)context;
-(LGView*)GetViewById:(NSString*)lId;
-(void)SetEnabled:(BOOL)enabled;
-(void)SetFocusable:(BOOL)focusable;
-(void)SetBackground:(NSString*)background;
-(void)SetBackgroundRef:(LuaRef*)ref;
-(NSInteger)GetVisibility;
-(void)SetVisibility:(NSInteger)visibility;
-(float)GetAlpha;
-(void)SetOnClickListener:(LuaTranslator *)lt;

-(LuaFragment*)findFragment;
-(NavController*)findNavController;
-(LuaNavController*)findNavControllerInternal;

@property (nonatomic, strong) NSMutableDictionary *xmlProperties;

@property (nonatomic, strong) NSString* android_alpha;
@property (nonatomic, retain) NSString* android_background;
@property (nonatomic, retain) NSNumber* android_clickable;
@property (nonatomic, retain) NSString* android_id;
@property (nonatomic, retain) NSString* android_tag;
@property (nonatomic, retain) NSString* android_name;
@property (nonatomic, retain) NSString* android_minHeight;
@property (nonatomic, retain) NSString* android_minWidth;
@property (nonatomic, retain) NSString* android_paddingBottom;
@property (nonatomic, retain) NSString* android_paddingLeft;
@property (nonatomic, retain) NSString* android_paddingRight;
@property (nonatomic, retain) NSString* android_paddingTop;
@property (nonatomic, retain) NSString* android_padding;
@property (nonatomic, retain) NSString* android_visibility;

//Viewgroup
@property(nonatomic, retain) NSString* android_layout_width;
@property(nonatomic, retain) NSString* android_layout_height;

@property(nonatomic, retain) NSString* android_layout_margin;
@property(nonatomic, retain) NSString* android_layout_marginBottom;
@property(nonatomic, retain) NSString* android_layout_marginLeft;
@property(nonatomic, retain) NSString* android_layout_marginRight;
@property(nonatomic, retain) NSString* android_layout_marginTop;

@property(nonatomic, retain) NSString *android_gravity;
@property(nonatomic, retain) NSString* android_layout_gravity;
@property(nonatomic, retain) NSNumber* android_layout_weight;

@property(nonatomic, retain) NSString* style;
@property(nonatomic, retain) NSString* colorAccent;

@property(nonatomic, retain) NSString* lua_id;

@property (nonatomic, retain) LuaContext *lc;
@property (nonatomic, retain) UIView *_view;
@property (nonatomic, retain) UIViewController *cont;
@property (nonatomic, retain) LGView *parent;
@property (nonatomic, retain) NSString *transitionName;

@property (nonatomic) int dWidth;
@property (nonatomic) int dHeight;
@property (nonatomic) int dPaddingBottom;
@property (nonatomic) int dPaddingLeft;
@property (nonatomic) int dPaddingRight;
@property (nonatomic) int dPaddingTop;
@property (nonatomic) int dX;
@property (nonatomic) int dY;

@property(nonatomic) int dMarginBottom;
@property(nonatomic) int dMarginLeft;
@property(nonatomic) int dMarginRight;
@property(nonatomic) int dMarginTop;

@property (nonatomic) int dGravity;
@property (nonatomic) int dLayoutGravity;

@property(nonatomic) BOOL layout;
@property(nonatomic) int baseLine;
@property(nonatomic, retain) UIImage *backgroundImage;

@property(nonatomic, strong) LuaTranslator *ltOnClickListener;

@property(nonatomic, strong) LuaFragment *fragment;

@property(nonatomic, strong) NavController *navController;

@end

@protocol OnClickListenerInternal <NSObject>

-onClick:(LGView*)view;

@end
