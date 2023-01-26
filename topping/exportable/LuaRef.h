#import <Foundation/Foundation.h>
#import "LuaClass.h"
#import "LuaInterface.h"
#import "LuaContext.h"

@interface LuaRef : NSObject <LuaClass, LuaInterface>
{
    
}

+(void)resourceLoader;
+(LuaRef*)withValue:(NSString*)val;
+(LuaRef*)getRef:(LuaContext*)lc :(NSString *)ids;
-(NSString*)getCleanId;

@property (nonatomic, strong) NSString *idRef;

@end
