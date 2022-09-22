#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class GDataXMLElement;

@interface LGIdParser : NSObject
{
}

-(void)Initialize;
+(LGIdParser*) GetInstance;
-(void) Parse:(NSString*)folder :(NSArray*)clearedDirectoryList;
-(void) ParseXML:(NSString*)path :(NSString *)filename;
-(NSDictionary *)GetKeys;

@property (nonatomic, retain) NSMutableDictionary *idMap;

@end
