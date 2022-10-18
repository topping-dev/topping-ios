#import "LuaCoroutineScope.h"
#import "LuaFunction.h"
#import "LuaDispatchers.h"

@implementation LuaCoroutineScope

-(void)launch:(LuaTranslator *)lt
{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        [lt Call];
    });
}

-(void)launchDispatcher:(LuaInt *)dispatcher :(LuaTranslator *)lt
{
    switch([dispatcher intValue]) {
        case DEFAULT:
        {
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                [lt Call];
            });
        } break;
        case MAIN:
        {
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [lt Call];
            });
        } break;
        case UNCONFINED:
        {
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                [lt Call];
            });
        } break;
        case IO:
        {
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                [lt Call];
            });
        } break;
        default:
        {
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                [lt Call];
            });
        }
    }
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
