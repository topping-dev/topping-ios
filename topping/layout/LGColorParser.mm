#import "LGColorParser.h"
#import "Defines.h"
#import "GDataXMLNode.h"
#import "LGParser.h"
#import "LuaResource.h"
#import <math.h>

@implementation LGColorState

-(int)getUIControlStateFlag {
    int flag = 0;
    if(self.state_focused)
        flag |= UIControlStateHighlighted;
    if(!self.state_enabled)
        flag |= UIControlStateDisabled;
    if(self.state_selected || self.state_pressed || self.state_checked)
        flag |= UIControlStateSelected;
    return flag;
}

-(UIColor*)getColorForState:(int)state :(UIColor*)defColor {
    if(state == UIControlStateNormal) {
        return self.color;
    }
    else if(state == UIControlStateSelected && (self.state_selected || self.state_pressed || self.state_checked)) {
        return self.color;
    } else if(state == UIControlStateDisabled && !self.state_enabled) {
        return self.color;
    }
    return defColor;
}

@end

@implementation LGColorParser

@synthesize colorMap;

+(LGColorParser *) getInstance
{
	return [LGParser getInstance].pColor;
}

-(void)initialize
{
    NSArray *colorDirectories = [LuaResource getResourceDirectories:LUA_COLOR_FOLDER];
    self.clearedDirectoryList = [[LGParser getInstance] tester:colorDirectories :LUA_COLOR_FOLDER];
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
    if(self.colorMap == nil)
    {
        self.colorMap = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *transparent = [NSMutableDictionary dictionary];
        [transparent setObject:[UIColor clearColor] forKey:ORIENTATION_PORTRAIT_S];
        [transparent setObject:[UIColor clearColor] forKey:ORIENTATION_LANDSCAPE_S];
        [self.colorMap setObject:transparent forKey:@"transparent"];
    }
    self.colorFileCacheMap = [NSMutableDictionary dictionary];
    for(DynamicResource *dr in self.clearedDirectoryList)
    {
        NSArray *files = [LuaResource getResourceFiles:(NSString*)dr.data];
        [files enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *filename = (NSString *)obj;
            NSString *fNameNoExt = [filename stringByDeletingPathExtension];
            NSString *fNameExt = [filename pathExtension];
            if([fNameExt isEqualToString:@"xml"])
                [self.colorFileMap setObject:fNameNoExt forKey:fNameNoExt];
        }];
    }
}

-(void) parseXML:(NSString *)filename;
{
	NSFileManager *fm = [NSFileManager defaultManager];	
	NSString  *scriptPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Scripts/"];
	NSBundle *bund = [NSBundle mainBundle];
	if(![fm fileExistsAtPath:scriptPath])
	{
		[fm createDirectoryAtPath:scriptPath attributes:nil];
		return;
	}
	
	NSString *pathToRead = [scriptPath stringByAppendingPathComponent:filename];
	NSFileHandle *f = [NSFileHandle fileHandleForReadingAtPath:pathToRead];
	NSData *dat = [f readDataToEndOfFile];
	GDataXMLDocument *xml = [[GDataXMLDocument alloc] initWithData:dat error:nil];
	if(xml == nil)
		return;
	
	GDataXMLElement *root = [xml rootElement];
    
    if([root kind] != GDataXMLElementKind)
        return;
	
	for(GDataXMLElement *child in [root children])
	{
		NSArray *attrs = [child attributes];
		for(GDataXMLNode *node in attrs)
		{
			[self.colorMap setObject:[self parseColorInternal:[child stringValue]] forKey:[node stringValue]];
		}
	}
}

-(void)parseXML:(int)orientation :(GDataXMLElement *)element
{    
    if([element kind] != GDataXMLElementKind)
        return;
    
    for(GDataXMLNode *attr in element.attributes)
    {
        if(COMPARE(attr.name, @"name"))
        {
            NSMutableDictionary *oldValue = [self.colorMap objectForKey:attr.stringValue];
            NSMutableDictionary *valueDict = [NSMutableDictionary dictionary];
            if(orientation & ORIENTATION_PORTRAIT)
                [valueDict setObject:[self parseColor:element.stringValue] forKey:ORIENTATION_PORTRAIT_S];
            else
            {
                id val;
                if(oldValue != nil && ((val = [oldValue objectForKey:ORIENTATION_PORTRAIT_S]) != nil))
                    [valueDict setObject:val forKey:ORIENTATION_PORTRAIT_S];
            }
            
            if(orientation & ORIENTATION_LANDSCAPE)
                [valueDict setObject:[self parseColor:element.stringValue] forKey:ORIENTATION_LANDSCAPE_S];
            else
            {
                id val;
                if(oldValue != nil && ((val = [oldValue objectForKey:ORIENTATION_LANDSCAPE_S]) != nil))
                    [valueDict setObject:val forKey:ORIENTATION_LANDSCAPE_S];
            }
            
            [self.colorMap setObject:valueDict forKey:attr.stringValue];
            break;
        }
    }
}

-(UIColor *) parseColor:(NSString *)color
{
    return [self parseColor:color :0 :[UIColor blackColor]];
}

-(UIColor *) parseColor:(NSString *)color :(int)state :(UIColor*)defColor
{
	UIColor *retVal = nil;
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if(CONTAINS(color, @"color/"))
    {
        NSArray *arr = SPLIT(color, @"/");
        NSString *file = [arr objectAtIndex:arr.count - 1];
        NSMutableDictionary *val = [self.colorMap objectForKey:file];
        if(val != nil)
        {
            if(UIInterfaceOrientationIsPortrait(interfaceOrientation))
                retVal = [val objectForKey:ORIENTATION_PORTRAIT_S];
            else
                retVal = [val objectForKey:ORIENTATION_LANDSCAPE_S];
        }
        else {
            LGColorState *lcs = [self getColorState:file];
            if(lcs != nil) {
                retVal = [lcs getColorForState:state :defColor];
            }
        }
    }
	if(retVal == nil && STARTS_WITH(color, @"#"))
		retVal = [self parseColorInternal:color];
	return retVal;
}

-(UIColor *) parseColorInternal:(NSString *)color
{
	uint aI = 255;
	uint rI = 0;
	uint gI = 0;
	uint bI = 0;
	if([color length] == 7)
	{
		NSScanner *scan = [NSScanner scannerWithString:SUBSTRING_L(color, 1, 2)];
		[scan scanHexInt:&rI];
		scan = [NSScanner scannerWithString:SUBSTRING_L(color, 3, 2)];
		[scan scanHexInt:&gI];
		scan = [NSScanner scannerWithString:SUBSTRING_L(color, 5, 2)];
		[scan scanHexInt:&bI];
	}
	else if([color length] == 9)
	{
		NSScanner *scan = [NSScanner scannerWithString:SUBSTRING_L(color, 1, 2)];
		[scan scanHexInt:&aI];
		scan = [NSScanner scannerWithString:SUBSTRING_L(color, 3, 2)];
		[scan scanHexInt:&rI];
		scan = [NSScanner scannerWithString:SUBSTRING_L(color, 5, 2)];
		[scan scanHexInt:&gI];
		scan = [NSScanner scannerWithString:SUBSTRING_L(color, 7, 2)];
		[scan scanHexInt:&bI];		
	}
	return [UIColor colorWithRed:rI/255.0f green:gI/255.0f blue:bI/255.0f alpha:aI/255.0f];
}

-(LGColorState*)getColorState:(NSString*)ref {
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    NSString *orient = ORIENTATION_LANDSCAPE_S;
    int orientI = ORIENTATION_LANDSCAPE;
    if(UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
        orient = ORIENTATION_PORTRAIT_S;
        orientI = ORIENTATION_PORTRAIT;
    }
    NSMutableDictionary *dict = [self.colorFileCacheMap objectForKey:ref];
    LGColorState *lcs = nil;
    if(dict != nil)
        lcs = [dict objectForKey:orient];
    if(lcs != nil) {
        return lcs;
    }
    else {
        NSString *file = ref;
        if(CONTAINS(ref, @"color/"))
        {
            NSArray *arr = SPLIT(ref, @"/");
            file = [arr objectAtIndex:arr.count - 1];
        }
        for(DynamicResource *dr in self.clearedDirectoryList)
        {
            if(dr.orientation & orientI) {
                lcs = [self parseColorStateXML:(NSString*)dr.data :APPEND(file, @".xml")];
                if(lcs != nil) {
                    if(dict == nil)
                        dict = [NSMutableDictionary dictionary];
                    [dict setObject:lcs forKey:orient];
                    [self.colorFileCacheMap setObject:dict forKey:file];
                    return lcs;
                }
            }
        }
    }
    return nil;
}

-(UIColor *)getTextColorFromColor:(UIColor *)color {
    CGFloat r, g, b, a;
    BOOL success = [color getRed:&r green:&g blue:&b alpha:&a];
    if(success) {
        r = r * 255;
        g = g * 255;
        b = b * 255;
        float brightness = round(((r * 299) +
                              (g * 587) +
                              (b * 114)) / 1000);
        if(brightness > 125)
            return UIColor.blackColor;
        else
            return UIColor.whiteColor;
    }
    return UIColor.whiteColor;
}

-(LGColorState *) parseColorStateXML:(NSString*)path :(NSString *)filename
{
    NSString *fontBundlePath = [[sToppingEngine getUIRoot] stringByAppendingPathComponent:path];
    NSData *dat = [[LuaResource getResource:fontBundlePath :filename] getData];
    GDataXMLDocument *xml = [[GDataXMLDocument alloc] initWithData:dat error:nil];
    if(xml == nil)
    {
        NSLog(@"Cannot read xml file %@", filename);
        return nil;
    }
    
    GDataXMLElement *root = [xml rootElement];
    if([root kind] != GDataXMLElementKind)
        return nil;
    if(COMPARE([root name], @"selector"))
    {
        return [self parseColorState:root];
    }
    
    return nil;
}

-(LGColorState*)parseColorState:(GDataXMLElement*)root
{
    NSArray *children = [root children];
    
    LGColorState *lcs = [LGColorState new];
       
    for(GDataXMLElement *child in children)
    {
        if([child kind] != GDataXMLElementKind)
            continue;
        if(![[child name] isEqualToString:@"item"])
            continue;
        
        NSArray *attrs = [child attributes];
        for(GDataXMLNode *node in attrs)
        {
            if(COMPARE([node name], @"android:color"))
            {
                lcs.color = [self parseColor:[node stringValue]];
            }
            else if(COMPARE([node name], @"android:lStar"))
            {
                lcs.lStar = STOF([node stringValue]);
            }
            else if(COMPARE([node name], @"android:state_pressed"))
            {
                lcs.state_pressed = SSTOB([node stringValue]);
            }
            else if(COMPARE([node name], @"android:state_focused"))
            {
                lcs.state_focused = SSTOB([node stringValue]);
            }
            else if(COMPARE([node name], @"android:state_selected"))
            {
                lcs.state_selected = SSTOB([node stringValue]);
            }
            else if(COMPARE([node name], @"android:state_checkable"))
            {
                lcs.state_checkable = SSTOB([node stringValue]);
            }
            else if(COMPARE([node name], @"android:state_checked"))
            {
                lcs.state_checked = SSTOB([node stringValue]);
            }
            else if(COMPARE([node name], @"android:state_enabled"))
            {
                lcs.state_enabled = SSTOB([node stringValue]);
            }
            else if(COMPARE([node name], @"android:state_window_focused"))
            {
                lcs.state_window_focused = SSTOB([node stringValue]);
            }
        }
    }
    
    return lcs;
}

-(NSDictionary *)getKeys
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for(NSString *key in self.colorMap)
    {
        [dict setObject:key forKey:key];
    }

    return dict;
}

@end
