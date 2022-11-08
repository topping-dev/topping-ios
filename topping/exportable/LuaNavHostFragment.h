#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LuaFragment.h"
#import "LuaRef.h"
#import "KotlinExports.h"

@class NavHostController;
@class NavController;
@class Navigation;
@class DialogFragmentNavigator;

@interface LuaNavHostFragment : LuaFragment

+(NavController*)findNavController:(LuaFragment*)fragment;
+(LuaNavController*)findNavControllerInternal:(LuaFragment*)fragment;
+(LuaNavHostFragment*)create:(NSString*)graphResId;
+(LuaNavHostFragment*)create:(NSString*)graphResId :(NSMutableDictionary*)startDestinationArgs;

-(NavController*)getNavController;
-(LuaNavController*)getNavControllerInternal;
-(void)onCreateNavController:(NavController*)navController;
-(void)setNavGraph:(NSString*)graphResId :(NSMutableDictionary*)startDestinationArgs;

@property(nonatomic, strong) NavHostController* mNavController;
@property(nonatomic, strong) NSNumber* mIsPrimaryOnBeforeCreate;
@property(nonatomic, strong) LGView* mViewParent;
@property(nonatomic, strong) NSString* mGraphId;
@property BOOL mDefaultNavHost;

@end
