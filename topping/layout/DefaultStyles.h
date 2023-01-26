#import <Foundation/Foundation.h>

@interface DefaultStyles : NSObject

-(void)initialize;

@property (nonatomic, retain) NSMutableDictionary *styleMap;
@property (nonatomic, retain) NSMutableDictionary *parentMap;

@end
