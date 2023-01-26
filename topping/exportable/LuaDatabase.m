#import "LuaDatabase.h"
#import "LuaFunction.h"

#import "LuaValues.h"

@implementation LuaDatabase

@synthesize db;

+(LuaDatabase*)create:(LuaContext *)context
{
	LuaDatabase *db = [[LuaDatabase alloc] init];
	return db;
}

-(void)checkAndCreateDatabase
{
	db = [[DatabaseHelper alloc] init];
}

-(LuaObjectStore*)open
{
	LuaObjectStore *conn = [[LuaObjectStore alloc] init];
	conn.obj = [db Open];
	return conn;
}

-(LuaObjectStore*)query:(LuaObjectStore*)conn :(NSString*)str
{
	LuaObjectStore *stmt = [[LuaObjectStore alloc] init];
	stmt.obj = [db Query:conn.obj :[str cStringUsingEncoding:NSUTF8StringEncoding]];
	return stmt;
}

-(LuaObjectStore*)insert:(LuaObjectStore*)conn :(NSString*)str
{
	LuaObjectStore *stmt = [[LuaObjectStore alloc] init];
	stmt.obj = [db Query:conn.obj :[str cStringUsingEncoding:NSUTF8StringEncoding]];
	return stmt;
}

-(void)finalize:(LuaObjectStore*)stmt
{
	[db Finalize:stmt.obj];
	stmt = nil;
}

-(void)close:(LuaObjectStore*)conn
{
	[db Close:conn.obj];
	conn = nil;
}

-(int)getInt:(LuaObjectStore*)stmt :(int)column
{
	return [db GetInt:stmt.obj :column];
}

-(float)getFloat:(LuaObjectStore*)stmt :(int)column
{
	return (float)[db GetDouble:stmt.obj :column];
}

-(NSString*)getString:(LuaObjectStore*)stmt :(int)column
{
	return [db GetString:stmt.obj :column];
}

-(double)getDouble:(LuaObjectStore*)stmt :(int)column
{
	return [db GetDouble:stmt.obj :column];
}

-(long)getLong:(LuaObjectStore*)stmt :(int)column
{
	return [db GetInt64:stmt.obj :column];
}

-(NSString*)GetId
{
	return @"LuaDatabase"; 
}

+ (NSString*)className
{
	return @"LuaDatabase";
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(create:)) 
										:@selector(create:) 
										:[LuaDatabase class]
										:[NSArray arrayWithObjects:[LuaContext class], nil] 
										:[LuaDatabase class]] 
			 forKey:@"create"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(checkAndCreateDatabase)) :@selector(checkAndCreateDatabase) :nil :MakeArray(nil)] forKey:@"checkAndCreateDatabase"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(open)) :@selector(open) :[LuaObjectStore class] :MakeArray(nil)] forKey:@"open"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(query::)) :@selector(query::) :[LuaObjectStore class] :MakeArray([LuaObjectStore class]C [NSString class]C nil)] forKey:@"query"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(insert::)) :@selector(insert::) :[LuaObjectStore class] :MakeArray([LuaObjectStore class]C [NSString class]C nil)] forKey:@"insert"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(finalize:)) :@selector(finalize:) :nil :MakeArray([LuaObjectStore class]C nil)] forKey:@"finalize"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(close:)) :@selector(close:) :nil :MakeArray([LuaObjectStore class]C nil)] forKey:@"close"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(getInt::)) :@selector(getInt::) :nil :MakeArray([LuaObjectStore class]C [LuaInt class]C nil)] forKey:@"GetInt"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(getFloat::)) :@selector(getFloat::) :nil :MakeArray([LuaObjectStore class]C [LuaInt class]C nil)] forKey:@"GetFloat"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(getString::)) :@selector(getString::) :nil :MakeArray([LuaObjectStore class]C [LuaInt class]C nil)] forKey:@"GetString"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(getDouble::)) :@selector(getDouble::) :nil :MakeArray([LuaObjectStore class]C [LuaInt class]C nil)] forKey:@"GetDouble"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(getLong::)) :@selector(getLong::) :nil :MakeArray([LuaObjectStore class]C [LuaInt class]C nil)] forKey:@"GetLong"];
	
	return dict;
}

@end
