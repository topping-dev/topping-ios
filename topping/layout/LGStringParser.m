#import "LGStringParser.h"
#import "LGParser.h"
#import "Defines.h"
#import "GDataXMLNode.h"

@implementation LGStringParser

@synthesize stringMap;

- (id) init
{
	self = [super init];
	if (self != nil) {
	}
	return self;
}

+(LGStringParser *) getInstance
{
	return [LGParser getInstance].pString;
}

-(void) parseXML:(NSString *)filename;
{
/*	if(self.stringMap == nil)
	{
		self.stringMap = [[NSMutableDictionary alloc] init];
		[self.stringMap setObject:[UIColor clearColor] forKey:@"transparent"];
	}
	
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
	GDataXMLDocument *xml = [[GDataXMLDocument alloc] initWithData:dat options:0 error:nil];
	if(xml == nil)
		return;
	
	GDataXMLElement *root = [xml rootElement];
	
	for(GDataXMLElement *child in [root children])
	{
		NSArray *attrs = [child attributes];
		for(GDataXMLNode *node in attrs)
		{
			[self.stringMap setObject:[self ParseColorInternal:[child stringValue]] forKey:[node stringValue]];
		}
	}*/
}

-(void)parseXML:(int)orientation :(GDataXMLElement *)element
{
    if(self.stringMap == nil)
	{
		self.stringMap = [[NSMutableDictionary alloc] init];
    }
    
    if([element kind] != GDataXMLElementKind)
        return;
    
    for(GDataXMLNode *attr in element.attributes)
    {
        if(COMPARE(attr.name, @"name"))
        {
            NSMutableDictionary *oldValue = [self.stringMap objectForKey:attr.stringValue];
            NSMutableDictionary *valueDict = [NSMutableDictionary dictionary];
            if(orientation & ORIENTATION_PORTRAIT)
                [valueDict setObject:element.stringValue forKey:ORIENTATION_PORTRAIT_S];
            else
            {
                id val;
                if(oldValue != nil && ((val = [oldValue objectForKey:ORIENTATION_PORTRAIT_S]) != nil))
                    [valueDict setObject:val forKey:ORIENTATION_PORTRAIT_S];
            }
            
            if(orientation & ORIENTATION_LANDSCAPE)
                [valueDict setObject:element.stringValue forKey:ORIENTATION_LANDSCAPE_S];
            else
            {
                id val;
                if(oldValue != nil && ((val = [oldValue objectForKey:ORIENTATION_LANDSCAPE_S]) != nil))
                    [valueDict setObject:val forKey:ORIENTATION_LANDSCAPE_S];
            }
            
            [self.stringMap setObject:valueDict forKey:attr.stringValue];
            break;
        }
    }
}

-(NSString *)getString:(NSString *)key
{
    if(key == nil)
        return nil;
    
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if(STARTS_WITH(key, @"@string/"))
    {
        NSArray *arr = SPLIT(key, @"/");
        NSMutableDictionary *val = [self.stringMap objectForKey:[arr objectAtIndex:arr.count - 1]];
        if(val != nil)
        {
            if(UIInterfaceOrientationIsPortrait(interfaceOrientation))
                return [val objectForKey:ORIENTATION_PORTRAIT_S];
            else
                return [val objectForKey:ORIENTATION_LANDSCAPE_S];
        }
    }
    return key;
}

-(NSDictionary *)getKeys
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for(NSString *key in self.stringMap)
    {
        [dict setObject:key forKey:key];
    }

    return dict;
}

@end
