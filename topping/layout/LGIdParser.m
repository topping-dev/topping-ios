#import "LGIdParser.h"
#import "Defines.h"
#import "LGParser.h"
#import "DisplayMetrics.h"
#import "LuaResource.h"
#import "GDataXMLNode.h"
#import <topping/topping-Swift.h>

@implementation LGIdParser

@synthesize idMap;

- (id) init
{
    self = [super init];
    if (self != nil) {
    }
    return self;
}

-(void)initialize
{
    self.idMap = [NSMutableDictionary dictionary];
}

+(LGIdParser *) getInstance
{
    return [LGParser getInstance].pId;
}

-(void) parse:(NSString*)folder :(NSArray*)clearedDirectoryList {
    for(DynamicResource *dr in clearedDirectoryList)
    {
        NSArray *files = [LuaResource getResourceFiles:(NSString*)dr.data];
        for(NSString *file in files)
        {
            NSString *path = [[sToppingEngine getUIRoot] stringByAppendingPathComponent:folder];
            [self parseXML:path :file];
        }
    }
}

-(void) parseXML:(NSString*)path :(NSString *)filename
{
    NSData *dat = [[LuaResource getResource:path :filename] getData];
    GDataXMLDocument *xml = [[GDataXMLDocument alloc] initWithData:dat error:nil];
    if(xml == nil)
    {
        NSLog(@"Cannot read xml file %@", filename);
        return;
    }
    
    GDataXMLElement *root = [xml rootElement];
    [self ParseChildXML:root];
}

-(void) ParseChildXML:(GDataXMLElement*) element {

    if([element kind] != GDataXMLElementKind)
        return;
    
    for(GDataXMLNode *attr in [element attributes])
    {
        if(COMPARE(attr.name, @"android:id")
           || COMPARE(attr.name, @"lua:id"))
        {
            NSArray *arr = SPLIT(attr.stringValue, @"/");
            NSString *name = [arr objectAtIndex:[arr count] - 1];
            [self.idMap setObject:attr.stringValue forKey:name];
        }
    }
    
    for(GDataXMLElement *child in [element children])
    {
        [self ParseChildXML:child];
    }
}

-(NSDictionary *)getKeys {
    return self.idMap;
}

-(void)addKey:(NSString *)key :(NSString *)value
{
    [self.idMap setObject:value forKey:key];
}

-(BOOL)hasId:(NSString *)idVal
{
    NSArray *arr = SPLIT(idVal, @"/");
    NSString *name = [arr objectAtIndex:[arr count] - 1];
    
    return self.idMap[name] != nil;
}

-(NSString *)getId:(NSString *)idVal
{
    return REPLACE(idVal, @"+", @"");
}

@end
