#import <Foundation/Foundation.h>
#import "LGScrollView.h"
#import "LuaTab.h"

@protocol MDCTabBarViewDelegate;

@protocol LGTabBarDelegate <NSObject>

-(void)didSelectTab:(LuaTab*)tab atIndex:(int)pos;

@end

@interface LGTabLayout : LGScrollView <MDCTabBarViewDelegate>

-(void)AddTab:(LuaTab*)tab;

-(LuaTab*)GetTabAtIndex:(int)position;

-(int)GetTabCount;

-(void)RemoveTabAtPosition:(int)position;

-(void)RemoveTab:(LuaTab*)tab;

-(void)RemoveAllTabs;

-(void)SelectTab:(LuaTab*)tab;

-(void)SelectTabAtIndex:(int)position;

-(void)SetTabSelectedListener:(LuaTranslator*)lt;

@property (nonatomic, retain) NSString* app_tabBackground;
@property (nonatomic, retain) NSString* app_tabContentStart;
@property (nonatomic, retain) NSString* app_tabGravity;
@property (nonatomic, retain) NSString* app_tabIndicatorAnimationMode;
@property (nonatomic, retain) NSString* app_tabIndicatorColor;
@property (nonatomic, retain) NSString* app_tabIndicatorFullWidth;
@property (nonatomic, retain) NSString* app_tabIndicatorGravity;
@property (nonatomic, retain) NSString* app_tabIndicatorHeight;
@property (nonatomic, retain) NSString* app_tabInlineLabel;
@property (nonatomic, retain) NSString* app_tabMaxWidth;
@property (nonatomic, retain) NSString* app_tabMinWidth;
@property (nonatomic, retain) NSString* app_tabMode;
@property (nonatomic, retain) NSString* app_tabPadding;
@property (nonatomic, retain) NSString* app_tabPaddingBottom;
@property (nonatomic, retain) NSString* app_tabPaddingEnd;
@property (nonatomic, retain) NSString* app_tabPaddingStart;
@property (nonatomic, retain) NSString* app_tabPaddingTop;
@property (nonatomic, retain) NSString* app_tabRippleColor;
@property (nonatomic, retain) NSString* app_tabSelectedTextColor;
@property (nonatomic, retain) NSString* app_tabTextAppearance;
@property (nonatomic, retain) NSString* app_tabTextColor;
@property (nonatomic, retain) NSString* app_tabUnboundedRipple;

@property (nonatomic, retain) UIView *tab;
@property (nonatomic, retain) NSMutableArray *items;
@property (nonatomic, retain) id<LGTabBarDelegate> delegate;
@property (nonatomic, retain) LuaTranslator *ltTabSelectedListener;

@end
