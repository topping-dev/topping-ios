#import "LuaBundle.h"
#import <topping/topping-Swift.h>
#import "Topping.h"

@implementation LuaBundle

- (instancetype)initWithBundle:(NSMutableDictionary*)bundle
{
    self = [super init];
    if (self) {
        self.bundle = bundle;
    }
    return self;
}

-(NSString *)getString:(NSString *)key {
    return [self getString:key :nil];
}

-(NSString *)getString:(NSString *)key :(NSString *)def {
    NSString *val = [self.bundle objectForKey:key];
    if(val != nil)
        return val;
    return def;
}

-(void)putString:(NSString *)key :(NSString *)value {
    [self.bundle setObject:value forKey:key];
}

-(NSNumber*)getNumber:(NSString*)key :(double)def {
    NSNumber *num = [self.bundle objectForKey:key];
    if(num != nil)
        return num;
    return [NSNumber numberWithDouble:def];
}

-(short)getByte:(NSString *)key {
    return [self getByte:key :0];
}

-(short)getByte:(NSString *)key :(short)def {
    NSNumber *num = [self getNumber:key :def];
    return [num shortValue];
}

-(void)putByte:(NSString *)key :(short)value {
    [self.bundle setObject:[NSNumber numberWithShort:value] forKey:key];
}

-(int)getInt:(NSString*)key {
    return [self getInt:key :0];
}

-(int)getInt:(NSString*)key :(int)def {
    NSNumber *num = [self getNumber:key :def];
    return [num intValue];
}

-(void)putInt:(NSString*)key :(int)value {
    [self.bundle setObject:[NSNumber numberWithInt:value] forKey:key];
}

-(long)getLong:(NSString*)key {
    return [self getLong:key :0];
}

-(long)getLong:(NSString*)key :(long)def {
    NSNumber *num = [self getNumber:key :def];
    return [num longValue];
}

-(void)putLong:(NSString*)key :(long)value {
    [self.bundle setObject:[NSNumber numberWithLong:value] forKey:key];
}

-(float)getFloat:(NSString*)key {
    return [self getFloat:key :0];
}

-(float)getFloat:(NSString*)key :(float)def {
    NSNumber *num = [self getNumber:key :def];
    return [num floatValue];
}

-(void)putFloat:(NSString*)key :(float)value {
    [self.bundle setObject:[NSNumber numberWithFloat:value] forKey:key];
}

-(double)getDouble:(NSString*)key {
    return [self getDouble:key :0];
}

-(double)getDouble:(NSString*)key :(double)def {
    NSNumber *num = [self getNumber:key :def];
    return [num doubleValue];
}

-(void)putDouble:(NSString*)key :(double)value {
    [self.bundle setObject:[NSNumber numberWithDouble:value] forKey:key];
}

+ (NSString *)className {
    return @"LuaBundle";
}

+ (NSMutableDictionary *)luaMethods {
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    
    //TODO:
    
    return dict;
}

@end
