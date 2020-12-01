#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "DatabaseHelper.h"
#import "LuaInterface.h"
#import "LuaClass.h"
#import "LuaContext.h"
#import "LuaObjectStore.h"

/**
 * Lua database interface for SQLite operations.
 * This class is used to create database file and manupilate it from lua.
 */
@interface LuaDatabase : NSObject<LuaClass, LuaInterface>
{
	 DatabaseHelper *db;
}

/**
 * Database Object that is stored.
 */
@property(nonatomic, retain) DatabaseHelper *db;

/**
 * Creates LuaDatabase Object From Lua.
 */
+(LuaDatabase*)Create:(LuaContext*)context;
/**
 * Checks and Creates Database File on Storage.
 */
-(void)CheckAndCreateDatabase;
/**
 * Opens connection to database.
 * @return LuaObjectStore of connection.
 */
 -(LuaObjectStore*)Open;
/**
 * Send sql query to connection.
 * @param conn object store of connection
 * @param str sql statement string
 * @return LuaObjectStore of statement.
 */
-(LuaObjectStore*)Query:(LuaObjectStore*)conn :(NSString*)str;
/**
 * Send sql query to connection for insert,update operations.
 * @param conn object store of connection
 * @param str sql statement string
 * @return LuaObjectStore of statement.
 */
-(LuaObjectStore*)Insert:(LuaObjectStore*)conn :(NSString*)str;
/**
 * Finalize statement.
 * @param LuaObjectStore of statement.
 */
-(void)Finalize:(LuaObjectStore*)stmt;
/**
 * Finalize statement.
 * @param LuaObjectStore of connection.
 */
-(void)Close:(LuaObjectStore*)conn;
/**
 * Get Integer value at column
 * @param stmt statement object
 * @param column column
 * @return Integer value
 */	
-(int)GetInt:(LuaObjectStore*)stmt :(int)column;
/**
 * Get Float value at column
 * @param stmt statement object
 * @param column column
 * @return Float value
 */
-(float)GetFloat:(LuaObjectStore*)stmt :(int)column;
/**
 * Get String value at column
 * @param stmt statement object
 * @param column column
 * @return String value
 */
-(NSString*)GetString:(LuaObjectStore*)stmt :(int)column;
/**
 * Get Double value at column
 * @param stmt statement object
 * @param column column
 * @return Double value
 */
-(double)GetDouble:(LuaObjectStore*)stmt :(int)column;
/**
 * Get Long value at column
 * @param stmt statement object
 * @param column column
 * @return Long value
 */
-(long)GetLong:(LuaObjectStore*)stmt :(int)column;


@end
