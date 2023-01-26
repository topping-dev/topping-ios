#import <Foundation/Foundation.h>
#import "LGScrollView.h"
#import "LuaTab.h"

@protocol MDCTabBarViewDelegate;
@protocol OnScrollCallback;

@protocol LGTabBarDelegate <NSObject>

-(void)didSelectTab:(LuaTab*)tab atIndex:(int)pos;

@end

@interface LGTabLayout : LGScrollView <MDCTabBarViewDelegate, OnScrollCallback>

-(void)addTab:(LuaTab*)tab;

-(LuaTab*)getTabAtIndex:(int)position;

-(int)getTabCount;

-(void)removeTabAtPosition:(int)position;

-(void)removeTab:(LuaTab*)tab;

-(void)removeAllTabs;

-(void)selectTab:(LuaTab*)tab;

-(void)selectTabAtIndex:(int)position;

-(void)setTabSelectedListener:(LuaTranslator*)lt;
-(void)setCanSelectTab:(LuaTranslator*)lt;

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
@property (nonatomic, retain) LuaTranslator *ltCanSelectTab;

@property (nonatomic) CGPoint lastContentOffset;

@end
