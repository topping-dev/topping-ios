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
        id returnObject = [contents objectAtIndex:0];
        [contents removeObjectAtIndex:0];
        return returnObject;
    }
    else
    {
        return nil;
    }
}

@end
