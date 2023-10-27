#import "LuaThread.h"
#import "LuaFunction.h"
#import "LuaLong.h"

@implementation LuaThread

+(void) runOnBackgroundInternal:(dispatch_block_t)block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}

+(void) runOnUIThreadInternal:(dispatch_block_t)block
{
    if([NSThread isMainThread])
        block();
    else
        dispatch_async(dispatch_get_main_queue(), block);
}

+(dispatch_queue_t)createConcurrentInternal:(NSString *)label {
    return dispatch_queue_create(label.UTF8String, DISPATCH_QUEUE_CONCURRENT);
}

+(void)synchronized:(NSObject *)obj :(void (^)(void))block {
    @synchronized (obj) {
        block();
    }
}

+(void)runOnUIThread:(LuaTranslator *)runnable
{
    [LuaThread runOnUIThreadInternal:^{
        [runnable callIn:nil];
    }];
}

+(void)runOnBackground:(LuaTranslator *)runnable
{
    [LuaThread runOnBackgroundInternal:^{
        [runnable callIn:nil];
    }];
}

+(LuaThread *)create:(LuaTranslator *)runnable
{
    LuaThread *lt = [[LuaThread alloc] init];
    lt.runnable = runnable;
    return lt;
}

-(void)run
{
    if(self.runnable != nil)
    {
        [LuaThread runOnBackgroundInternal:^{
            [self.runnable callIn:nil];
        }];
    }
}

-(void)Wait:(long) milliseconds
{
    self.sema = dispatch_semaphore_create(0);
    dispatch_semaphore_wait(self.sema, milliseconds < 0 ? DISPATCH_TIME_FOREVER : milliseconds);
}

-(void)Notify
{
    if(self.sema != nil)
        dispatch_semaphore_signal(self.sema);
}

-(void)interrupt
{
    if(self.sema != nil)
    dispatch_semaphore_signal(self.sema);
}

-(void)sleep:(long) milliseconds
{
    self.sema = dispatch_semaphore_create(0);
    dispatch_semaphore_wait(self.sema, milliseconds < 0 ? DISPATCH_TIME_FOREVER : milliseconds);
}

-(NSString*)GetId
{
    return @"LuaThread";
}

+ (NSString*)className
{
    return @"LuaThread";
}

+(NSMutableDictionary*)luaMethods
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(runOnUIThread:))
                                        :@selector(runOnUIThread:)
                                        :nil
                                        :[NSArray arrayWithObjects:[LuaTranslator class], nil]
                                        :[LuaThread class]]
             forKey:@"runOnUIThread"];
    [dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(runOnBackground:))
                               :@selector(runOnBackground:)
                               :nil
                               :[NSArray arrayWithObjects:[LuaTranslator class], nil]
                               :[LuaThread class]]
             forKey:@"runOnBackground"];
    [dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(create:))
                      :@selector(create:)
                      :[NSObject class]
                      :[NSArray arrayWithObjects:[LuaTranslator class], nil]
                      :[LuaThread class]]
    forKey:@"create"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(run)) :@selector(run) :nil :MakeArray(nil)] forKey:@"run"];
    /*[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(Wait:)) :@selector(Wait:) :nil :MakeArray([LuaLong class]C nil)] forKey:@"wait"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(notify)) :@selector(notify) :nil :MakeArray(nil)] forKey:@"notify"];*/
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(interrupt)) :@selector(interrupt) :nil :MakeArray(nil)] forKey:@"interrupt"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(sleep:)) :@selector(sleep:) :nil :MakeArray([LuaLong class]C nil)] forKey:@"sleep"];
    return dict;
}

@end
