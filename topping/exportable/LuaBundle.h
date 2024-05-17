#import <Foundation/Foundation.h>
#import "LuaClass.h"
#import "LuaInterface.h"
#import <ToppingIOSKotlinHelper/ToppingIOSKotlinHelper.h>

@interface BundleWrapper : NSObject

@property (nonatomic, retain) id obj;

@end

@interface LuaBundle : NSObject <LuaClass>

- (instancetype)initWithBundle:(NSMutableDictionary*)bundle;
-(BOOL)getBoolean:(NSString*)key;
-(BOOL)getBoolean:(NSString*)key :(BOOL)def;
-(void)putBoolean:(NSString*)key :(BOOL)value;
-(NSString*)getString:(NSString*)key;
-(NSString*)getString:(NSString*)key :(NSString*)def;
-(void)putString:(NSString*)key :(NSString*)value;
-(char)getByte:(NSString*)key;
-(char)getByte:(NSString*)key :(char)def;
-(void)putByte:(NSString*)key :(char)value;
-(char)getChar:(NSString*)key;
-(char)getChar:(NSString*)key :(char)def;
-(void)putChar:(NSString*)key :(char)value;
-(short)getShort:(NSString*)key;
-(short)getShort:(NSString*)key :(short)def;
-(void)putShort:(NSString*)key :(short)value;
-(int)getInt:(NSString*)key;
-(int)getInt:(NSString*)key :(int)def;
-(void)putInt:(NSString*)key :(int)value;
-(long)getLong:(NSString*)key;
-(long)getLong:(NSString*)key :(long)def;
-(void)putLong:(NSString*)key :(long)value;
-(float)getFloat:(NSString*)key;
-(float)getFloat:(NSString*)key :(float)def;
-(void)putFloat:(NSString*)key :(float)value;
-(double)getDouble:(NSString*)key;
-(double)getDouble:(NSString*)key :(double)def;
-(void)putDouble:(NSString*)key :(double)value;
-(TIOSKHKotlinShortArray*)getShortArray:(NSString*)key;
-(TIOSKHKotlinShortArray*)getShortArray:(NSString*)key :(TIOSKHKotlinShortArray*)def;
-(void)putShortArray:(NSString*)key :(TIOSKHKotlinShortArray*)value;
-(TIOSKHKotlinBooleanArray*)getBooleanArray:(NSString*)key;
-(TIOSKHKotlinBooleanArray*)getBooleanArray:(NSString*)key :(TIOSKHKotlinBooleanArray*)def;
-(void)putBooleanArray:(NSString*)key :(TIOSKHKotlinBooleanArray*)value;
-(TIOSKHKotlinByteArray*)getByteArray:(NSString*)key;
-(TIOSKHKotlinByteArray*)getByteArray:(NSString*)key :(TIOSKHKotlinByteArray*)def;
-(void)putByteArray:(NSString*)key :(TIOSKHKotlinByteArray*)value;
-(TIOSKHKotlinCharArray*)getCharArray:(NSString*)key;
-(TIOSKHKotlinCharArray*)getCharArray:(NSString*)key :(TIOSKHKotlinCharArray*)def;
-(void)putCharArray:(NSString*)key :(TIOSKHKotlinCharArray*)value;
-(TIOSKHKotlinIntArray*)getIntArray:(NSString*)key;
-(TIOSKHKotlinIntArray*)getIntArray:(NSString*)key :(TIOSKHKotlinIntArray*)def;
-(void)putIntArray:(NSString*)key :(TIOSKHKotlinIntArray*)value;
-(TIOSKHKotlinLongArray*)getLongArray:(NSString*)key;
-(TIOSKHKotlinLongArray*)getLongArray:(NSString*)key :(TIOSKHKotlinLongArray*)def;
-(void)putLongArray:(NSString*)key :(TIOSKHKotlinLongArray*)value;
-(TIOSKHKotlinFloatArray*)getFloatArray:(NSString*)key;
-(TIOSKHKotlinFloatArray*)getFloatArray:(NSString*)key :(TIOSKHKotlinFloatArray*)def;
-(void)putFloatArray:(NSString*)key :(TIOSKHKotlinFloatArray*)value;
-(TIOSKHKotlinDoubleArray*)getDoubleArray:(NSString*)key;
-(TIOSKHKotlinDoubleArray*)getDoubleArray:(NSString*)key :(TIOSKHKotlinDoubleArray*)def;
-(void)putDoubleArray:(NSString*)key :(TIOSKHKotlinDoubleArray*)value;
-(TIOSKHKotlinArray<NSString*>*)getStringArray:(NSString*)key;
-(TIOSKHKotlinArray<NSString*>*)getStringArray:(NSString*)key :(TIOSKHKotlinArray<NSString*>*)def;
-(void)putStringArray:(NSString*)key :(TIOSKHKotlinArray<NSString*>*)value;
-(TIOSKHKotlinArray*)getArray:(NSString*)key;
-(TIOSKHKotlinArray*)getArray:(NSString*)key :(TIOSKHKotlinArray*)def;
-(void)putArray:(NSString*)key :(TIOSKHKotlinArray*)value;
-(id)getObject:(NSString*)key;
-(id)getObject:(NSString*)key :(id)def;
-(void)putObject:(NSString*)key :(id)value;
-(LuaBundle*)getBundle:(NSString*)key;
-(LuaBundle*)getBundle:(NSString*)key :(LuaBundle*)def;
-(void)putBundle:(NSString*)key :(LuaBundle*)value;

@property (nonatomic, retain) NSMutableDictionary *bundle;

@end
