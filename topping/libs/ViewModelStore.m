#import "ViewModelStore.h"

@implementation ViewModelStore

-(void)put:(NSString*)key :(LuaViewModel*)viewModel
{
    [self.mMap setObject:viewModel forKey:key];
}

-(LuaViewModel*)get:(NSString*)key
{
    return [self.mMap objectForKey:key];
}

-(NSArray*)keys
{
    return [self.mMap allKeys];
}

-(void)clear
{
    for(NSString* key in [self.mMap allKeys])
    {
        [((LuaViewModel*)[self.mMap objectForKey:key]) clear];
    }
        
    [self.mMap removeAllObjects];
}

@end
