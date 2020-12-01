#import "LuaDatabase.h"
#import "LuaFunction.h"

#import "LuaValues.h"

@implementation LuaDatabase

@synthesize db;

+(LuaDatabase*)Create:(LuaContext *)context
{
	LuaDatabase *db = [[LuaDatabase alloc] init];
	return db;
}

-(void)CheckAndCreateDatabase
{
	db = [[DatabaseHelper alloc] init];
}

-(LuaObjectStore*)Open
{
	LuaObjectStore *conn = [[LuaObjectStore alloc] init];
	conn.obj = [db Open];
	return conn;
}

-(LuaObjectStore*)Query:(LuaObjectStore*)conn :(NSString*)str
{
	LuaObjectStore *stmt = [[LuaObjectStore alloc] init];
	stmt.obj = [db Query:conn.obj :[str cStringUsingEncoding:NSUTF8StringEncoding]];
	return stmt;
}

-(LuaObjectStore*)Insert:(LuaObjectStore*)conn :(NSString*)str
{
	LuaObjectStore *stmt = [[LuaObjectStore alloc] init];
	stmt.obj = [db Query:conn.obj :[str cStringUsingEncoding:NSUTF8StringEncoding]];
	return stmt;
}

-(void)Finalize:(LuaObjectStore*)stmt
{
	[db Finalize:stmt.obj];
	stmt = nil;
}

-(void)Close:(LuaObjectStore*)conn
{
	[db Close:conn.obj];
	conn = nil;
}

-(int)GetInt:(LuaObjectStore*)stmt :(int)column
{
	return [db GetInt:stmt.obj :column];
}

-(float)GetFloat:(LuaObjectStore*)stmt :(int)column
{
	return (float)[db GetDouble:stmt.obj :column];
}

-(NSString*)GetString:(LuaObjectStore*)stmt :(int)column
{
	return [db GetString:stmt.obj :column];
}

-(double)GetDouble:(LuaObjectStore*)stmt :(int)column
{
	return [db GetDouble:stmt.obj :column];
}

-(long)GetLong:(LuaObjectStore*)stmt :(int)column
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
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(Create:)) 
										:@selector(Create:) 
										:[LuaDatabase class]
										:[NSArray arrayWithObjects:[LuaContext class], nil] 
										:[LuaDatabase class]] 
			 forKey:@"Create"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(CheckAndCreateDatabase)) :@selector(CheckAndCreateDatabase) :nil :MakeArray(nil)] forKey:@"CheckAndCreateDatabase"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(Open)) :@selector(Open) :[LuaObjectStore class] :MakeArray(nil)] forKey:@"Open"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(Query::)) :@selector(Query::) :[LuaObjectStore class] :MakeArray([LuaObjectStore class]C [NSString class]C nil)] forKey:@"Query"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(Insert::)) :@selector(Insert::) :[LuaObjectStore class] :MakeArray([LuaObjectStore class]C [NSString class]C nil)] forKey:@"Insert"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(Finalize:)) :@selector(Finalize:) :nil :MakeArray([LuaObjectStore class]C nil)] forKey:@"Finalize"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(Close:)) :@selector(Close:) :nil :MakeArray([LuaObjectStore class]C nil)] forKey:@"Close"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(GetInt::)) :@selector(GetInt::) :nil :MakeArray([LuaObjectStore class]C [LuaInt class]C nil)] forKey:@"GetInt"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(GetFloat::)) :@selector(GetFloat::) :nil :MakeArray([LuaObjectStore class]C [LuaInt class]C nil)] forKey:@"GetFloat"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(GetString::)) :@selector(GetString::) :nil :MakeArray([LuaObjectStore class]C [LuaInt class]C nil)] forKey:@"GetString"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(GetDouble::)) :@selector(GetDouble::) :nil :MakeArray([LuaObjectStore class]C [LuaInt class]C nil)] forKey:@"GetDouble"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(GetLong::)) :@selector(GetLong::) :nil :MakeArray([LuaObjectStore class]C [LuaInt class]C nil)] forKey:@"GetLong"];
	
	return dict;
}

@end
