#import "LuaNativeObject.h"


@implementation LuaNativeObject

- (instancetype)initWithObject:(NSObject*)object
{
    self = [super init];
    if (self) {
        self.obj = object;
    }
    return self;
}

-(NSString*)GetId
{
	return @"LuaNativeObject"; 
}

+ (NSString*)className
{
	return @"LuaNativeObject";
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	return dict;
}

@end
