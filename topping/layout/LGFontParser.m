#import "LGFontParser.h"
#import "LGParser.h"
#import "Defines.h"
#import "DisplayMetrics.h"
#import "LuaResource.h"
#import "GDataXMLNode.h"
#import <CoreText/CoreText.h>

@implementation LGFontData

@end

@implementation LGFontReturn

@end

@implementation LGFontParser

- (id) init
{
	self = [super init];
	if (self != nil) {
	}
	return self;
}

+(LGFontParser *) GetInstance
{
	return [LGParser GetInstance].pFont;
}

+(int)ParseTextStyle:(NSString *)textStyle
{
    NSArray *arr = SPLIT(textStyle, @"|");
    int flg = 0;
    for(NSString *sty in arr)
    {
        if([sty isEqualToString:@"normal"])
            flg |= FONT_STYLE_NORMAL;
        else if([sty isEqualToString:@"bold"])
            flg |= FONT_STYLE_BOLD;
        else if([sty isEqualToString:@"italic"])
            flg |= FONT_STYLE_ITALIC;
    }
    
    return flg;
}

-(void)Initialize
{
    NSArray *layoutDirectories = [LuaResource GetResourceDirectories:LUA_FONT_FOLDER];
    self.clearedDirectoryList = [[LGParser GetInstance] Tester:layoutDirectories :LUA_FONT_FOLDER];
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
    self.fontMap = [NSMutableDictionary dictionary];
    self.fontCacheMap = [NSMutableDictionary dictionary];
    for(DynamicResource *dr in self.clearedDirectoryList)
    {
        NSArray *files = [LuaResource GetResourceFiles:(NSString*)dr.data];
        [files enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *filename = (NSString *)obj;
            NSString *fNameNoExt = [filename stringByDeletingPathExtension];
            NSString *fNameExt = [filename pathExtension];
            if([fNameExt isEqualToString:@"xml"])
                [self.fontMap setObject:fNameNoExt forKey:fNameNoExt];
        }];
    }
}

-(LGFontReturn *) ParseXML:(NSString*)path :(NSString *)filename
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
    if([root kind] != GDataXMLElementKind)
        return nil;
    if(COMPARE([root name], @"font-family"))
    {
        return [self ParseFont:root];
    }
    
    return nil;
}

-(LGFontReturn*)ParseFont:(GDataXMLElement*)root
{
    NSArray *children = [root children];
    
    LGFontReturn *lfr = [LGFontReturn new];
    lfr.fontMap = [NSMutableDictionary dictionary];
       
    for(GDataXMLElement *child in children)
    {
        if([child kind] != GDataXMLElementKind)
            continue;
        if(![[child name] isEqualToString:@"font"])
            continue;
        
        LGFontData *lfd = [LGFontData new];
        lfd.fontStyle = FONT_STYLE_NORMAL;
        lfd.fontWeight = 400;
        
        NSArray *attrs = [child attributes];
        for(GDataXMLNode *node in attrs)
        {
            if(COMPARE([node name], @"android:font"))
            {
                LuaStream *stream = nil;
                for(DynamicResource *dr in self.clearedDirectoryList)
                {
                    NSArray *arr = SPLIT([node stringValue], @"/");
                    if(CONTAINS([arr objectAtIndex:0], @"font"))
                    {
                        if([arr count] > 1)
                        {
                            NSString *name = [arr objectAtIndex:1];
                            NSString *path = [[sToppingEngine GetUIRoot] stringByAppendingPathComponent:(NSString*)dr.data];
                            stream = [LuaResource GetResource:path :APPEND(name, @".ttf")];
                            if(stream == nil)
                            {
                                stream = [LuaResource GetResource:path :APPEND(name, @".ttc")];
                                if(stream == nil)
                                {
                                    stream = [LuaResource GetResource:path :APPEND(name, @".otf")];
                                }
                            }
                            if(stream != nil)
                            {
                                break;
                            }
                        }
                    }
                }
                
                if(stream == nil || ![stream HasStream])
                {
                    NSLog(@"Cannot read font file %@", [root name]);
                    continue;
                }
                
                NSData *inData = stream.data;
                CFErrorRef error;
                CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)inData);
                CGFontRef font = CGFontCreateWithDataProvider(provider);
                if (!CTFontManagerRegisterGraphicsFont(font, &error)) {
                    CFStringRef errorDescription = CFErrorCopyDescription(error);
                    NSLog(@"Failed to load font: %@", errorDescription);
                    CFRelease(errorDescription);
                }
                NSString *fontName = (__bridge NSString *)CGFontCopyPostScriptName(font);
                CFRelease(font);
                CFRelease(provider);
                
                lfd.fontName = fontName;
            }
            else if(COMPARE([node name], @"android:fontStyle"))
            {
                NSString *sty = [node stringValue];
                if([sty isEqualToString:@"italic"])
                    lfd.fontStyle = FONT_STYLE_ITALIC;
            }
            else if(COMPARE([node name], @"android:fontWeight"))
            {
                lfd.fontWeight = [[node stringValue] intValue];
            }
        }
        
        int mapFlag = FONT_STYLE_NORMAL;
        if(lfd.fontWeight > 500)
        {
            mapFlag = FONT_STYLE_BOLD;
        }
        if(lfd.fontStyle == FONT_STYLE_ITALIC)
            mapFlag |= FONT_STYLE_ITALIC;
        [lfr.fontMap setObject:lfd forKey:[NSNumber numberWithInt:mapFlag]];
    }
    
    return lfr;
}

-(LGFontReturn *)GetFont:(NSString *)key
{
    if(key == nil)
        return nil;
    
    NSArray *arr = SPLIT(key, @"/");
    LGFontReturn *retVal = nil;
    if(CONTAINS([arr objectAtIndex:0], @"font"))
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
    
    return retVal;
}

-(NSDictionary *)GetKeys
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for(NSString *key in self.fontMap)
    {
        [dict setObject:key forKey:key];
    }

    return dict;
}

@end
