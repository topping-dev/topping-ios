#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LuaInterface.h"
#import "LuaClass.h"
#import "LuaContext.h"

@interface LuaStore : NSObject<LuaClass, LuaInterface>
{

}

+(void)setString:(NSString*)key :(NSString*)value;
+(void)setNumber:(NSString*)key :(double)value;
+(NSObject*)get:(NSString *)key;
+(NSString*)getString:(NSString*)key;
+(double)getNumber:(NSString*)key;

@end
