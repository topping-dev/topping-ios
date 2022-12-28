#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LuaClass.h"
#import "LuaInterface.h"
#import "LuaContext.h"
#import "LuaStream.h"
#import "LuaForm.h"

@interface LuaTabForm : NSObject <LuaClass, LuaInterface, UITabBarControllerDelegate>
{
	LuaContext *context;
	NSString *luaId;
	UITabBarController *tabController;
	NSMutableArray *localViewControllersArray;
	NSMutableArray *localLGViewControllersArray;
}

+(LuaTabForm*)Create:(LuaContext*)context :(NSString *)luaId;
-(void)AddTab:(LuaForm*)form :(NSString*)title :(LuaStream*)image :(LuaRef*)ui;
-(void)AddTabStream:(LuaForm *)form :(NSString *)title :(LuaStream *)image :(LGView*)ui;
-(void)AddTabSrc:(LuaForm*)form :(NSString*)title :(NSString*)path :(NSString *)image :(LuaRef*)ui;
-(void)AddTabSrcStream:(LuaForm*)form :(NSString*)title :(NSString*)path :(NSString *)image :(LGView*)ui;
-(void)Setup:(LuaForm*)form;

@property (nonatomic, retain) LuaContext* context;
@property (nonatomic, retain) NSString* luaId;
@property (nonatomic, retain) UITabBarController *tabController;
@property (nonatomic, retain) NSMutableArray *localViewControllersArray;
@property (nonatomic, retain) NSMutableArray *localLGViewControllersArray;

@end
