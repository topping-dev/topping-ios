#import "LuaViewModelProvider.h"
#import "LuaAll.h"
#import "LuaViewModel.h"

@implementation LuaViewModelProvider

+(LuaViewModelProvider*)OfForm:(LuaForm*)form
{    
    return form.viewModelProvider;
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
    return dict;
}

@end
