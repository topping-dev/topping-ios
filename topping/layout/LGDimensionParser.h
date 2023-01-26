#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class GDataXMLElement;

@interface LGDimensionParser : NSObject 
{
	NSMutableDictionary *dimensionMap;
}

+(LGDimensionParser*) getInstance;
-(void) parseXML:(NSString *)filename;
-(void) parseXML:(int)orientation :(GDataXMLElement *)element;
-(int)getDimension:(NSString *)key;
-(NSDictionary *)getKeys;

@property (nonatomic, retain) NSMutableDictionary *dimensionMap;

@end
