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

-(void)initProperties;
-(void)copyAttributesTo:(LGView*)viewToCopy;
-(BOOL)setAttributeValue:(NSString*) name :(NSString*) value;
-(void)applyStyles;

-(void)addSelfToParent:(UIView*)par :(LuaForm*)cont;
-(void)addSelfToParentNoSetup:(UIView *)par :(LuaForm*)cont;
-(UIView*)createComponent;
-(void)initComponent:(UIView *)view :(LuaContext *)lc;
-(void)setupComponent:(UIView *)view;
-(void)componentAddMethod:(UIView*)par :(UIView *)me;

//Positioning
-(void)clearDimensions;
-(void)resize;
-(void)resizeAndInvalidate;
-(void)readWidth;
-(void)readHeight;
-(void)readWidthHeight;
-(void)resizeInternal;
-(void)afterResize:(BOOL)vertical;
-(int)getContentW;
-(int)getContentH;
-(NSObject*)hasAttribute:(NSString *)key;
-(BOOL)containsAttribute:(NSString *)key :(NSObject *)val;

-(void)reduceWidth:(int)share;
-(void)reduceHeight:(int)share;
-(int)getCalculatedHeight;
-(int)getCalculatedWidth;
-(void)configChange;
-(NSString *) debugDescription:(NSString *)val;

-(NSArray*)allPropertyNames;

-(NSMutableDictionary*)onSaveInstanceState;

-(void)viewDidLayoutSubviews;

//Lua
-(UIView*)getView;
+(LGView*)create:(LuaContext *)context;
-(LGView*)getViewById:(LuaRef*)lId;
-(LGView*)getViewByIdInternal:(NSString*)sId;
-(void)setEnabled:(BOOL)enabled;
-(void)setFocusable:(BOOL)focusable;
-(void)setBackground:(LuaRef*)ref;
-(NSInteger)getVisibility;
-(void)setVisibility:(NSInteger)visibility;
-(float)getAlpha;
-(void)setOnClickListener:(LuaTranslator *)lt;
-(NSDictionary*)getBindings;

-(LuaFragment*)findFragment;
-(NavController*)findNavController;
-(LuaNavController*)findNavControllerInternal;

@property (nonatomic, strong) NSMutableDictionary *xmlProperties;
@property (nonatomic, strong) NSArray *attrs;

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
