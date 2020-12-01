#import <Foundation/Foundation.h>

@interface DefaultStyles : NSObject

-(void)Initialize;

@property (nonatomic, retain) NSMutableDictionary *styleMap;
@property (nonatomic, retain) NSMutableDictionary *parentMap;

@end
