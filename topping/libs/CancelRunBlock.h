#import <Foundation/Foundation.h>

@class CancelRunBlock;

typedef BOOL (^dispatch_cancel_block_t)(BOOL cancelBlock);
typedef void (^dispatch_run_block_t)(void);

@protocol CancelRunBlockDelegate <NSObject>

@optional
-(void)onCancel:(CancelRunBlock*)job;
-(void)onFinish:(CancelRunBlock*)job;

@end

@interface CancelRunBlock : NSObject

+(CancelRunBlock*)dispatch_async_with_cancel_block:(dispatch_queue_t) queue :(void (^)(void))block;

@property (nonatomic, copy) dispatch_cancel_block_t cancelBlock;
@property (nonatomic, copy) dispatch_run_block_t runBlock;
@property (nonatomic, retain) id<CancelRunBlockDelegate> delegate;

@end
