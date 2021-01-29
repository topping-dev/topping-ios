#import "LuaNativeCall.h"
#import "LuaFunction.h"

@implementation LuaNativeCall

+(LuaNativeObject *)CallClass:(NSString *)clss :(NSString *)func :(NSArray *)params
{
    SEL selector = NSSelectorFromString(func);
    NSMethodSignature *sig = [clss methodSignatureForSelector:selector];
    if (!sig)
        return nil;

    NSInvocation* invo = [NSInvocation invocationWithMethodSignature:sig];
    [invo setTarget:clss];
    [invo setSelector:selector];
    int i = 2;
    for(id obj in params)
        [invo setArgument:&obj atIndex:i++];
    [invo invoke];
    LuaNativeObject *lno = [LuaNativeObject new];
    if (sig.methodReturnLength) {
        id anObject;
        [invo getReturnValue:&anObject];
        lno.obj = anObject;
    }
    return lno;
}

+(LuaNativeObject *)Call:(LuaNativeObject *)obj :(NSString *)func :(NSArray *)params
{
    //objc_msgSend(target, @selector(action:::), );
    SEL selector = NSSelectorFromString(func);
    NSMethodSignature *sig = [obj methodSignatureForSelector:selector];
    if (!sig)
        return nil;

    NSInvocation* invo = [NSInvocation invocationWithMethodSignature:sig];
    [invo setTarget:self];
    [invo setSelector:selector];
    int i = 2;
    for(id obj in params)
        [invo setArgument:&obj atIndex:i++];
    [invo invoke];
    LuaNativeObject *lno = [LuaNativeObject new];
    if (sig.methodReturnLength) {
        id anObject;
        [invo getReturnValue:&anObject];
        lno.obj = anObject;
    }
    return lno;
}

-(NSString*)GetId
{
    return @"LuaNativeCall";
}

+ (NSString*)className
{
    return @"LuaNativeCall";
}

+(NSMutableDictionary*)luaMethods
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(CallClass:::))
                                        :@selector(CallClass:::)
                                        :[LuaNativeObject class]
                                        :[NSArray arrayWithObjects:[NSString class], [NSString class], [NSArray class], nil]
                                        :[LuaNativeCall class]]
             forKey:@"CallClass"];
    [dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(Call:::))
                                        :@selector(Call:::)
                                        :[LuaNativeObject class]
                                        :[NSArray arrayWithObjects:[LuaNativeObject class], [NSString class], [NSArray class], nil]
                                        :[LuaNativeCall class]]
             forKey:@"Call"];
    return dict;
}

@end
