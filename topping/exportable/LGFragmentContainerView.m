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

-(void)initComponent:(UIView *)view :(LuaContext *)lc {
    [super initComponent:view :lc];
    
    NSString *name = self.android_name;
    NSString *tag = self.android_tag;
    NSString *idVal = [self GetId];
    
    LuaFragment *existingFragment = [self.fm findFragmentByIdWithId:idVal];
    if(name != nil && existingFragment == nil) {
        if([idVal isEqual: @""]) {
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
-(void)addSubview:(LGView *)val {
    [super addSubview:val];
}

-(void)addSubview:(LGView *)val :(NSInteger)index {
    [super addSubview:val :index];
}

- (void)removeSubview:(LGView *)val {
    [super removeSubview:val];
}

+(LGFragmentContainerView*)create:(LuaContext *)context
{
    LGFragmentContainerView *lfcv = [[LGFragmentContainerView alloc] init];
    [lfcv initProperties];
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
    
    ClassMethod(create:, LGFragmentContainerView, @[[LuaContext class]C [NSString class]], @"create", [LGFragmentContainerView class])

    return dict;
}

@end
