#import "LGValueParser.h"
#import "LGParser.h"
#import "Defines.h"
#import "DisplayMetrics.h"
#import "LuaResource.h"
#import "GDataXMLNode.h"
#import "LGStyleParser.h"
#import "LGDimensionParser.h"

@implementation LGValueParser

- (id) init
{
	self = [super init];
	if (self != nil) {
	}
	return self;
}

-(void)Initialize
{
    NSArray *layoutDirectories = [LuaResource GetResourceDirectories:LUA_VALUES_FOLDER];
    self.clearedDirectoryList = [[LGParser GetInstance] Tester:layoutDirectories :LUA_VALUES_FOLDER];
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

+(LGValueParser *) GetInstance
{
	return [LGParser GetInstance].pValue;
}

-(void)ParseXML:(int)orientation :(GDataXMLElement *)element
{
    if(self.valueMap == nil)
    {
        self.valueMap = [[NSMutableDictionary alloc] init];
        self.valueKeyMap = [[NSMutableDictionary alloc] init];
    }
    
    GDataXMLNode *nameAttr;
    GDataXMLNode *typeAttr;
    GDataXMLNode *parentAttr;
    for(GDataXMLNode *attr in element.attributes)
    {
        if(COMPARE(attr.name, @"name"))
        {
            nameAttr = attr;
        }
        else if(COMPARE(attr.name, @"type"))
        {
            typeAttr = attr;
        }
        else if(COMPARE(attr.name, @"parent"))
        {
            parentAttr = attr;
        }
    }
    
    if(nameAttr != nil)
    {
        UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        
        NSMutableDictionary *valueDict = nil;
        if(UIInterfaceOrientationIsPortrait(interfaceOrientation))
            valueDict = [self.valueMap objectForKey:ORIENTATION_PORTRAIT_S];
        else
            valueDict = [self.valueMap objectForKey:ORIENTATION_LANDSCAPE_S];
        
        if(valueDict == nil)
            valueDict = [NSMutableDictionary dictionary];
        
        NSObject *val = [self getValue:element :typeAttr.stringValue :orientation :nameAttr.stringValue];
        if(val != nil)
        {
            [valueDict setObject:val forKey:nameAttr.stringValue];
                    
            if(UIInterfaceOrientationIsPortrait(interfaceOrientation))
                [self.valueMap setObject:valueDict forKey:ORIENTATION_PORTRAIT_S];
            else
                [self.valueMap setObject:valueDict forKey:ORIENTATION_LANDSCAPE_S];
        }
    }
}

-(NSObject*)getValue:(GDataXMLElement *)element
                    :(NSString *)type :(int)orientation :(NSString *)name
{
    if(type != nil && COMPARE(element.name, @"item"))
        return [self getValueIn:type :element :orientation :name];
    else
        return [self getValueIn:element.name :element :orientation :name];
}

-(NSObject*)getValueIn:(NSString *)type :(GDataXMLElement *)element :(int)orientation :(NSString*) name
{
    if(COMPARE(type, @"bool"))
    {
        if([self.valueKeyMap objectForKey:@"bool"] == nil)
            [self.valueKeyMap setObject:[NSMutableDictionary dictionary] forKey:@"bool"];
        [[self.valueKeyMap objectForKey:@"bool"] setObject:name forKey:name];
        return [NSNumber numberWithBool:SSTOB(element.stringValue)];
    }
    else if(COMPARE(type, @"integer"))
    {
        if([self.valueKeyMap objectForKey:@"integer"] == nil)
            [self.valueKeyMap setObject:[NSMutableDictionary dictionary] forKey:@"integer"];
        [[self.valueKeyMap objectForKey:@"integer"] setObject:name forKey:name];
        return [NSNumber numberWithInt:STOI(element.stringValue)];
    }
    else if(COMPARE(type, @"integer-array"))
    {
        NSMutableArray *arr = nil;
        if(element.childCount > 0)
        {
            arr = [NSMutableArray arrayWithCapacity:element.childCount];
            for(int i = 0; i < element.children.count; i++)
            {
                GDataXMLElement *child = [element.children objectAtIndex:i];
                [arr addObject:[NSNumber numberWithInt:STOI(child.stringValue)]];
            }
        }
        if(arr == nil)
            arr = [NSMutableArray array];
        
        if([self.valueKeyMap objectForKey:@"integer-array"] == nil)
            [self.valueKeyMap setObject:[NSMutableDictionary dictionary] forKey:@"integer-array"];
        [[self.valueKeyMap objectForKey:@"integer-array"] setObject:arr forKey:name];
        
        return arr;
    }
    else if(COMPARE(type, @"id"))
    {
        //TODO: Fix this
    }
    else if(COMPARE(type, @"array"))
    {
        NSMutableArray *arr = nil;
        if(element.childCount > 0)
        {
            arr = [NSMutableArray arrayWithCapacity:element.childCount];
            for(int i = 0; i < element.children.count; i++)
            {
                GDataXMLElement *child = [element.children objectAtIndex:i];
                [arr addObject:[self GetValue:child.stringValue]];
            }
        }
        if(arr == nil)
            arr = [NSMutableArray array];
        
        if([self.valueKeyMap objectForKey:@"array"] == nil)
            [self.valueKeyMap setObject:[NSMutableDictionary dictionary] forKey:@"array"];
        [[self.valueKeyMap objectForKey:@"array"] setObject:arr forKey:name];
        
        return arr;
    }
    
    return nil;
}

-(NSObject *)GetValueDirect:(NSString *)keyT
{
    if(keyT == nil)
        return nil;
    
    NSArray *arr = SPLIT(keyT, @"/");
    NSString *key = [arr objectAtIndex:arr.count - 1];
    
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    NSDictionary *dict = nil;
    if(UIInterfaceOrientationIsPortrait(interfaceOrientation))
        dict = [self.valueMap objectForKey:ORIENTATION_PORTRAIT_S];
    else
        dict = [self.valueMap objectForKey:ORIENTATION_LANDSCAPE_S];
    
    if(dict != nil)
    {
        NSObject *val = [dict objectForKey:key];
        if(val != nil)
            return val;
    }
    
    return key;
}

-(BOOL)GetBoolValueDirect:(NSString *)key
{
    @try {
        NSObject *obj = [self GetValueDirect:key];
        return [((NSNumber*)obj) boolValue];
    } @catch (NSException *exception) {
    }
    return false;
}

-(NSObject *)GetValue:(NSString *)key
{
    if(key == nil)
        return nil;
    
    if(COMPARE(key, @"@null"))
    {
        return [UIColor clearColor];
    }
    else if(STARTS_WITH(key, @"@string/") || 
            STARTS_WITH(key, @"@android:string/"))
    {
        return [[LGStringParser GetInstance] GetString:key];
    }
    else if(STARTS_WITH(key, @"@drawable/") ||
            STARTS_WITH(key, @"@android:drawable/"))
    {
        return [[LGDrawableParser GetInstance] ParseDrawable:key];
    }
    else if(STARTS_WITH(key, @"@color/") || STARTS_WITH(key, @"@android:color/") || STARTS_WITH(key, @"#"))
    {
        return [[LGColorParser GetInstance] ParseColor:key];
    }
    else if(STARTS_WITH(key, @"@style/"))
    {
        NSArray *arr = SPLIT(key, @"/");
        NSString *val = [arr objectAtIndex:arr.count - 1];
        return [[LGStyleParser GetInstance] GetStyle:val];
    }
    else
    {
        return [self GetValueDirect:key];
    }
    
    return key;
}

-(NSMutableDictionary *)GetAllKeys
{
    NSMutableDictionary *dictRet = [NSMutableDictionary dictionary];
    [dictRet setObject:[[LGDrawableParser GetInstance] GetKeys] forKey:@"drawable"];
    [dictRet setObject:[[LGStringParser GetInstance] GetKeys] forKey:@"string"];
    [dictRet setObject:[[LGColorParser GetInstance] GetKeys] forKey:@"color"];
    [dictRet setObject:[[LGLayoutParser GetInstance] GetKeys] forKey:@"layout"];
    [dictRet setObject:[[LGDimensionParser GetInstance] GetKeys] forKey:@"dimen"];
    [dictRet setObject:[[LGStyleParser GetInstance] GetKeys] forKey:@"style"];
    [dictRet setObject:[[LGIdParser GetInstance] GetKeys] forKey:@"id"];
    for(NSString *key in self.valueKeyMap)
    {
        [dictRet setObject:[self.valueKeyMap objectForKey:key] forKey:key];
    }
    
    return dictRet;
}


@end
