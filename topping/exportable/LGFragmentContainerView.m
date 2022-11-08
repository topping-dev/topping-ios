#import "LGFragmentContainerView.h"
#import "LuaFunction.h"
#import "Defines.h"
#import "LuaNavHostFragment.h"
#import "Topping/Topping-Swift.h"

@implementation LGFragmentContainerView

- (instancetype)initWithFragmentManager:(FragmentManager*)fragmentManager
{
    self = [super init];
    if (self) {
        self.fm = fragmentManager;
        self.mDrawDisappearingViewsFirst = true;
    }
    return self;
}

-(void)InitComponent:(UIView *)view :(LuaContext *)lc {
    [super InitComponent:view :lc];
    
    NSString *name = self.android_name;
    NSString *tag = self.android_tag;
    NSString *idVal = [self GetId];
    
    LuaFragment *existingFragment = [self.fm findFragmentByIdWithId:idVal];
    if(name != nil && existingFragment == nil) {
        if(idVal < 0) {
            //TODO: Excep
            return;
        }
        LuaFragment *containerFragment = [[self.fm getFragmentFactory] instantiateWithClassName:name];
        [containerFragment onInflate:lc :self.xmlProperties :nil];
        [[[[self.fm beginTransaction] setReorderingAllowedWithReorderingAllowed:true] addWithContainer:self fragment:containerFragment tag:tag] commitAllowingStateLoss];
    }
    [self.fm onContainerAvailableWithView:self];
}

//TODO:These
-(void)AddSubview:(LGView *)val {
    [super AddSubview:val];
}

-(void)AddSubview:(LGView *)val :(NSInteger)index {
    [super AddSubview:val :index];
}

- (void)RemoveSubview:(LGView *)val {
    [super RemoveSubview:val];
}

+(LGFragmentContainerView*)Create:(LuaContext *)context
{
    LGFragmentContainerView *lfcv = [[LGFragmentContainerView alloc] init];
    [lfcv InitProperties];
    return lfcv;
}

-(NSString*)GetId
{
    if(self.lua_id != nil)
        return self.lua_id;
    if(self.android_id != nil)
        return self.android_id;
    return [LGFragmentContainerView className];
}

+ (NSString*)className
{
    return @"LGFragmentContainerView";
}

+(NSMutableDictionary*)luaMethods
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(Create:))
                                        :@selector(Create:)
                                        :[LGFragmentContainerView class]
                                        :[NSArray arrayWithObjects:[LuaContext class], [NSString class], nil]
                                        :[LGFragmentContainerView class]]
             forKey:@"Create"];
    return dict;
}

@end
