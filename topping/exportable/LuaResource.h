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
+(NSObject*)getResourceAssetSd:(NSString*) path :(NSString*) resName;
/**
 * This function gets resource from other data location, if can not it gets from package.
 * @param path root path to search.
 * @param resName resource name to search
 * @return Data of resource
 */
+(NSObject*)getResourceSdAsset:(NSString*) path :(NSString*) resName;
/**
 * This function gets resource from package.
 * @param path root path to search.
 * @param resName resource name to search
 * @return Data of resource
 */
+(NSObject*)getResourceAsset:(NSString*) path :(NSString*) resName;
/**
 * This function gets resource from other data location.
 * @param path root path to search.
 * @param resName resource name to search
 * @return Data of resource
 */
+(NSObject*)getResourceSd:(NSString*) path :(NSString*) resName;

+(LuaStream*)getResource:(NSString*) path :(NSString *)resName;
+(LuaStream*)getResourceRef:(LuaRef*) ref;

+(NSArray*)getResourceDirectories:(NSString*) startsWith;
+(NSArray*)getResourceFiles:(NSString*) path;

@end
