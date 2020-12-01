#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LuaClass.h"
#import "LuaInterface.h"

@interface LuaLog : NSObject <LuaClass, LuaInterface>
{
}

+(void)V:(NSString *)tag :(NSString *)message;
+(void)D:(NSString *)tag :(NSString *)message;
+(void)I:(NSString *)tag :(NSString *)message;
+(void)W:(NSString *)tag :(NSString *)message;
+(void)E:(NSString *)tag :(NSString *)message;

@end
