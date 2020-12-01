#import "LGParser.h"
#import "LGDimensionParser.h"
#import "Defines.h"
#import "LuaResource.h"
#import "CommonDelegate.h"
#import <GDataXMLNode.h>

@implementation DynamicResource

@synthesize orientation, data;

@end

@implementation LGParser

- (id) init
{
	self = [super init];
	if (self != nil) {
		sLGParser = self;
	}
	return self;
}

+(LGParser*)GetInstance
{
	if(sLGParser == nil)
		[[LGParser alloc] init];
	return sLGParser;
}

-(void)Initialize
{
	self.pLayout = [[LGLayoutParser alloc] init];
	self.pDrawable = [[LGDrawableParser alloc] init];
	self.pDimen = [[LGDimensionParser alloc] init];
	self.pColor = [[LGColorParser alloc] init];
    self.pString = [[LGStringParser alloc] init];
    self.pValue = [[LGValueParser alloc] init];
    self.pStyle = [[LGStyleParser alloc] init];
    
    self.MatchStringStart = [NSMutableArray array];
    self.MatchStringEnd = [NSMutableArray array];
    
    NSMutableArray *lst = [NSMutableArray array];
    [lst addObject:@"ld"];
    [self.MatchStringStart addObject:lst];
    lst = [NSMutableArray array];
    [lst addObject:@"sw"];
    [self.MatchStringStart addObject:lst];
    lst = [NSMutableArray array];
    [lst addObject:@"w"];
    [self.MatchStringStart addObject:lst];
    lst = [NSMutableArray array];
    [lst addObject:@"h"];
    [self.MatchStringStart addObject:lst];
    lst = [NSMutableArray array];
    [lst addObject:@"small"];
    [lst addObject:@"normal"];
    [lst addObject:@"large"];
    [lst addObject:@"xlarge"];
    [self.MatchStringStart addObject:lst];
    lst = [NSMutableArray array];
    [lst addObject:@"port"];
    [lst addObject:@"land"];
    [self.MatchStringStart addObject:lst];
    lst = [NSMutableArray array];
    [lst addObject:@"ldpi"];
    [lst addObject:@"mdpi"];
    [lst addObject:@"hdpi"];
    [lst addObject:@"xhdpi"];
    [lst addObject:@"xxhdpi"];
    [lst addObject:@"xxxhdpi"];
    [lst addObject:@"nodpi"];
    [self.MatchStringStart addObject:lst];
    lst = [NSMutableArray array];
    [lst addObject:@"v"];
    [self.MatchStringStart addObject:lst];
    
    lst = [NSMutableArray array];
    [self.MatchStringEnd addObject:lst];
    lst = [NSMutableArray array];
    [lst addObject:@"dp"];
    [self.MatchStringEnd addObject:lst];
    lst = [NSMutableArray array];
    [lst addObject:@"dp"];
    [self.MatchStringEnd addObject:lst];
    lst = [NSMutableArray array];
    [lst addObject:@"dp"];
    [self.MatchStringEnd addObject:lst];
    lst = [NSMutableArray array];
    [self.MatchStringEnd addObject:lst];
    lst = [NSMutableArray array];
    [self.MatchStringEnd addObject:lst];
    lst = [NSMutableArray array];
    [self.MatchStringEnd addObject:lst];
    lst = [NSMutableArray array];
    
    [self.pDrawable Initialize];
    [self.pLayout Initialize];
    [self.pValue Initialize];
    [self ParseValues];
}

-(void)ParseValues
{
    NSArray *directoryList = [LuaResource GetResourceDirectories:LUA_VALUES_FOLDER];
    NSMutableArray *clearedDirectoryList = [self Tester:directoryList :LUA_VALUES_FOLDER];
    for(DynamicResource *dr in clearedDirectoryList)
    {
        NSArray *files = [LuaResource GetResourceFiles:(NSString*)dr.data];
        for(NSString *file in files)
        {
            NSString *path = [[sToppingEngine GetUIRoot] stringByAppendingPathComponent:LUA_VALUES_FOLDER];
            LuaStream *ls = [LuaResource GetResource:path :file];
            if([ls HasStream])
            {
                GDataXMLDocument *xml = [[GDataXMLDocument alloc] initWithData:[ls GetData] error:nil];
                if(xml == nil)
                {
                    NSLog(@"Cannot read xml file %@", file);
                    continue;
                }
                
                GDataXMLElement *root = [xml rootElement];
                if(COMPARE(root.name, @"resources"))
                {
                    for(GDataXMLElement *child in root.children)
                    {
                        NSString *childName = child.name;
                        if(COMPARE(childName, @"color"))
                        {
                            [self.pColor ParseXML:dr.orientation :child];
                        }
                        else if(COMPARE(childName, @"dimen"))
                        {
                            [self.pDimen ParseXML:dr.orientation :child];
                        }
                        else if(COMPARE(childName, @"string"))
                        {
                            [self.pString ParseXML:dr.orientation :child];
                        }
                        else if(COMPARE(childName, @"bool")
                                || COMPARE(childName, @"integer")
                                || COMPARE(childName, @"item")
                                || COMPARE(childName, @"integer-array")
                                || COMPARE(childName, @"array"))
                        {
                            [self.pValue ParseXML:dr.orientation :child];
                        }
                    }
                }
            }
        }
    }
    for(DynamicResource *dr in clearedDirectoryList)
    {
        NSArray *files = [LuaResource GetResourceFiles:(NSString*)dr.data];
        for(NSString *file in files)
        {
            NSString *path = [[sToppingEngine GetUIRoot] stringByAppendingPathComponent:LUA_VALUES_FOLDER];
            LuaStream *ls = [LuaResource GetResource:path :file];
            if([ls HasStream])
            {
                GDataXMLDocument *xml = [[GDataXMLDocument alloc] initWithData:[ls GetData] error:nil];
                if(xml == nil)
                {
                    NSLog(@"Cannot read xml file %@", file);
                    continue;
                }
                
                GDataXMLElement *root = [xml rootElement];
                if(COMPARE(root.name, @"resources"))
                {
                    for(GDataXMLElement *child in root.children)
                    {
                        NSString *childName = child.name;
                        if(COMPARE(childName, @"style"))
                        {
                            [self.pStyle ParseXML:dr.orientation :child];
                        }
                    }
                }
            }
        }
        [self.pStyle LinkParents];
    }
}

-(NSMutableArray *)Tester:(NSArray*)directoryList :(NSString*)directoryType
{
    NSMutableArray *clearedDirectoryList = [NSMutableArray array];
    for(NSString *dirName in directoryList)
    {
        if(COMPARE(dirName, directoryType))
        {
            DynamicResource *dr = [[DynamicResource alloc] init];
            dr.orientation = ORIENTATION_PORTRAIT | ORIENTATION_LANDSCAPE;
            dr.data = dirName;
            [clearedDirectoryList addObject:dr];
        }
        else
        {
            NSArray *dirResourceTypes = SPLIT(dirName, @"-");
            MATCH_ID count = (MATCH_ID)0;
            BOOL result = NO;
            int orientation = ORIENTATION_PORTRAIT | ORIENTATION_LANDSCAPE;
            for(NSString *toMatch in dirResourceTypes)
            {
                if(COMPARE(toMatch, directoryType))
                    continue;
                result = NO;
                count = [self Matcher:count: toMatch: &result];
                if(!result)
                {
                    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
                    NSString *replaced = REPLACE(language, @"-", @"-r");
                    NSArray *langSplit = SPLIT(language, @"-");
                    if(COMPARE(toMatch, [langSplit objectAtIndex:0])
                       || CONTAINS(dirName, replaced))
                    {
                        result = YES;
                        count = MATCH_ID_LANGUAGE;
                    }
                }
                else
                {
                    switch(count)
                    {
                        case MATCH_ID_LAYOUT_DIRECTION:
                        {
                            
                        }break;
                        case MATCH_ID_SMALLEST_WIDTH:
                        {
                            CGRect screenRect = [[UIScreen mainScreen] bounds];
                            CGFloat width = screenRect.size.width;
                            CGFloat height = screenRect.size.height;
                            CGFloat sw = width;
                            if(height < width)
                                sw = height;
                            NSString *swWidthS = SUBSTRING(toMatch, 2, toMatch.length - 2);
                            CGFloat swWidth = [swWidthS floatValue];
                            if(sw > swWidth)
                                result = YES;
                        }break;
                        case MATCH_ID_AVAILABLE_WIDTH:
                        {
                            CGRect screenRect = [[UIScreen mainScreen] bounds];
                            CGFloat sw = screenRect.size.width;
                            NSString *swWidthS = SUBSTRING(toMatch, 1, toMatch.length - 2);
                            CGFloat swWidth = [swWidthS floatValue];
                            if(sw > swWidth)
                                result = YES;
                        }break;
                        case MATCH_ID_AVAILABLE_HEIGHT:
                        {
                            CGRect screenRect = [[UIScreen mainScreen] bounds];
                            CGFloat sw = screenRect.size.height;
                            NSString *swWidthS = SUBSTRING(toMatch, 1, toMatch.length - 2);
                            CGFloat swWidth = [swWidthS floatValue];
                            if(sw > swWidth)
                                result = YES;
                        }break;
                        case MATCH_ID_SCREEN_SIZE:
                        {
                            /*CGRect screenBounds = [[UIScreen mainScreen] bounds];
                            if(screenBounds.size.width < 320 && screenBounds.size.height < 426 && COMPARE(toMatch, @"small"))
                                result = true;
                            if(screenBounds.size.width >= 320 && screenBounds.size.height <= 470 && COMPARE(toMatch, @"normal"))
                                result = true;
                                
                            320x426
                            320x470
                            480x640
                            720x960
                            float scale = [[UIScreen mainScreen] scale];
                            if(scale == 1 && COMPARE(toMatch, @"normal"))
                                result = true;
                            else if(scale == 2 && COMPARE(toMatch, @"large"))
                                result = true;*/
                            //TODO:Needs work
                        }break;
                        case MATCH_ID_SCREEN_ORIENTATION:
                        {
                            if(COMPARE(toMatch, @"port"))
                                orientation = ORIENTATION_PORTRAIT;
                            else
                                orientation = ORIENTATION_LANDSCAPE;
                            result = true;
                        }break;
                        case MATCH_ID_SCREEN_PIXEL_DENSITY:
                        {
                            float scale = [[UIScreen mainScreen] scale];
                            if(scale == 1 && COMPARE(toMatch, @"mdpi"))
                                result = true;
                            else if(scale == 2 && COMPARE(toMatch, @"xhdpi"))
                                result = true;
                            else if(scale == 3 && COMPARE(toMatch, @"xxhdpi"))
                                result = true;
                            if(COMPARE(toMatch, @"nodpi"))
                                result = true;
                        }break;
                        case MATCH_ID_VERSION:
                        {
                            NSString *versionS = SUBSTRING(toMatch, 1, toMatch.length);
                            int version = [versionS intValue];
                            
                            int tempVer = 0;
                            if(SYSTEM_VERSION_LESS_THAN(@"5.0"))
                                tempVer = 9;
                            else if(SYSTEM_VERSION_LESS_THAN(@"6.0"))
                                tempVer = 10;
                            else
                                tempVer = 11;
                            if(tempVer >= version)
                                true;
                        }break;
                    }
                    if(result)
                    {
                        DynamicResource *dr = [[DynamicResource alloc] init];
                        dr.orientation = orientation;
                        dr.data = dirName;
                        [clearedDirectoryList addObject:dr];
                    }
                }
            }
        }
    }
    return clearedDirectoryList;
}

-(MATCH_ID) Matcher:(MATCH_ID)count :(NSString*)toMatch :(BOOL *) result
{
    BOOL found = NO;
    int lastCount = 0;
    for (int i = (int)count; i < self.MatchStringStart.count; i++)
    {
        lastCount = i;
        NSMutableArray *matchList = [self.MatchStringStart objectAtIndex:i];
        for(int j = 0; j < matchList.count; j++)
        {
            NSString *s = [matchList objectAtIndex:j];
            if (STARTS_WITH(toMatch, s))
            {
                NSMutableArray *matchListEnd = [self.MatchStringEnd objectAtIndex:i];
                if (matchListEnd.count == 0)
                {
                    found = true;
                    break;
                }
                else
                {
                    NSString *es = [matchListEnd objectAtIndex:j];
                    if (ENDS_WITH(toMatch, es))
                    {
                        found = true;
                        break;
                    }
                }
            }
        }
        if (found)
            break;
    }
    *result = found;
    return (MATCH_ID)lastCount;
}

@end
