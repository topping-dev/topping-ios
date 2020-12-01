#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

typedef struct lua_State lua_State;

@interface LuaGlobalFunction : NSObject 
{
	NSString *name;
	int (*__index)(lua_State *L);
	int (*__newindex)(lua_State *L);
	int (*__gc)(lua_State *L);
	int (*__tostring)(lua_State *L);
}

@property(nonatomic, retain) NSString *name;
@property(nonatomic) int (*__index)(lua_State *L);
@property(nonatomic) int (*__newindex)(lua_State *L);
@property(nonatomic) int (*__gc)(lua_State *L);
@property(nonatomic) int (*__tostring)(lua_State *L);

@end
