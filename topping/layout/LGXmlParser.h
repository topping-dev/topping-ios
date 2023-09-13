#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class GDataXMLElement;

@interface LGXmlParser : NSObject
{
}

+(LGXmlParser*) getInstance;
-(void)initialize;
-(NSString *)getXml:(NSString *)key;

@property (nonatomic, retain) NSMutableArray *clearedDirectoryList;

@end
