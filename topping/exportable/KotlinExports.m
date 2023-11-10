#import <Foundation/Foundation.h>
#import "KotlinExports.h"

#import <Topping/Topping-Swift.h>

@implementation KotlinMatrixConvertor

+(CATransform3D)cATransfrom3DMatrixFromSkiko:(TIOSKHSkikoMatrix33*)matrix {
    CATransform3D transform = CATransform3DIdentity;
    transform.m11 = [matrix.mat getIndex:TIOSKHExtensionsKt.kMScaleX];
    transform.m21 = [matrix.mat getIndex:TIOSKHExtensionsKt.kMSkewX];
    transform.m41 = [matrix.mat getIndex:TIOSKHExtensionsKt.kMTransX];
    transform.m14 = [matrix.mat getIndex:TIOSKHExtensionsKt.kMPersp0];
    transform.m12 = [matrix.mat getIndex:TIOSKHExtensionsKt.kMSkewY];
    transform.m22 = [matrix.mat getIndex:TIOSKHExtensionsKt.kMScaleY];
    transform.m42 = [matrix.mat getIndex:TIOSKHExtensionsKt.kMTransY];
    transform.m24 = [matrix.mat getIndex:TIOSKHExtensionsKt.kMPersp1];
    return transform;
}

+(TIOSKHSkikoMatrix33*)skikoMatrixFromCATransform3D:(CATransform3D)transform {
    TIOSKHSkikoMatrix33 *matrixIden = TIOSKHSkikoMatrix33.companion.IDENTITY;
    TIOSKHKotlinFloatArray *arr = matrixIden.mat;
    [arr setIndex:TIOSKHExtensionsKt.kMScaleX value:transform.m11];
    [arr setIndex:TIOSKHExtensionsKt.kMSkewX value:transform.m21];
    [arr setIndex:TIOSKHExtensionsKt.kMTransX value:transform.m41];
    [arr setIndex:TIOSKHExtensionsKt.kMPersp0 value:transform.m14];
    [arr setIndex:TIOSKHExtensionsKt.kMSkewY value:transform.m12];
    [arr setIndex:TIOSKHExtensionsKt.kMScaleY value:transform.m22];
    [arr setIndex:TIOSKHExtensionsKt.kMTransY value:transform.m42];
    [arr setIndex:TIOSKHExtensionsKt.kMPersp1 value:transform.m24];
    TIOSKHSkikoMatrix33 *matrix = [[TIOSKHSkikoMatrix33 alloc] initWithMat:arr];
    
    return matrix;
}

@end

@implementation NSObject (KotlinExtension)

-(void)setValueForKeyPath:(id)value :(NSString*)key
{
    [self setValue:value forKeyPath:key];
}

@end

@implementation LuaAppBarConfiguration

+(LuaAppBarConfiguration*)create:(BOOL)singleTop :(LuaRef*)popUpTo :(BOOL)popUpToInclusive
                                :(LuaRef*)enterAnim :(LuaRef*)exitAnim :(LuaRef*)popEnterAnim :(LuaRef*)popExitAnim
{
    return [[LuaAppBarConfiguration alloc] init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.no = [[AppBarConfiguration alloc] init];
    }
    return self;
}

-(void)setTopLevelDestinations:(NSMutableArray *)ids {
    self.no.mTopLevelDestinations = [[NSMutableSet alloc] initWithArray:ids];
}

-(NSObject *)getNativeObject {
    return self.no;
}

+ (NSString *)className {
    return @"LuaAppBarConfiguration";
}

+ (NSMutableDictionary *)luaMethods {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    ClassMethod(create:::::::, LuaAppBarConfiguration, @[[LuaBool class]C [LuaRef class]C [LuaBool class]C [LuaRef class]C [LuaRef class]C [LuaRef class]C [LuaRef class]C], @"create", [LuaAppBarConfiguration class])
    InstanceMethodNoRet(setTopLevelDestinations:, MakeArray([NSMutableArray class]C nil), @"setTopLevelDestinations")
    
    return dict;
}

@end

@implementation LuaNavController

- (instancetype)initWithController:(NavController*)controller
{
    self = [super init];
    if (self) {
        self.no = controller;
    }
    return self;
}

- (instancetype)initWithContext:(LuaContext*)context
{
    self = [super init];
    if (self) {
        self.no = [[NavController alloc] initWithContext:context];
    }
    return self;
}

-(void)navigateUp
{
    [self.no navigateUp];
}

-(void)navigateRef:(LuaRef*)ref
{
    [self.no navigateRefWithRef:ref];
}

-(void)navigateRef:(LuaRef*)ref :(NSDictionary*)dict
{
    [self.no navigateRefWithRef:ref args:dict];
}

-(void)navigateRef:(LuaRef*)ref :(NSDictionary*)dict :(NavOptions*)navOptions
{
    [self.no navigateRefWithRef:ref args:dict navOptions:navOptions];
}

-(void)navigateRef:(LuaRef*)ref :(NSDictionary*)dict :(NavOptions*)navOptions :(id<NavigatorExtras>) extras
{
    [self.no navigateRefWithRef:ref args:dict navOptions:navOptions navigatorExtras:extras];
}

- (NSObject *)getNativeObject {
    return self.no;
}

+ (NSString *)className {
    return @"LuaNavController";
}

+ (NSMutableDictionary *)luaMethods {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    InstanceMethodNoRetNoArg(navigateUp, @"navigateUp")
    InstanceMethodNoRet(navigateRef:, MakeArray([LuaRef class]C nil), @"navigate")
    InstanceMethodNoRet(navigateRef::, MakeArray([LuaRef class]C [NSDictionary class]C nil), @"navigateArgs")
    InstanceMethodNoRet(navigateRef:::, MakeArray([LuaRef class]C [NSDictionary class]C [NavOptions class]C nil), @"navigateArgsOptions")
        
    return dict;
}

@end

