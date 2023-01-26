#import <Foundation/Foundation.h>

typedef enum Dispatchers
{
    DEFAULT,
    MAIN,
    UNCONFINED,
    IO
} Dispatchers;

@class CancelRunBlock;
@class CoroutineScope;

typedef BOOL (^dispatch_cancel_block_t)(BOOL cancelBlock);
typedef void (^dispatch_run_block_t)(void);

@protocol CancelRunBlockDelegate <NSObject>

@optional
-(void)onCancel:(CancelRunBlock*)job;
-(void)onFinish:(CancelRunBlock*)job;

@end

@interface CancelRunBlock : NSObject

+(CancelRunBlock*)dispatch_async_with_cancel_block:(CoroutineScope*)scope :(dispatch_queue_t)queue :(void (^)(void))block;
+(CancelRunBlock*)dispatch_async_with_cancel_block_result:(CoroutineScope*)scope :(dispatch_queue_t)queue :(NSObject* (^)(void))block;
-(void)wait;

@property (nonatomic, copy) dispatch_cancel_block_t cancelBlock;
@property (nonatomic, copy) dispatch_run_block_t runBlock;
@property (nonatomic, retain) id<CancelRunBlockDelegate> delegate;
@property (nonatomic, retain) CoroutineScope *scope;
@property (nonatomic) bool executed;
@property (nonatomic, retain) NSObject *result;

@end

@interface CoroutineScope : NSObject

+(NSObject*)withContext:(int)dispatcher :(NSObject* (^)(CoroutineScope*))block;
-(CancelRunBlock*)launch:(void (^)(CoroutineScope*))block;
-(CancelRunBlock*)launch:(int)dispatcher :(void (^)(CoroutineScope*))block;

@property (nonatomic, retain) NSMutableDictionary *coroutineContext;

@end
