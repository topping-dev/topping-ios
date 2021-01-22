#import "DefaultStyles.h"
#import "Defines.h"
#import "LGValueParser.h"
#import <GDataXMLNode.h>

@implementation DefaultStyles

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.styleMap = [NSMutableDictionary dictionary];
        self.parentMap = [NSMutableDictionary dictionary];
    }
    return self;
}

-(void)Initialize
{
    NSBundle *bund = [NSBundle bundleWithIdentifier:@"dev.topping.ios"];
    NSString *themePath = [bund pathForResource:@"themes" ofType:@"xml"];
    NSData *resourceData = [NSData dataWithContentsOfFile:themePath];
    GDataXMLDocument *xml = [[GDataXMLDocument alloc] initWithData:resourceData error:nil];
    
    GDataXMLElement *root = [xml rootElement];
    if(COMPARE(root.name, @"resources"))
    {
        for(GDataXMLElement *child in root.children)
        {
            NSString *childName = child.name;
            if(COMPARE(childName, @"style"))
            {
                [self ParseXML:child];
            }
        }
    }
    [self LinkParents];
}

-(void)ParseXML:(GDataXMLElement *)element
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
    
    [self ParseXML :nameAttr :parentAttr :element];
}

-(void)ParseXML:(GDataXMLNode *)nameAttr :(GDataXMLNode *)parentAttr :(GDataXMLElement *)element
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

@end
