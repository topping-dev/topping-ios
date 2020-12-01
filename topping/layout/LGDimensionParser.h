#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class GDataXMLElement;

@interface LGDimensionParser : NSObject 
{
	NSMutableDictionary *dimensionMap;
}

+(LGDimensionParser*) GetInstance;
-(void) ParseXML:(NSString *)filename;
-(void) ParseXML:(int)orientation :(GDataXMLElement *)element;
-(int)GetDimension:(NSString *)key;
-(NSDictionary *)GetKeys;

@property (nonatomic, retain) NSMutableDictionary *dimensionMap;

@end
