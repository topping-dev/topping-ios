#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LuaInterface.h"
#import "LuaClass.h"
#import "LuaContext.h"

@interface LuaStore : NSObject<LuaClass, LuaInterface>
{

}

+(void)SetString:(NSString*)key :(NSString*)value;
+(void)SetNumber:(NSString*)key :(double)value;
+(NSObject*)Get:(NSString *)key;
+(NSString*)GetString:(NSString*)key;
+(double)GetNumber:(NSString*)key;

@end
