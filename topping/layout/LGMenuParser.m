#import "LGMenuParser.h"
#import "LGParser.h"
#import "Defines.h"
#import "DisplayMetrics.h"
#import "LuaResource.h"
#import "GDataXMLNode.h"

@implementation LGMenuParser

- (id) init
{
	self = [super init];
	if (self != nil) {
	}
	return self;
}

-(void)Initialize
{
    NSArray *layoutDirectories = [LuaResource GetResourceDirectories:LUA_MENU_FOLDER];
    self.clearedDirectoryList = [[LGParser GetInstance] Tester:layoutDirectories :LUA_MENU_FOLDER];
    [self.clearedDirectoryList sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2)
     {
         NSString *aData = ((DynamicResource*)obj1).data;
         NSString *bData = ((DynamicResource*)obj2).data;
         if(COMPARE(aData, bData))
             return NSOrderedSame;
         else if(aData.length > bData.length)
             return NSOrderedAscending;
         else
             return NSOrderedDescending;
     }];
}

+(LGMenuParser *) GetInstance
{
	return [LGParser GetInstance].pMenu;
}

-(NSMutableArray *) ParseXML:(NSString*)path :(NSString *)filename
{
    NSString *fontBundlePath = [[sToppingEngine GetUIRoot] stringByAppendingPathComponent:path];
    NSData *dat = [[LuaResource GetResource:fontBundlePath :filename] GetData];
    GDataXMLDocument *xml = [[GDataXMLDocument alloc] initWithData:dat error:nil];
    if(xml == nil)
    {
        NSLog(@"Cannot read xml file %@", filename);
        return nil;
    }
    
    GDataXMLElement *root = [xml rootElement];
    if(COMPARE([root name], @"menu"))
    {
        return [self ParseMenu:root];
    }
    
    return nil;
}

-(NSMutableArray *)GetMenu:(NSString *)key
{
    if(key == nil)
        return nil;
    if(self.menuCache == nil) {
        self.menuCache = [NSMutableDictionary dictionary];
    }
    
    NSArray *arr = SPLIT(key, @"/");
    NSMutableArray *retVal = [self.menuCache objectForKey:key];
    if(retVal != nil)
        return retVal;
    if(CONTAINS([arr objectAtIndex:0], @"menu"))
    {
        if([arr count] > 1)
        {
            NSString *name = [arr objectAtIndex:1];
            for(DynamicResource *dr in self.clearedDirectoryList)
            {
                retVal = [self ParseXML:(NSString*)dr.data :APPEND(name, @".xml")];
                if(retVal != nil)
                {
                    break;
                }
            }
        }
    }
    [self.menuCache setObject:retVal forKey:key];
    return retVal;
}

-(NSMutableArray*)ParseMenu:(GDataXMLElement*)root
{
    NSArray *children = [root children];
    
    NSMutableArray *menuArr = [NSMutableArray array];
       
    for(GDataXMLElement *child in children)
    {
        if(![[child name] isEqualToString:@"item"])
            continue;
        
        LuaMenu *item = [LuaMenu new];

        NSArray *attrs = [child attributes];
        for(GDataXMLNode *node in attrs)
        {
            if(COMPARE([node name], @"android:id"))
            {
                item.idVal = REPLACE([node stringValue], @"+", @"");
            }
            else if(COMPARE([node name], @"android:title"))
            {
                item.title = [[LGStringParser GetInstance] GetString:[node stringValue]];
            }
            else if(COMPARE([node name], @"android:icon"))
            {
                item.iconRes = [LuaRef WithValue:[node stringValue]];
            }
        }
        
        [menuArr addObject:item];
    }
    
    return menuArr;
}


@end
