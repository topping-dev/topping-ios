#import <Foundation/Foundation.h>


@interface NSQueue : NSObject
{
    NSMutableArray *contents;
}

- (void)queue:(id)object;
- (id)dequeue;

@end
