#import "LGAbsListView.h"

@implementation LGAbsListView

-(NSString*)GetId
{
    if(self.lua_id != nil)
        return self.lua_id;
    if(self.android_id != nil)
        return self.android_id;
    return [LGAbsListView className];
}

+ (NSString*)className
{
    return @"LGAbsListView";
}

@end
