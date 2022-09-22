#import <Foundation/Foundation.h>
#import "LuaClass.h"
#import "LuaInterface.h"
#import "LuaContext.h"

NS_ASSUME_NONNULL_BEGIN

@interface LuaRef : NSObject <LuaClass, LuaInterface>
{
    
}

+(void)ResourceLoader;
+(LuaRef*)WithValue:(NSString*)val;
+(LuaRef*)GetRef:(LuaContext*)lc :(NSString *)ids;
-(NSString*)GetCleanId;

@property (nonatomic, strong) NSString *idRef;

@end

NS_ASSUME_NONNULL_END
