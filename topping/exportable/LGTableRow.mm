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
    if(self.lua_id != nil)
        return self.lua_id;
    if(self.android_tag != nil)
        return self.android_tag;
    else
        return [LGTableRow className];
}

+ (NSString*)className
{
    return @"LGTableRow";
}

+(NSMutableDictionary*)luaMethods
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(Create::))
                                        :@selector(Create::)
                                        :[LGTableRow class]
                                        :[NSArray arrayWithObjects:[LuaContext class], [NSString class], nil]
                                        :[LGTableRow class]]
             forKey:@"Create"];
    return dict;
}

@end
