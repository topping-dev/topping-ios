#import "LuaJSON.h"
#import "LuaFunction.h"
#import "LuaValues.h"

@implementation LuaJSONObject

@synthesize jso;

+(LuaJSONObject*)createJSOFromString:(NSString*)str
{
	LuaJSONObject *jso = [[LuaJSONObject alloc] init];
    jso.jso = [NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
	return jso;
}

-(LuaJSONObject *)getJSONObject:(NSString *)name
{
	LuaJSONObject *jso = [[LuaJSONObject alloc] init];
	jso.jso = [self.jso objectForKey:name];
	return jso;
}

-(LuaJSONArray *)getJSONArray:(NSString *)name
{
	LuaJSONArray *jsa = [[LuaJSONArray alloc] init];
	jsa.jsa = [self.jso objectForKey:name];
	return jsa;
}

-(NSString*)getString:(NSString*)name
{
	return [self.jso objectForKey:name];
}

-(int)getInt:(NSString*)name
{
	return [[self.jso objectForKey:name] intValue];
}

-(double)getDouble:(NSString*)name
{
	return [[self.jso objectForKey:name] doubleValue];
}

-(float)getFloat:(NSString*)name
{
	return [[self.jso objectForKey:name] floatValue];
}

-(bool)getBool:(NSString*)name;
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
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(createJSOFromString:)) 
										:@selector(createJSOFromString:) 
										:[LuaJSONObject class]
										:[NSArray arrayWithObjects:[NSString class], nil] 
										:[LuaJSONObject class]] 
			 forKey:@"createJSOFromString"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(getJSONObject:)) :@selector(getJSONObject:) :[LuaJSONObject class]	:MakeArray([NSString class]C nil)] forKey:@"getJSONObject"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(getJSONArray:)) :@selector(getJSONArray:) :[LuaJSONArray class]	:MakeArray([NSString class]C nil)] forKey:@"getJSONArray"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(getString:)) :@selector(getString:) :[NSString class]	:MakeArray([NSString class]C nil)] forKey:@"getString"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(getInt:)) :@selector(getInt:) :[LuaInt class]	:MakeArray([NSString class]C nil)] forKey:@"getInt"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(getDouble:)) :@selector(getDouble:) :[LuaDouble class]	:MakeArray([NSString class]C nil)] forKey:@"getDouble"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(getFloat:)) :@selector(getFloat:) :[LuaFloat class]	:MakeArray([NSString class]C nil)] forKey:@"getFloat"];
	
	return dict;
}

@end

@implementation LuaJSONArray

@synthesize jsa;

-(int)count
{
	return [self.jsa count];
}

-(LuaJSONObject *)getJSONObject:(int)index
{
	LuaJSONObject *jso = [[LuaJSONObject alloc] init];
	jso.jso = [self.jsa objectAtIndex:index];
	return jso;
}

-(LuaJSONArray *)getJSONArray:(int)index
{
	LuaJSONArray *jsa = [[LuaJSONArray alloc] init];
	jsa.jsa = [self.jsa objectAtIndex:index];
	return jsa;
}

-(NSString*)getString:(int)index
{
	return [self.jsa objectAtIndex:index];
}

-(int)getInt:(int)index
{
	return [[self.jsa objectAtIndex:index] intValue];
}

-(double)getDouble:(int)index
{
	return [[self.jsa objectAtIndex:index] doubleValue];
}

-(float)getFloat:(int)index
{
	return [[self.jsa objectAtIndex:index] floatValue];
}

-(bool)getBool:(int)index
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

	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(count)) :@selector(count) :[LuaInt class]	:MakeArray(nil)] forKey:@"count"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(getJSONObject:)) :@selector(getJSONObject:) :[LuaJSONObject class]	:MakeArray([LuaInt class]C nil)] forKey:@"getJSONObject"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(getJSONArray:)) :@selector(getJSONArray:) :[LuaJSONArray class]	:MakeArray([LuaInt class]C nil)] forKey:@"getJSONArray"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(getString:)) :@selector(getString:) :[NSString class]	:MakeArray([LuaInt class]C nil)] forKey:@"getString"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(getInt:)) :@selector(getInt:) :[LuaInt class]	:MakeArray([LuaInt class]C nil)] forKey:@"getInt"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(getDouble:)) :@selector(getDouble:) :[LuaDouble class]	:MakeArray([LuaInt class]C nil)] forKey:@"getDouble"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(getFloat:)) :@selector(getFloat:) :[LuaFloat class]	:MakeArray([LuaInt class]C nil)] forKey:@"getFloat"];
	
	return dict;
}

@end

