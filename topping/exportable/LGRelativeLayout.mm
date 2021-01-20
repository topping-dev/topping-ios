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
    GETID
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
