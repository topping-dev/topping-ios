#import "lua.h"
#import "lauxlib.h"
#import "lobject.h"
#import "ltable.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface Lunar : NSObject 
{
	
}

+(void)register:(lua_State*)L :(Class)T;
+(int)push:(lua_State*)L :(NSObject*)obj :(bool)gc;
+(NSMutableDictionary*)parseTable:(TValue *) valP;
/*+(NSObject*) check:(lua_State*) L:(int) narg;
//member function dispatcher
+(int) thunk:(lua_State*) L;
+(int) gc_T:(lua_State*) L;
+(int) tostring_T:(lua_State*) L;*/


@end
