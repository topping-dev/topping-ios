#import "LGColorParser.h"
#import "Defines.h"
#import "GDataXMLNode.h"
#import "LGParser.h"

@implementation LGColorParser

@synthesize colorMap;

- (id) init
{
	self = [super init];
	if (self != nil) {
	}
	return self;
}

+(LGColorParser *) GetInstance
{
	return [LGParser GetInstance].pColor;
}

-(void) ParseXML:(NSString *)filename;
{
	if(self.colorMap == nil)
	{
		self.colorMap = [[NSMutableDictionary alloc] init];
		[self.colorMap setObject:[UIColor clearColor] forKey:@"transparent"];
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
			[self.colorMap setObject:[self ParseColorInternal:[child stringValue]] forKey:[node stringValue]];
		}
	}
}

-(void)ParseXML:(int)orientation :(GDataXMLElement *)element
{
    if(self.colorMap == nil)
	{
		self.colorMap = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *transparent = [NSMutableDictionary dictionary];
        [transparent setObject:[UIColor clearColor] forKey:ORIENTATION_PORTRAIT_S];
        [transparent setObject:[UIColor clearColor] forKey:ORIENTATION_LANDSCAPE_S];
		[self.colorMap setObject:transparent forKey:@"transparent"];
	}
    
    for(GDataXMLNode *attr in element.attributes)
    {
        if(COMPARE(attr.name, @"name"))
        {
            NSMutableDictionary *oldValue = [self.colorMap objectForKey:attr.stringValue];
            NSMutableDictionary *valueDict = [NSMutableDictionary dictionary];
            if(orientation & ORIENTATION_PORTRAIT)
                [valueDict setObject:[self ParseColor:element.stringValue] forKey:ORIENTATION_PORTRAIT_S];
            else
            {
                id val;
                if(oldValue != nil && ((val = [oldValue objectForKey:ORIENTATION_PORTRAIT_S]) != nil))
                    [valueDict setObject:val forKey:ORIENTATION_PORTRAIT_S];
            }
            
            if(orientation & ORIENTATION_LANDSCAPE)
                [valueDict setObject:[self ParseColor:element.stringValue] forKey:ORIENTATION_LANDSCAPE_S];
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

-(UIColor *) ParseColor:(NSString *)color
{
	UIColor *retVal = nil;
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if(CONTAINS(color, @"color/"))
    {
        NSArray *arr = SPLIT(color, @"/");
        NSMutableDictionary *val = [self.colorMap objectForKey:[arr objectAtIndex:arr.count - 1]];
        if(val != nil)
        {
            if(UIInterfaceOrientationIsPortrait(interfaceOrientation))
                retVal = [val objectForKey:ORIENTATION_PORTRAIT_S];
            else
                retVal = [val objectForKey:ORIENTATION_LANDSCAPE_S];
        }
    }
	if(retVal == nil)
		retVal = [self ParseColorInternal:color];
	return retVal;
}

-(UIColor *) ParseColorInternal:(NSString *)color
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

-(NSDictionary *)GetKeys
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for(NSString *key in self.colorMap)
    {
        [dict setObject:key forKey:key];
    }

    return dict;
}

@end
