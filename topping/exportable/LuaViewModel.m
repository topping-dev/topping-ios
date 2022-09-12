#import "LuaViewModel.h"
#import "LuaAll.h"

@implementation LuaViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.mBagOfTags = [NSMutableDictionary dictionary];
        self.mCleared = false;
    }
    return self;
}

-(void)onCleared
{
    
}

-(void)clear
{
    self.mCleared = true;
    if (self.mBagOfTags != nil) {
        @synchronized (self) {
            for(NSObject *value in [self.mBagOfTags allKeys])
            {
                [self closeWithRuntimeException:value];
            }
        }
    }
    [self onCleared];
}

-(NSObject*)setTagIfAbsent:(NSString*)key :(NSObject*)value
{
    NSObject *previous;
    @synchronized (self) {
        previous = [self.mBagOfTags objectForKey:key];
        if(previous == nil) {
            [self.mBagOfTags setObject:value forKey:key];
        }
    }
    NSObject *result = previous == nil ? value : previous;
    if(self.mCleared)
    {
        [self closeWithRuntimeException:result];
    }
    return result;
}

-(NSObject*)getTag:(NSString*)key
{
    if(self.mBagOfTags == nil)
        return nil;
    @synchronized (self) {
        return [self.mBagOfTags objectForKey:key];
    }
}

-(void)closeWithRuntimeException:(NSObject*)result
{
    
}

-(NSString*)GetId
{
    return @"LuaViewModel";
}

+ (NSString*)className
{
    return @"LuaViewModel";
}

+(NSMutableDictionary*)luaMethods
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    return dict;
}

@end
