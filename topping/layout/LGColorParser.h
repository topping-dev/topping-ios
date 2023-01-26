#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class GDataXMLElement;

@interface LGColorParser : NSObject 
{
	NSMutableDictionary *colorMap;
}

+(LGColorParser*) getInstance;
-(void) parseXML:(NSString *)filename;
-(void) parseXML:(int)orientation :(GDataXMLElement *)element;

-(UIColor*) parseColor:(NSString *)color;
-(UIColor*) parseColorInternal:(NSString *)color;
-(UIColor*)getTextColorFromColor:(UIColor*)color;
-(NSDictionary*)getKeys;

@property (nonatomic, retain) NSMutableDictionary *colorMap;

@end
