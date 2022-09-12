#ifndef OrderedDictionary_h
#define OrderedDictionary_h

#import <Foundation/Foundation.h>

@interface OrderedDictionary : NSMutableDictionary
{
    NSMutableDictionary *dictionary;
    NSMutableArray *array;
}

- (void)insertObject:(id)anObject forKey:(id)aKey atIndex:(NSUInteger)anIndex;
- (id)keyAtIndex:(NSUInteger)anIndex;
- (NSUInteger)indexOfKey:(id)key;
- (id)remove:(id)aKey;
- (NSEnumerator *)keyEnumerator;
- (NSEnumerator *)reverseKeyEnumerator;
- (id)newest;
- (id)eldest;
- (id)ceil:(id)key;
- (id)putIfAbsent:(id)key :(id)value;

@end

#endif /* OrderedDictionary_h */
