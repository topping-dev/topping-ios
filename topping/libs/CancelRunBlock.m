#import "CancelRunBlock.h"

@implementation CancelRunBlock

+(CancelRunBlock*)dispatch_async_with_cancel_block:(dispatch_queue_t) queue :(void (^)(void))block {
    __block BOOL execute = YES;
    __block BOOL executed = NO;
    
    __block CancelRunBlock *crb = [CancelRunBlock new];

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
        });
    };
    
    crb.cancelBlock = cancelBlock;
    crb.runBlock = runBlock;

    return crb;
}

@end
