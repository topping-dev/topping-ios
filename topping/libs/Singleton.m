#import "Singleton.h"

static Singleton *sharedMyManager = nil;

@implementation Singleton

@synthesize someProperty;

#pragma mark Singleton Methods
+ (id)sharedManager {
    @synchronized(self) {
        if(sharedMyManager == nil)
            sharedMyManager = [[super allocWithZone:NULL] init];
    }
    return sharedMyManager;
}
+ (id)allocWithZone:(NSZone *)zone {
    return [self sharedManager];
}

- (id)init {
    if (self = [super init]) {
        someProperty = @"Default Property Value";
    }
    return self;
}

@end
