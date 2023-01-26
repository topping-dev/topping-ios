#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LuaClass.h"
#import "LuaInterface.h"

@interface LuaLog : NSObject <LuaClass, LuaInterface>
{
}

+(void)v:(NSString *)tag :(NSString *)message;
+(void)d:(NSString *)tag :(NSString *)message;
+(void)i:(NSString *)tag :(NSString *)message;
+(void)w:(NSString *)tag :(NSString *)message;
+(void)e:(NSString *)tag :(NSString *)message;

@end
