#import "LuaRef.h"
#import "LuaFunction.h"
#import <lua.h>
#import "ToppingEngine.h"
#import "LGValueParser.h"
#import "Defines.h"

@implementation LuaRef

/* pushes new closure table onto the stack, using closure table at
 * given index as its parent */
void lc_newclosuretable(lua_State *L, int idx)
{
    lua_newtable(L);
    lua_pushvalue(L,idx);
    lua_rawseti(L,-2,0);
}

/* gets upvalue with ID varid by consulting upvalue table at index
 * tidx for the upvalue table at given nesting level. */
void lc_getupvalue(lua_State *L, int tidx, int level, int varid)
{
    if (level == 0) {
        lua_rawgeti(L,tidx,varid);
    }
    else {
        lua_pushvalue(L,tidx);
        while (--level >= 0) {
            lua_rawgeti(L,tidx,0); /* 0 links to parent table */
            lua_remove(L,-2);
            tidx = -1;
        }
        lua_rawgeti(L,-1,varid);
        lua_remove(L,-2);
    }
}

/* function(t,k) */
int lcf6 (lua_State *L) {
    int lc_nformalargs = 2;
    lua_settop(L,2);

    /* if type(store[k]) == "table" then */
    int lc2 = 2;
    lua_getfield(L,LUA_ENVIRONINDEX,"type");
    lc_getupvalue(L,lua_upvalueindex(1),0,1);
    lua_pushvalue(L,2);
    lua_gettable(L,-2);
    lua_remove(L,-2);
    lua_call(L,1,1);
    lua_pushliteral(L,"table");
    int lc3 = lua_equal(L,-2,-1);
    lua_pop(L,2);
    lua_pushboolean(L,lc3);
    int lc4 = lua_toboolean(L,-1);
    lua_pop(L,1);
    if (lc4 > 0) {

        /* return store[k] */
        lc_getupvalue(L,lua_upvalueindex(1),0,1);
        lua_pushvalue(L,2);
        lua_gettable(L,-2);
        lua_remove(L,-2);
        return 1;
    }
    else {

        /* else
         * return LuaRef.WithValue(store[k]) */
        int lc5 = lua_gettop(L);
        lua_getfield(L,LUA_ENVIRONINDEX,"LuaRef");
        lua_pushliteral(L,"withValue");
        lua_gettable(L,-2);
        lua_remove(L,-2);
        lc_getupvalue(L,lua_upvalueindex(1),0,1);
        lua_pushvalue(L,2);
        lua_gettable(L,-2);
        lua_remove(L,-2);
        lua_call(L,1,LUA_MULTRET);
        return (lua_gettop(L) - lc5);
    }
}

/* function (t,k,v) */
int lcf7 (lua_State *L) {
    int lc_nformalargs = 3;
    lua_settop(L,3);

    /* error("attempt to update a read-only table", 2) */
    lua_getfield(L,LUA_ENVIRONINDEX,"error");
    lua_pushliteral(L,"attempt to update a read-only table");
    lua_pushnumber(L,2);
    lua_call(L,2,0);
    return 0;
}

/* name: readOnlyTable
 * function(t) */
int readOnlyTable (lua_State *L) {
    int lc_nformalargs = 1;
    lua_settop(L,1);

    /* local proxy = {} */
    lua_newtable(L);

    /* local store = t */
    lc_newclosuretable(L,lua_upvalueindex(1));
    int lc1 = 3;
    lua_pushvalue(L,1);
    lua_rawseti(L,lc1,1);

    /* local mt = {       -- create metatable
     *         __index = function(t,k)
     *             if type(store[k]) == "table" then
     *                 return store[k]
     *             else
     *                 return LuaRef.WithValue(store[k])
     *             end
     *         end,
     *         __newindex = function (t,k,v)
     *           error("attempt to update a read-only table", 2)
     *         end
     *     } */
    lua_createtable(L,0,2);
    lua_pushliteral(L,"__index");
    lua_pushvalue(L,lc1);
    lua_pushcclosure(L, lcf6,1);
    lua_rawset(L,-3);
    lua_pushliteral(L,"__newindex");
    lua_pushcfunction(L, lcf7);
    lua_rawset(L,-3);

    /* setmetatable(proxy, mt) */
    lua_getfield(L,LUA_GLOBALSINDEX,"setmetatable");
    lua_pushvalue(L,2);
    lua_pushvalue(L,4);
    lua_call(L,2,0);

    /* return proxy */
    lua_pushvalue(L,2);
    return 1;
}

+(void)resourceLoader
{
    /* function readOnlyTable (t)
     *     local proxy = {}
     *     local store = t
     *     local mt = {       -- create metatable
     *         __index = function(t,k)
     *             if type(store[k]) == "table" then
     *                 return store[k]
     *             else
     *                 return LuaRef.WithValue(store[k])
     *             end
     *         end,
     *         __newindex = function (t,k,v)
     *           error("attempt to update a read-only table", 2)
     *         end
     *     }
     *     setmetatable(proxy, mt)
     *     return proxy
     * end */
    lua_State *L = [sToppingEngine getLuaState];
    lua_pushcfunction(L, readOnlyTable);
    lua_setfield(L,LUA_GLOBALSINDEX,"readOnlyTable");

    NSMutableSet *reservedKeywordSet = [NSMutableSet new];
    [reservedKeywordSet addObject:@"and"];
    [reservedKeywordSet addObject:@"end"];
    [reservedKeywordSet addObject:@"in"];
    [reservedKeywordSet addObject:@"repeat"];
    [reservedKeywordSet addObject:@"break"];
    [reservedKeywordSet addObject:@"do"];
    [reservedKeywordSet addObject:@"else"];
    [reservedKeywordSet addObject:@"false"];
    [reservedKeywordSet addObject:@"for"];
    [reservedKeywordSet addObject:@"function"];
    [reservedKeywordSet addObject:@"elseif"];
    [reservedKeywordSet addObject:@"if"];
    [reservedKeywordSet addObject:@"not"];
    [reservedKeywordSet addObject:@"local"];
    [reservedKeywordSet addObject:@"nil"];
    [reservedKeywordSet addObject:@"or"];
    [reservedKeywordSet addObject:@"return"];
    [reservedKeywordSet addObject:@"then"];
    [reservedKeywordSet addObject:@"true"];
    [reservedKeywordSet addObject:@"until"];
    [reservedKeywordSet addObject:@"while"];
    
    NSMutableDictionary *allKeys = [[LGValueParser getInstance] getAllKeys];
    NSMutableArray *classArr = [NSMutableArray array];
    for(NSString *key in allKeys)
    {
        NSDictionary *keyvalue = [allKeys objectForKey:key];
        int arrayCount = 0;
        int primitiveCount = 0;
        for(NSString *keyIn in keyvalue)
        {
            /*NSObject *obj = [keyvalue objectForKey:keyIn];
            if([obj isKindOfClass:[NSArray class]])
            {
                NSArray *arr = (NSArray*)obj;
                arrayCount += arr.count;
            }
            else
            {*/
                primitiveCount++;
            //}
        }

        lua_createtable(L, arrayCount, primitiveCount);
        for(NSString *keyIn in keyvalue)
        {
            lua_pushstring(L, [keyIn cStringUsingEncoding:NSUTF8StringEncoding]);
            NSObject *obj = [keyvalue objectForKey:keyIn];
            /*if([obj isKindOfClass:[NSArray class]])
            {
                NSArray *arr = (NSArray*)obj;
                lua_createtable(L, arr.count - 1, 1);
                lua_pushnumber(L,0);
                NSMutableString *str = [NSMutableString string];
                [str appendFormat:@"@%@/%@", key, [arr objectAtIndex:0]];
                lua_pushstring(L, [str cStringUsingEncoding:NSUTF8StringEncoding]);
                lua_rawset(L,-3);
                for(int i = 1; i < arr.count; i++)
                {
                    NSString *val = [arr objectAtIndex:i];
                    NSMutableString *str = [NSMutableString string];
                    [str appendFormat:@"@%@/%@", key, val];
                    lua_pushstring(L, [val cStringUsingEncoding:NSUTF8StringEncoding]);
                    lua_rawseti(L,-2,i);
                }
            }
            else
            {*/
                NSMutableString *str = [NSMutableString string];
                [str appendFormat:@"@%@/%@", key, keyIn];
                lua_pushstring(L, [str cStringUsingEncoding:NSUTF8StringEncoding]);
                //lua_pushnumber(L, (int) kvp.getValue());
            //}
            lua_rawset(L,-3);
        }
        lua_setfield(L,LUA_GLOBALSINDEX, [[NSString stringWithFormat:@"v%@", key] cStringUsingEncoding:NSUTF8StringEncoding]);

        /* tXXXX= readOnlyTable(vXXXX) */
        lua_getfield(L,LUA_GLOBALSINDEX,"readOnlyTable");
        lua_getfield(L,LUA_GLOBALSINDEX,[[NSString stringWithFormat:@"v%@", key] cStringUsingEncoding:NSUTF8StringEncoding]);
        lua_call(L,1,1);
        lua_setfield(L,LUA_GLOBALSINDEX,[[NSString stringWithFormat:@"t%@", key] cStringUsingEncoding:NSUTF8StringEncoding]);
        
        [classArr addObject:key];
    }

    /* tLR = { XXXX=tXXXX,YYYY=tYYYY } */
    lua_createtable(L, 0, classArr.count);
    for(int i = 0; i < classArr.count; i++)
    {
        NSString *key = [classArr objectAtIndex:i];
        lua_pushstring(L, [key cStringUsingEncoding:NSUTF8StringEncoding]);
        lua_getfield(L,LUA_GLOBALSINDEX, [[NSString stringWithFormat:@"t%@", key] cStringUsingEncoding:NSUTF8StringEncoding]);
        lua_rawset(L,-3);
    }

    lua_setfield(L,LUA_GLOBALSINDEX,"tLR");

    /* _G['LR'] = readOnlyTable(tLR) */
    lua_getfield(L,LUA_GLOBALSINDEX,"readOnlyTable");
    lua_getfield(L,LUA_GLOBALSINDEX,"tLR");
    lua_call(L,1,1);
    lua_getfield(L,LUA_GLOBALSINDEX,"_G");
    lua_insert(L,-2);
    lua_pushliteral(L,"LR");
    lua_insert(L,-2);
    lua_settable(L,-3);
    lua_pop(L,1);
}

+(LuaRef*)withValue:(NSString *)val
{
    LuaRef *lr = [[LuaRef alloc] init];
    lr.idRef = val;
    return lr;
}


+(LuaRef*)getRef:(LuaContext*)lc :(NSString *)ids
{
    LuaRef *lr = [[LuaRef alloc] init];
    lr.idRef = ids;
    return lr;
}

-(NSString*)GetId
{
    return @"LuaRef";
}

+ (NSString*)className
{
    return @"LuaRef";
}

+(NSMutableDictionary*)luaMethods
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(withValue:))
                                        :@selector(withValue:)
                                        :[LuaRef class]
                                        :[NSArray arrayWithObjects:[NSString class], nil]
                                        :[LuaRef class]]
             forKey:@"withValue"];
    [dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(getRef::))
                                        :@selector(getRef::)
                                        :[LuaRef class]
                                        :[NSArray arrayWithObjects:[LuaContext class], [NSString class], nil]
                                        :[LuaRef class]]
             forKey:@"getRef"];
    return dict;
}

@end
