#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LuaRef.h"

@class AppBarConfiguration;
@class FragmentManager;
@class LuaFragment;
@class LGView;

@protocol KotlinProtocol <NSObject>

-(NSObject*)getNativeObject;

@end

@interface LuaAppBarConfiguration : NSObject <LuaClass, KotlinProtocol>

+(LuaAppBarConfiguration*)create:(BOOL)singleTop :(LuaRef*)popUpTo :(BOOL)popUpToInclusive
                                :(LuaRef*)enterAnim :(LuaRef*)exitAnim :(LuaRef*)popEnterAnim :(LuaRef*)popExitAnim;

-(void)setTopLevelDestinations:(NSMutableArray*)ids;

@property (nonatomic, retain) AppBarConfiguration *no;

@end

@class NavController;
@class NavOptions;
@protocol NavigatorExtras;

@interface LuaNavController : NSObject <LuaClass, KotlinProtocol>

- (instancetype)initWithController:(NavController*)controller;

- (instancetype)initWithContext:(LuaContext*)context;

-(void)navigateUp;

-(void)navigateRef:(LuaRef*)ref;

-(void)navigateRef:(LuaRef*)ref :(NSDictionary*)dict;

-(void)navigateRef:(LuaRef*)ref :(NSDictionary*)dict :(NavOptions*)navOptions;

-(void)navigateRef:(LuaRef*)ref :(NSDictionary*)dict :(NavOptions*)navOptions :(id<NavigatorExtras>) extras;

@property (nonatomic, retain) NavController *no;

@end
