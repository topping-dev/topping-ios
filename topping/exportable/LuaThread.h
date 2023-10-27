#import <Foundation/Foundation.h>
#import "LuaClass.h"
#import "LuaInterface.h"
#import "LuaContext.h"
#import "LuaTranslator.h"

NS_ASSUME_NONNULL_BEGIN

@interface LuaThread : NSObject <LuaClass, LuaInterface>

+(void)runOnBackgroundInternal:(dispatch_block_t)block;
+(void)runOnUIThreadInternal:(dispatch_block_t)block;
+(dispatch_queue_t)createConcurrentInternal:(NSString *)label;
+(void)synchronized:(NSObject*)obj :(void (^)(void))block;
+(void)runOnUIThread:(LuaTranslator *)runnable;
+(void)runOnBackground:(LuaTranslator *)runnable;
+(LuaThread*)create:(LuaTranslator *)runnable;
-(void)run;
-(void)interrupt;
-(void)sleep:(long) milliseconds;

@property (nonatomic, retain) LuaTranslator* runnable;
@property (nonatomic, retain) dispatch_semaphore_t sema;

@end

NS_ASSUME_NONNULL_END
