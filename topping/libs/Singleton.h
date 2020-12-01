#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#define s(T) [T sharedManager]

@interface Singleton : NSObject {
    NSString *someProperty;
}

@property (nonatomic, retain) NSString *someProperty;

+ (id)sharedManager;

@end
