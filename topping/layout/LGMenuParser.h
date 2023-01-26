#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LuaMenu.h"

@class GDataXMLElement;

@interface LGMenuParser : NSObject
{
}

+(LGMenuParser*) getInstance;
-(void)initialize;
-(NSMutableArray *)getMenu:(NSString *)key;

@property (nonatomic, retain) NSMutableDictionary *menuCache;
@property (nonatomic, retain) NSMutableArray *clearedDirectoryList;

@end
