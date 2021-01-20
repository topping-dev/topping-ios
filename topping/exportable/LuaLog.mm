#import "LuaLog.h"
#import "LuaFunction.h"

@implementation LuaLog

+(void)V:(NSString *)tag :(NSString *)message
{
    [LuaLog MSG:@"V-->" :tag :message];
}

+(void)D:(NSString *)tag :(NSString *)message
{
    [LuaLog MSG:@"D-->" :tag :message];
}

+(void)I:(NSString *)tag :(NSString *)message
{
    [LuaLog MSG:@"I-->" :tag :message];
}

+(void)W:(NSString *)tag :(NSString *)message
{
    [LuaLog MSG:@"W-->" :tag :message];
}

+(void)E:(NSString *)tag :(NSString *)message
{
    [LuaLog MSG:@"E-->" :tag :message];
}

+(void)MSG:(NSString*)pref :(NSString *)tag :(NSString *)message
{
    NSMutableString *prefix = [NSMutableString string];
    [prefix appendString:pref];
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
        :nil
        :[NSArray arrayWithObjects:[NSString class], [NSString class], nil]
        :[LuaLog class]]
    forKey:@"V"];
        [dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(D::))
        :@selector(D::)
        :nil
        :[NSArray arrayWithObjects:[NSString class], [NSString class], nil]
        :[LuaLog class]]
    forKey:@"D"];
        [dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(I::))
        :@selector(I::)
        :nil
        :[NSArray arrayWithObjects:[NSString class], [NSString class], nil]
        :[LuaLog class]]
    forKey:@"I"];
        [dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(W::))
        :@selector(W::)
        :nil
        :[NSArray arrayWithObjects:[NSString class], [NSString class], nil]
        :[LuaLog class]]
    forKey:@"W"];
        [dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(E::))
        :@selector(E::)
        :nil
        :[NSArray arrayWithObjects:[NSString class], [NSString class], nil]
        :[LuaLog class]]
    forKey:@"E"];
	return dict;
}

@end
