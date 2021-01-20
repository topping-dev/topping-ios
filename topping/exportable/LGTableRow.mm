#import "LGTableRow.h"
#import "LuaFunction.h"
#import "Defines.h"

@implementation LGTableRow

-(void)ComponentAddMethod:(UIView *)par :(UIView *)me
{
    [super ComponentAddMethod:par :me];
}

//Lua
+(LGTableRow*)Create:(LuaContext *)context
{
    LGTableRow *lfl = [[LGTableRow alloc] init];
    [lfl InitProperties];
    return lfl;
}

-(NSString*)GetId
{
    GETID
    return [LGTableRow className];
}

+ (NSString*)className
{
    return @"LGTableRow";
}

+(NSMutableDictionary*)luaMethods
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(Create:))
                                        :@selector(Create:)
                                        :[LGTableRow class]
                                        :[NSArray arrayWithObjects:[LuaContext class], [NSString class], nil]
                                        :[LGTableRow class]]
             forKey:@"Create"];
    return dict;
}

@end
