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

-(LuaViewModel*)Get:(NSString*)tag
{
    if(viewModelStore == nil)
        viewModelStore = [NSMutableDictionary dictionary];
    LuaViewModel *luaViewModel = [viewModelStore objectForKey:tag];
    if(luaViewModel == nil)
    {
        luaViewModel = [LuaViewModel new];
        [viewModelStore setObject:luaViewModel forKey:tag];
    }
    
    return luaViewModel;
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
    
    ClassMethod(OfForm:, LuaViewModelProvider, MakeArray([LuaForm class]C nil), @"OfForm")
    ClassMethod(OfFragment:, LuaViewModelProvider, MakeArray([LuaFragment class]C nil), @"OfFragment")
    InstanceMethod(Get:, LuaViewModel, MakeArray([NSString class]C nil), @"Get")
    
    return dict;
}

@end
