#import "CoroutineScope.h"

@class CoroutineScope;

@implementation CancelRunBlock

+(CancelRunBlock*)dispatch_async_with_cancel_block:(CoroutineScope*)scope :(dispatch_queue_t) queue :(void (^)(void))block {
    __block BOOL execute = YES;
    __block BOOL executed = NO;
    
    __block CancelRunBlock *crb = [CancelRunBlock new];
    crb.scope = scope;

    dispatch_cancel_block_t cancelBlock = ^BOOL (BOOL cancelled) {
        execute = !cancelled;
        return executed == NO;
    };
    
    dispatch_run_block_t runBlock = ^() {
        dispatch_async(queue, ^{
            if (execute)
            {
                block();
                if(crb.delegate != nil && [crb.delegate respondsToSelector:@selector(onFinish)])
                {
                    [crb.delegate onFinish:crb];
                }
            } else {
                if(crb.delegate != nil && [crb.delegate respondsToSelector:@selector(onCancel)])
                {
                    [crb.delegate onCancel:crb];
                }
            }
            executed = YES;
            crb.executed = YES;
            [crb.scope.coroutineContext removeObjectForKey:block];
        });
    };
    
    crb.cancelBlock = cancelBlock;
    crb.runBlock = runBlock;

    return crb;
}

+(CancelRunBlock*)dispatch_async_with_cancel_block_result:(CoroutineScope*)scope :(dispatch_queue_t)queue :(NSObject* (^)(void))block {
    __block BOOL execute = YES;
    __block BOOL executed = NO;
    
    __block CancelRunBlock *crb = [CancelRunBlock new];
    crb.scope = scope;

    dispatch_cancel_block_t cancelBlock = ^BOOL (BOOL cancelled) {
        execute = !cancelled;
        return executed == NO;
    };
    
    dispatch_run_block_t runBlock = ^() {
        dispatch_async(queue, ^{
            if (execute)
            {
                crb.result = block();
                if(crb.delegate != nil && [crb.delegate respondsToSelector:@selector(onFinish)])
                {
                    [crb.delegate onFinish:crb];
                }
            } else {
                if(crb.delegate != nil && [crb.delegate respondsToSelector:@selector(onCancel)])
                {
                    [crb.delegate onCancel:crb];
                }
            }
            executed = YES;
            crb.executed = YES;
            [crb.scope.coroutineContext removeObjectForKey:block];
        });
    };
    
    crb.cancelBlock = cancelBlock;
    crb.runBlock = runBlock;

    return crb;
}

-(void)wait {
    while (!self.executed) {
        sleep(100);
    }
}

@end

@implementation CoroutineScope

+(NSObject *)withContext:(int)dispatcher :(NSObject *(^)(CoroutineScope*))block {
    __block CoroutineScope *scope = [CoroutineScope new];
    CancelRunBlock *crb = [scope launch:dispatcher :^(CoroutineScope *scope) {
        CancelRunBlock *crbIn = [scope.coroutineContext objectForKey:block];
        crbIn.result = block(scope);
    }];
    [crb wait];
    return crb.result;
}

-(CancelRunBlock *)launch:(void (^)(CoroutineScope*))block {
    CancelRunBlock* crb = [CancelRunBlock dispatch_async_with_cancel_block:self :dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) :^(void){
        block(self);
    }];
    if(self.coroutineContext == nil) {
        self.coroutineContext = [NSMutableDictionary dictionary];
    }
    [self.coroutineContext setObject:crb forKey:block];
    return crb;
}

-(CancelRunBlock *)launch:(int)dispatcher :(void (^)(CoroutineScope*))block {
    CancelRunBlock* crb = nil;
    switch(dispatcher) {
        case DEFAULT:
        {
            crb = [CancelRunBlock dispatch_async_with_cancel_block:self :dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) :^(void){
                block(self);
            }];
        } break;
        case MAIN:
        {
            crb = [CancelRunBlock
                   dispatch_async_with_cancel_block:self :dispatch_get_main_queue() :^(void){
                block(self);
            }];
        } break;
        case UNCONFINED:
        {
            crb = [CancelRunBlock dispatch_async_with_cancel_block:self :dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) :^(void){
                block(self);
            }];
        } break;
        case IO:
        {
            crb = [CancelRunBlock dispatch_async_with_cancel_block:self :dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) :^(void){
                block(self);
            }];
        } break;
        default:
        {
            crb = [CancelRunBlock dispatch_async_with_cancel_block:self :dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) :^(void){
                block(self);
            }];
        }
    }
    if(self.coroutineContext == nil) {
        self.coroutineContext = [NSMutableDictionary dictionary];
    }
    [self.coroutineContext setObject:crb forKey:block];
    return crb;
}

@end
