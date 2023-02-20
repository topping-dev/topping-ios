#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LuaClass.h"
#import "LuaInterface.h"
#import "LuaFormIntent.h"

@class LuaForm;

/**
 * Context class that stores various operating system data.
 */
@interface LuaContext : NSObject <LuaClass, LuaInterface>
{
	NSString *lua_id;
	UINavigationController *navController;
}

-(void)setup:(UIViewController*)controller :(BOOL)navigation;
-(void)setup:(UIViewController *)controller;
-(LuaForm*)getForm;
-(void)startForm:(LuaFormIntent*)formIntent;

@property (nonatomic, retain) NSString *packageName;
@property (nonatomic, retain) NSString *lua_id;
@property (nonatomic, retain) UINavigationController *navController;
@property (nonatomic, strong) LuaForm *form;

@end
