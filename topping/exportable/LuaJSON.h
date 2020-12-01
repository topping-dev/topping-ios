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
+(LuaJSONObject*)CreateJSOFromString:(NSString*)str;
/**
 * Get object value at name.
 * @param name Name value.
 * @return LuaJSONObject
 */
-(LuaJSONObject *)GetJSONObject:(NSString *)name;
/**
 * Get array value at name.
 * @param name Name value.
 * @return LuaJSONArray
 */
-(LuaJSONArray *)GetJSONArray:(NSString *)name;
/**
 * Get string value at name.
 * @param name Name value.
 * @return String value.
 */
-(NSString*)GetString:(NSString*)name;
/**
 * Get int value at name.
 * @param name Name value.
 * @return Int value.
 */
-(int)GetInt:(NSString*)name;
/**
 * Get double value at name.
 * @param name Name value.
 * @return Double value.
 */
-(double)GetDouble:(NSString*)name;
/**
 * Get float value at name.
 * @param name Name value.
 * @return Float value.
 */
-(float)GetFloat:(NSString*)name;
/**
 * Get bool value at name.
 * @param name Name value.
 * @return Bool value.
 */
-(bool)GetBool:(NSString*)name;

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
-(int)Count;
/**
 * Get object value at name.
 * @param index index value
 * @return LuaJSONObject
 */
-(LuaJSONObject *)GetJSONObject:(int)index;
/**
 * Get array value at name.
 * @param index index value
 * @return LuaJSONArray
 */
-(LuaJSONArray *)GetJSONArray:(int)index;
/**
 * Get string value at name.
 * @param index index value
 * @return String value.
 */
-(NSString*)GetString:(int)index;
/**
 * Get int value at name.
 * @param index index value
 * @return Int value.
 */
-(int)GetInt:(int)index;
/**
 * Get double value at name.
 * @param index index value
 * @return Double value.
 */
-(double)GetDouble:(int)index;
/**
 * Get float value at name.
 * @param index index value
 * @return Float value.
 */
-(float)GetFloat:(int)index;
/**
 * Get bool value at name.
 * @param index index value
 * @return Bool value.
 */
-(bool)GetBool:(int)index;

@property(nonatomic, retain) NSArray *jsa;

@end

