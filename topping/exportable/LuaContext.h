#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LuaClass.h"
#import "LuaInterface.h"

/**
 * Context class that stores various operating system data.
 */
@interface LuaContext : NSObject <LuaClass, LuaInterface>
{
	NSString *lua_id;
	UINavigationController *navController;
}

-(void)Setup:(UIViewController *)controller;

@property (nonatomic, retain) NSString *lua_id;
@property (nonatomic, retain) UINavigationController *navController;

@end
