#import "LGTextInputLayout.h"
#import "LuaFunction.h"

@implementation LGTextInputLayout

+(LGTextInputLayout*)create:(LuaContext*)context {
    LGTextInputLayout *dl = [[LGTextInputLayout alloc] init];
    dl.lc = context;
    return dl;
}

-(NSString*)GetId
{
    if(self.lua_id != nil)
        return self.lua_id;
    if(self.android_id != nil)
        return self.android_id;
    return [LGTextInputLayout className];
}

+ (NSString*)className
{
    return @"LGTextInputLayout";
}

+(NSMutableDictionary*)luaMethods
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];

    ClassMethod(create:, LGTextInputLayout, @[[LuaContext class]], @"create", [LGTextInputLayout class])
    
    return dict;
}

@end
