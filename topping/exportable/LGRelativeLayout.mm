#import "LGRelativeLayout.h"
#import "LuaFunction.h"
#import "Defines.h"

@implementation LGRelativeLayout

-(void)ComponentAddMethod:(UIView *)par :(UIView *)me
{
    [super ComponentAddMethod:par :me];
}

//Lua
+(LGRelativeLayout*)Create:(LuaContext *)context
{
    LGRelativeLayout *lfl = [[LGRelativeLayout alloc] init];
    [lfl InitProperties];
    return lfl;
}

-(NSString*)GetId
{
    if(self.lua_id != nil)
        return self.lua_id;
    if(self.android_id != nil)
        return self.android_id;
    if(self.android_tag != nil)
        return self.android_tag;
    return [LGRelativeLayout className];
}

+ (NSString*)className
{
    return @"LGRelativeLayout";
}

+(NSMutableDictionary*)luaMethods
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(Create:))
                                        :@selector(Create:)
                                        :[LGRelativeLayout class]
                                        :[NSArray arrayWithObjects:[LuaContext class], [NSString class], nil]
                                        :[LGRelativeLayout class]]
             forKey:@"Create"];
    return dict;
}

@end
