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
+(LuaDatabase*)create:(LuaContext*)context;
/**
 * Checks and Creates Database File on Storage.
 */
-(void)checkAndCreateDatabase;
/**
 * Opens connection to database.
 * @return LuaObjectStore of connection.
 */
 -(LuaObjectStore*)open;
/**
 * Send sql query to connection.
 * @param conn object store of connection
 * @param str sql statement string
 * @return LuaObjectStore of statement.
 */
-(LuaObjectStore*)query:(LuaObjectStore*)conn :(NSString*)str;
/**
 * Send sql query to connection for insert,update operations.
 * @param conn object store of connection
 * @param str sql statement string
 * @return LuaObjectStore of statement.
 */
-(LuaObjectStore*)insert:(LuaObjectStore*)conn :(NSString*)str;
/**
 * Finalize statement.
 * @param LuaObjectStore of statement.
 */
-(void)finalize:(LuaObjectStore*)stmt;
/**
 * Finalize statement.
 * @param LuaObjectStore of connection.
 */
-(void)close:(LuaObjectStore*)conn;
/**
 * Get Integer value at column
 * @param stmt statement object
 * @param column column
 * @return Integer value
 */	
-(int)getInt:(LuaObjectStore*)stmt :(int)column;
/**
 * Get Float value at column
 * @param stmt statement object
 * @param column column
 * @return Float value
 */
-(float)getFloat:(LuaObjectStore*)stmt :(int)column;
/**
 * Get String value at column
 * @param stmt statement object
 * @param column column
 * @return String value
 */
-(NSString*)getString:(LuaObjectStore*)stmt :(int)column;
/**
 * Get Double value at column
 * @param stmt statement object
 * @param column column
 * @return Double value
 */
-(double)getDouble:(LuaObjectStore*)stmt :(int)column;
/**
 * Get Long value at column
 * @param stmt statement object
 * @param column column
 * @return Long value
 */
-(long)getLong:(LuaObjectStore*)stmt :(int)column;


@end
