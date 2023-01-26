#import "CDefines.h"
#import "Defines.h"
#import "ToppingEngine.h"

FILE *GetResourceAssetSdF(const char *filename, const char *mode)
{
	NSString *scriptsRoot = [sToppingEngine getScriptsRoot];
	NSString *name = [NSString stringWithCString:filename encoding:NSUTF8StringEncoding];
	NSArray *arr = SPLIT(name, @"/");
	name = [arr objectAtIndex:[arr count] - 1];
	arr = SPLIT(name, @".");
	if([arr count] < 2)
		return nil;
	NSString* resourcePath = [[NSBundle mainBundle] pathForResource:[arr objectAtIndex:0] ofType:[arr objectAtIndex:1]];
	if(resourcePath != nil)
		return fopen([resourcePath cStringUsingEncoding:NSUTF8StringEncoding], mode);
	else 
	{
		NSString *basePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/"];
		NSString *resourcePathDirectory = [basePath stringByAppendingPathComponent:scriptsRoot];
		NSFileManager *fileManager = [NSFileManager defaultManager];
		if(![fileManager fileExistsAtPath:resourcePathDirectory])
			[fileManager createDirectoryAtPath:resourcePathDirectory withIntermediateDirectories:YES attributes:nil error:nil];
		NSString *resourceFile = [resourcePathDirectory stringByAppendingPathComponent:name];
		if([fileManager fileExistsAtPath:resourceFile])
			return fopen([resourceFile cStringUsingEncoding:NSUTF8StringEncoding], mode);
	}
	
	return NULL;
}

FILE *GetResourceSdAssetF(const char *filename, const char *mode)
{
	NSString *scriptsRoot = [sToppingEngine getScriptsRoot];
	NSString *name = [NSString stringWithCString:filename encoding:NSUTF8StringEncoding];
	NSString *basePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/"];
	NSString *resourcePathDirectory = [basePath stringByAppendingPathComponent:scriptsRoot];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if(![fileManager fileExistsAtPath:resourcePathDirectory])
		[fileManager createDirectoryAtPath:resourcePathDirectory withIntermediateDirectories:YES attributes:nil error:nil];
	NSString *resourceFile = [resourcePathDirectory stringByAppendingPathComponent:name];
	if([fileManager fileExistsAtPath:resourceFile])
		return fopen([resourceFile cStringUsingEncoding:NSUTF8StringEncoding], mode);
	else 
	{
		NSArray *arr = SPLIT(name, @"/");
		name = [arr objectAtIndex:[arr count] - 1];
		arr = SPLIT(name, @".");
		if([arr count] < 2)
			return NULL;
		NSString* resourcePath = [[NSBundle mainBundle] pathForResource:[arr objectAtIndex:0] ofType:[arr objectAtIndex:1]];
		if(resourcePath != nil)
			return fopen([resourcePath cStringUsingEncoding:NSUTF8StringEncoding], mode);
	}
	
	return NULL;
}

FILE *GetResourceAssetF(const char *filename, const char *mode)
{
	NSString *name = [NSString stringWithCString:filename encoding:NSUTF8StringEncoding];
	NSArray *arr = SPLIT(name, @"/");
	name = [arr objectAtIndex:[arr count] - 1];
	arr = SPLIT(name, @".");
	if([arr count] < 2)
		return NULL;
	NSString* resourcePath = [[NSBundle mainBundle] pathForResource:[arr objectAtIndex:0] ofType:[arr objectAtIndex:1]];
    if(resourcePath == nil) {
        NSString *scriptPath = [sToppingEngine getScriptsRoot];
        if(scriptPath == nil)
            scriptPath = @"scripts";
        resourcePath = [[NSBundle mainBundle] pathForResource:[arr objectAtIndex:0] ofType:[arr objectAtIndex:1] inDirectory:scriptPath];
    }
	if(resourcePath != nil)
		return fopen([resourcePath cStringUsingEncoding:NSUTF8StringEncoding], "r");
	
	return NULL;
}

FILE *lua_ifopen(const char *filename, const char *mode)
{
	FILE *f = NULL;
	switch([sToppingEngine getPrimaryLoad])
	{
		case EXTERNAL_DATA:
		case INTERNAL_DATA:
		{
			f = GetResourceSdAssetF(filename, mode);
		}break;
		case RESOURCE_DATA:
		default:
		{
			f = GetResourceAssetF(filename, mode);
		}break;
	}
	return f;
}
