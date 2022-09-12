#import "LGTableLayout.h"
#import "LuaFunction.h"
#import "Defines.h"

@implementation LGTableLayout

-(void)ComponentAddMethod:(UIView *)par :(UIView *)me
{
    [super ComponentAddMethod:par :me];
}

//Lua
+(LGTableLayout*)Create:(LuaContext *)context
{
    LGTableLayout *lfl = [[LGTableLayout alloc] init];
    [lfl InitProperties];
    return lfl;
}

-(NSString*)GetId
{
    if(self.lua_id != nil)
        return self.lua_id;
    if(self.android_id != nil)
        return self.android_id;
    return [LGTableLayout className];
}

+ (NSString*)className
{
    return @"LGTableLayout";
}

+(NSMutableDictionary*)luaMethods
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(Create:))
                                        :@selector(Create:)
                                        :[LGTableLayout class]
                                        :[NSArray arrayWithObjects:[LuaContext class], [NSString class], nil]
                                        :[LGTableLayout class]]
             forKey:@"Create"];
    return dict;
}

@end
