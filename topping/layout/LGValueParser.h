#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class GDataXMLElement;

@interface LGValueParser : NSObject
{
}

+(LGValueParser*) GetInstance;
-(void)Initialize;
-(void)ParseXML:(int)orientation :(GDataXMLElement *)element;
-(NSObject*)GetValue:(NSString *)key;
-(NSObject*)GetValueDirect:(NSString *)key;
-(BOOL)GetBoolValueDirect:(NSString *)key;
-(NSMutableDictionary *)GetAllKeys;

@property (nonatomic, retain) NSMutableDictionary *valueMap;
@property (nonatomic, retain) NSMutableDictionary *valueKeyMap;
@property (nonatomic, retain) NSMutableArray *clearedDirectoryList;

@end
