#import <Foundation/Foundation.h>
#import "KotlinExports.h"

#import <Topping/Topping-Swift.h>

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
    
    ClassMethod(create:::::::, LuaAppBarConfiguration, MakeArray([LuaBool class]C [LuaRef class]C [LuaBool class]C [LuaRef class]C [LuaRef class]C [LuaRef class]C [LuaRef class]C nil), @"create")
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

