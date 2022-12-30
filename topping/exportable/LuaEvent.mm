#import "LuaEvent.h"
#import "Defines.h"
#import "LuaFunction.h"
#import "LuaValues.h"
#import <topping/topping-Swift.h>

@implementation LuaEvent

static NSMutableDictionary* eventMap = [NSMutableDictionary dictionary];

+(NSObject*)OnUIEvent:(NSObject<LuaInterface>*)pGui :(int) EventType :(LuaContext*)lc :(int)ArgCount, ...
{
    LuaTranslator *ltToCall;
    ltToCall = [eventMap objectForKey:APPEND([pGui GetId], ITOS(EventType))];
    NSObject *ret = nil;
    if(ltToCall != nil)
    {
        va_list ap;
        va_start(ap, ArgCount);
        ret = [ltToCall CallInSelf:pGui :lc :ap];
        va_end(ap);
    }
    return ret;
}

+(void)RegisterUIEvent:(LuaRef *)luaId :(int)event :(LuaTranslator *)lt
{
    [LuaEvent RegisterUIEventInternal:[luaId GetCleanId] :event :lt];
}

+(void)RegisterUIEventInternal:(NSString *)luaId :(int)event :(LuaTranslator *)lt
{
    [eventMap setObject:lt forKey:APPEND(luaId, ITOS(event))];
}

-(NSString*)GetId
{
    return @"LuaEvent";
}

+ (NSString*)className
{
	return @"LuaEvent";
}

+(NSMutableDictionary*)luaStaticVars
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[NSNumber numberWithInt:0] forKey:@"UI_EVENT_CREATE"];
    [dict setObject:[NSNumber numberWithInt:1] forKey:@"UI_EVENT_FRAGMENT_CREATE_VIEW"];
    [dict setObject:[NSNumber numberWithInt:2] forKey:@"UI_EVENT_FRAGMENT_VIEW_CREATED"];
    [dict setObject:[NSNumber numberWithInt:3] forKey:@"UI_EVENT_RESUME"];
    [dict setObject:[NSNumber numberWithInt:4] forKey:@"UI_EVENT_PAUSE"];
    [dict setObject:[NSNumber numberWithInt:5] forKey:@"UI_EVENT_DESTROY"];
    [dict setObject:[NSNumber numberWithInt:6] forKey:@"UI_EVENT_UPDATE"];
    [dict setObject:[NSNumber numberWithInt:7] forKey:@"UI_EVENT_PAINT"];
    [dict setObject:[NSNumber numberWithInt:8] forKey:@"UI_EVENT_MOUSEDOWN"];
    [dict setObject:[NSNumber numberWithInt:9] forKey:@"UI_EVENT_MOUSEUP"];
    [dict setObject:[NSNumber numberWithInt:10] forKey:@"UI_EVENT_MOUSEMOVE"];
    [dict setObject:[NSNumber numberWithInt:11] forKey:@"UI_EVENT_KEYDOWN"];
    [dict setObject:[NSNumber numberWithInt:12] forKey:@"UI_EVENT_KEYUP"];
    [dict setObject:[NSNumber numberWithInt:13] forKey:@"UI_EVENT_NFC"];
    return dict;
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    ClassMethodNoRet(RegisterUIEvent:::, @[[LuaRef class]C [LuaInt class]C [LuaTranslator class]], @"RegisterUIEvent", [LuaEvent class])
    
	return dict;
}

@end
