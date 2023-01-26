#import "LuaCoroutineScope.h"
#import "LuaFunction.h"
#import "LuaDispatchers.h"
#import "CoroutineScope.h"
#import "Lifecycle.h"

@implementation LuaJob

- (instancetype)initWithJob:(CancelRunBlock*)job
{
    self = [super init];
    if (self) {
        self.job = job;
    }
    return self;
}

-(void)cancel {
    self.job.cancelBlock(true);
}

-(void)delay:(long)milliseconds {
    sleep((unsigned int)milliseconds);
}

+ (NSString *)className {
    return @"LuaJob";
}

+ (NSMutableDictionary *)luaMethods {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    InstanceMethodNoRetNoArg(cancel, @"cancel")
    InstanceMethodNoRet(delay:, @[ [LuaLong class] ], @"delay")
    
    return dict;
}

@end

@implementation LuaCoroutineScope

- (instancetype)initWithScope:(CoroutineScope*)scope
{
    self = [super init];
    if (self) {
        self.jobSet = [NSMutableSet set];
        self.scope = scope;
    }
    return self;
}

-(LuaJob*)launch:(LuaTranslator *)lt
{
    __block LuaJob *lj;
    CancelRunBlock* crb = [self.scope launch:^(CoroutineScope *scope){
        [lt call:lj];
    }];
    crb.delegate = self;
    lj = [[LuaJob alloc] initWithJob:crb];
    [self.jobSet addObject:lj];
    return lj;
}

-(LuaJob*)launchDispatcher:(int)dispatcher :(LuaTranslator *)lt
{
    __block LuaJob *lj;
    CancelRunBlock *crb = [self.scope launch:dispatcher :^(CoroutineScope *scope){
        [lt call:lj];
    }];
    crb.delegate = self;
    lj = [[LuaJob alloc] initWithJob:crb];
    [self.jobSet addObject:lj];
    return lj;
}

-(void)onCancel:(CancelRunBlock*)job {
    [self.jobSet removeObject:job];
}

-(void)onFinish:(CancelRunBlock*)job {
    [self.jobSet removeObject:job];
}

+ (NSString *)className {
    return @"LuaCoroutineScope";
}

+ (NSMutableDictionary *)luaMethods {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    InstanceMethodNoRet(launch:, MakeArray([LuaTranslator class]C nil), @"launch")
    InstanceMethodNoRet(launchDispatcher::, MakeArray([LuaInt class]C [LuaTranslator class]C nil), @"launchDispatcher")
    
    return dict;
}

@end
