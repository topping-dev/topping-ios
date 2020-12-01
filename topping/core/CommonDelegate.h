#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "NSQueue.h"
#include <libkern/OSAtomic.h>
#include <CoreFoundation/CFURL.h>
#import <AudioToolbox/AudioServices.h>
#import "LuaForm.h"

@interface CommonDelegate : NSObject <UIAlertViewDelegate>
{
	UIActivityIndicatorView *uiAav;
}

+(CommonDelegate*) GetInstance;
+(LuaForm*) GetActiveForm;
+(void)SetActiveForm:(LuaForm*)form;
-(void)InitMain:(UIWindow *)windw :(UIScene*)scene;
- (void)applicationWillEnterForeground:(UIApplication *)application;
- (void)applicationWillResignActive:(UIApplication *)application;
- (void)applicationDidEnterBackground:(UIApplication *)application;
- (void)applicationDidBecomeActive:(UIApplication *)application;
- (void)applicationWillTerminate:(UIApplication *)application;
-(BOOL)HasResourceData:(NSString *)resourcePath :(NSString *)name;
-(BOOL)HasExternalResourceData:(NSString *)resourcePath :(NSString *)name :(BOOL)intermediate;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) LuaForm *startForm;
@property (nonatomic, retain) IBOutlet UINavigationController *uiNavigationController;

@property (nonatomic) BOOL statusBarHidden;
@property (nonatomic) BOOL statusBarIsDark;
@property (nonatomic) BOOL onBackground;

@end
