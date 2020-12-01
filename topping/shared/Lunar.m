#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "Lunar.h"
#import "ToppingEngine.h"
#import "LuaFunction.h"
#import "LuaBool.h"
#import "LuaChar.h"
#import "LuaShort.h"
#import "LuaInt.h"
#import "LuaLong.h"
#import "LuaFloat.h"
#import "LuaDouble.h"
#import "LuaNativeObject.h"
@import ObjectiveC.runtime;
#include "lstate.h"
#import "Defines.h"
#import "LuaGlobalFunction.h"
#import "LuaTranslator.h"
#import "NSStack.h"

static NSObject *check(lua_State *L, int narg);
static int sThunk(lua_State *L);
static int thunk(lua_State *L);
static int gc_T(lua_State *L);
static int tostring_T (lua_State *L);

@implementation Lunar
static NSMutableDictionary *dictFunctionNames = NULL;

+(void) Register:(lua_State*)L :(Class) T
{
	if(dictFunctionNames == NULL)
	{
		dictFunctionNames = [NSMutableDictionary new];
		//[dictFunctionNames init];
	}
//	NSString *className = NSStringFromClass(T);
	NSString *className = [T performSelector:NSSelectorFromString(@"className")];
	lua_newtable(L);
	int methods = lua_gettop(L);
	
	luaL_newmetatable(L, [className cStringUsingEncoding:NSASCIIStringEncoding]);
	int metatable = lua_gettop(L);
	
	luaL_newmetatable(L,"DO NOT TRASH");
	lua_pop(L,1);
	
	// store method table in globals so that
	// scripts can add functions written in Lua.
	lua_pushvalue(L, methods);
	lua_setfield(L, LUA_GLOBALSINDEX, [className cStringUsingEncoding:NSASCIIStringEncoding]);
	
	// hide metatable from Lua getmetatable()
	lua_pushvalue(L, methods);
	lua_setfield(L, metatable, "__metatable");
	
	lua_pushvalue(L, methods);
	lua_setfield(L, metatable, "__index");
	
	lua_pushcfunction(L, tostring_T);
	lua_setfield(L, metatable, "__tostring");
	
	lua_pushcfunction(L, gc_T);
	lua_setfield(L, metatable, "__gc");
	
	lua_newtable(L);                // mt for method table
	lua_setmetatable(L, methods);
	
	NSMutableArray *arr = nil;
    NSStack *clsStack = [NSStack new];
    Class clsToLoop = T;
    while(clsToLoop != nil)
    {
        if([clsToLoop respondsToSelector:NSSelectorFromString(@"luaMethods")])
        {
            [clsStack push:clsToLoop];
        }
        clsToLoop = [clsToLoop superclass];
    }
    
    clsToLoop = [clsStack pop];
    while(clsToLoop != nil)
    {
        NSMutableDictionary	*methodNames = [clsToLoop performSelector:NSSelectorFromString(@"luaMethods")];
        for(NSString *funcName in methodNames)
        {
            LuaFunction *lf = [methodNames objectForKey:funcName];
            NSString *sMethodName = NSStringFromSelector(method_getName(lf->m));
            NSRange range = [sMethodName rangeOfString:@":"];
            if(range.location != NSNotFound)
            {
                sMethodName = [sMethodName substringWithRange:NSMakeRange(0, range.location)];
            }
            if(sMethodName == nil)
            {
                NSLog(APPEND(@"Null method on class name", className));
                continue;
            }
            lua_pushstring(L, [sMethodName cStringUsingEncoding:NSASCIIStringEncoding]);
            lf->luaName = sMethodName;
            //lua_pushlightuserdata(L, (void*)methods[i]);
            if(arr == nil)
                arr = [[NSMutableArray alloc] init];

            [arr addObject:lf];
            
            lua_pushlightuserdata(L, lf);
            if(lf->classOfMethod != NULL)
                lua_pushcclosure(L, sThunk, 1);
            else
                lua_pushcclosure(L, thunk, 1);
            lua_settable(L, methods);
            //NSLog(@"%@", NSStringFromSelector(method_getName(methods[i])));)
        }
        clsToLoop = [clsStack pop];
    }
	if(arr != NULL)
		[dictFunctionNames setObject:arr forKey:className];
    
    if([T respondsToSelector:NSSelectorFromString(@"luaStaticVars")])
    {
        NSMutableDictionary *staticVars = [T performSelector:NSSelectorFromString(@"luaStaticVars")];
        for(NSString *var in staticVars)
        {
            NSObject *val = [staticVars objectForKey:var];
            lua_pushstring(L, [var cStringUsingEncoding:NSUTF8StringEncoding]);
            [sToppingEngine FillVariable:val];
            lua_settable(L, methods);
        }
    }
	
	lua_pop(L, 2);  // drop metatable and method table
	
	if([T respondsToSelector:NSSelectorFromString(@"luaGlobals")])
	{
		NSMutableDictionary	*globalNames = [T performSelector:NSSelectorFromString(@"luaGlobals")];
		for(NSString *globalName in globalNames)
		{
			NSObject *val = [globalNames objectForKey:globalName];
			if([val isKindOfClass:[NSNumber class]])
			{
				NSNumber* num = (NSNumber*)val;
				if(!strcmp([num objCType], @encode(int)))
					lua_pushinteger(L, [num intValue]);
				else if(!strcmp([num objCType], @encode(unsigned int)))
					lua_pushinteger(L, [num unsignedIntValue]);
				else if(!strcmp([num objCType], @encode(long)))
					lua_pushinteger(L, [num longValue]);
				else if(!strcmp([num objCType], @encode(unsigned long)))
					lua_pushinteger(L, [num unsignedLongValue]);
				else if(!strcmp([num objCType], @encode(long long)))
					lua_pushinteger(L, [num longLongValue]);
				else if(!strcmp([num objCType], @encode(unsigned long long)))
					lua_pushinteger(L, [num unsignedLongLongValue]);	 
				else if(!strcmp([num objCType], @encode(float)))
					lua_pushnumber(L, [num floatValue]);
				else if(!strcmp([num objCType], @encode(double)))
					lua_pushnumber(L, [num doubleValue]);
				lua_setglobal(L, [globalName cStringUsingEncoding:NSUTF8StringEncoding]);				
			}
			else if([val isKindOfClass:[NSString class]])
			{
				lua_pushstring(L, [((NSString*)val) cStringUsingEncoding:NSUTF8StringEncoding]);
				lua_setglobal(L, [globalName cStringUsingEncoding:NSUTF8StringEncoding]);
			}
			else if([val isKindOfClass:[LuaGlobalFunction class]])
			{
				LuaGlobalFunction *lgf = (LuaGlobalFunction*)val;
				NSString *className = lgf.name;
				lua_newtable(L);
				int methodsa = lua_gettop(L);
				
				luaL_newmetatable(L, [className cStringUsingEncoding:NSASCIIStringEncoding]);
				int metatablea = lua_gettop(L);
				
				luaL_newmetatable(L,"DO NOT TRASH");
				lua_pop(L, 1);
				
				// store method table in globals so that
				// scripts can add functions written in Lua.
				lua_pushvalue(L, methodsa);
				lua_setfield(L, LUA_GLOBALSINDEX, [className cStringUsingEncoding:NSASCIIStringEncoding]);
				
				// hide metatable from Lua getmetatable()
				lua_pushvalue(L, methodsa);
				lua_setfield(L, metatablea, "__metatable");
				
				lua_pushvalue(L, methodsa);
				lua_setfield(L, metatablea, "__index");
				
				lua_pushcfunction(L, lgf.__tostring);
				lua_setfield(L, metatablea, "__tostring");
				
				lua_pushcfunction(L, lgf.__gc);
				lua_setfield(L, metatablea, "__gc");
				
				lua_newtable(L);                // mt for method table
				int mt = lua_gettop(L);
				
				lua_pushcfunction(L, lgf.__index);
				lua_setfield(L, mt, "__index");
				
				lua_pushcfunction(L, lgf.__newindex);
				lua_setfield(L, mt, "__newindex");
							
				lua_setmetatable(L, methodsa);
				
				lua_pop(L, 2);
			}
		}
	}
}

+(int) push:(lua_State*) L :(NSObject*) obj: (bool) gc
{
	if(!obj)
	{
		lua_pushnil(L); 
		return lua_gettop(L);
	}
	
	BOOL returnFromHere = YES;
	
	NSString *className;
	if([[obj class] respondsToSelector:NSSelectorFromString(@"className")])
		className = [[obj class] performSelector:NSSelectorFromString(@"className")];
	else
		className = NSStringFromClass([obj class]);
	
	if([className compare:@"NSNumber"] == 0)
	{
		[sToppingEngine PushDouble:[((NSNumber*)obj) doubleValue]];
	}
	else if([className compare:@"NSCFString"] == 0)
	{
		[sToppingEngine PushString:(NSString*)obj];
	}
	else if([className compare:@"NSMutableDictionary"] == 0)
	{
		[sToppingEngine PushTable:(NSMutableDictionary*)obj];
	}
	else
		returnFromHere = NO;
	if(returnFromHere)
		return 1;

	luaL_getmetatable(L, [className cStringUsingEncoding:NSASCIIStringEncoding]);  // lookup metatable in Lua registry
	if (lua_isnil(L, -1))
		luaL_error(L, "%@ missing metatable", className);
	
	int mt = lua_gettop(L);
	void ** ptrHold = (void**)lua_newuserdata(L,sizeof([obj class]));
	int ud = lua_gettop(L);
	if(ptrHold != NULL)
	{
        *ptrHold = obj;
		lua_pushvalue(L, mt);
		lua_setmetatable(L, -2);
		lua_getfield(L,LUA_REGISTRYINDEX,"DO NOT TRASH");
		if(lua_isnil(L,-1) )
		{
			luaL_newmetatable(L,"DO NOT TRASH");
			lua_pop(L,1);
		}
		lua_getfield(L,LUA_REGISTRYINDEX,"DO NOT TRASH");
		if(gc == false)
		{
			lua_pushboolean(L,1);
			lua_setfield(L,-2, [className cStringUsingEncoding:NSASCIIStringEncoding]);
		}
		lua_pop(L,1);
	}
	lua_settop(L,ud);
	lua_replace(L, mt);
	lua_settop(L, mt);
	
	return mt;  // index of userdata containing pointer to T object
}

static NSObject *check(lua_State *L, int narg) 
{
	void **ptrHold = (void **)(lua_touserdata(L, narg));
	if(ptrHold == NULL)
		return NULL;
    return *ptrHold;
}

+(NSMutableDictionary*) ParseTable:(TValue*)valP
{
	NSMutableDictionary *map = [[NSMutableDictionary alloc] init];
	Table *ot = (Table*)hvalue(valP);
	int size = sizenode(ot);
	for(int i = 0; i < size; i++)
	{
		Node *node = gnode(ot, i);
		TValue *key = key2tval(node);
		NSObject *keyObject = nil;
		switch(ttype(key))
		{
			case LUA_TNIL:
				break;
			case LUA_TSTRING:
			{
				keyObject = [NSString stringWithCString:svalue(key) encoding:NSUTF8StringEncoding];
			}break;
			case LUA_TNUMBER:
				keyObject = [NSNumber numberWithDouble:nvalue(key)];
				break;
			default:
				break;
		}
		
		const TValue *val = luaH_get(ot, key);
		NSObject *valObject = nil;
		switch(ttype(val))
		{
			case LUA_TNIL:
				break;
			case LUA_TSTRING:
			{
				valObject = [NSString stringWithCString:svalue(val) encoding:NSUTF8StringEncoding];
			}break;
			case LUA_TNUMBER:
				valObject = [NSNumber numberWithDouble:nvalue(val)];
				break;
			case LUA_TTABLE:
				valObject = [Lunar ParseTable:val];
				break;
			case LUA_TUSERDATA:
			{
				void **ptr = (rawuvalue(val) + 1);
                valObject = *ptr;
				if(valObject != NULL)
				{
					/*if(valObject.getClass().getName().startsWith("com.Resto.ScriptingEngine.LuaObject"))
					 {
					 Object objA = ((LuaObject<?>)valObject).obj;
					 if(objA == null)
					 {
					 Log.e("Lunar Push", "Cannot get lua object property static thunk");
					 return 0;
					 }
					 
					 valObject = objA;
					 }*/
				}
			}break;
			case LUA_TLIGHTUSERDATA:
			{
				void **ptr = pvalue(val);
                valObject = *ptr;
				if(valObject != NULL)
				{
					/*if(valObject.getClass().getName().startsWith("com.Resto.ScriptingEngine.LuaObject"))
					 {
					 Object objA = ((LuaObject<?>)valObject).obj;
					 if(objA == null)
					 {
					 Log.e("Lunar Push", "Cannot get lua object property static thunk");
					 return 0;
					 }
					 
					 valObject = objA;
					 }*/
				}
			}break;
		}
		[map setObject:valObject forKey:keyObject];
	}
	
	return map;
}

static int sThunk(lua_State *L) 
{
	//NSObject *obj = check(L, 1);
	//lua_remove(L, 1);
    LuaFunction	*lf = lua_touserdata(L, lua_upvalueindex(1));
	int count = 1;
	/*if(lua_istable(L, 1))
	{
		void **ptr = lua_topointer(L, 1);
		NSObject *o = (NSObject*)*ptr;
		if([o class] == [lf->classOfMethod->isa className])
		{
			luaL_typerror(L, 1, lua_typename(L, LUA_TNIL));
			return 1;
		}
	}*/
	NSMethodSignature *nms = [lf->classOfMethod methodSignatureForSelector:lf->selector];
	NSInvocation *ni = [NSInvocation invocationWithMethodSignature:nms];
    [ni retainArguments];
	[ni setTarget:lf->classOfMethod];
	[ni setSelector:lf->selector];	
	for(Class c in lf->argumentArray)
	{
		if(c == [LuaBool class])
        {
            bool val = (bool)lua_toboolean(L, count);
            if (!lua_isboolean(L, count))  /* avoid extra test when d is not 0 */
                luaL_typerror(L, count, lua_typename(L, LUA_TBOOLEAN));
            [ni setArgument:&val atIndex:count+1];
        }
		if(c == [LuaChar class]
		   || c == [LuaShort class]
		   || c == [LuaInt class])
		{
			int val = luaL_checkinteger(L, count);
			[ni setArgument:&val atIndex:count+1];
		}
		else if(c == [LuaLong class])
		{
			long val = luaL_checklong(L, count);
			[ni setArgument:&val atIndex:count+1];
		}
		else if(c == [LuaFloat class]
				|| c == [LuaDouble class])
		{
			double val = luaL_checknumber(L, count);
			[ni setArgument:&val atIndex:count+1];
		}
		else if(c == [NSString class])
		{
			const char *val = luaL_checkstring(L, count);
			NSString *valStr = [NSString stringWithCString:val encoding:NSUTF8StringEncoding];
			[ni setArgument:&valStr atIndex:count+1];
		}
        else if(c == [LuaTranslator class] && lua_isfunction(L, count))
        {
            int fref = luaL_ref(L, LUA_REGISTRYINDEX);
            //const void *o = lua_topointer(L, count);
            LuaTranslator *lt = [[LuaTranslator alloc] init];
            lt.obj = nil;
            lt.nobj = [NSNumber numberWithInt:fref];
            [ni setArgument:&lt atIndex:count+1];
        }
		else 
		{
			void **ptr = lua_touserdata(L, count);
			if(ptr == NULL)
			{
				//Table
				const void *o = lua_topointer(L, count);
				if(o == NULL)
				{
					if(lua_isboolean(L, count))
					{
						BOOL val = (lua_toboolean(L, count) > 0 ? YES : NO);
						[ni setArgument:&val atIndex:count+1];
					}
					else if(lua_isnumber(L, count) > 0)
					{
						double val = lua_tonumber(L, count);
						[ni setArgument:&val atIndex:count+1];
					}
					else if(lua_isstring(L, count) > 0)
					{
						NSString *val = [NSString stringWithCString:lua_tostring(L, count) encoding:NSUTF8StringEncoding];
						[ni setArgument:&val atIndex:count+1];
					}
					else if(lua_isnoneornil(L, count))
					{
						NSObject *val = nil;
						[ni setArgument:&val atIndex:count+1];
					}
				}
				else
				{
					Table *ot = (Table*)o;
					
					NSMutableDictionary *map = [[NSMutableDictionary alloc] init];
					int size = sizenode(ot);
					for(int i = 0; i < size; i++)
					{
						Node *node = gnode(ot, i);
						TValue *key = key2tval(node);
						NSObject *keyObject = nil;
						switch(ttype(key))
						{
							case LUA_TNIL:
								break;
							case LUA_TSTRING:
							{
								keyObject = [NSString stringWithCString:svalue(key) encoding:NSUTF8StringEncoding];
							}break;
							case LUA_TNUMBER:
								keyObject = [NSNumber numberWithDouble:nvalue(key)];
								break;
							default:
								break;
						}
						
						const TValue *val = luaH_get(ot, key);
						NSObject *valObject = nil;
						switch(ttype(val))
						{
							case LUA_TNIL:
								break;
							case LUA_TSTRING:
							{
								valObject = [NSString stringWithCString:svalue(val) encoding:NSUTF8StringEncoding];
							}break;
							case LUA_TNUMBER:
								valObject = [NSNumber numberWithDouble:nvalue(val)];
								break;
							case LUA_TTABLE:
								valObject = [Lunar ParseTable:val];
								break;
							case LUA_TUSERDATA:
							{
								void **ptr = (rawuvalue(val) + 1);
                                valObject = *ptr;
								if(valObject != NULL)
								{
									/*if(valObject.getClass().getName().startsWith("com.Resto.ScriptingEngine.LuaObject"))
									 {
									 Object objA = ((LuaObject<?>)valObject).obj;
									 if(objA == null)
									 {
									 Log.e("Lunar Push", "Cannot get lua object property static thunk");
									 return 0;
									 }
									 
									 valObject = objA;
									 }*/
								}
							}break;
							case LUA_TLIGHTUSERDATA:
							{
								void **ptr = pvalue(val);
                                valObject = *ptr;
								if(valObject != NULL)
								{
									/*if(valObject.getClass().getName().startsWith("com.Resto.ScriptingEngine.LuaObject"))
									 {
									 Object objA = ((LuaObject<?>)valObject).obj;
									 if(objA == null)
									 {
									 Log.e("Lunar Push", "Cannot get lua object property static thunk");
									 return 0;
									 }
									 
									 valObject = objA;
									 }*/
								}
							}break;
						}
						if(valObject != nil)
							[map setObject:valObject forKey:keyObject];
					}
					[ni setArgument:&map atIndex:count+1];
				}
			}
			else
			{
                void *o = *ptr;
				[ni setArgument:&o atIndex:count+1];
			}
		}
		++count;
	}
	[ni invoke];
	
	if(lf->returns != nil)
	{
		if(lf->returns == [LuaBool class]
		   || lf->returns == [LuaChar class]
		   || lf->returns == [LuaShort class]
		   || lf->returns == [LuaInt class])
		{
			int retVal = 0;
			[ni getReturnValue:&retVal];
			[sToppingEngine PushInt:retVal];
		}
		else if(lf->returns == [LuaLong class])
		{
			long retVal = 0;
			[ni getReturnValue:&retVal];
			[sToppingEngine PushLong:retVal];
		}
		else if(lf->returns == [LuaFloat class]
				|| lf->returns == [LuaDouble class])
		{
			double retVal = 0;
			[ni getReturnValue:&retVal];
			[sToppingEngine PushDouble:retVal];
		}
		else if(lf->returns == [NSString class])
		{
			NSString *retVal = @"";
			[ni getReturnValue:&retVal];
			[sToppingEngine PushString:retVal];
		}
		else if(lf->returns == [NSMutableDictionary class])
		{
			NSMutableDictionary *retVal = [[NSMutableDictionary alloc] init];
			[ni getReturnValue:&retVal];
			[sToppingEngine PushTable:retVal];
		}
		else 
		{
			void *retVal;
			[ni getReturnValue:&retVal];
            [Lunar push:L :retVal :FALSE];
		}
	}
	
	return 1;
}

static int thunk(lua_State *L) 
{
	NSObject *obj = check(L, 1);
	//NSObject *obj = check(L, 2);
	if(obj == NULL)
		return 0;
	lua_remove(L, 1);
    LuaFunction	*lf = lua_touserdata(L, lua_upvalueindex(1));
	int count = 1;
    NSMethodSignature *nms = [object_getClass(obj) instanceMethodSignatureForSelector:lf->selector];
	NSInvocation *ni = [NSInvocation invocationWithMethodSignature:nms];
    [ni retainArguments];
	[ni setTarget:obj];
	[ni setSelector:lf->selector];	
	for(Class c in lf->argumentArray)
	{
        if(c == [LuaBool class])
        {
            bool val = (bool)lua_toboolean(L, count);
            if (!lua_isboolean(L, count))  /* avoid extra test when d is not 0 */
                luaL_typerror(L, count, lua_typename(L, LUA_TBOOLEAN));
            [ni setArgument:&val atIndex:count+1];
        }
		if(c == [LuaChar class]
		   || c == [LuaShort class]
		   || c == [LuaInt class])
		{
			int val = luaL_checkinteger(L, count);
			[ni setArgument:&val atIndex:count+1];
		}
		else if(c == [LuaLong class])
		{
			long val = luaL_checklong(L, count);
			[ni setArgument:&val atIndex:count+1];
		}
		else if(c == [LuaFloat class]
				|| c == [LuaDouble class])
		{
			double val = luaL_checknumber(L, count);
			[ni setArgument:&val atIndex:count+1];
		}
		else if(c == [NSString class])
		{
			const char *val = luaL_checkstring(L, count);
			NSString *valStr = LUA_COPY_STRING([NSString stringWithCString:val encoding:NSUTF8StringEncoding]);
			[ni setArgument:&valStr atIndex:count+1];
		}
        else if(c == [LuaTranslator class] && lua_isfunction(L, count))
        {
            int fref = luaL_ref(L, LUA_REGISTRYINDEX);
            //const void *o = lua_topointer(L, count);
            LuaTranslator *lt = [[LuaTranslator alloc] init];
            lt.obj = obj;
            lt.nobj = [NSNumber numberWithInt:fref];
            [ni setArgument:&lt atIndex:count+1];
        }
		else 
		{
			void **ptr = lua_touserdata(L, count);
			if(ptr == NULL)
			{
				//Table
				const void *o = lua_topointer(L, count);
				if(o == NULL)
				{
					if(lua_isstring(L, count) > 0)
					{
						NSString *val = [NSString stringWithCString:lua_tostring(L, count) encoding:NSUTF8StringEncoding];
						[ni setArgument:&val atIndex:count+1];
					}
					else if(lua_isboolean(L, count))
					{
						BOOL val = (lua_toboolean(L, count) > 0 ? YES : NO);
						[ni setArgument:&val atIndex:count+1];
					}
					else if(lua_isnumber(L, count) > 0)
					{
						double val = lua_tonumber(L, count);
						[ni setArgument:&val atIndex:count+1];
					}
					else if(lua_isnoneornil(L, count))
					{
						NSObject *val = nil;
						[ni setArgument:&val atIndex:count+1];
					}
				}
				else
				{
					Table *ot = (Table*)o;
					
					NSMutableDictionary *map = [[NSMutableDictionary alloc] init];
					int size = sizenode(ot);
					for(int i = 0; i < size; i++)
					{
						Node *node = gnode(ot, i);
						TValue *key = key2tval(node);
						NSObject *keyObject = nil;
						switch(ttype(key))
						{
							case LUA_TNIL:
								break;
							case LUA_TSTRING:
							{
								keyObject = [NSString stringWithCString:svalue(key) encoding:NSUTF8StringEncoding];
							}break;
							case LUA_TNUMBER:
								keyObject = [NSNumber numberWithDouble:nvalue(key)];
								break;
							default:
								break;
						}
						
						const TValue *val = luaH_get(ot, key);
						NSObject *valObject = nil;
						switch(ttype(val))
						{
							case LUA_TNIL:
								break;
							case LUA_TSTRING:
							{
								valObject = LUA_COPY_STRING([NSString stringWithCString:svalue(val) encoding:NSUTF8StringEncoding]);
							}break;
							case LUA_TNUMBER:
								valObject = [NSNumber numberWithDouble:nvalue(val)];
								break;
							case LUA_TTABLE:
								valObject = [Lunar ParseTable:val];
								break;
							case LUA_TUSERDATA:
							{
								void **ptr = (rawuvalue(val) + 1);
                                valObject = *ptr;
								if(valObject != NULL)
								{
									/*if(valObject.getClass().getName().startsWith("com.Resto.ScriptingEngine.LuaObject"))
									 {
									 Object objA = ((LuaObject<?>)valObject).obj;
									 if(objA == null)
									 {
									 Log.e("Lunar Push", "Cannot get lua object property static thunk");
									 return 0;
									 }
									 
									 valObject = objA;
									 }*/
								}
							}break;
							case LUA_TLIGHTUSERDATA:
							{
								void **ptr = pvalue(val);
                                valObject = *ptr;
								if(valObject != NULL)
								{
									/*if(valObject.getClass().getName().startsWith("com.Resto.ScriptingEngine.LuaObject"))
									 {
									 Object objA = ((LuaObject<?>)valObject).obj;
									 if(objA == null)
									 {
									 Log.e("Lunar Push", "Cannot get lua object property static thunk");
									 return 0;
									 }
									 
									 valObject = objA;
									 }*/
								}
							}break;
						}
						if(valObject == nil && keyObject == nil)
                        {
                            for(int j = 0; j < ot->sizearray; j++)
                            {
                                TValue *valO = &ot->array[j];
                                switch(ttype(valO))
                                {
                                    case LUA_TNIL:
                                        break;
                                    case LUA_TSTRING:
                                    {
                                        valObject = LUA_COPY_STRING([NSString stringWithCString:svalue(valO) encoding:NSUTF8StringEncoding]);
                                    }break;
                                    case LUA_TNUMBER:
                                        valObject = [NSNumber numberWithDouble:nvalue(valO)];
                                        break;
                                    case LUA_TTABLE:
                                        valObject = [Lunar ParseTable:valO];
                                        break;
                                    case LUA_TUSERDATA:
                                    {
                                        void **ptr = (rawuvalue(valO) + 1);
                                        valObject = *ptr;
                                        if(valObject != NULL)
                                        {
                                            /*if(valObject.getClass().getName().startsWith("com.Resto.ScriptingEngine.LuaObject"))
                                             {
                                             Object objA = ((LuaObject<?>)valObject).obj;
                                             if(objA == null)
                                             {
                                             Log.e("Lunar Push", "Cannot get lua object property static thunk");
                                             return 0;
                                             }
                                             
                                             valObject = objA;
                                             }*/
                                        }
                                    }break;
                                    case LUA_TLIGHTUSERDATA:
                                    {
                                        void **ptr = pvalue(valO);
                                        valObject = *ptr;
                                        if(valObject != NULL)
                                        {
                                            /*if(valObject.getClass().getName().startsWith("com.Resto.ScriptingEngine.LuaObject"))
                                             {
                                             Object objA = ((LuaObject<?>)valObject).obj;
                                             if(objA == null)
                                             {
                                             Log.e("Lunar Push", "Cannot get lua object property static thunk");
                                             return 0;
                                             }
                                             
                                             valObject = objA;
                                             }*/
                                        }
                                    }break;
                                }
                                [map setObject:valObject forKey:ITOS(j)];
                            }
                        }
                        else
							[map setObject:valObject forKey:keyObject];
					}
					[ni setArgument:&map atIndex:count+1];
				}
			}
			else
			{
                //__unsafe_unretained NSObject *o = (__bridge NSObject*)*ptr;
                void *o = *ptr;
				[ni setArgument:&o atIndex:count+1];
			}
		}
		++count;
	}
	[ni invoke];
	
	if(lf->returns != nil)
	{
		if(lf->returns == [LuaBool class]
		   || lf->returns == [LuaChar class]
		   || lf->returns == [LuaShort class]
		   || lf->returns == [LuaInt class])
		{
			int retVal = 0;
			[ni getReturnValue:&retVal];
			[sToppingEngine PushInt:retVal];
		}
		else if(lf->returns == [LuaLong class])
		{
			long retVal = 0;
			[ni getReturnValue:&retVal];
			[sToppingEngine PushLong:retVal];
		}
		else if(lf->returns == [LuaFloat class]
				|| lf->returns == [LuaDouble class])
		{
			double retVal = 0;
			[ni getReturnValue:&retVal];
			[sToppingEngine PushDouble:retVal];
		}
		else if(lf->returns == [NSString class])
		{
			NSString *retVal = @"";
			[ni getReturnValue:&retVal];
			[sToppingEngine PushString:retVal];
		}
		else if(lf->returns == [NSMutableDictionary class])
		{
			NSMutableDictionary *retVal = [[NSMutableDictionary alloc] init];
			[ni getReturnValue:&retVal];
			[sToppingEngine PushTable:retVal];
		}
		else 
		{
			NSObject *retVal;
			[ni getReturnValue:&retVal];
			[Lunar push:L :retVal :FALSE];
		}
	}
	
	return 1;
}

// garbage collection metamethod
static int gc_T(lua_State *L) 
{
	NSObject * obj = check(L, 1);
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

/*+(int) tostring_T:(lua_State*) L
{
	void **ptrHold = (void **)(lua_touserdata(L, 1));
	if(ptrHold == NULL)
		return 0;
	NSObject *obj = ((NSObject*)*ptrHold);
	NSString *className = NSStringFromClass([obj class]);
	lua_pushstring(L, className);
	return 1;
}*/

static int tostring_T (lua_State *L)
{
	void **ptrHold = (void **)(lua_touserdata(L, 1));
	if(ptrHold == NULL)
		return 0;
    NSObject *obj = *ptrHold;
	NSString *className = NSStringFromClass([obj class]);
	lua_pushstring(L, [className cStringUsingEncoding:NSASCIIStringEncoding]);
	return 1;
}

@end
