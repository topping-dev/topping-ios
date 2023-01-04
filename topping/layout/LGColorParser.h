#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class GDataXMLElement;

@interface LGColorParser : NSObject 
{
	NSMutableDictionary *colorMap;
}

+(LGColorParser*) GetInstance;
-(void) ParseXML:(NSString *)filename;
-(void) ParseXML:(int)orientation :(GDataXMLElement *)element;

-(UIColor*) ParseColor:(NSString *)color;
-(UIColor*) ParseColorInternal:(NSString *)color;
-(UIColor*)GetTextColorFromColor:(UIColor*)color;
-(NSDictionary*)GetKeys;

@property (nonatomic, retain) NSMutableDictionary *colorMap;

@end
