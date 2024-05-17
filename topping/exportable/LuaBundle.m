#import "LuaBundle.h"
#import <ToppingIOSKotlinHelper/ToppingIOSKotlinHelper.h>
#import <Topping/Topping-Swift.h>
#import "Topping.h"

@implementation BundleWrapper

@end

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

-(BOOL)getBoolean:(NSString *)key {
    return [self getBoolean:key :false];
}

-(BOOL)getBoolean:(NSString *)key :(BOOL)def {
    NSNumber *num = [self getNumber:key :def];
    return [num boolValue];
}

-(void)putBoolean:(NSString *)key :(BOOL)value {
    [self.bundle setObject:[NSNumber numberWithBool:value] forKey:key];
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

-(TIOSKHKotlinShortArray *)getShortArray:(NSString *)key {
    return [self.bundle objectForKey:key];
}

-(TIOSKHKotlinShortArray *)getShortArray:(NSString *)key :(TIOSKHKotlinShortArray *)def {
    TIOSKHKotlinShortArray *arr = [self.bundle objectForKey:key];
    if(arr == nil)
        return def;
    return arr;
}

- (void)putShortArray:(NSString *)key :(TIOSKHKotlinShortArray *)value {
    [self.bundle setObject:value forKey:key];
}

-(TIOSKHKotlinBooleanArray *)getBooleanArray:(NSString *)key {
    return [self.bundle objectForKey:key];
}

-(TIOSKHKotlinBooleanArray *)getBooleanArray:(NSString *)key :(TIOSKHKotlinBooleanArray *)def {
    TIOSKHKotlinBooleanArray *arr = [self.bundle objectForKey:key];
    if(arr == nil)
        return def;
    return arr;
}

-(void)putBooleanArray:(NSString *)key :(TIOSKHKotlinBooleanArray *)value {
    [self.bundle setObject:value forKey:key];
}

-(TIOSKHKotlinByteArray *)getByteArray:(NSString *)key {
    return [self.bundle objectForKey:key];
}

- (TIOSKHKotlinByteArray *)getByteArray:(NSString *)key :(TIOSKHKotlinByteArray *)def {
    TIOSKHKotlinByteArray *arr = [self.bundle objectForKey:key];
    if(arr == nil)
        return def;
    return arr;
}

- (void)putByteArray:(NSString *)key :(TIOSKHKotlinByteArray *)value {
    [self.bundle setObject:value forKey:key];
}

-(TIOSKHKotlinCharArray *)getCharArray:(NSString *)key {
    return [self.bundle objectForKey:key];
}

-(TIOSKHKotlinCharArray *)getCharArray:(NSString *)key :(TIOSKHKotlinCharArray *)def {
    TIOSKHKotlinCharArray *arr = [self.bundle objectForKey:key];
    if(arr == nil)
        return def;
    return arr;
}

-(void)putCharArray:(NSString *)key :(TIOSKHKotlinCharArray *)value {
    [self.bundle setObject:value forKey:key];
}

-(TIOSKHKotlinIntArray*)getIntArray:(NSString*)key {
    return [self.bundle objectForKey:key];
}

-(TIOSKHKotlinIntArray*)getIntArray:(NSString*)key :(TIOSKHKotlinIntArray*)def {
    TIOSKHKotlinIntArray *arr = [self.bundle objectForKey:key];
    if(arr == nil)
        return def;
    return arr;
}

-(void)putIntArray:(NSString*)key :(TIOSKHKotlinIntArray*)value {
    [self.bundle setObject:value forKey:key];
}

-(TIOSKHKotlinLongArray*)getLongArray:(NSString*)key {
    return [self.bundle objectForKey:key];
}

-(TIOSKHKotlinLongArray*)getLongArray:(NSString*)key :(TIOSKHKotlinLongArray*)def {
    TIOSKHKotlinLongArray *arr = [self.bundle objectForKey:key];
    if(arr == nil)
        return def;
    return arr;
}

-(void)putLongArray:(NSString*)key :(TIOSKHKotlinFloatArray*)value {
    [self.bundle setObject:value forKey:key];
}

-(TIOSKHKotlinFloatArray*)getFloatArray:(NSString*)key {
    return [self.bundle objectForKey:key];
}

-(TIOSKHKotlinFloatArray*)getFloatArray:(NSString*)key :(TIOSKHKotlinFloatArray*)def {
    TIOSKHKotlinFloatArray *arr = [self.bundle objectForKey:key];
    if(arr == nil)
        return def;
    return arr;
}

-(void)putFloatArray:(NSString*)key :(TIOSKHKotlinFloatArray*)value {
    [self.bundle setObject:value forKey:key];
}

-(TIOSKHKotlinDoubleArray *)getDoubleArray:(NSString *)key {
    return [self.bundle objectForKey:key];
}

-(TIOSKHKotlinDoubleArray *)getDoubleArray:(NSString *)key :(TIOSKHKotlinDoubleArray *)def {
    TIOSKHKotlinDoubleArray *arr = [self.bundle objectForKey:key];
    if(arr == nil)
        return def;
    return arr;
}

-(void)putDoubleArray:(NSString *)key :(TIOSKHKotlinDoubleArray *)value {
    [self.bundle setObject:value forKey:key];
}

-(TIOSKHKotlinArray<NSString*>*)getStringArray:(NSString*)key {
    return [self.bundle objectForKey:key];
}

-(TIOSKHKotlinArray<NSString*>*)getStringArray:(NSString*)key :(TIOSKHKotlinArray<NSString*>*)def {
    TIOSKHKotlinArray *arr = [self.bundle objectForKey:key];
    if(arr == nil)
        return def;
    return arr;
}

-(void)putStringArray:(NSString*)key :(TIOSKHKotlinArray<NSString*>*)value {
    [self.bundle setObject:value forKey:key];
}

-(TIOSKHKotlinArray*)getArray:(TIOSKHKotlinArray*)key {
    return [self.bundle objectForKey:key];
}

-(TIOSKHKotlinArray*)getArray:(NSString*)key :(TIOSKHKotlinArray*)def {
    TIOSKHKotlinArray *arr = [self.bundle objectForKey:key];
    if(arr == nil)
        return def;
    return arr;
}

-(void)putArray:(NSString*)key :(TIOSKHKotlinArray*)value {
    [self.bundle setObject:value forKey:key];
}

-(id)getObject:(NSString*)key {
    BundleWrapper *objWrapper = [self.bundle objectForKey:key];
    return objWrapper.obj;
}

-(id)getObject:(NSString*)key :(id)def {
    BundleWrapper *objWrapper = [self.bundle objectForKey:key];
    if(objWrapper == nil)
        return def;
    return objWrapper.obj;
}

-(void)putObject:(NSString*)key :(id)value {
    BundleWrapper *wrapper = [[BundleWrapper alloc] init];
    wrapper.obj = value;
    [self.bundle setObject:wrapper forKey:key];
}

-(LuaBundle *)getBundle:(NSString *)key {
    return [self getObject:key];
}

-(LuaBundle *)getBundle:(NSString *)key :(LuaBundle *)def {
    return [self getObject:key :def];
}

-(void)putBundle:(NSString *)key :(LuaBundle *)value {
    [self putObject:key :value];
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
