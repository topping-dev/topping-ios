#import "LGConstraintLayout.h"
#import "LuaFunction.h"
#import "Defines.h"
#import "LGDimensionParser.h"
#import "IOSKotlinHelper/IOSKotlinHelper.h"

@implementation LGConstraintLayout

-(void)initComponent:(UIView *)view :(LuaContext *)lc
{
    [super initComponent:view :lc];
    IOSKHMutableDictionary *dict = [[IOSKHMutableDictionary alloc] initWithDictionary:self.xmlProperties copyItems:true];
    self.wrapper = [[IOSKHConstraintLayout alloc] initWithContext:lc attrs:dict self:self];
}

+(LGConstraintLayout*)create:(LuaContext *)context
{
    LGConstraintLayout *lcl = [[LGConstraintLayout alloc] init];
    [lcl initProperties];
    return lcl;
}

-(NSString*)GetId
{
    if(self.lua_id != nil)
        return self.lua_id;
    if(self.android_id != nil)
        return self.android_id;
    return [LGConstraintLayout className];
}

+ (NSString*)className
{
    return @"LGConstraintLayout";
}

+(NSMutableDictionary*)luaMethods
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(create:))
                                        :@selector(create:)
                                        :[LGConstraintLayout class]
                                        :[NSArray arrayWithObjects:[LuaContext class], [NSString class], nil]
                                        :[LGConstraintLayout class]]
             forKey:@"create"];
    return dict;
}

@end
