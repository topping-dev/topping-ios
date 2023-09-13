#import "LGXmlParser.h"
#import "LGParser.h"
#import "Defines.h"
#import "DisplayMetrics.h"
#import "LuaResource.h"
#import "GDataXMLNode.h"

@implementation LGXmlParser

- (id) init
{
	self = [super init];
	if (self != nil) {
	}
	return self;
}

-(void)initialize
{
    NSArray *layoutDirectories = [LuaResource getResourceDirectories:LUA_XML_FOLDER];
    self.clearedDirectoryList = [[LGParser getInstance] tester:layoutDirectories :LUA_XML_FOLDER];
    [self.clearedDirectoryList sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2)
     {
         NSString *aData = (NSString*)((DynamicResource*)obj1).data;
         NSString *bData = (NSString*)((DynamicResource*)obj2).data;
         if(COMPARE(aData, bData))
             return NSOrderedSame;
         else if(aData.length > bData.length)
             return NSOrderedAscending;
         else
             return NSOrderedDescending;
     }];
}

+(LGXmlParser *) getInstance
{
	return [LGParser getInstance].pXml;
}

-(NSString *)getXml:(NSString *)key
{
    if(key == nil)
        return nil;
    
    NSArray *arr = SPLIT(key, @"/");
    if(CONTAINS([arr objectAtIndex:0], @"xml"))
    {
        if([arr count] > 1)
        {
            NSString *name = [arr objectAtIndex:1];
            for(DynamicResource *dr in self.clearedDirectoryList)
            {
                if([name isEqualToString:key]) {
                    NSString *xmlBundlePath = [[sToppingEngine getUIRoot] stringByAppendingPathComponent:(NSString*)dr.data];
                    NSData *dat = [[LuaResource getResource:xmlBundlePath :APPEND(name, @".xml")] getData];
                    return [[NSString alloc] initWithData:dat encoding:NSUTF8StringEncoding];
                }
            }
        }
    }
    return nil;
}

@end
