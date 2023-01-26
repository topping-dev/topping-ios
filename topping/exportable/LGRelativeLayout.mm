#import "LGRelativeLayout.h"
#import "LuaFunction.h"
#import "Defines.h"

@implementation LGRelativeLayout

-(void)componentAddMethod:(UIView *)par :(UIView *)me
{
    [super componentAddMethod:par :me];
}

//Lua
+(LGRelativeLayout*)create:(LuaContext *)context
{
    LGRelativeLayout *lfl = [[LGRelativeLayout alloc] init];
    [lfl initProperties];
    return lfl;
}

-(NSString*)GetId
{
    if(self.lua_id != nil)
        return self.lua_id;
    if(self.android_id != nil)
        return self.android_id;
    return [LGRelativeLayout className];
}

+ (NSString*)className
{
    return @"LGRelativeLayout";
}

+(NSMutableDictionary*)luaMethods
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(create:))
                                        :@selector(create:)
                                        :[LGRelativeLayout class]
                                        :[NSArray arrayWithObjects:[LuaContext class], [NSString class], nil]
                                        :[LGRelativeLayout class]]
             forKey:@"create"];
    return dict;
}

@end
