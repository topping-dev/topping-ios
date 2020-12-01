#import <Foundation/Foundation.h>

@class GDataXMLElement;
@class GDataXMLNode;

NS_ASSUME_NONNULL_BEGIN

@interface LGStyleParser : NSObject

+(LGStyleParser *) GetInstance;

-(void)ParseXML:(int)orientation :(GDataXMLElement *)element;
-(void)ParseXML:(int)orientation :(GDataXMLNode *)nameAttr :(GDataXMLNode *)parentAttr :(GDataXMLElement *)element;
-(void)LinkParents;
-(NSDictionary *)GetStyle:(NSString *)style;
-(NSObject *)GetStyleValue:(NSString *)style :(NSString*)key;
-(NSDictionary *)GetKeys;

@property (nonatomic, retain) NSMutableDictionary *styleMap;
@property (nonatomic, retain) NSMutableDictionary *parentMap;

@end

NS_ASSUME_NONNULL_END
