#import "Common.h"
#import "NSQueue.h"

@implementation NSQueue

// superclass overrides

- (id)init
{
    if (self = [super init])
    {
        contents = [[NSMutableArray alloc] init];
    }
    return self;
}

// Queue methods

- (void)queue:(id)object
{
    [contents addObject:object];
}

- (id)dequeue
{
    NSUInteger count = [contents count];
    if (count > 0)
    {
        int last = contents.count - 1;
        id returnObject = [contents objectAtIndex:last];
        [contents removeObjectAtIndex:last];
        return returnObject;
    }
    else
    {
        return nil;
    }
}

-(void)clear {
    [contents removeAllObjects];
}

@end

@implementation NSDeque

// superclass overrides

- (id)init
{
    if (self = [super init])
    {
        contents = [[NSMutableArray alloc] init];
    }
    return self;
}

// Queue methods
- (void)add:(id)object
{
    [self addLast:object];
}

- (void)addLast:(id)object
{
    [contents addObject:object];
}

- (void)addFirst:(id)object
{
    [contents insertObject:object atIndex:0];
}

- (id)pollFirst
{
    NSUInteger count = [contents count];
    if (count > 0)
    {
        id returnObject = [contents objectAtIndex:0];
        [contents removeObjectAtIndex:0];
        return returnObject;
    }
    else
    {
        return nil;
    }
}

- (id)pollLast
{
    NSUInteger count = [contents count];
    if (count > 0)
    {
        id returnObject = [contents objectAtIndex:count - 1];
        [contents removeObjectAtIndex:count - 1];
        return returnObject;
    }
    else
    {
        return nil;
    }
}

- (id)peekFirst
{
    NSUInteger count = [contents count];
    if (count > 0)
    {
        id returnObject = [contents objectAtIndex:0];
        return returnObject;
    }
    else
    {
        return nil;
    }
}

- (id)peekLast
{
    NSUInteger count = [contents count];
    if (count > 0)
    {
        id returnObject = [contents objectAtIndex:count - 1];
        return returnObject;
    }
    else
    {
        return nil;
    }
}

-(void)clear {
    [contents removeAllObjects];
}

@end
