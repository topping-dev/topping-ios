#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class GDataXMLElement;

@interface LGIdParser : NSObject
{
}

-(void)initialize;
+(LGIdParser*) getInstance;
-(void) parse:(NSString*)folder :(NSArray*)clearedDirectoryList;
-(void) parseXML:(NSString*)path :(NSString *)filename;
-(NSDictionary *)getKeys;
-(void) addKey:(NSString*)key :(NSString*)value;

@property (nonatomic, retain) NSMutableDictionary *idMap;

@end
