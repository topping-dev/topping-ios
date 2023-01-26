#import "LuaResource.h"
#import "LuaFunction.h"
#import "LuaRef.h"
#import "LGValueParser.h"
#import "LGDrawableParser.h"
#import "Defines.h"

@implementation LuaResource

+(NSObject*)getResourceAssetSd:(NSString*) path :(NSString*) resName
{
	return GetResourceAssetSd(path, resName, nil);
}

+(NSObject*)getResourceSdAsset:(NSString*) path :(NSString*) resName
{
	return GetResourceSdAsset(path, resName, nil);
}

+(NSObject*)getResourceAsset:(NSString*) path :(NSString*) resName
{
	return GetResourceAsset(path, resName, nil);
}

+(NSObject*)getResourceSd:(NSString*) path :(NSString*) resName
{
	return GetResourceSd(path, resName, nil);
}

+(LuaStream *) getResource:(NSString *)path :(NSString *)resName
{
    NSBundle *bund = [NSBundle mainBundle];
#if TARGET_OS_MACCATALYST
    NSString *bundlePath = [bund resourcePath];
#else
    NSString *bundlePath = [bund bundlePath];
#endif
    NSString *truePath = [bundlePath stringByAppendingPathComponent:path];
	switch([sToppingEngine getPrimaryLoad])
	{
		case EXTERNAL_DATA:
		case INTERNAL_DATA:
		{
            NSData *data = GetResourceSdAsset(truePath, resName, nil);
            if(data == nil)
                return nil;
            LuaStream *ls = [[LuaStream alloc] init];
            [ls setStream:data];
			return ls;
		}break;
		case RESOURCE_DATA:
		default:
		{
            NSData *data = GetResourceAsset(truePath, resName, nil);
            if(data == nil)
                return nil;
            LuaStream *ls = [[LuaStream alloc] init];
            [ls setStream:data];
            return ls;
		}break;
	}
}

+(LuaStream *) getResourceRef:(LuaRef*)ref
{
    LuaStream *ls = [[LuaStream alloc] init];
    NSObject *obj = [[LGValueParser getInstance] getValue:ref.idRef];
    if([obj isKindOfClass:[LGDrawableReturn class]])
    {
        LGDrawableReturn *ldr = ((LGDrawableReturn*)obj);
        ls.nonStreamData = ldr.img;
    }
    return ls;
}

+(NSArray *)getResourceDirectories:(NSString *)startsWith
{
    NSMutableArray *lst = [NSMutableArray array];
    NSFileManager *fm = [NSFileManager defaultManager];
    switch ([sToppingEngine getPrimaryLoad])
    {
        case EXTERNAL_DATA:
        case INTERNAL_DATA:
        {
            //TODO:Fix me
            NSFileManager *fm = [NSFileManager defaultManager];
            NSString  *scriptPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/res/"];
        } break;
        case RESOURCE_DATA:
        {
            NSBundle *bund = [NSBundle mainBundle];
            NSString *uiRoot = [sToppingEngine getUIRoot];
#if TARGET_OS_MACCATALYST
            NSString *resBundlePath = [[bund resourcePath] stringByAppendingPathComponent:uiRoot];
#else
            NSString *resBundlePath = [[bund bundlePath] stringByAppendingPathComponent:uiRoot];
#endif
            NSArray *fileList = [fm directoryContentsAtPath:resBundlePath];
            for(NSString *file in fileList)
            {
                if(STARTS_WITH(file, startsWith))
                {
                    NSString *path = [resBundlePath stringByAppendingPathComponent:file];
                    BOOL isDir = NO;
                    [fm fileExistsAtPath:path isDirectory:(&isDir)];
                    if(isDir) {
                        [lst addObject:file];
                    }
                }
            }
        } break;
    }
    return lst;
    
}

+(NSArray *)getResourceFiles:(NSString *)path
{
    NSFileManager *fm = [NSFileManager defaultManager];
    switch ([sToppingEngine getPrimaryLoad])
    {
        case EXTERNAL_DATA:
        case INTERNAL_DATA:
        {
            //TODO:Fix me
            NSFileManager *fm = [NSFileManager defaultManager];
            NSString  *scriptPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/res/"];
            return nil;
        } break;
        case RESOURCE_DATA:
        default:
        {
            NSBundle *bund = [NSBundle mainBundle];
#if TARGET_OS_MACCATALYST
            NSString *bundlePath = [bund resourcePath];
#else
            NSString *bundlePath = [bund bundlePath];
#endif
            NSString *uiRoot = [sToppingEngine getUIRoot];
            NSString *resBundlePath = [bundlePath stringByAppendingPathComponent:uiRoot];
            NSString *folderPath = [resBundlePath stringByAppendingPathComponent:path];
            NSArray *files = [fm contentsOfDirectoryAtPath:folderPath error:nil];
            return files;
        } break;
    }
}

-(NSString*)GetId
{
	return @"LuaResource"; 
}

+ (NSString*)className
{
	return @"LuaResource";
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(getResourceAssetSd::)) 
										:@selector(getResourceAssetSd::) 
										:[NSObject class]
										:[NSArray arrayWithObjects:[NSString class], [NSString class], nil] 
										:[LuaResource class]] 
			 forKey:@"getResourceAssetSd"];
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(getResourceSdAsset::)) 
										:@selector(getResourceSdAsset::) 
										:[NSObject class]
										:[NSArray arrayWithObjects:[NSString class], [NSString class], nil] 
										:[LuaResource class]] 
			 forKey:@"getResourceSdAsset"];
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(getResourceAsset::)) 
										:@selector(getResourceAsset::) 
										:[NSObject class]
										:[NSArray arrayWithObjects:[NSString class], [NSString class], nil] 
										:[LuaResource class]] 
			 forKey:@"getResourceAsset"];
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(getResourceSd::)) 
										:@selector(getResourceSd::) 
										:[NSObject class]
										:[NSArray arrayWithObjects:[NSString class], [NSString class], nil] 
										:[LuaResource class]] 
			 forKey:@"getResourceSd"];
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(getResource::)) 
										:@selector(getResource::) 
										:[NSObject class]
										:[NSArray arrayWithObjects:[NSString class], [NSString class], nil] 
										:[LuaResource class]] 
			 forKey:@"getResource"];
    [dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(getResourceRef:))
                                        :@selector(getResourceRef:)
                                        :[NSObject class]
                                        :[NSArray arrayWithObjects:[LuaRef class], nil]
                                        :[LuaResource class]]
             forKey:@"getResourceRef"];

	return dict;
}

@end
