#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LuaRef.h"
#import <ToppingIOSKotlinHelper/ToppingIOSKotlinHelper.h>

@class AppBarConfiguration;
@class FragmentManager;
@class LuaFragment;
@class LGView;

@interface KotlinMatrixConvertor : NSObject

+(CATransform3D)cATransfrom3DMatrixFromSkiko:(TIOSKHSkikoMatrix33*)matrix;
+(TIOSKHSkikoMatrix33*)skikoMatrixFromCATransform3D:(CATransform3D)transform;

@end

@interface NSObject (KotlinExtension)

-(void)setValueForKeyPath:(id)value :(NSString*)key;

@end

/*
 Kotlin native generator do not extend
 */
@protocol KNG <NSObject>

-(TIOSKHSkiaCanvas*)getCanvas;
-(TIOSKHSkiaCanvasKt*)getCanvasKt;

@end

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
