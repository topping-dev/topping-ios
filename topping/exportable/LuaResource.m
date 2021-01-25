#import "LuaResource.h"
#import "LuaFunction.h"
#import "LuaRef.h"
#import "LGValueParser.h"
#import "LGDrawableParser.h"
#import "Defines.h"

@implementation LuaResource

+(NSObject*)GetResourceAssetSd:(NSString*) path :(NSString*) resName
{
	return GetResourceAssetSd(path, resName, nil);
}

+(NSObject*)GetResourceSdAsset:(NSString*) path :(NSString*) resName
{
	return GetResourceSdAsset(path, resName, nil);
}

+(NSObject*)GetResourceAsset:(NSString*) path :(NSString*) resName
{
	return GetResourceAsset(path, resName, nil);
}

+(NSObject*)GetResourceSd:(NSString*) path :(NSString*) resName
{
	return GetResourceSd(path, resName, nil);
}

+(LuaStream *) GetResource:(NSString *)path :(NSString *)resName
{
    NSBundle *bund = [NSBundle mainBundle];
    NSString *bundlePath = [bund bundlePath];
    NSString *truePath = [bundlePath stringByAppendingPathComponent:path];
	switch([sToppingEngine GetPrimaryLoad])
	{
		case EXTERNAL_DATA:
		case INTERNAL_DATA:
		{
            NSData *data = GetResourceSdAsset(truePath, resName, nil);
            if(data == nil)
                return nil;
            LuaStream *ls = [[LuaStream alloc] init];
            [ls SetStream:data];
			return ls;
		}break;
		case RESOURCE_DATA:
		default:
		{
            NSData *data = GetResourceAsset(truePath, resName, nil);
            if(data == nil)
                return nil;
            LuaStream *ls = [[LuaStream alloc] init];
            [ls SetStream:data];
            return ls;
		}break;
	}
}

+(LuaStream *) GetResourceRef:(LuaRef*)ref
{
    LuaStream *ls = [[LuaStream alloc] init];
    NSObject *obj = [[LGValueParser GetInstance] GetValue:ref.idRef];
    if([obj isKindOfClass:[LGDrawableReturn class]])
    {
        LGDrawableReturn *ldr = ((LGDrawableReturn*)obj);
        ls.nonStreamData = ldr.img;
    }
    return ls;
}

+(NSArray *)GetResourceDirectories:(NSString *)startsWith
{
    NSMutableArray *lst = [NSMutableArray array];
    NSFileManager *fm = [NSFileManager defaultManager];
    switch ([sToppingEngine GetPrimaryLoad])
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
            NSString *bundlePath = [bund bundlePath];
            NSString *uiRoot = [sToppingEngine GetUIRoot];
            NSString *resBundlePath = [bundlePath stringByAppendingPathComponent:uiRoot];
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

+(NSArray *)GetResourceFiles:(NSString *)path
{
    NSFileManager *fm = [NSFileManager defaultManager];
    switch ([sToppingEngine GetPrimaryLoad])
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
            NSString *bundlePath = [bund bundlePath];
            NSString *uiRoot = [sToppingEngine GetUIRoot];
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
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(GetResourceAssetSd::)) 
										:@selector(GetResourceAssetSd::) 
										:[NSObject class]
										:[NSArray arrayWithObjects:[NSString class], [NSString class], nil] 
										:[LuaResource class]] 
			 forKey:@"GetResourceAssetSd"];
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(GetResourceSdAsset::)) 
										:@selector(GetResourceSdAsset::) 
										:[NSObject class]
										:[NSArray arrayWithObjects:[NSString class], [NSString class], nil] 
										:[LuaResource class]] 
			 forKey:@"GetResourceSdAsset"];
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(GetResourceAsset::)) 
										:@selector(GetResourceAsset::) 
										:[NSObject class]
										:[NSArray arrayWithObjects:[NSString class], [NSString class], nil] 
										:[LuaResource class]] 
			 forKey:@"GetResourceAsset"];
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(GetResourceSd::)) 
										:@selector(GetResourceSd::) 
										:[NSObject class]
										:[NSArray arrayWithObjects:[NSString class], [NSString class], nil] 
										:[LuaResource class]] 
			 forKey:@"GetResourceSd"];
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(GetResource::)) 
										:@selector(GetResource::) 
										:[NSObject class]
										:[NSArray arrayWithObjects:[NSString class], [NSString class], nil] 
										:[LuaResource class]] 
			 forKey:@"GetResource"];
    [dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(GetResourceRef:))
                                        :@selector(GetResourceRef:)
                                        :[NSObject class]
                                        :[NSArray arrayWithObjects:[LuaRef class], nil]
                                        :[LuaResource class]]
             forKey:@"GetResourceRef"];

	return dict;
}

@end
