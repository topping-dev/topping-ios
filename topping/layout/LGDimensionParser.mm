#import "LGDimensionParser.h"
#import "GDataXMLNode.h"
#import "DisplayMetrics.h"
#import "LGParser.h"
#import "Defines.h"

@implementation LGDimensionParser

@synthesize dimensionMap;

- (id) init
{
	self = [super init];
	if (self != nil) {
	}
	return self;
}

+(LGDimensionParser*)GetInstance
{
	return [LGParser GetInstance].pDimen;
}

-(void) ParseXML:(NSString *)filename
{
	if(self.dimensionMap == nil)
	{
		self.dimensionMap = [[NSMutableDictionary alloc] init];
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
	GDataXMLDocument *xml = [[GDataXMLDocument alloc] initWithData:dat error:nil];
	if(xml == nil)
		return;
	
	GDataXMLElement *root = [xml rootElement];
	
	for(GDataXMLElement *child in [root children])
	{
		NSArray *attrs = [child attributes];
		for(GDataXMLNode *node in attrs)
		{
			[self.dimensionMap setObject:[NSNumber numberWithInt:[DisplayMetrics readSize:[child stringValue]]] forKey:[node stringValue]];
		}
	}
}

-(void)ParseXML:(int)orientation :(GDataXMLElement *)element
{
    if(self.dimensionMap == nil)
	{
		self.dimensionMap = [[NSMutableDictionary alloc] init];
    }
    
    for(GDataXMLNode *attr in element.attributes)
    {
        if(COMPARE(attr.name, @"name"))
        {
            NSMutableDictionary *oldValue = [self.dimensionMap objectForKey:attr.stringValue];
            NSMutableDictionary *valueDict = [NSMutableDictionary dictionary];
            if(orientation & ORIENTATION_PORTRAIT)
                [valueDict setObject:[NSNumber numberWithInt:[DisplayMetrics readSize:element.stringValue]] forKey:ORIENTATION_PORTRAIT_S];
            else
            {
                id val;
                if(oldValue != nil && ((val = [oldValue objectForKey:ORIENTATION_PORTRAIT_S]) != nil))
                    [valueDict setObject:val forKey:ORIENTATION_PORTRAIT_S];
            }
            
            if(orientation & ORIENTATION_LANDSCAPE)
                [valueDict setObject:[NSNumber numberWithInt:[DisplayMetrics readSize:element.stringValue]] forKey:ORIENTATION_LANDSCAPE_S];
            else
            {
                id val;
                if(oldValue != nil && ((val = [oldValue objectForKey:ORIENTATION_LANDSCAPE_S]) != nil))
                    [valueDict setObject:val forKey:ORIENTATION_LANDSCAPE_S];
            }
            
            [self.dimensionMap setObject:valueDict forKey:attr.stringValue];
            break;
        }
    }
}

-(int)GetDimension:(NSString *)key
{
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if(STARTS_WITH(key, @"@dimen/"))
    {
        NSArray *arr = SPLIT(key, @"/");
        NSMutableDictionary *val = [self.dimensionMap objectForKey:[arr objectAtIndex:arr.count - 1]];
        if(val != nil)
        {
            if(UIInterfaceOrientationIsPortrait(interfaceOrientation))
                return [[val objectForKey:ORIENTATION_PORTRAIT_S] intValue];
            else
                return [[val objectForKey:ORIENTATION_LANDSCAPE_S] intValue];
        }
    }
    return [DisplayMetrics readSize:key];
}

-(NSDictionary *)GetKeys
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for(NSString *key in self.dimensionMap)
    {
        [dict setObject:key forKey:key];
    }

    return dict;
}

@end
