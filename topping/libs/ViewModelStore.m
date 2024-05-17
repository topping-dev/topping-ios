#import "ViewModelStore.h"

@implementation ViewModelStore

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.mMap = [NSMutableDictionary dictionary];
    }
    return self;
}

-(void)put:(NSString*)key :(NSObject*)viewModel
{
    [self.mMap setObject:viewModel forKey:key];
}

-(void)put:(NSString*)key ptr:(void*)viewModel
{
    [self.mMap setObject:[NSValue valueWithPointer:viewModel] forKey:key];
}

-(LuaViewModel*)get:(NSString*)key
{
    return [self.mMap objectForKey:key];
}

-(void*)getPtr:(NSString*)key
{
    NSValue *value = [self.mMap objectForKey:key];
    return [value pointerValue];
}

-(NSObject*)getObj:(NSString*)key
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
