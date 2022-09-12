#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LuaFragment.h"
#import "LuaRef.h"

@class NavHostController;
@class NavController;
@class Navigation;
@class DialogFragmentNavigator;

@interface LGNavHostFragment : LuaFragment

+(NavController*)findNavController:(LuaFragment*)fragment;
+(LGNavHostFragment*)create:(NSString*)graphResId;
+(LGNavHostFragment*)create:(NSString*)graphResId :(NSMutableDictionary*)startDestinationArgs;

-(NavController*)getNavController;
-(void)onCreateNavController:(NavController*)navController;
-(void)setNavGraph:(NSString*)graphResId :(NSMutableDictionary*)startDestinationArgs;

@property(nonatomic, strong) NavHostController* mNavController;
@property(nonatomic, strong) NSNumber* mIsPrimaryOnBeforeCreate;
@property(nonatomic, strong) LGView* mViewParent;
@property(nonatomic, strong) NSString* mGraphId;
@property BOOL mDefaultNavHost;

@end
