#import <Foundation/Foundation.h>
#import "LGViewGroup.h"
#import "LuaTranslator.h"

@class LuaForm;
@class LGView;
@class NavigationDrawerSwipeController;
@protocol NavigationDrawerSwipeControllerDelegate;
@class LGDrawerLayout;

@interface LGDrawerLayoutDelegate : NSObject <UIViewControllerTransitioningDelegate, NavigationDrawerSwipeControllerDelegate>

- (instancetype)initWithDrawer:(LGDrawerLayout*)drawerLayout :(BOOL)animation;

@property(nonatomic, retain) LGDrawerLayout *drawerLayout;
@property(nonatomic) BOOL supportAnimation;

@end

@interface LGDrawerLayout : LGViewGroup

-(void)addOnDrawerSlide:(LuaTranslator*)lt;
-(void)addOnDrawerOpened:(LuaTranslator*)lt;
-(void)addOnDrawerClosed:(LuaTranslator*)lt;
-(void)addOnDrawerStateChanged:(LuaTranslator*)lt;

-(void)removeOnDrawerSlide:(LuaTranslator*)lt;
-(void)removeOnDrawerOpened:(LuaTranslator*)lt;
-(void)removeOnDrawerClosed:(LuaTranslator*)lt;
-(void)removeOnDrawerStateChanged:(LuaTranslator*)lt;

@property (nonatomic, retain) LGView *drawerLayout;
@property (nonatomic, retain) LuaForm *drawerForm;

@property (nonatomic) BOOL isOpen;
@property (nonatomic) BOOL state;

@property (nonatomic, retain) NSMutableArray *ltOnDrawerSlide;
@property (nonatomic, retain) NSMutableArray *ltOnDrawerOpened;
@property (nonatomic, retain) NSMutableArray *ltOnDrawerClosed;
@property (nonatomic, retain) NSMutableArray *ltOnDrawerStateChanged;

@property (nonatomic, retain) NavigationDrawerSwipeController *navigationController;
@property (nonatomic, retain) LGDrawerLayoutDelegate *delegate;

@end

