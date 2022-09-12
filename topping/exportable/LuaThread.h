#import <Foundation/Foundation.h>
#import "LuaClass.h"
#import "LuaInterface.h"
#import "LuaContext.h"
#import "LuaTranslator.h"

NS_ASSUME_NONNULL_BEGIN

@interface LuaThread : NSObject <LuaClass, LuaInterface>

+(void) RunOnBackgroundInternal:(dispatch_block_t)block;
+(void) RunOnUIThreadInternal:(dispatch_block_t)block;
+(void)RunOnUIThread:(LuaTranslator *)runnable;
+(void)RunOnBackground:(LuaTranslator *)runnable;
+(LuaThread*)New:(LuaTranslator *)runnable;
-(void)Run;
-(void)Wait:(long) milliseconds;
-(void)Notify;
-(void)Interrupt;
-(void)Sleep:(long) milliseconds;

@property (nonatomic, retain) LuaTranslator* runnable;
@property (nonatomic, retain) dispatch_semaphore_t sema;

@end

NS_ASSUME_NONNULL_END
