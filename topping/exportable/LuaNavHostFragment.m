#import "LuaNavHostFragment.h"
#import "LuaFunction.h"
#import "Defines.h"
#import <Topping/Topping-Swift.h>

@implementation LuaNavHostFragment

+ (NavController *)findNavController:(LuaFragment *)fragment {
    LuaFragment* findFragment = fragment;
    while(findFragment != nil) {
        if([findFragment isKindOfClass:[LuaNavHostFragment class]]) {
            return [((LuaNavHostFragment*)findFragment) getNavController];
        }
        LuaFragment* primaryNavFragment = [[findFragment getParentFragmentManager] getPrimaryNavigationFragment];
        if([primaryNavFragment isKindOfClass:[LuaNavHostFragment class]]) {
            return [((LuaNavHostFragment*)findFragment) getNavController];
        }
        findFragment = findFragment.mParentFragment;
        
        LGView *view = fragment.lgview;
        if(view != nil) {
            return [Navigation findNavControllerWithView:view];
        }
    }
    
    return nil;
}

+ (LuaNavController *)findNavControllerInternal:(LuaFragment *)fragment {
    return [[LuaNavController alloc] initWithController:[LuaNavHostFragment findNavController:fragment]];
}

+(LuaNavHostFragment *)create:(NSString *)graphResId{
    return [LuaNavHostFragment create:graphResId :nil];
}

+(LuaNavHostFragment *)create:(NSString *)graphResId :(NSMutableDictionary *)startDestinationArgs {
    NSMutableDictionary *b = nil;
    if(graphResId != nil) {
        b = [NSMutableDictionary dictionary];
        [b setObject:graphResId forKey:@"android-support-nav:fragment:graphId"];
    }
    if(startDestinationArgs != nil) {
        if(b == nil) {
            b = [NSMutableDictionary dictionary];
        }
        [b setObject:startDestinationArgs forKey:@"android-support-nav:fragment:startDestinationArgs"];
    }
    
    LuaNavHostFragment *result = [LuaNavHostFragment new];
    if(b != nil) {
        result.mArguments = b;
    }
    return result;
}

- (NavController *)getNavController {
    return self.mNavController;
}

- (LuaNavController *)getNavControllerInternal {
    return [[LuaNavController alloc] initWithController:self.mNavController];
}

- (void)onAttach:(LuaContext *)context {
    [super onAttach:context];
    if(self.mDefaultNavHost) {
        [[[[self getParentFragmentManager] beginTransaction] setPrimaryNavigationFragmentWithFragment:self] commit];
    }
}

-(void)onCreate:(NSMutableDictionary *)savedInsanceState {
    LuaContext *context = [self getContext];
    
    self.mNavController = [[NavHostController alloc] initWithContext:context];
    [self.mNavController setLifecycleOwnerWithOwner:self];
    //TODO
    /*[self.mNavController setOnBackPressedDispatcherWithDispatcher:[self GetForm] getOnba];
    [self.mNavController enableOnBackPressedWithEnabled:self.mIsPrimaryOnBeforeCreate != nil && [self.mIsPrimaryOnBeforeCreate boolValue]];*/
    self.mIsPrimaryOnBeforeCreate = nil;
    [self.mNavController setViewModelStoreWithViewModelStore:[self getViewModelStore]];
    [self onCreateNavController:self.mNavController];
    
    NSMutableDictionary* navState = nil;
    if(savedInsanceState != nil) {
        navState = (NSMutableDictionary*)[savedInsanceState objectForKey:@"android-support-nav:fragment:navControllerState"];
        NSNumber *defHost = [savedInsanceState objectForKey:@"android-support-nav:fragment:defaultHost"];
        if(defHost != nil && [defHost boolValue] == true) {
            self.mDefaultNavHost = true;
            [[[[self getParentFragmentManager] beginTransaction] setPrimaryNavigationFragmentWithFragment:self] commit];
        }
        self.mGraphId = [[LGIdParser getInstance] getId:[savedInsanceState objectForKey:@"android-support-nav:fragment:graphId"]];
    }
    
    if(navState != nil) {
        [self.mNavController restoreStateWithNavStateP:navState];
    }
    if(self.mGraphId != nil) {
        [self.mNavController setGraphWithGraphResId:self.mGraphId];
    } else {
        NSMutableDictionary *args = self.mArguments;
        NSString *graphId = args != nil ? [[LGIdParser getInstance] getId:[args objectForKey:@"android-support-nav:fragment:graphId"]] : nil;
        NSMutableDictionary *startDestinationArgs = args != nil ? [args objectForKey:@"android-support-nav:fragment:startDestinationArgs"] : nil;
        if(graphId != nil) {
            [self.mNavController setGraphWithGraphResId:graphId startDestinationArgsP:startDestinationArgs];
        }
    }
    
    [super onCreate:savedInsanceState];
}

- (void)onCreateNavController:(NavController *)navController {
    [[navController getNavigationProvider] addNavigatorWithNavigator:[[DialogFragmentNavigator alloc] initWithContext:self.context manager:self.mFragmentManager]];
    [[navController getNavigationProvider] addNavigatorWithNavigator:[self createFragmentNavigator]];
}

-(void)setNavGraph:(NSString *)graphResId :(NSMutableDictionary *)startDestinationArgs {
    NSMutableDictionary *b = nil;
    if(graphResId != nil) {
        b = [NSMutableDictionary dictionary];
        [b setObject:graphResId forKey:@"android-support-nav:fragment:graphId"];
    }
    if(startDestinationArgs != nil) {
        if(b == nil) {
            b = [NSMutableDictionary dictionary];
        }
        [b setObject:startDestinationArgs forKey:@"android-support-nav:fragment:startDestinationArgs"];
    }
    
    self.mArguments = b;
}

- (void)onPrimaryNavigationFragmentChanged:(BOOL)isPrimaryNavigationFragment {
    if(self.mNavController != nil) {
        [self.mNavController enableOnBackPressedWithEnabled:isPrimaryNavigationFragment];
    } else {
        self.mIsPrimaryOnBeforeCreate = [NSNumber numberWithBool:isPrimaryNavigationFragment];
    }
}

- (FragmentNavigator*)createFragmentNavigator {
    return [[FragmentNavigator alloc] initWithContext:[self getContext] manager:[self getChildFragmentManager] containerId:[self getContainerId]];
}

- (NSString*)getContainerId {
    NSString* idVal = [self GetId];
    if(idVal != nil) {
        return idVal;
    }
    
    return @"@id/nav_host_fragment_container";
}

- (LGView *)onCreateView:(LGLayoutParser *)inflater :(LGViewGroup *)container :(NSMutableDictionary *)savedInstanceState {
    LGFragmentContainerView *containerView = [LGFragmentContainerView create:[self getContext]];
    containerView.android_id = [self getContainerId];
    containerView.android_layout_width = @"match_parent";
    containerView.android_layout_height = @"match_parent";
    containerView.parent = container;
    [containerView addSelfToParent:[container getView] :self.context.form];
    return containerView;
}

- (void)onViewCreated:(LGView *)view :(NSMutableDictionary *)savedInstanceState {
    [super onViewCreated:view :savedInstanceState];
    if(![view isKindOfClass:[LGViewGroup class]])
    {
        return;
    }
    view.navController = self.mNavController;
    if(view.parent != nil) {
        self.mViewParent = view.parent;
        if([self.mViewParent GetId] == self.mFragmentId) {
            self.mViewParent.navController = self.mNavController;
        }
    }
}

-(void)onInflate:(LuaContext *)context :(NSDictionary *)attrs :(NSMutableDictionary *)savedInstanceState {
    [super onInflate:context :attrs :savedInstanceState];
    
    self.mGraphId = [[LGIdParser getInstance] getId:[attrs objectForKey:@"navGraph"]];
    NSString *defaultNavHost = [attrs objectForKey:@"defaultNavHost"];
    if(defaultNavHost != nil) {
        self.mDefaultNavHost = SSTOB(defaultNavHost);
    }
}

- (void)onSaveInstanceState:(NSMutableDictionary *)outState {
    [super onSaveInstanceState:outState];
    NSMutableDictionary *navState = [self.mNavController saveState];
    if(navState == nil) {
        [outState setObject:navState forKey:@"android-support-nav:fragment:navControllerState"];
    }
    if(self.mDefaultNavHost) {
        [outState setObject:[NSNumber numberWithBool:true] forKey:@"android-support-nav:fragment:defaultHost"];
    }
    if(self.mGraphId != nil) {
        [outState setObject:self.mGraphId forKey:@"android-support-nav:fragment:graphId"];
    }
}

-(void)onDestroyView {
    [super onDestroyView];
    if(self.mViewParent != nil && [Navigation findViewNavControllerWithView:self.mViewParent] == self.mNavController) {
        [Navigation setViewNavControllerWithView:self.mViewParent controller:nil];
    }
    self.mViewParent = nil;
}

-(NSString*)GetId
{
    if(self.mFragmentId != nil)
        return self.mFragmentId;
    if(self.luaId != nil)
        return self.luaId;
    return [LuaNavHostFragment className];
}

+ (NSString*)className
{
    return @"LuaNavHostFragment";
}

+(NSMutableDictionary*)luaMethods
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    
    InstanceMethodNoArg(getNavControllerInternal, LuaNavController, @"getNavController")

    return dict;
}

@end
