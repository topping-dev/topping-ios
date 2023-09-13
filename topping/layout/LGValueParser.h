#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class GDataXMLElement;

@interface LGValueParser : NSObject
{
}

+(LGValueParser*) getInstance;
-(void)initialize;
-(void)parseXML:(int)orientation :(GDataXMLElement *)element;
-(NSObject*)getValue:(NSString *)key;
-(NSObject*)getValueDirect:(NSString *)key;
-(NSString*)getValueType:(NSString *)key;
-(BOOL)getBoolValueDirect:(NSString *)key;
-(BOOL)getBoolValueDirect:(NSString *)key :(BOOL)def;
-(NSMutableDictionary *)getAllKeys;

@property (nonatomic, retain) NSMutableDictionary *valueMap;
@property (nonatomic, retain) NSMutableDictionary *valueKeyMap;
@property (nonatomic, retain) NSMutableArray *clearedDirectoryList;

@end
