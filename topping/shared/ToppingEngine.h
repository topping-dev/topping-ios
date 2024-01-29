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
#define LUA_FONT_FOLDER @"font"
#define LUA_NAVIGATION_FOLDER @"navigation"
#define LUA_MENU_FOLDER @"menu"
#define LUA_COLOR_FOLDER @"color"
#define LUA_XML_FOLDER @"xml"

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

+(void)addLuaPlugin:(Class) plugin;
+(NSArray*)getViewPlugins;
+(void)report: (lua_State*) L;
-(void)startup;
-(void)startupDefines;
-(void)loadScripts;
-(void)startupDownload;
-(void)loadScriptsDownload;
-(void)restart;
-(void)unload;

-(bool)beginCall:(NSString*) func;
-(bool)executeCall:(uint8)params :(uint8)res;
-(void)endCall:(uint8)res;
-(void)callFunction:(NSString*)FunctionName :(int)ref;

-(void)registerTag:(const char*)nibC :(int)tag :(const char*)strTag;
-(NSString *)getTag:(NSString*)nib :(int) tag;
-(void)fillVariable:(NSObject*) type;

-(NSObject*)onNativeEventArgs:(NSObject*)pGui :(int)ref :(NSArray*)Args;
-(NSObject*)onGuiEventArgs:(NSObject*)pGui :(NSString*)FunctionName :(NSArray*)Args;

-(void)pushBool:(bool) val;
-(void)pushNil;
-(void)pushInt:(int32) val;
-(void)pushUInt:(uint32) val;
-(void)pushLong:(long) val;
-(void)pushFloat:(float) val;
-(void)pushDouble:(double) val;
-(void)pushString:(NSString*) val;
-(void)pushArray:(NSMutableArray *)val;
-(void)pushTable:(NSMutableDictionary*) val;
	
-(void)registerCoreFunctions;
-(void)registerGlobals;
-(lua_State*)getLuaState;

-(NSString *)getScriptsRoot;
-(int) getPrimaryLoad;
-(NSString *)getUIRoot;
-(NSString *)getMainUI;
-(NSString *)getMainForm;
-(NSString *)getAppStyle;

@property (nonatomic, retain) NSString* scriptsRoot;
@property (nonatomic) int primaryLoad;
@property (nonatomic) double forceLoad;
@property (nonatomic, retain) NSString* uiRoot;
@property (nonatomic, retain) NSString* mainUI;
@property (nonatomic, retain) NSString* mainForm;
@property (nonatomic, retain) NSString* appStyle;
@property (nonatomic) BOOL useSafeArea;

@end
