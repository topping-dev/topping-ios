#import "LuaLog.h"
#import "LuaFunction.h"

@implementation LuaLog

+(void)v:(NSString *)tag :(NSString *)message
{
    [LuaLog MSG:@"V-->" :tag :message];
}

+(void)d:(NSString *)tag :(NSString *)message
{
    [LuaLog MSG:@"D-->" :tag :message];
}

+(void)i:(NSString *)tag :(NSString *)message
{
    [LuaLog MSG:@"I-->" :tag :message];
}

+(void)w:(NSString *)tag :(NSString *)message
{
    [LuaLog MSG:@"W-->" :tag :message];
}

+(void)e:(NSString *)tag :(NSString *)message
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
        [dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(v::))
        :@selector(v::)
        :nil
        :[NSArray arrayWithObjects:[NSString class], [NSString class], nil]
        :[LuaLog class]]
    forKey:@"v"];
        [dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(d::))
        :@selector(d::)
        :nil
        :[NSArray arrayWithObjects:[NSString class], [NSString class], nil]
        :[LuaLog class]]
    forKey:@"d"];
        [dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(i::))
        :@selector(i::)
        :nil
        :[NSArray arrayWithObjects:[NSString class], [NSString class], nil]
        :[LuaLog class]]
    forKey:@"i"];
        [dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(w::))
        :@selector(w::)
        :nil
        :[NSArray arrayWithObjects:[NSString class], [NSString class], nil]
        :[LuaLog class]]
    forKey:@"w"];
        [dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(e::))
        :@selector(e::)
        :nil
        :[NSArray arrayWithObjects:[NSString class], [NSString class], nil]
        :[LuaLog class]]
    forKey:@"e"];
	return dict;
}

@end
