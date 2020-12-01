#import "LuaJSON.h"
#import "LuaFunction.h"
#import "LuaValues.h"

@implementation LuaJSONObject

@synthesize jso;

+(LuaJSONObject*)CreateJSOFromString:(NSString*)str
{
	LuaJSONObject *jso = [[LuaJSONObject alloc] init];
    jso.jso = [NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
	return jso;
}

-(LuaJSONObject *)GetJSONObject:(NSString *)name
{
	LuaJSONObject *jso = [[LuaJSONObject alloc] init];
	jso.jso = [self.jso objectForKey:name];
	return jso;
}

-(LuaJSONArray *)GetJSONArray:(NSString *)name
{
	LuaJSONArray *jsa = [[LuaJSONArray alloc] init];
	jsa.jsa = [self.jso objectForKey:name];
	return jsa;
}

-(NSString*)GetString:(NSString*)name
{
	return [self.jso objectForKey:name];
}

-(int)GetInt:(NSString*)name
{
	return [[self.jso objectForKey:name] intValue];
}

-(double)GetDouble:(NSString*)name
{
	return [[self.jso objectForKey:name] doubleValue];
}

-(float)GetFloat:(NSString*)name
{
	return [[self.jso objectForKey:name] floatValue];
}

-(bool)GetBool:(NSString*)name;
{
	return [[self.jso objectForKey:name] boolValue];
}

-(NSString*)GetId
{
	return @"LuaJSONObject"; 
}

+ (NSString*)className
{
	return @"LuaJSONObject";
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(CreateJSOFromString:)) 
										:@selector(CreateJSOFromString:) 
										:[LuaJSONObject class]
										:[NSArray arrayWithObjects:[NSString class], nil] 
										:[LuaJSONObject class]] 
			 forKey:@"CreateJSOFromString"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(GetJSONObject:)) :@selector(GetJSONObject:) :[LuaJSONObject class]	:MakeArray([NSString class]C nil)] forKey:@"GetJSONObject"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(GetJSONArray:)) :@selector(GetJSONArray:) :[LuaJSONArray class]	:MakeArray([NSString class]C nil)] forKey:@"GetJSONArray"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(GetString:)) :@selector(GetString:) :[NSString class]	:MakeArray([NSString class]C nil)] forKey:@"GetString"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(GetInt:)) :@selector(GetInt:) :[LuaInt class]	:MakeArray([NSString class]C nil)] forKey:@"GetInt"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(GetDouble:)) :@selector(GetDouble:) :[LuaDouble class]	:MakeArray([NSString class]C nil)] forKey:@"GetDouble"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(GetFloat:)) :@selector(GetFloat:) :[LuaFloat class]	:MakeArray([NSString class]C nil)] forKey:@"GetFloat"];
	
	return dict;
}

@end

@implementation LuaJSONArray

@synthesize jsa;

-(int)Count
{
	return [self.jsa count];
}

-(LuaJSONObject *)GetJSONObject:(int)index
{
	LuaJSONObject *jso = [[LuaJSONObject alloc] init];
	jso.jso = [self.jsa objectAtIndex:index];
	return jso;
}

-(LuaJSONArray *)GetJSONArray:(int)index
{
	LuaJSONArray *jsa = [[LuaJSONArray alloc] init];
	jsa.jsa = [self.jsa objectAtIndex:index];
	return jsa;
}

-(NSString*)GetString:(int)index
{
	return [self.jsa objectAtIndex:index];
}

-(int)GetInt:(int)index
{
	return [[self.jsa objectAtIndex:index] intValue];
}

-(double)GetDouble:(int)index
{
	return [[self.jsa objectAtIndex:index] doubleValue];
}

-(float)GetFloat:(int)index
{
	return [[self.jsa objectAtIndex:index] floatValue];
}

-(bool)GetBool:(int)index
{
	return [[self.jsa objectAtIndex:index] boolValue];
}

-(NSString*)GetId
{
	return @"LuaJSONArray"; 
}

+ (NSString*)className
{
	return @"LuaJSONArray";
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];

	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(Count)) :@selector(Count) :[LuaInt class]	:MakeArray(nil)] forKey:@"Count"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(GetJSONObject:)) :@selector(GetJSONObject:) :[LuaJSONObject class]	:MakeArray([LuaInt class]C nil)] forKey:@"GetJSONObject"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(GetJSONArray:)) :@selector(GetJSONArray:) :[LuaJSONArray class]	:MakeArray([LuaInt class]C nil)] forKey:@"GetJSONArray"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(GetString:)) :@selector(GetString:) :[NSString class]	:MakeArray([LuaInt class]C nil)] forKey:@"GetString"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(GetInt:)) :@selector(GetInt:) :[LuaInt class]	:MakeArray([LuaInt class]C nil)] forKey:@"GetInt"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(GetDouble:)) :@selector(GetDouble:) :[LuaDouble class]	:MakeArray([LuaInt class]C nil)] forKey:@"GetDouble"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(GetFloat:)) :@selector(GetFloat:) :[LuaFloat class]	:MakeArray([LuaInt class]C nil)] forKey:@"GetFloat"];
	
	return dict;
}

@end

