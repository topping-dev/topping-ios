#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LuaInterface.h"
#import "LuaClass.h"
#import "LuaStream.h"
#import "LuaRef.h"

/**
 * Lua resource class.
 * This class is used to fetch resources from lua.
 */
@interface LuaResource : NSObject <LuaClass, LuaInterface>
{

}

/**
 * This function gets resource from package, if can not it gets from other data location.
 * @param path root path to search.
 * @param resName resource name to search
 * @return Data of resource
 */
+(NSObject*)GetResourceAssetSd:(NSString*) path :(NSString*) resName;
/**
 * This function gets resource from other data location, if can not it gets from package.
 * @param path root path to search.
 * @param resName resource name to search
 * @return Data of resource
 */
+(NSObject*)GetResourceSdAsset:(NSString*) path :(NSString*) resName;
/**
 * This function gets resource from package.
 * @param path root path to search.
 * @param resName resource name to search
 * @return Data of resource
 */
+(NSObject*)GetResourceAsset:(NSString*) path :(NSString*) resName;
/**
 * This function gets resource from other data location.
 * @param path root path to search.
 * @param resName resource name to search
 * @return Data of resource
 */
+(NSObject*)GetResourceSd:(NSString*) path :(NSString*) resName;

+(LuaStream*)GetResource:(NSString*) path :(NSString *)resName;
+(LuaStream*)GetResourceRef:(LuaRef*) ref;

+(NSArray*)GetResourceDirectories:(NSString*) startsWith;
+(NSArray*)GetResourceFiles:(NSString*) path;

@end
