#import <Foundation/Foundation.h>
#import "LGViewGroup.h"
#import "LuaTranslator.h"
#import "LGLinearLayout.h"
#import "LGRecyclerView.h"

@class LuaForm;
@class LGView;

@interface LGNavigationView : LGLinearLayout <LGRecyclerViewAdapterDelegate>

+(LGNavigationView*)create:(LuaContext*)context;
-(void)setNavigationItemSelectListener:(LuaTranslator*)lt;
-(void)notify;

@property(nonatomic, retain) LGView *headerView;
@property(nonatomic, retain) LGRecyclerView *subView;
@property(nonatomic, retain) LGRecyclerViewAdapter *adapter;

@property(nonatomic, retain) LuaTranslator *ltNavigationItemSelectListener;

@property(nonatomic, retain) NSString *app_menu;
@property(nonatomic, retain) NSString *app_headerLayout;
@property(nonatomic, retain) NSString *app_itemTextColor;
@property(nonatomic, retain) NSString *app_itemTextAppearance;
@property(nonatomic, retain) NSString *app_itemMaxLines;
@property(nonatomic, retain) NSString *app_itemIconTint;
@property(nonatomic, retain) NSString *app_itemIconSize;
@property(nonatomic, retain) NSString *app_itemIconPadding;
@property(nonatomic, retain) NSString *app_subheaderColor;
@property(nonatomic, retain) NSString *app_subheaderTextAppearance;

@end

