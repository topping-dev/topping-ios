#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LuaInterface.h"
#import "LuaClass.h"

@class LuaJSONArray;

/**
 * Class that handles JSON Object.
 */
@interface LuaJSONObject : NSObject<LuaClass, LuaInterface>
{
	NSDictionary *jso;
}

/**
 * Creates LuaJSON from json string.
 */
+(LuaJSONObject*)createJSOFromString:(NSString*)str;
/**
 * Get object value at name.
 * @param name Name value.
 * @return LuaJSONObject
 */
-(LuaJSONObject *)getJSONObject:(NSString *)name;
/**
 * Get array value at name.
 * @param name Name value.
 * @return LuaJSONArray
 */
-(LuaJSONArray *)getJSONArray:(NSString *)name;
/**
 * Get string value at name.
 * @param name Name value.
 * @return String value.
 */
-(NSString*)getString:(NSString*)name;
/**
 * Get int value at name.
 * @param name Name value.
 * @return Int value.
 */
-(int)getInt:(NSString*)name;
/**
 * Get double value at name.
 * @param name Name value.
 * @return Double value.
 */
-(double)getDouble:(NSString*)name;
/**
 * Get float value at name.
 * @param name Name value.
 * @return Float value.
 */
-(float)getFloat:(NSString*)name;
/**
 * Get bool value at name.
 * @param name Name value.
 * @return Bool value.
 */
-(bool)getBool:(NSString*)name;

/**
 * Object store of json object.
 */
@property (nonatomic, retain) NSDictionary *jso;

@end

/**
 * Class that handles JSON Array.
 */
@interface LuaJSONArray : NSObject<LuaClass, LuaInterface>
{
	NSArray *jsa;
}

/**
 * Get array count.
 * @return count of array.
 */
-(int)count;
/**
 * Get object value at name.
 * @param index index value
 * @return LuaJSONObject
 */
-(LuaJSONObject *)getJSONObject:(int)index;
/**
 * Get array value at name.
 * @param index index value
 * @return LuaJSONArray
 */
-(LuaJSONArray *)getJSONArray:(int)index;
/**
 * Get string value at name.
 * @param index index value
 * @return String value.
 */
-(NSString*)getString:(int)index;
/**
 * Get int value at name.
 * @param index index value
 * @return Int value.
 */
-(int)getInt:(int)index;
/**
 * Get double value at name.
 * @param index index value
 * @return Double value.
 */
-(double)getDouble:(int)index;
/**
 * Get float value at name.
 * @param index index value
 * @return Float value.
 */
-(float)getFloat:(int)index;
/**
 * Get bool value at name.
 * @param index index value
 * @return Bool value.
 */
-(bool)getBool:(int)index;

@property(nonatomic, retain) NSArray *jsa;

@end

