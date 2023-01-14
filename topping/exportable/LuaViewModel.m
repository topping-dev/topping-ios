#import "LuaViewModel.h"
#import "LuaAll.h"
#import "CancelRunBlock.h"

@implementation ClosableCoroutineScope

-(void)close {
    for(CancelRunBlock* crb in self.jobSet) {
        crb.cancelBlock(YES);
    }
    [self.jobSet removeAllObjects];
}

@end

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

-(void)SetObject:(NSString *)key :(NSObject *)obj
{
    [self.objectMap setObject:obj forKey:key];
}

-(NSObject *)GetObject:(NSString *)key
{
    return [self.objectMap objectForKey:key];
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
    if([result isKindOfClass:[ClosableCoroutineScope class]]) {
        [((ClosableCoroutineScope*)result) close];
    }
}

-(LuaCoroutineScope*)getViewModelScope {
    LuaCoroutineScope* scope = (LuaCoroutineScope*)[self getTag:@"LuaViewModelScope.JOB_KEY"];
    if(scope != nil) {
        return scope;
    }
    return (LuaCoroutineScope*)[self setTagIfAbsent:@"LuaViewModelScope.JOB_KEY" :[ClosableCoroutineScope new]];
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
    
    InstanceMethodNoArg(GetObject, @[[NSString class]], @"GetObject")
    InstanceMethodNoRet(SetObject::, @[[NSString class]C [NSObject class]], @"SetObject")
    
    return dict;
}

@end
