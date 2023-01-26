#import "LuaViewModelProvider.h"
#import "LuaAll.h"
#import "LuaViewModel.h"
#import "LuaFragment.h"
#import <Topping/Topping-Swift.h>

@implementation LuaViewModelProvider

+(LuaViewModelProvider*)ofForm:(LuaForm*)form
{    
    return [[LuaViewModelProvider alloc] initWithViewModelProvider:[[ViewModelProvider alloc] initWithOwner:form]];
}

+(LuaViewModelProvider*)ofFragment:(LuaFragment*)fragment
{
    return [[LuaViewModelProvider alloc] initWithViewModelProvider:[[ViewModelProvider alloc] initWithOwner:fragment]];
}

- (instancetype)initWithViewModelProvider:(ViewModelProvider*)viewModelProvider
{
    self = [super init];
    if (self) {
        self.viewModelProvider = viewModelProvider;
    }
    return self;
}

-(LuaViewModel*)get:(NSString*)key
{
    return [self.viewModelProvider getWithKey:key];
}

-(void *)get:(NSString *)key ptr:(void *)ptr {
    return [self.viewModelProvider getWithKey:key ptr:ptr];
}

-(NSString*)GetId
{
    return @"LuaViewModelProvider";
}

+ (NSString*)className
{
    return @"LuaViewModelProvider";
}

+(NSMutableDictionary*)luaMethods
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    
    ClassMethod(ofForm:, LuaViewModelProvider, MakeArray([LuaForm class]C nil), @"ofForm", [LuaViewModelProvider class])
    ClassMethod(ofFragment:, LuaViewModelProvider, MakeArray([LuaFragment class]C nil), @"ofFragment", [LuaViewModelProvider class])
    InstanceMethod(get:, LuaViewModel, MakeArray([NSString class]C nil), @"get")
    
    return dict;
}

@end
