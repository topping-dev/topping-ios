#import <Foundation/Foundation.h>
#import "LuaClass.h"
#import "LuaInterface.h"

@interface LuaBundle : NSObject <LuaClass>

- (instancetype)initWithBundle:(NSMutableDictionary*)bundle;
-(NSString*)getString:(NSString*)key;
-(NSString*)getString:(NSString*)key :(NSString*)def;
-(void)putString:(NSString*)key :(NSString*)value;
-(short)getByte:(NSString*)key;
-(short)getByte:(NSString*)key :(short)def;
-(void)putByte:(NSString*)key :(short)value;
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

@property (nonatomic, retain) NSMutableDictionary *bundle;

@end
