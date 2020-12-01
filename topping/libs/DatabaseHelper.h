#import <Foundation/Foundation.h>

@interface DatabaseHelper : NSObject
{
    // Database variables
    NSString *databaseName;
    NSString *databasePath;
    NSString *path;
}

-(void) CreateDatabase;
-(void) CheckAndCreateDatabase;
-(void*) Open;
-(void*)Query:(void *)conn :(const char *)query;
-(void)Step:(void *)stmt;
-(void)Finalize:(void *)statement;
-(void)Close:(void *)conn;
-(BOOL)Read:(void *)statement;
-(int)GetInt:(void *)statement :(int)column;
-(long)GetInt64:(void *)statement :(int)column;
-(NSString *)GetString:(void *)statement :(int)column;
-(double)GetDouble:(void *)statement :(int)column;
-(NSData*)GetBlob:(void *)statement :(int)column;
-(NSNumber *)GetNumber:(void *)statement :(int)column;

@property (nonatomic, retain) NSString *databaseName;
@property (nonatomic, retain) NSString *databasePath;
@end
