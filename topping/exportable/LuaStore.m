#import "LuaStore.h"
#import "lua.h"
#import "ToppingEngine.h"
#import "LuaFunction.h"
#import "LuaValues.h"
#import "LuaGlobalFunction.h"

@implementation LuaStore

static int LuaStore_gc(lua_State *L);
static int LuaStore_gc(lua_State *L)
{
	void **ptrHold = (void **)(lua_touserdata(L, 1));
	if(ptrHold == NULL)
		return 0;
    NSObject * obj = (__bridge NSObject *)(*ptrHold);
	if(obj == NULL)
		return 0;
	lua_getfield(L, LUA_REGISTRYINDEX, "DO NOT TRASH");
	if(lua_istable(L,-1) )
	{
		NSString *className = NSStringFromClass([obj class]);
		lua_getfield(L,-1, [className cStringUsingEncoding:NSASCIIStringEncoding]);
		if(lua_isnil(L,-1))
		{
			/*delete obj;
			 obj = NULL;*/
		}
	}
	lua_pop(L,3);
	return 0;
}

static int LuaStore_index(lua_State *L);
static int LuaStore_index(lua_State *L)
{
	void **ptrHold = (void **)(lua_touserdata(L, 1));
	const char* keyC = lua_tostring(L, 2);
    NSObject *val = [LuaStore get:[NSString stringWithCString:keyC encoding:NSUTF8StringEncoding]];
	if([val isKindOfClass:[NSNumber class]])
	{
		NSNumber* num = (NSNumber*)val;
		if(!strcmp([num objCType], @encode(BOOL)))
			[sToppingEngine pushBool:[num boolValue]];
		else if(!strcmp([num objCType], @encode(unsigned char)))
			[sToppingEngine pushInt:[num unsignedCharValue]];
		else if(!strcmp([num objCType], @encode(char)))
		{
			char c = [num charValue];
			char *cP = &c;
			[sToppingEngine pushString:[NSString  stringWithCString:cP encoding:NSUTF8StringEncoding]];
		}		
		else if(!strcmp([num objCType], @encode(int)))
			[sToppingEngine pushInt:[num intValue]];
		else if(!strcmp([num objCType], @encode(unsigned int)))
			[sToppingEngine pushUInt:[num unsignedIntValue]];
		else if(!strcmp([num objCType], @encode(long)))
			[sToppingEngine pushLong:[num longValue]];
		else if(!strcmp([num objCType], @encode(unsigned long)))
			[sToppingEngine pushLong:[num unsignedLongValue]];
		else if(!strcmp([num objCType], @encode(long long)))
			[sToppingEngine pushDouble:[num longLongValue]];
		else if(!strcmp([num objCType], @encode(unsigned long long)))
			[sToppingEngine pushDouble:[num unsignedLongLongValue]];	 
		else if(!strcmp([num objCType], @encode(float)))
			[sToppingEngine pushFloat:[num floatValue]];
		else if(!strcmp([num objCType], @encode(double)))
			[sToppingEngine pushDouble:[num doubleValue]];
	}
	else if([val isKindOfClass:[NSString class]])
		[sToppingEngine pushString:(NSString*)val];
	return 1;
}

static int LuaStore_newindex(lua_State *L);
static int LuaStore_newindex(lua_State *L)
{
	void **ptrHold = (void **)(lua_touserdata(L, 1));
	if(ptrHold == NULL)
		return 0;
	const char* keyC = lua_tostring(L, 2);
	NSObject *val = nil;
	if(lua_isstring(L, 3))
	{
		val = [NSString stringWithCString:lua_tostring(L, 3) encoding:NSUTF8StringEncoding];
		[LuaStore setString:[NSString stringWithCString:keyC encoding:NSUTF8StringEncoding] :(NSString*)val];
	}
	else if(lua_isnumber(L, 3))
	{
		val = [NSNumber numberWithDouble:lua_tonumber(L, 3)];
		[LuaStore setNumber:[NSString stringWithCString:keyC encoding:NSUTF8StringEncoding] :[((NSNumber*)val) doubleValue]];
	}
	else 
		return 0;

	return 1;
}

static int LuaStore_tostring(lua_State *L);
static int LuaStore_tostring(lua_State *L)
{
	void **ptrHold = (void **)(lua_touserdata(L, 1));
	if(ptrHold == NULL)
		return 0;
    NSObject *obj = (__bridge NSObject *)(*ptrHold);
	NSString *className = NSStringFromClass([obj class]);
	lua_pushstring(L, [className cStringUsingEncoding:NSASCIIStringEncoding]);
	return 1;
}

+(void) setString:(NSString *)key :(NSString *)value
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:value forKey:key];
}

+(void) setNumber:(NSString *)key :(double)value
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:[NSNumber numberWithDouble:value] forKey:key];
}

+(NSObject *) get:(NSString *)key
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	return [defaults objectForKey:key];
}

+(NSString *) getString:(NSString *)key
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	return [defaults objectForKey:key];
}

+(double) getNumber:(NSString *)key
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	return [((NSNumber*)[defaults objectForKey:key]) doubleValue];
}

-(NSString*)GetId
{
	return @"LuaStore"; 
}

+ (NSString*)className
{
	return @"LuaStore";
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(setString::)) 
										:@selector(setString::) 
										:nil
										:MakeArray([NSString class]C [NSString class]C nil)
										:[LuaStore class]] 
			 forKey:@"setString"];
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(setNumber::)) 
										:@selector(setNumber::) 
										:nil
										:MakeArray([NSString class]C [LuaDouble class]C nil)
										:[LuaStore class]] 
			 forKey:@"setNumber"];
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(getString:)) 
										:@selector(getString:) 
										:[NSString class]
										:MakeArray([NSString class]C nil)
										:[LuaStore class]] 
			 forKey:@"getString"];
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(getNumber:)) 
										:@selector(getNumber:) 
										:[LuaDouble class]
										:MakeArray([NSString class]C nil)
										:[LuaStore class]] 
			 forKey:@"getNumber"];	
	return dict;
}

+(NSMutableDictionary*)luaGlobals
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	LuaGlobalFunction *lgf = [[LuaGlobalFunction alloc] init];
	lgf.name = @"STORE";
	lgf.__index = &LuaStore_index;
	lgf.__newindex = &LuaStore_newindex;
	lgf.__gc = &LuaStore_gc;
	lgf.__tostring = &LuaStore_tostring;
	[dict setObject:lgf forKey:@"STORE"];
	return dict;
}

@end
