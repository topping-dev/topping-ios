#import "LuaBundle.h"
#import <ToppingIOSKotlinHelper/ToppingIOSKotlinHelper.h>
#import <Topping/Topping-Swift.h>
#import "Topping.h"

@implementation LuaBundle

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.bundle = [NSMutableDictionary dictionary];
    }
    return self;
}

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

-(char)getByte:(NSString *)key {
    return [self getByte:key :0];
}

-(char)getByte:(NSString *)key :(char)def {
    NSNumber *num = [self getNumber:key :def];
    return [num unsignedCharValue];
}

-(void)putByte:(NSString *)key :(char)value {
    [self.bundle setObject:[NSNumber numberWithUnsignedChar:value] forKey:key];
}

-(char)getChar:(NSString *)key {
    return [self getChar:key :0];
}

-(char)getChar:(NSString *)key :(char)def {
    NSNumber *num = [self getNumber:key :def];
    return [num charValue];
}

-(void)putChar:(NSString *)key :(char)value {
    [self.bundle setObject:[NSNumber numberWithChar:value] forKey:key];
}

-(short)getShort:(NSString *)key {
    return [self getShort:key :0];
}

-(short)getShort:(NSString *)key :(short)def {
    NSNumber *num = [self getNumber:key :def];
    return [num shortValue];
}

-(void)putShort:(NSString *)key :(short)value {
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
    
    InstanceMethod(getString:, NSString, @[ [NSString class] ], @"getString")
    InstanceMethod(getString::, NSString, @[ [NSString class]C [NSString class] ], @"getStringDef")
    InstanceMethodNoRet(putString::, @[ [NSString class]C [NSString class] ], @"putString")
    InstanceMethod(getByte:, LuaChar, @[ [NSString class] ], @"getByte")
    InstanceMethod(getByte::, LuaChar, @[ [NSString class]C [LuaChar class] ], @"getByteDef")
    InstanceMethodNoRet(putByte::, @[ [NSString class]C [LuaChar class] ], @"putByte")
    InstanceMethod(getChar:, LuaChar, @[ [NSString class] ], @"getChar")
    InstanceMethod(getChar::, LuaChar, @[ [NSString class]C [LuaChar class] ], @"getCharDef")
    InstanceMethodNoRet(putChar::, @[ [NSString class]C [LuaChar class] ], @"putChar")
    InstanceMethod(getShort:, LuaShort, @[ [NSString class] ], @"getShort")
    InstanceMethod(getShort::, LuaShort, @[ [NSString class]C [LuaShort class] ], @"getShortDef")
    InstanceMethodNoRet(putShort::, @[ [NSString class]C [LuaShort class] ], @"putShort")
    InstanceMethod(getInt:, LuaInt, @[ [NSString class] ], @"getInt")
    InstanceMethod(getInt::, LuaInt, @[ [NSString class]C [LuaInt class] ], @"getIntDef")
    InstanceMethodNoRet(putInt::, @[ [NSString class]C [LuaInt class] ], @"putInt")
    InstanceMethod(getLong:, LuaLong, @[ [NSString class] ], @"getLong")
    InstanceMethod(getLong::, LuaLong, @[ [NSString class]C [LuaLong class] ], @"getLongDef")
    InstanceMethodNoRet(putLong::, @[ [NSString class]C [LuaLong class] ], @"putLong")
    InstanceMethod(getFloat:, LuaFloat, @[ [NSString class] ], @"getFloat")
    InstanceMethod(getFloat::, LuaFloat, @[ [NSString class]C [LuaFloat class] ], @"getFloatDef")
    InstanceMethodNoRet(putFloat::, @[ [NSString class]C [LuaFloat class] ], @"putFloat")
    InstanceMethod(getDouble:, LuaDouble, @[ [NSString class] ], @"getDouble")
    InstanceMethod(getDouble::, LuaDouble, @[ [NSString class]C [LuaDouble class] ], @"getDoubleDef")
    InstanceMethodNoRet(putDouble::, @[ [NSString class]C [LuaDouble class] ], @"putDouble")
    
    return dict;
}

@end
