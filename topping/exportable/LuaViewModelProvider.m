#import "LuaViewModelProvider.h"
#import "LuaAll.h"
#import "LuaViewModel.h"
#import "LuaFragment.h"
#import <Topping/Topping-Swift.h>

@implementation LuaViewModelProvider

+(LuaViewModelProvider*)OfForm:(LuaForm*)form
{    
    return [[LuaViewModelProvider alloc] initWithViewModelProvider:[[ViewModelProvider alloc] initWithOwner:form]];
}

+(LuaViewModelProvider*)OfFragment:(LuaFragment*)fragment
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

-(LuaViewModel*)Get:(NSString*)key
{
    return [self.viewModelProvider getWithKey:key];
}

-(void *)Get:(NSString *)key ptr:(void *)ptr {
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
    
    ClassMethod(OfForm:, LuaViewModelProvider, MakeArray([LuaForm class]C nil), @"OfForm", [LuaViewModelProvider class])
    ClassMethod(OfFragment:, LuaViewModelProvider, MakeArray([LuaFragment class]C nil), @"OfFragment", [LuaViewModelProvider class])
    InstanceMethod(Get:, LuaViewModel, MakeArray([NSString class]C nil), @"Get")
    
    return dict;
}

@end
