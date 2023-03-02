#import "LGTextInputLayout.h"
#import "LuaFunction.h"

@implementation LGTextInputLayout

+(LGTextInputLayout*)create:(LuaContext*)context {
    LGTextInputLayout *dl = [[LGTextInputLayout alloc] init];
    dl.lc = context;
    return dl;
}

- (NSString *)GetId {
    return @"LGTextInputLayout";
}

+(NSMutableDictionary*)luaMethods
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];

    ClassMethod(create:, LGTextInputLayout, @[[LuaContext class]], @"create", [LGTextInputLayout class])
    
    return dict;
}

@end
