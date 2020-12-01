#import "LuaLog.h"
#import "LuaFunction.h"

@implementation LuaLog

+(void)V:(NSString *)tag :(NSString *)message
{
    NSMutableString *str = [NSMutableString string];
    [str appendString:@"V-->"];
}

+(void)D:(NSString *)tag :(NSString *)message
{
    NSMutableString *str = [NSMutableString string];
    [str appendString:@"D-->"];
}

+(void)I:(NSString *)tag :(NSString *)message
{
    NSMutableString *str = [NSMutableString string];
    [str appendString:@"I-->"];
}

+(void)W:(NSString *)tag :(NSString *)message
{
    NSMutableString *str = [NSMutableString string];
    [str appendString:@"W-->"];
}

+(void)E:(NSString *)tag :(NSString *)message
{
    NSMutableString *str = [NSMutableString string];
    [str appendString:@"E-->"];
}

+(void)MSG:(NSMutableString*)prefix :(NSString *)tag :(NSString *)message
{
    [prefix appendString:tag];
    [prefix appendString:@":"];
    [prefix appendString:message];
    NSLog(@"%@", prefix);
}

-(NSString*)GetId
{
    return [LuaLog className];
}

+ (NSString*)className
{
	return @"LuaLog";
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
        [dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(V::))
        :@selector(V::)
        :[LuaLog class]
        :[NSArray arrayWithObjects:[NSString class], [NSString class], nil]
        :[LuaLog class]]
    forKey:@"V"];
        [dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(D::))
        :@selector(D::)
        :[LuaLog class]
        :[NSArray arrayWithObjects:[NSString class], [NSString class], nil]
        :[LuaLog class]]
    forKey:@"D"];
        [dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(I::))
        :@selector(I::)
        :[LuaLog class]
        :[NSArray arrayWithObjects:[NSString class], [NSString class], nil]
        :[LuaLog class]]
    forKey:@"I"];
        [dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(W::))
        :@selector(W::)
        :[LuaLog class]
        :[NSArray arrayWithObjects:[NSString class], [NSString class], nil]
        :[LuaLog class]]
    forKey:@"W"];
        [dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(E::))
        :@selector(E::)
        :[LuaLog class]
        :[NSArray arrayWithObjects:[NSString class], [NSString class], nil]
        :[LuaLog class]]
    forKey:@"E"];
	return dict;
}

@end
