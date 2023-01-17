#import "ILGRecyclerViewAdapter.h"
#import "LuaFunction.h"
#import "ToppingEngine.h"

@implementation ILGRecyclerViewAdapter

+(ILGRecyclerViewAdapter *)Create {
    return [[ILGRecyclerViewAdapter alloc] init];
}

-(NSString*)GetId
{
    return [ILGRecyclerViewAdapter className];
}

+ (NSString*)className
{
	return @"ILGRecyclerViewAdapter";
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
        
	return dict;
}

@end
