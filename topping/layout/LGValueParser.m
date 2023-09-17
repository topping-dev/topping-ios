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

-(void)initialize
{
    NSArray *layoutDirectories = [LuaResource getResourceDirectories:LUA_VALUES_FOLDER];
    self.clearedDirectoryList = [[LGParser getInstance] tester:layoutDirectories :LUA_VALUES_FOLDER];
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
    
    {
        NSBundle *bund = [NSBundle bundleWithIdentifier:@"dev.topping.ios"];
        NSString *themePath = [bund pathForResource:@"constraintlayoutValues" ofType:@"xml"];
        NSData *resourceData = [NSData dataWithContentsOfFile:themePath];
        
        GDataXMLDocument *xml = [[GDataXMLDocument alloc] initWithData:resourceData error:nil];
        
        GDataXMLElement *root = [xml rootElement];
        
        
        if(COMPARE(root.name, @"resources"))
        {
            for(GDataXMLElement *child in root.children)
            {
                [self parseXML:ORIENTATION_PORTRAIT :child];
                [self parseXML:ORIENTATION_LANDSCAPE :child];
            }
        }
    }
}

+(LGValueParser *) getInstance
{
	return [LGParser getInstance].pValue;
}

-(void)parseXML:(int)orientation :(GDataXMLElement *)element
{
    if(self.valueMap == nil)
    {
        self.valueMap = [[NSMutableDictionary alloc] init];
        self.valueKeyMap = [[NSMutableDictionary alloc] init];
    }
    
    GDataXMLNode *nameAttr;
    GDataXMLNode *typeAttr;
    GDataXMLNode *parentAttr;
    GDataXMLNode *formatAttr;
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
        else if(COMPARE(attr.name, @"format"))
        {
            formatAttr = attr;
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
        
        NSString *type = typeAttr.stringValue;
        if(formatAttr != nil) {
            if(CONTAINS(formatAttr.stringValue, @"enum")) {
                type = formatAttr.stringValue;
            } else {
                return;
            }
        }
        
        NSObject *val = [self getValue:element :type :orientation :nameAttr.stringValue];
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
    if(type != nil && (COMPARE(element.name, @"item") || CONTAINS(type, @"enum")))
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
        NSString *value = APPEND(@"id/", name);
        [[LGIdParser getInstance] addKey:name :value];
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
                [arr addObject:[self getValue:child.stringValue]];
            }
        }
        if(arr == nil)
            arr = [NSMutableArray array];
        
        if([self.valueKeyMap objectForKey:@"array"] == nil)
            [self.valueKeyMap setObject:[NSMutableDictionary dictionary] forKey:@"array"];
        [[self.valueKeyMap objectForKey:@"array"] setObject:arr forKey:name];
        
        return arr;
    }
    else if(CONTAINS(type, @"enum")) {
        NSArray *types = SPLIT(type, @"|");
        BOOL isReference = false;
        for(NSString *t in types) {
            if(COMPARE(t, @"reference")) {
                isReference = true;
            }
        }
        NSMutableDictionary *dict = nil;
        if(element.childCount > 0)
        {
            dict = [NSMutableDictionary dictionaryWithCapacity:element.childCount];
            for(int i = 0; i < element.children.count; i++)
            {
                GDataXMLElement *child = [element.children objectAtIndex:i];
                if(![child respondsToSelector:NSSelectorFromString(@"attributes")])
                    continue;
                if(child.attributes != nil) {
                    if(isReference) {
                        [dict setObject:[child attributeForName:@"value"].stringValue forKey:[child attributeForName:@"name"].stringValue];
                    } else {
                        [dict setObject:[NSNumber numberWithInt:STOI([child attributeForName:@"value"].stringValue)] forKey:[child attributeForName:@"name"].stringValue];
                    }
                }
            }
        }
        if(dict == nil)
            dict = [NSMutableDictionary dictionary];
        
        return dict;
    }
    
    return nil;
}

-(NSObject *)getValueDirect:(NSString *)keyT :(NSString *)header {
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
        if(val != nil) {
            return val;
        }
        else if(header != nil) { //Lets check attributes
            NSMutableDictionary *dictIn = [dict objectForKey:header];
            val = [dictIn objectForKey:key];
            if(val != nil)
                return val;
        }
    }
    
    return keyT;
}

-(NSObject *)getValueDirect:(NSString *)keyT
{
    return [self getValueDirect:keyT :nil];
}

- (BOOL) isBoolNumber:(NSNumber *)num
{
   CFTypeID boolID = CFBooleanGetTypeID(); // the type ID of CFBoolean
   CFTypeID numID = CFGetTypeID((__bridge CFTypeRef)(num)); // the type ID of num
   return numID == boolID;
}

-(NSString *)getValueType:(NSString *)key {
    if(key == nil)
        return @"nil";
    
    if(COMPARE(key, @"@null"))
    {
        return @"color";
    }
    if(STARTS_WITH(key, @"@id/") ||
       STARTS_WITH(key, @"+@id/"))
    {
        return @"id";
    }
    else if(STARTS_WITH(key, @"@string/") ||
            STARTS_WITH(key, @"@android:string/"))
    {
        return @"string";
    }
    else if(STARTS_WITH(key, @"@drawable/") ||
            STARTS_WITH(key, @"@android:drawable/"))
    {
        return @"drawable";
    }
    else if(STARTS_WITH(key, @"@color/") || STARTS_WITH(key, @"@android:color/") || STARTS_WITH(key, @"#"))
    {
        return @"color";
    }
    else if(STARTS_WITH(key, @"@style/"))
    {
        return @"style";
    }
    else if(STARTS_WITH(key, @"@layout/"))
    {
        return @"layout";
    }
    else if(STARTS_WITH(key, @"@xml/"))
    {
        return @"xml";
    }
    else {
        NSObject* obj = [self getValueDirect:key];
        if(obj == nil)
            return @"nil";
        if([obj isKindOfClass:[NSNumber class]]) {
            NSNumber *number = (NSNumber*)obj;
            if([self isBoolNumber:number])
                return @"boolean";
            if (![number isKindOfClass:[NSDecimalNumber class]]) {
                CFNumberType numberType = CFNumberGetType((CFNumberRef)number);
                if (numberType == kCFNumberFloat32Type ||
                    numberType == kCFNumberFloat64Type ||
                    numberType == kCFNumberCGFloatType)
                {
                    return @"float";
                } else {
                    return @"int";
                }
            }
            else
                return @"float";
        }
        return @"string";
    }
}

-(BOOL)getBoolValueDirect:(NSString *)key
{
    @try {
        NSObject *obj = [self getValueDirect:key];
        return [((NSNumber*)obj) boolValue];
    } @catch (NSException *exception) {
    }
    return false;
}

-(BOOL)getBoolValueDirect:(NSString *)key :(BOOL)def
{
    @try {
        NSObject *obj = [self getValueDirect:key];
        return [((NSNumber*)obj) boolValue];
    } @catch (NSException *exception) {
    }
    return def;
}

-(NSObject *)getValue:(NSString *)key :(NSString*)header
{
    if(key == nil)
        return nil;
    
    if(COMPARE(key, @"@null"))
    {
        return [UIColor clearColor];
    }
    else if(STARTS_WITH(key, @"@id/") ||
            STARTS_WITH(key, @"@+id/"))
    {
        NSArray *arr = SPLIT(key, @"/");
        return [arr objectAtIndex:[arr count] - 1];
    }
    else if(STARTS_WITH(key, @"@string/") || 
            STARTS_WITH(key, @"@android:string/"))
    {
        return [[LGStringParser getInstance] getString:key];
    }
    else if(STARTS_WITH(key, @"@drawable/") ||
            STARTS_WITH(key, @"@android:drawable/"))
    {
        return [[LGDrawableParser getInstance] parseDrawable:key];
    }
    else if(STARTS_WITH(key, @"@color/") || STARTS_WITH(key, @"@android:color/") || STARTS_WITH(key, @"#"))
    {
        return [[LGColorParser getInstance] parseColor:key];
    }
    else if(STARTS_WITH(key, @"@style/"))
    {
        NSArray *arr = SPLIT(key, @"/");
        NSString *val = [arr objectAtIndex:arr.count - 1];
        return [[LGStyleParser getInstance] getStyle:val];
    }
    else
    {
        return [self getValueDirect:key :header];
    }
    
    return nil;
}

-(NSObject *)getValue:(NSString *)key {
    return [self getValue:key :nil];
}

-(NSMutableDictionary *)getAllKeys
{
    NSMutableDictionary *dictRet = [NSMutableDictionary dictionary];
    [dictRet setObject:[[LGDrawableParser getInstance] getKeys] forKey:@"drawable"];
    [dictRet setObject:[[LGStringParser getInstance] getKeys] forKey:@"string"];
    [dictRet setObject:[[LGColorParser getInstance] getKeys] forKey:@"color"];
    [dictRet setObject:[[LGLayoutParser getInstance] getKeys] forKey:@"layout"];
    [dictRet setObject:[[LGDimensionParser getInstance] getKeys] forKey:@"dimen"];
    [dictRet setObject:[[LGStyleParser getInstance] getKeys] forKey:@"style"];
    [dictRet setObject:[[LGIdParser getInstance] getKeys] forKey:@"id"];
    for(NSString *key in self.valueKeyMap)
    {
        [dictRet setObject:[self.valueKeyMap objectForKey:key] forKey:key];
    }
    
    return dictRet;
}


@end
