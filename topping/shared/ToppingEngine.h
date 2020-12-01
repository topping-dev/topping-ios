#import "Common.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LuaContext.h"

#define CHECK_FLOAT(L,narg) (lua_isnoneornil(L,(narg)) ) ? 0.00f : (float)luaL_checknumber(L,(narg)); 
#define CHECK_ULONG(L,narg) (uint32)luaL_checknumber((L),(narg))
#define CHECK_UINT32(L,narg) (uint32)luaL_checknumber((L),(narg))
#define CHECK_USHORT(L, narg) (uint16)luaL_checkinteger((L),(narg))
#define CHECK_UINT16(L, narg) (uint16)luaL_checkinteger((L),(narg))
#define CHECK_LONG(L, narg) (int32)luaL_checkinteger((L),(narg))
#define CHECK_INT32(L, narg) (int32)luaL_checkinteger((L),(narg))
#define CHECK_BOOL(L,narg) (lua_toboolean((L),(narg)) > 0) ? true : false
#define CHECK_STRING(L, narg) (lua_tostring((L),(narg)))

#define PUSH_UINT32(L, val) lua_pushinteger(L, (uint32)val)
#define PUSH_INT32(L, val) lua_pushinteger(L, val)
#define PUSH_FLOAT(L, val) lua_pushnumber(L, (float)val)
#define PUSH_STRING(L, val) lua_pushstring(L, val);

#define lua_tonsstring(val) ([NSString stringWithCString:val encoding:NSUTF8StringEncoding])

#define EXTERNAL_DATA 1
#define INTERNAL_DATA 2
#define RESOURCE_DATA 3

#define sToppingEngine s(ToppingEngine)

#define LUA_LAYOUT_FOLDER @"layout"
#define LUA_DRAWABLE_FOLDER @"drawable"
#define LUA_VALUES_FOLDER @"values"
#define LUA_ANIMATORS_FOLDER @"animator"
#define LUA_ANIMS_FOLDER @"anim"

typedef struct lua_State lua_State;

@interface ToppingEngine : Singleton 
{
@private
	lua_State * lu; //main state
	
	NSMutableDictionary *GuiBindingMap;
	NSMutableDictionary *TagMap;
	
	NSString* scriptsRoot;
	int primaryLoad;
	double forceLoad;
	NSString* uiRoot;
	NSString* mainUI;
	NSString* mainForm;
    NSString* appStyle;
}

+(void)AddLuaPlugin:(Class) plugin;
+(NSArray*)GetViewPlugins;
+(void)report: (lua_State*) L;
-(void)Startup;
-(void)StartupDefines;
-(void)LoadScripts;
-(void)StartupDownload;
-(void)LoadScriptsDownload;
-(void)Restart;
-(void)Unload;

-(bool)BeginCall:(NSString*) func;
-(bool)ExecuteCall:(uint8)params :(uint8)res;
-(void)EndCall:(uint8)res;
-(void)CallFunction:(NSString*)FunctionName :(int)ref;

-(void)RegisterTag:(const char*)nibC :(int)tag :(const char*)strTag;
-(NSString *)GetTag:(NSString*)nib :(int) tag;
-(void)FillVariable:(NSObject*) type;

-(NSObject*)OnNativeEventArgs:(NSObject*)pGui :(int)ref :(NSArray*)Args;
-(NSObject*)OnGuiEventArgs:(NSObject*)pGui :(NSString*)FunctionName :(NSArray*)Args;

-(void)PushBool:(bool) val;
-(void)PushNil;
-(void)PushInt:(int32) val;
-(void)PushUInt:(uint32) val;
-(void)PushLong:(long) val;
-(void)PushFloat:(float) val;
-(void)PushDouble:(double) val;
-(void)PushString:(NSString*) val;
-(void)PushArray:(NSMutableArray *)val;
-(void)PushTable:(NSMutableDictionary*) val;
	
-(void)RegisterCoreFunctions;
-(void)RegisterGlobals;
-(lua_State*)GetLuaState;

-(NSString *)GetScriptsRoot;
-(int) GetPrimaryLoad;
-(NSString *)GetUIRoot;
-(NSString *)GetMainUI;
-(NSString *)GetMainForm;
-(NSString *)GetAppStyle;

@property (nonatomic, retain) NSString* scriptsRoot;
@property (nonatomic) int primaryLoad;
@property (nonatomic) double forceLoad;
@property (nonatomic, retain) NSString* uiRoot;
@property (nonatomic, retain) NSString* mainUI;
@property (nonatomic, retain) NSString* mainForm;
@property (nonatomic, retain) NSString* appStyle;

@end
