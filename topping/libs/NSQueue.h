#import <Foundation/Foundation.h>

@interface NSQueue : NSObject
{
    NSMutableArray *contents;
}

- (void)queue:(id)object;
- (id)dequeue;
- (void)clear;

@end

@interface NSDeque : NSObject
{
    NSMutableArray *contents;
}

- (void)add:(id)object;
- (void)addLast:(id)object;
- (void)addFirst:(id)object;
- (id)pollLast;
- (id)pollFirst;
- (void)clear;
- (id)peekLast;
- (id)peekFirst;

@end
