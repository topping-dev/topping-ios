#import "OrderedDictionary.h"

@implementation OrderedDictionary

- (id)init
{
    return [self initWithCapacity:0];
}

- (id)initWithCapacity:(NSUInteger)capacity
{
    self = [super init];
    if (self != nil)
    {
        dictionary = [[NSMutableDictionary alloc] initWithCapacity:capacity];
        array = [[NSMutableArray alloc] initWithCapacity:capacity];
    }
    return self;
}

- (id)copy
{
    return [self mutableCopy];
}

- (void)setObject:(id)anObject forKey:(id)aKey
{
    if (![dictionary objectForKey:aKey])
    {
        [array addObject:aKey];
    }
    [dictionary setObject:anObject forKey:aKey];
}

- (void)removeObjectForKey:(id)aKey
{
    [dictionary removeObjectForKey:aKey];
    [array removeObject:aKey];
}

- (id)remove:(id)aKey {
    id ret = [dictionary objectForKey:aKey];
    [self removeObjectForKey:aKey];
    return ret;
}

- (NSUInteger)count
{
    return [dictionary count];
}

- (id)objectForKey:(id)aKey
{
    return [dictionary objectForKey:aKey];
}

- (NSEnumerator *)keyEnumerator
{
    return [array objectEnumerator];
}

- (NSEnumerator *)reverseKeyEnumerator
{
    return [array reverseObjectEnumerator];
}

- (void)insertObject:(id)anObject forKey:(id)aKey atIndex:(NSUInteger)anIndex
{
    if (![dictionary objectForKey:aKey])
    {
        [self removeObjectForKey:aKey];
    }
    [array insertObject:aKey atIndex:anIndex];
    [dictionary setObject:anObject forKey:aKey];
}

- (id)keyAtIndex:(NSUInteger)anIndex
{
    return [array objectAtIndex:anIndex];
}

- (NSUInteger)indexOfKey:(id)key
{
    return [array indexOfObject:key];
}

- (id)newest
{
    id key = [array lastObject];
    return [dictionary objectForKey:key];
}

- (id)eldest
{
    id key = [array objectAtIndex:0];
    return [dictionary objectForKey:key];
}

- (id)ceil:(id)key
{
    NSUInteger index = [self indexOfKey:key];
    if(index == 0)
        return nil;
    
    index--;
    return [self objectForKey:[self keyAtIndex:index]];
}

- (id)putIfAbsent:(id)key :(id)value
{
    if ([dictionary objectForKey:key])
    {
        return value;
    }
    [self setObject:value forKey:key];
    
    return nil;
}

@end
