#import "LGStyleParser.h"
#import "LGParser.h"
#import "Defines.h"
#import "DisplayMetrics.h"
#import "LuaResource.h"
#import "DefaultStyles.h"
#import "GDataXMLNode.h"
#import "LGColorParser.h"

@implementation LGStyleParser

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.styleMap = [NSMutableDictionary dictionary];
        self.parentMap = [NSMutableDictionary dictionary];
    }
    return self;
}

+(LGStyleParser *) GetInstance
{
    return [LGParser GetInstance].pStyle;
}

-(void)ParseXML:(int)orientation :(GDataXMLElement *)element
{
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
    
    [self ParseXML:orientation :nameAttr :parentAttr :element];
}

-(void)ParseXML:(int)orientation :(GDataXMLNode *)nameAttr :(GDataXMLNode *)parentAttr :(GDataXMLElement *)element
{
    NSMutableDictionary *dict = nil;
    if(element.childCount > 0)
    {
        dict = [NSMutableDictionary dictionary];
        for(int i = 0; i < element.children.count; i++)
        {
            GDataXMLElement *child = [element.children objectAtIndex:i];
            if(!COMPARE(child.name, @"item"))
                continue;
            
            GDataXMLNode *nameAttr = [child attributeForName:@"name"];
            if(nameAttr == nil)
                continue;
            //NSObject *obj = [[LGValueParser GetInstance] GetValue:child.stringValue];
            [dict setObject:child.stringValue forKey:nameAttr.stringValue];
        }
    }
    if(dict == nil)
        return;
    
    [self.styleMap setObject:dict forKey:nameAttr.stringValue];
    
    if(parentAttr != nil)
        [self.parentMap setObject:parentAttr.stringValue forKey:nameAttr.stringValue];
}

-(void)LinkParents
{
    DefaultStyles *ds = [DefaultStyles new];
    [ds Initialize];
    for(NSString *key in ds.styleMap)
    {
        [self.styleMap setObject:[ds.styleMap objectForKey:key] forKey:key];
    }
    NSMutableDictionary *linkedMap = [NSMutableDictionary dictionary];
    for(NSString *name in self.parentMap)
    {
        NSString *parent = [self.parentMap objectForKey:name];
        
        [self LinkParent:parent :name :linkedMap];
    }
}

-(void)LinkParent:(NSString*)parent :(NSString*)name :(NSMutableDictionary *)linkedMap
{
    NSString *parentOfParent = [self.parentMap objectForKey:parent];
    if(parentOfParent != nil && parent != nil && ![parent isEqualToString:@""] && [linkedMap objectForKey:parent] == nil)
    {
        [self LinkParent:parentOfParent :parent :linkedMap];
    }
    NSMutableDictionary *parentStyle = [self.styleMap objectForKey:parent];
    NSMutableDictionary *currentStyle = [self.styleMap objectForKey:name];
    
    for (NSString *key in parentStyle)
    {
        if([currentStyle objectForKey:key] == nil)
        {
            [currentStyle setObject:[parentStyle objectForKey:key] forKey:key];
        }
    }
    
    [self.styleMap setObject:currentStyle forKey:name];
    
    [linkedMap setObject:[NSNumber numberWithInt:1] forKey:name];
}

-(NSDictionary*)GetStyle:(NSString *)style
{
    return [self.styleMap objectForKey:style];
}

-(NSObject *)GetStyleValue:(NSString *)style :(NSString *)key
{
    NSMutableDictionary *dict = [self.styleMap objectForKey:style];
    
    if(dict != nil)
    {
        NSString *valRef = [dict objectForKey:key];
        NSObject *val = [[LGValueParser GetInstance] GetValue:valRef];
        return val;
    }
    
    return nil;
}

-(NSDictionary *)GetKeys
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for(NSString *key in self.styleMap)
    {
        [dict setObject:key forKey:key];
    }

    return dict;
}

@end
