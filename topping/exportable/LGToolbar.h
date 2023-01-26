#import <Foundation/Foundation.h>
#import "LGView.h"
#import "LuaStream.h"

@interface LGToolbar : LGView

-(void)setMenu:(LuaRef*)menu;

-(void)setLogo:(LuaRef*)logo;

-(void)setNavigationIcon:(LuaRef*)navigationIcon;

-(void)setNavigationIconImage:(UIImage*)img;

-(void)setOverflowIcon:(LuaRef*)overflowIcon;

-(NSString*)getTitle;

-(void)setTitleInternal:(NSString*)title;

-(void)setTitle:(LuaRef*)ref;

-(void)setTitleTextColor:(LuaRef*)color;

-(void)setTitleTextApperance:(LuaRef*)ref;

-(NSString*)getSubtitle;

-(void)setSubtitleInternal:(NSString*)subtitle;

-(void)setSubtitle:(LuaRef*)ref;

-(void)setSubtitleTextColor:(LuaRef*)color;

-(void)setSubtitleTextApperance:(LuaRef*)ref;

-(void)navigationTap;

-(void)setNavigationOnClickListener:(LuaTranslator*)lt;

-(void)setNavigationOnClickListenerInternal:(id<OnClickListenerInternal>)runnable;

-(void)overflowTap;

-(void)setMenuItemClickListener:(LuaTranslator*)lt;

@property (nonatomic, retain) NSString* android_buttonGravity;
@property (nonatomic, retain) NSString* android_collapseContentDescription;
@property (nonatomic, retain) NSString* android_collapseIcon;
@property (nonatomic, retain) NSString* android_contentInsetEnd;
@property (nonatomic, retain) NSString* android_contentInsetEndWithActions;
@property (nonatomic, retain) NSString* android_contentInsetLeft;
@property (nonatomic, retain) NSString* android_contentInsetRight;
@property (nonatomic, retain) NSString* android_contentInsetStart;
@property (nonatomic, retain) NSString* android_contentInsetStartWithNavigation;
@property (nonatomic, retain) NSString* android_logo;
@property (nonatomic, retain) NSString* android_logoDescription;
@property (nonatomic, retain) NSString* android_maxButtonHeight;
@property (nonatomic, retain) NSString* android_navigationContentDescription;
@property (nonatomic, retain) NSString* android_navigationIcon;
@property (nonatomic, retain) NSString* android_popupTheme;
@property (nonatomic, retain) NSString* android_subtitle;
@property (nonatomic, retain) NSString* android_subtitleTextAppearance;
@property (nonatomic, retain) NSString* android_subtitleTextColor;
@property (nonatomic, retain) NSString* android_title;
@property (nonatomic, retain) NSString* android_titleMargin;
@property (nonatomic, retain) NSString* android_titleMarginBottom;
@property (nonatomic, retain) NSString* android_titleMarginEnd;
@property (nonatomic, retain) NSString* android_titleMarginStart;
@property (nonatomic, retain) NSString* android_titleMarginTop;
@property (nonatomic, retain) NSString* android_titleTextAppearance;
@property (nonatomic, retain) NSString* android_titleTextColor;
@property (nonatomic, retain) UIView *toolbar;
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UIBarButtonItem *title_;
@property (nonatomic, retain) UIBarButtonItem *spacer;
@property (nonatomic, retain) NSMutableArray *startItems;
@property (nonatomic, retain) NSMutableArray *endItems;
@property (nonatomic, retain) LuaTranslator *ltNavigationClick;
@property (nonatomic, retain) LuaTranslator *ltOverflowClick;
@property (nonatomic, retain) id<OnClickListenerInternal> inNavigationClick;

@end
