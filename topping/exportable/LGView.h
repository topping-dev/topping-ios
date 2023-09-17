#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LuaClass.h"
#import "LuaContext.h"
#import "LuaForm.h"
#import "LuaRef.h"
#import "LuaRect.h"

#define CALL_RET(V) if(V) { return; }
#define IS_VIEW_NO_ID(X) (X == nil || [X isEqualToString:@""])

@class LuaForm;
@class LuaFragment;
@protocol LuaInterface;
@class NavController;
@class LuaNavController;
@protocol IOSKHTView;
@class IOSKHViewGroupLayoutParams;
@class LGRelativeLayoutParams;

typedef NS_ENUM(NSInteger, VISIBILITY)
{
	VISIBLE = 0,
	INVISIBILE = 4,
	GONE = 8
};

enum LAYOUTDIMENSION
{
	MATCH_PARENT = -1,
	WRAP_CONTENT = -2
};

enum GRAVITY
{
    NO_GRAVITY = 0x0000,
    AXIS_SPECIFIED = 0x0001,
    AXIS_PULL_BEFORE = 0x0002,
    AXIS_PULL_AFTER = 0x0004,
    AXIS_CLIP = 0x0008,
    AXIS_X_SHIFT = 0,
    AXIS_Y_SHIFT = 4,
    GRAVITY_TOP = (AXIS_PULL_BEFORE|AXIS_SPECIFIED)<<AXIS_Y_SHIFT,
    GRAVITY_BOTTOM = (AXIS_PULL_AFTER|AXIS_SPECIFIED)<<AXIS_Y_SHIFT,
    GRAVITY_LEFT = (AXIS_PULL_BEFORE|AXIS_SPECIFIED)<<AXIS_X_SHIFT,
    GRAVITY_RIGHT = (AXIS_PULL_AFTER|AXIS_SPECIFIED)<<AXIS_X_SHIFT,
    GRAVITY_CENTER_VERTICAL = AXIS_SPECIFIED<<AXIS_Y_SHIFT,
    GRAVITY_FILL_VERTICAL = GRAVITY_TOP|GRAVITY_BOTTOM,
    GRAVITY_CENTER_HORIZONTAL = AXIS_SPECIFIED<<AXIS_X_SHIFT,
    GRAVITY_FILL_HORIZONTAL = GRAVITY_LEFT|GRAVITY_RIGHT,
    GRAVITY_CENTER = GRAVITY_CENTER_VERTICAL|GRAVITY_CENTER_HORIZONTAL,
    GRAVITY_FILL = GRAVITY_FILL_VERTICAL|GRAVITY_FILL_HORIZONTAL,
    GRAVITY_CLIP_VERTICAL = AXIS_CLIP<<AXIS_Y_SHIFT,
    GRAVITY_CLIP_HORIZONTAL = AXIS_CLIP<<AXIS_X_SHIFT,
    RELATIVE_LAYOUT_DIRECTION = 0x00800000,
    HORIZONTAL_GRAVITY_MASK = (AXIS_SPECIFIED |
                               AXIS_PULL_BEFORE | AXIS_PULL_AFTER) << AXIS_X_SHIFT,
    VERTICAL_GRAVITY_MASK = (AXIS_SPECIFIED |
                AXIS_PULL_BEFORE | AXIS_PULL_AFTER) << AXIS_Y_SHIFT,
    DISPLAY_CLIP_VERTICAL = 0x10000000,
    DISPLAY_CLIP_HORIZONTAL = 0x01000000,
    GRAVITY_START = RELATIVE_LAYOUT_DIRECTION | GRAVITY_LEFT,
    GRAVITY_END = RELATIVE_LAYOUT_DIRECTION | GRAVITY_RIGHT,
    RELATIVE_HORIZONTAL_GRAVITY_MASK = GRAVITY_START | GRAVITY_END
};

@interface Gravity : NSObject

+(LuaRect*)apply:(int)gravity :(int)w :(int)h :(LuaRect*)container;
+(LuaRect*)apply:(int)gravity :(int)w :(int)h :(LuaRect*)container :(int)layoutDirection;
+(LuaRect*)apply:(int)gravity :(int)w :(int)h :(LuaRect*)container :(int)xAdj :(int)yAdj;
+(LuaRect*)apply:(int)gravity :(int)w :(int)h :(LuaRect*)container :(int)xAdj :(int)yAdj :(int)layoutDirection;
+(BOOL)isVertical:(int)gravity;
+(BOOL)isHorizontal:(int)gravity;
+(int)getAbsoluteGravity:(int)gravity;

@end

enum MEASURE_SPEC
{
    MODE_SHIFT = 30,
    MODE_MASK = 0x3 << MODE_SHIFT,
    UNSPECIFIED = 0 << MODE_SHIFT,
    EXACTLY = 1 << MODE_SHIFT,
    AT_MOST = 2 << MODE_SHIFT,
    MEASURED_STATE_TOO_SMALL = 0x01000000,
    MEASURED_SIZE_MASK = 0x00ffffff,
    MEASURED_STATE_MASK = 0xff000000,
    MEASURED_HEIGHT_STATE_SHIFT = 16
};

@interface MeasureSpec : NSObject

+(int)makeMeasureSpec:(int)size :(int)mode;
+(int)getMode:(int)measureSpec;
+(int)getSize:(int)measureSpec;

@end

@interface LGView : NSObject <LuaClass, LuaInterface, IOSKHTView>
{
    NSArray *propertyNameCache;
}

+(BOOL)isRtl;

-(void)initProperties;
-(void)copyAttributesTo:(LGView*)viewToCopy;
-(BOOL)setAttributeValue:(NSString*) name :(NSString*) value;
-(void)applyStyles;

-(void)addSelfToParent:(UIView*)par :(LuaForm*)cont;
-(void)addSelfToParentNoSetup:(UIView *)par :(LuaForm*)cont;
-(void)beforeInitSubviews;
-(void)beforeInitComponent;
-(UIView*)createComponent;
-(void)initComponent:(UIView *)view :(LuaContext *)lc;
-(void)setupComponent:(UIView *)view;
-(void)componentAddMethod:(UIView*)par :(UIView *)me;
-(LGView*)generateLGViewForName:(NSString*)name :(NSArray*)attrs;

//Positioning
-(void)clearDimensions;
-(void)resize;
-(void)resizeAndInvalidate;
-(void)resolveLayoutDirection;
-(void)readWidth;
-(void)readHeight;
-(void)readWidthHeight;
-(void)measure:(int)widthMeasureSpec :(int)heightMeasureSpec;
-(void)onMeasure:(int)widthMeasureSpec :(int)heightMeasureSpec;
+(int)combineMeasuredStates:(int)curState :(int)newState;
-(int)getMeasuredState;
-(int)getSuggestedMinimumWidth;
-(int)getSuggestedMinimumHeight;
+(int)resolveSize:(int)size :(int) measureSpec;
+(int)resolveSizeAndState:(int)size :(int)measureSpec :(int)childMeasuredState;
-(void)setMeasuredDimension:(int)measuredWidth :(int)measuredHeight;
-(void)resizeInternal;
-(int)getContentW;
-(int)getContentH;
-(NSObject*)hasAttribute:(NSString *)key;
-(BOOL)containsAttribute:(NSString *)key :(NSObject *)val;

-(void)reduceWidth:(int)share;
-(void)reduceHeight:(int)share;
-(int)getCalculatedHeight;
-(int)getCalculatedWidth;
-(void)configChange;
-(void)layout:(int)l :(int)t :(int)r :(int)b;
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

-(int)getLeft;
-(int)getRight;
-(int)getTop;
-(int)getBottom;
-(int)getMLeft;
-(int)getMRight;
-(int)getMTop;
-(int)getMBottom;

-(LuaFragment*)findFragment;
-(NavController*)findNavController;
-(LuaNavController*)findNavControllerInternal;

-(BOOL)callTMethodArr:(NSString *)methodName :(NSArray *)arr;
-(BOOL)callTMethod:(NSString*)methodName :(id)arg, ...;

@property (nonatomic, strong) NSMutableDictionary *xmlProperties;
@property (nonatomic, strong) NSArray *attrs;

@property (nonatomic, strong) NSString* android_alpha;
@property (nonatomic, retain) NSString* android_background;
@property (nonatomic, retain) NSString* android_clickable;
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
@property (nonatomic, retain) NSString* android_enabled;
@property (nonatomic, retain) NSString* android_elevation;

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
@property(nonatomic, retain) NSString* android_layout_weight;

@property(nonatomic, retain) NSString* style;
@property(nonatomic, retain) NSString* colorAccent;

//RelativeLayout
@property(nonatomic, retain) NSString *android_layout_above, *android_layout_alignBaseline, *android_layout_alignBottom;
@property(nonatomic, retain) NSString *android_layout_alignEnd, *android_layout_alignLeft, *android_layout_alignParentBottom;
@property(nonatomic, retain) NSString *android_layout_alignParentEnd, *android_layout_alignParentLeft, *android_layout_alignParentRight;
@property(nonatomic, retain) NSString *android_layout_alignParentStart, *android_layout_alignParentTop, *android_layout_alignRight;
@property(nonatomic, retain) NSString *android_layout_alignStart, *android_layout_alignTop, *android_layout_alignWithParentIfMissing, *android_layout_below;
@property(nonatomic, retain) NSString *android_layout_centerHorizontal, *android_layout_centerInParent, *android_layout_centerVertical;
@property(nonatomic, retain) NSString *android_layout_toEndOf, *android_layout_toRightOf, *android_layout_toStartOf, *android_layout_toLeftOf;
@property(nonatomic, strong) LGRelativeLayoutParams *rlParams;

@property(nonatomic, retain) NSString* lua_id;

@property (nonatomic, retain) LuaContext *lc;
@property (nonatomic, retain) UIView *_view;
@property (nonatomic, retain) UIViewController *cont;
@property (nonatomic, retain) LGView *parent;
@property (nonatomic, retain) NSString *transitionName;

@property (nonatomic) int dWidth;
@property (nonatomic) int dHeight;
@property (nonatomic) int dWidthDimension;
@property (nonatomic) int dHeightDimension;
@property (nonatomic) int dWidthSpec;
@property (nonatomic) int dHeightSpec;
@property (nonatomic) int dPaddingBottom;
@property (nonatomic) int dPaddingLeft;
@property (nonatomic) int dPaddingRight;
@property (nonatomic) int dPaddingTop;
@property (nonatomic) int dX;
@property (nonatomic) int dY;
@property (nonatomic) int dPivotX;
@property (nonatomic) int dPivotY;
@property (nonatomic) int dRotation;
@property (nonatomic) int dRotationX;
@property (nonatomic) int dRotationY;
@property (nonatomic) int dScaleX;
@property (nonatomic) int dScaleY;
@property (nonatomic) int dTranslationX;
@property (nonatomic) int dTranslationY;
@property (nonatomic) int dTranslationZ;

@property(nonatomic) int dMarginBottom;
@property(nonatomic) int dMarginLeft;
@property(nonatomic) int dMarginRight;
@property(nonatomic) int dMarginTop;

@property (nonatomic) int dGravity;
@property (nonatomic) int dGravityDimen;
@property (nonatomic) int dLayoutGravity;
@property (nonatomic) int dLayoutGravityDimen;
@property (nonatomic) int dVisibility;

@property(nonatomic) BOOL layout;
@property(nonatomic) BOOL layoutRequested;
@property(nonatomic) int baseLine;

@property(nonatomic) BOOL widthSpecSet, heightSpecSet;

@property(nonatomic, strong) LuaTranslator *ltOnClickListener;

@property(nonatomic, strong) LuaFragment *fragment;

@property(nonatomic, strong) NavController *navController;

@property(nonatomic, strong) LuaRef *lrBackground;

@property(nonatomic, strong) IOSKHViewGroupLayoutParams *kLayoutParams;
@property(nonatomic, strong) id kParentType;

@property (nonatomic, strong) NSMutableArray *methodSkip;
@property (nonatomic, strong) NSMutableDictionary *methodEventMap;

@end

@protocol OnClickListenerInternal <NSObject>

-onClick:(LGView*)view;

@end
