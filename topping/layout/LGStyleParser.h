#import <Foundation/Foundation.h>

@class GDataXMLElement;
@class GDataXMLNode;

NS_ASSUME_NONNULL_BEGIN

@interface LGStyleParser : NSObject

+(LGStyleParser *) getInstance;

-(void)parseXML:(int)orientation :(GDataXMLElement *)element;
-(void)parseXML:(int)orientation :(GDataXMLNode *)nameAttr :(GDataXMLNode *)parentAttr :(GDataXMLElement *)element;
-(void)linkParents;
-(NSDictionary *)getStyle:(NSString *)style;
-(NSObject *)getStyleValue:(NSString *)style :(NSString*)key;
-(NSDictionary *)getKeys;

@property (nonatomic, retain) NSMutableDictionary *styleMap;
@property (nonatomic, retain) NSMutableDictionary *parentMap;

@end

NS_ASSUME_NONNULL_END
