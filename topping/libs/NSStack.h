#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSStack : NSObject {
    NSMutableArray* m_array;
    NSUInteger count;
}

- (void)push:(id)anObject;
- (id)pop;
- (void)clear;

@property (nonatomic, readonly) NSUInteger count;

@end

NS_ASSUME_NONNULL_END
