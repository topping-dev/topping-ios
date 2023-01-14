#import "LuaCoroutineScope.h"
#import "LuaFunction.h"
#import "LuaDispatchers.h"
#import "CancelRunBlock.h"

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

+ (NSString *)className {
    return @"LuaJob";
}

+ (NSMutableDictionary *)luaMethods {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    InstanceMethodNoRetNoArg(cancel, @"cancel")
    
    return dict;
}

@end

@implementation LuaCoroutineScope

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.jobSet = [NSMutableSet set];
    }
    return self;
}

-(LuaJob*)launch:(LuaTranslator *)lt
{
    CancelRunBlock* crb = [CancelRunBlock dispatch_async_with_cancel_block:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) :^(void){
        [lt Call];
    }];
    crb.delegate = self;
    LuaJob *lj = [[LuaJob alloc] initWithJob:crb];
    [self.jobSet addObject:lj];
    return lj;
}

-(LuaJob*)launchDispatcher:(int)dispatcher :(LuaTranslator *)lt
{
    CancelRunBlock* crb = nil;
    switch(dispatcher) {
        case DEFAULT:
        {
            crb = [CancelRunBlock dispatch_async_with_cancel_block:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) :^(void){
                [lt Call];
            }];
        } break;
        case MAIN:
        {
            crb = [CancelRunBlock
                dispatch_async_with_cancel_block:dispatch_get_main_queue() :^(void){
                [lt Call];
            }];
        } break;
        case UNCONFINED:
        {
            crb = [CancelRunBlock dispatch_async_with_cancel_block:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) :^(void){
                [lt Call];
            }];
        } break;
        case IO:
        {
            crb = [CancelRunBlock dispatch_async_with_cancel_block:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) :^(void){
                [lt Call];
            }];
        } break;
        default:
        {
            crb = [CancelRunBlock dispatch_async_with_cancel_block:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) :^(void){
                [lt Call];
            }];
        }
    }
    crb.delegate = self;
    LuaJob *lj = [[LuaJob alloc] initWithJob:crb];
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
