#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class GDataXMLElement;

@interface LGStringParser : NSObject
{
	NSMutableDictionary *stringMap;
}

+(LGStringParser*) GetInstance;
-(void) ParseXML:(NSString *)filename;
-(void) ParseXML:(int)orientation :(GDataXMLElement *)element;
-(NSString*)GetString:(NSString *)key;
-(NSDictionary*)GetKeys;

@property (nonatomic, retain) NSMutableDictionary *stringMap;

@end
