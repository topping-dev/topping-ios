#import "LuaThread.h"
#import "LuaFunction.h"
#import "LuaLong.h"

@implementation LuaThread

+(void) RunOnBackgroundInternal:(dispatch_block_t)block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}

+(void) RunOnUIThreadInternal:(dispatch_block_t)block
{
    if([NSThread isMainThread])
        block();
    else
        dispatch_async(dispatch_get_main_queue(), block);
}

+(void)RunOnUIThread:(LuaTranslator *)runnable
{
    [LuaThread RunOnUIThreadInternal:^{
        [runnable CallIn:nil];
    }];
}

+(void)RunOnBackground:(LuaTranslator *)runnable
{
    [LuaThread RunOnBackgroundInternal:^{
        [runnable CallIn:nil];
    }];
}

+(LuaThread *)New:(LuaTranslator *)runnable
{
    LuaThread *lt = [[LuaThread alloc] init];
    lt.runnable = runnable;
    return lt;
}

-(void)Run
{
    if(self.runnable != nil)
    {
        [LuaThread RunOnBackgroundInternal:^{
            [self.runnable CallIn:nil];
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

-(void)Interrupt
{
    if(self.sema != nil)
    dispatch_semaphore_signal(self.sema);
}

-(void)Sleep:(long) milliseconds
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
    [dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(RunOnUIThread:))
                                        :@selector(RunOnUIThread:)
                                        :nil
                                        :[NSArray arrayWithObjects:[LuaTranslator class], nil]
                                        :[LuaThread class]]
             forKey:@"RunOnUIThread"];
    [dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(RunOnBackground:))
                               :@selector(RunOnBackground:)
                               :nil
                               :[NSArray arrayWithObjects:[LuaTranslator class], nil]
                               :[LuaThread class]]
             forKey:@"RunOnBackground"];
    [dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(New:))
                      :@selector(New:)
                      :[NSObject class]
                      :[NSArray arrayWithObjects:[LuaTranslator class], nil]
                      :[LuaThread class]]
    forKey:@"New"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(Run)) :@selector(Run) :nil :MakeArray(nil)] forKey:@"Run"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(Wait:)) :@selector(Wait:) :nil :MakeArray([LuaLong class]C nil)] forKey:@"Wait"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(Notify)) :@selector(Notify) :nil :MakeArray(nil)] forKey:@"Notify"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(Interrupt)) :@selector(Interrupt) :nil :MakeArray(nil)] forKey:@"Interrupt"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(Sleep:)) :@selector(Sleep:) :nil :MakeArray([LuaLong class]C nil)] forKey:@"Sleep"];
    return dict;
}

@end
