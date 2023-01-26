#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class GDataXMLElement;

@interface LGStringParser : NSObject
{
	NSMutableDictionary *stringMap;
}

+(LGStringParser*) getInstance;
-(void) parseXML:(NSString *)filename;
-(void) parseXML:(int)orientation :(GDataXMLElement *)element;
-(NSString*)getString:(NSString *)key;
-(NSDictionary*)getKeys;

@property (nonatomic, retain) NSMutableDictionary *stringMap;

@end
