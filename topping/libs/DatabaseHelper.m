#import "DatabaseHelper.h"
#import <sqlite3.h>


@implementation DatabaseHelper
@synthesize databaseName;
@synthesize databasePath;

-(id) init
{
    self = [super init];
    if(self)
    {
        databaseName = @"sqlite.db";
        databasePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Databases/"];
        path = [databasePath stringByAppendingPathComponent:databaseName];
    }
    return self;
}

-(void) CreateDatabase
{
    // Check if the SQL database has already been saved to the users phone, if not then copy it over
    
    // Create a FileManager object, we will use this to check the status
    // of the database and to copy it over if required
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:databasePath])
        [fileManager createDirectoryAtPath:databasePath attributes:nil];
    NSLog(databasePath);
#if !TARGET_IPHONE_SIMULATOR
    //databasePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:databaseName];
#endif
    
    // If not then proceed to copy the database from the application to the users filesystem
    
    // Get the path to the database in the application package
    NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:databaseName];
    
    NSError *error;
    [fileManager removeItemAtPath:path error:&error];
    NSLog(path);
    
    // Copy the database from the package to the users filesystem
    if([fileManager copyItemAtPath:databasePathFromApp toPath:path error:&error])
        NSLog(@"Success");
    else
        NSLog(@"Fail");
}

-(void) CheckAndCreateDatabase
{
    // Check if the SQL database has already been saved to the users phone, if not then copy it over
    BOOL success;
    
    // Create a FileManager object, we will use this to check the status
    // of the database and to copy it over if required
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:databasePath])
        [fileManager createDirectoryAtPath:databasePath attributes:nil];
#if !TARGET_IPHONE_SIMULATOR
    //databasePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:databaseName];
#endif
    
    // Check if the database has already been created in the users filesystem
    success = [fileManager fileExistsAtPath:path];
    // If the database already exists then return without doing anything
    if(success) return;
    
    // If not then proceed to copy the database from the application to the users filesystem
    
    // Get the path to the database in the application package
    NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:databaseName];
    
    // Copy the database from the package to the users filesystem
    [fileManager copyItemAtPath:databasePathFromApp toPath:path error:nil];
}

static void ACOS(sqlite3_context *context, int argc, sqlite3_value **argv)
{
    if(argc != 1)
    {
        sqlite3_result_null(context);
        return;
    }
    if (sqlite3_value_type(argv[0]) == SQLITE_NULL)
    {
        sqlite3_result_null(context);
        return;
    }
    
    double val = sqlite3_value_double(argv[0]);
    sqlite3_result_double(context, acosf(val));
}

static void COS(sqlite3_context *context, int argc, sqlite3_value **argv)
{
    if(argc != 1)
    {
        sqlite3_result_null(context);
        return;
    }
    if (sqlite3_value_type(argv[0]) == SQLITE_NULL)
    {
        sqlite3_result_null(context);
        return;
    }
    
    double val = sqlite3_value_double(argv[0]);
    sqlite3_result_double(context, cosf(val));
}

static void SIN(sqlite3_context *context, int argc, sqlite3_value **argv)
{
    if(argc != 1)
    {
        sqlite3_result_null(context);
        return;
    }
    if (sqlite3_value_type(argv[0]) == SQLITE_NULL)
    {
        sqlite3_result_null(context);
        return;
    }
    
    double val = sqlite3_value_double(argv[0]);
    sqlite3_result_double(context, sinf(val));
}

static void RADIANS(sqlite3_context *context, int argc, sqlite3_value **argv)
{
    if(argc != 1)
    {
        sqlite3_result_null(context);
        return;
    }
    if (sqlite3_value_type(argv[0]) == SQLITE_NULL)
    {
        sqlite3_result_null(context);
        return;
    }
    
    double val = sqlite3_value_double(argv[0]);
    sqlite3_result_double(context, ((val) / 180.0 * M_PI));
}

-(void *)Open
{
    sqlite3 *database;
    if(sqlite3_open([path UTF8String], &database) == SQLITE_OK)
    {
        sqlite3_create_function(database, "ACOS", 1, SQLITE_UTF8, NULL, &ACOS, NULL, NULL);
        sqlite3_create_function(database, "COS", 1, SQLITE_UTF8, NULL, &COS, NULL, NULL);
        sqlite3_create_function(database, "SIN", 1, SQLITE_UTF8, NULL, &SIN, NULL, NULL);
        sqlite3_create_function(database, "RADIANS", 1, SQLITE_UTF8, NULL, &RADIANS, NULL, NULL);
        
        return database;
    }

    return NULL;
}

-(void *)Query:(void *)conn :(const char *)query
{
/*    NSString *st;
    [[st cStringUsingEncoding:NSUTF8StringEncoding] ;]*/
    sqlite3_stmt *compiledStatement;
    if(sqlite3_prepare_v2(conn, query, -1, &compiledStatement, NULL) == SQLITE_OK)
        return compiledStatement;
    else
        NSLog(@"%@", [NSString stringWithCString:sqlite3_errmsg(conn) encoding:NSASCIIStringEncoding]);
    return NULL;
}

-(void)Step:(void *)stmt
{
    sqlite3_step(stmt);
}

-(void)Finalize:(void *)statement
{
    sqlite3_finalize(statement);
}

-(void)Close:(void *)conn
{
    sqlite3_close(conn);
}

-(BOOL)Read:(void *)statement
{
    if(sqlite3_step(statement) == SQLITE_ROW)
        return YES;
    
    return NO;
}

-(int)GetInt:(void *)statement :(int)column
{
    return sqlite3_column_int(statement, column);
}

-(long)GetInt64:(void *)statement :(int)column
{
    return sqlite3_column_int64(statement, column);
}

-(NSString *)GetString:(void *)statement :(int)column
{
    char * val = (char *)sqlite3_column_text(statement, column);
    if(val == NULL)
        return nil;
    return [NSString stringWithUTF8String:val];
}

-(double)GetDouble:(void *)statement :(int)column
{
    return sqlite3_column_double(statement, column);
}

-(NSData*)GetBlob:(void *)statement :(int)column
{
    return [[NSData alloc] initWithBytes:sqlite3_column_blob(statement, column) length:sqlite3_column_bytes(statement, column)];
}

-(NSNumber *)GetNumber:(void *)statement :(int)column
{
    switch(sqlite3_column_type(statement, column))
    {
        case SQLITE_INTEGER:
            return [NSNumber numberWithLong:[self GetInt64:statement :column]];
            break;
        case SQLITE_FLOAT:
            return [NSNumber numberWithDouble:[self GetDouble:statement :column]];
            break;
        default:
            return NULL;
            break;
    }
}

@end
