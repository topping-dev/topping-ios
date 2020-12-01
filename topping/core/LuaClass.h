#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@protocol LuaClass
+(NSString*) className;
+(NSMutableDictionary*) luaMethods;
@optional
+(NSMutableDictionary*) luaGlobals;
+(NSMutableDictionary*) luaStaticVars;
@end
