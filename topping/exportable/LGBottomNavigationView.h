#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LGFrameLayout.h"

@protocol MDCBottomNavigationBarDelegate;

@interface LGBottomNavigationView : LGFrameLayout <MDCBottomNavigationBarDelegate>
{

}

+(LGBottomNavigationView*)create:(LuaContext *)context;
-(void)setTabSelectedListener:(LuaTranslator*)lt;
-(void)setCanSelectTab:(LuaTranslator*)lt;

@property (nonatomic, retain) NSString* app_menu;
@property (nonatomic, retain) NSString* app_labelVisibilityMode;

@property (nonatomic, retain) UIView *bottomNav;
@property (nonatomic, retain) NSMutableArray *items;
@property (nonatomic, retain) LuaTranslator *ltTabSelectedListener;
@property (nonatomic, retain) LuaTranslator *ltCanSelectTab;

@end
