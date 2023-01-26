#import "LuaFragment.h"
#import "LuaEvent.h"
#import "Defines.h"
#import "LuaFunction.h"
#import "LuaValues.h"
#import "LGLayoutParser.h"
#import "LGViewGroup.h"
#import "CommonDelegate.h"
#import "DisplayMetrics.h"
#import "LuaTranslator.h"
#import "LuaMutableLiveData.h"
#import <Topping/Topping-Swift.h>

@implementation LuaFragmentContainer

-(instancetype)initWithFragment:(LuaFragment*)fragment {
    self = [self init];
    self.fragment = fragment;
    return self;
}

- (LGView *)onFindViewByIdWithIdVal:(NSString *)idVal {
    if(self.fragment.lgview == nil) {
        return nil;
    }
    return [self.fragment.lgview getViewByIdInternal:idVal];
}

-(BOOL)onHasView {
    return self.fragment.lgview != nil;
}

-(LuaFragment *)instantiateWithContext:(LuaContext *)context arguments:(NSDictionary<NSString *,id> *)arguments {
    return [LuaFragment create:context :[LuaRef withValue:@""]];
}

@end

@implementation OnPreAttachedListener

-(void)onPreAttached {
    
}

@end

@implementation LuaFragment

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.mState = FS_INITIALIZING;
        self.mMaxState = LIFECYCLESTATE_RESUMED;
        self.mWho = [[NSUUID UUID] UUIDString];
        self.mTargetWho = nil;
        self.mChildFragmentManager = [[FragmentManager alloc] init];
        [self initLifecycle];
    }
    return self;
}

+(LuaFragment*)create:(LuaContext*)context :(LuaRef*)luaId
{
    LuaFragment *lf = [[LuaFragment alloc] init];
    lf.luaId = [luaId getCleanId];
    lf.context = context;
    return lf;
}

+(LuaFragment*)create:(LuaContext*)context :(LuaRef*)luaId :(NSMutableDictionary*)arguments
{
    LuaFragment *lf = [[LuaFragment alloc] init];
    lf.luaId = [luaId getCleanId];
    lf.context = context;
    lf.mArguments = arguments;
    return lf;
}

+(LuaFragment*)createWithUI:(LuaContext *)context :(LuaRef *)luaId :(LuaRef*)ui :(NSMutableDictionary*)arguments
{
    LuaFragment *lf = [[LuaFragment alloc] init];
    lf.luaId = [luaId getCleanId];
    lf.context = context;
    lf.ui = ui;
    lf.mArguments = arguments;
    return lf;
}

-(LuaContext*)getContext
{
    return self.context;
}

-(LuaForm *)getForm
{
    return [self.mHost getActivity];
}

-(FragmentManager*)getFragmentManager
{
    return self.mHost.fragmentManager;
}

-(LGView*)getViewById:(LuaRef*)lId
{
    return [_lgview getViewById:lId];
}

-(LGView *)getViewByIdInternal:(NSString *)sId
{
    return [_lgview getViewByIdInternal:sId];
}

-(LGView *)getView
{
    return self.lgview;
}

-(void)setView:(LGView*)v
{
    self.lgview = v;
}

-(void)setViewXML:(LuaRef *)xml
{
    LGView *lgview;
    [[LGLayoutParser getInstance] parseRef:xml :[DisplayMetrics getMasterView] :nil :[LuaForm getActiveForm] :&lgview];
    self.lgview = lgview;
}

-(void)setViewId:(NSString *)luaId
{
    self.luaId = luaId;
}

-(void)setTitle:(NSString *)str
{
    [[LuaForm getActiveForm] setTitle:str];
}

-(void)setTitleRef:(LuaRef *)ref
{
    NSString *val = (NSString*)[[LGValueParser getInstance] getValue:ref.idRef];
    [self setTitle:val];
}

-(void)close
{
    [[LuaForm getActiveForm] close];
}

-(LuaNavController*)getNavController
{
    return [[LuaNavController alloc] initWithController:[LuaNavHostFragment findNavController:self]];
}

-(void)initLifecycle {
    self.mLifecycleRegistry = [[LifecycleRegistry alloc] initWithOwner:self];
    self.mSavedStateRegistryController = [[SavedStateRegistryController alloc] initWithOwner:self];
    self.mDefaultFactory = nil;
}

-(BOOL)isInitialized
{
    return YES;
}

-(NSDictionary*)getBindings {
    if([self getView] != nil) {
        if([[self getView] isKindOfClass:[LGViewGroup class]]) {
            return [((LGViewGroup*)[self getView]) getBindings];
        }
    }
    return @{};
}

-(NSMutableDictionary*)requireSavedInstanceState:(NSMutableDictionary*)dict {
    if(dict == nil)
        return [NSMutableDictionary new];
    else
        return dict;
}

-(void)onCreate:(NSMutableDictionary *)savedInstanceState {
    self.kotlinInterface = [LuaEvent getFragmentInstance:self.luaId :self];
    if(self.kotlinInterface != nil) {
        [self.kotlinInterface.ltOnCreate call:[[LuaBundle alloc] initWithBundle:[self requireSavedInstanceState:savedInstanceState]]];
    }
    [LuaEvent onUIEvent:self :UI_EVENT_CREATE :self.context :1, [[LuaBundle alloc] initWithBundle:[self requireSavedInstanceState:savedInstanceState]], nil];
}

-(LGView*)onCreateView:(LGLayoutParser*)inflater :(LGViewGroup *)container :(NSMutableDictionary *)savedInstanceState {
    LGView *viewToRet = nil;
    viewToRet = (LGView*)[LuaEvent onUIEvent:self :UI_EVENT_FRAGMENT_CREATE_VIEW :self.context :3,
                     [LuaViewInflator from:inflater], container, [[LuaBundle alloc] initWithBundle:[self requireSavedInstanceState:savedInstanceState]], nil];
    if(viewToRet == nil && self.kotlinInterface != nil) {
        viewToRet = (LGView*)[self.kotlinInterface.ltOnCreateView callIn:self.context, [LuaViewInflator from:inflater], container, [[LuaBundle alloc] initWithBundle:[self requireSavedInstanceState:savedInstanceState]], nil];
    }
    return viewToRet;
}

-(void)onViewCreated:(LGView *)view :(NSMutableDictionary *)savedInstanceState {
    if(self.kotlinInterface != nil) {
        [self.kotlinInterface.ltOnViewCreated call:view :[self requireSavedInstanceState:savedInstanceState]];
    }
    [LuaEvent onUIEvent:self :UI_EVENT_FRAGMENT_VIEW_CREATED :self.context :2, view, [[LuaBundle alloc] initWithBundle:[self requireSavedInstanceState:savedInstanceState]], nil];
}

-(void)onActivityCreated:(NSMutableDictionary *)savedInstanceState {
    self.mCalled = true;
}

-(void)onViewStateRestored:(NSMutableDictionary *)savedInstanceState {
    self.mCalled = true;
}

-(void)onStart {
    self.mCalled = true;
}

-(void)onResume {
    self.mCalled = true;
    if(self.kotlinInterface != nil) {
        [self.kotlinInterface.ltOnResume call];
    }
    [LuaEvent onUIEvent:self :UI_EVENT_RESUME :self.context :0, nil];
}

- (void)onSaveInstanceState:(NSMutableDictionary *)outState {
    [outState addEntriesFromDictionary:[self.lgview onSaveInstanceState]];
}

-(void)onPause {
    self.mCalled = true;
    if(self.kotlinInterface != nil) {
        [self.kotlinInterface.ltOnPause call];
    }
    [LuaEvent onUIEvent:self :UI_EVENT_PAUSE :self.context :0, nil];
}

-(void)onStop {
    self.mCalled = true;
}

-(void)onLowMemory {
    self.mCalled = true;
}

-(void)onDestroyView {
    self.mCalled = true;
    if(self.kotlinInterface != nil) {
        [self.kotlinInterface.ltOnDestroy call];
    }
    [LuaEvent onUIEvent:self :UI_EVENT_DESTROY :self.context :0, nil];
}

-(void)onDestroy {
    self.mCalled = true;
}

-(void)initState
{
    [self initLifecycle];
    self.mPreviousWho = self.mWho;
    self.mWho = [[NSUUID UUID] UUIDString];
    self.mAdded = false;
    self.mRemoving = false;
    self.mFromLayout = false;
    self.mInLayout = false;
    self.mRestored = false;
    self.mBackStackNesting = 0;
    self.mFragmentManager = nil;
    self.mChildFragmentManager = [[FragmentManager alloc] init];
    self.mHost = nil;
    self.mFragmentId = 0;
    self.mContainerId = 0;
    self.mTag = nil;
    self.mHidden = false;
    self.mDetached = false;
}

-(void)onDetach {
    self.mCalled = true;
}

-(void)onPrimaryNavigationChanged:(BOOL)isPrimaryNavigationFragment {
    
}

-(FragmentManager *)getParentFragmentManager {
    return self.mFragmentManager;
}

-(FragmentManager *)getChildFragmentManager {
    return self.mChildFragmentManager;
}

- (LuaFragment *)findFragmentByWho:(NSString *)who {
    if(who == self.mWho)
    {
        return self;
    }
    return [self.mChildFragmentManager findFragmentByWhoWithWho:who];
}

- (void)onHiddenChanged:(BOOL)hidden {
    
}

- (BOOL)isHidden {
    return self.mHidden;
}

- (BOOL)isInBackStack {
    return self.mBackStackNesting > 0;
}

-(void)setArguments:(NSMutableDictionary*)args {
    if(self.mFragmentManager != nil && [self isStateSaved]) {
        return;
    }
    self.mArguments = args;
}

-(NSMutableDictionary*)getArguments {
    return self.mArguments;
}

-(LuaBundle *)getArgumentsBundle {
    return [[LuaBundle alloc] initWithBundle:[self getArguments]];
}

-(BOOL)isStateSaved {
    if(self.mFragmentManager == nil)
        return false;
    
    return [self.mFragmentManager isStateSaved];
}

-(void)setPopDirection:(BOOL)direction {
    
}

-(void)setNextTransition:(NSInteger)transition {
    
}

- (void)setAnimations:(NSString*)enter :(NSString*)exit :(NSString*)popEnter :(NSString*)popExit {
    
}

- (LGLayoutParser *)getLayoutInflater {
    return [LGLayoutParser getInstance];
}

-(LGLayoutParser *)getLayoutInflater:(NSMutableDictionary *)savedInstanceState {
    return [LGLayoutParser getInstance];
}

-(LGLayoutParser *)onGetLayoutInflater:(NSMutableDictionary *)savedInstanceState {
    return [self getLayoutInflater:savedInstanceState];
}

-(id<ViewModelProviderFactory>)getDefaultViewModelProviderFactory {
    if(self.mFragmentManager == nil) {
        return nil;
    }
    if(self.mDefaultFactory == nil) {
        self.mDefaultFactory = [[SavedStateViewModelFactory alloc] initWithContext:self.context owner:self defaultArgs:[self getArguments]];
    }
    
    return self.mDefaultFactory;
}

-(LGLayoutParser *)performGetLayoutInflater:(NSMutableDictionary *)savedInstanceState {
    return [self onGetLayoutInflater:savedInstanceState];
}

-(void)onInflate:(LuaContext*)context :(NSDictionary*)attrs :(NSMutableDictionary*)savedInstanceState {
    self.mCalled = true;
    LuaForm *form = self.mHost == nil ? nil : [self.mHost getActivity];
    if(form != nil) {
        self.mCalled = false;
        [self onInflateForm:form :attrs :savedInstanceState];
    }
}

-(void)onInflateForm:(LuaForm*)form :(NSDictionary*)attrs :(NSMutableDictionary*)savedInstanceState {
    self.mCalled = true;
}

- (void)onAttachFragment:(LuaFragment *)fragment {
    
}

- (void)onPrimaryNavigationFragmentChanged:(BOOL)isPrimaryNavigationFragment {
    
}

-(void)onAttach:(LuaContext *)context
{
    self.mCalled = true;
    if(self.context == nil) {
        self.context = context;
    }
}

-(void)restoreChildFragmentState:(NSMutableDictionary *)savedInstanceState {
    if(savedInstanceState != nil) {
        NSObject *data = [savedInstanceState objectForKey:SAVED_STATE_TAG];
        if(data != nil) {
            [self.mChildFragmentManager restoreSaveStateInternalWithState:(FragmentManagerState*)data];
            [self.mChildFragmentManager dispatchCreate];
        }
    }
}

-(id<FragmentContainer>)createFragmentContainer {
    return [[LuaFragmentContainer alloc] initWithFragment:self];
}

-(SavedStateRegistry *)getSavedStateRegistry {
    return [self.mSavedStateRegistryController getSavedStateRegistry];
}

-(NSInteger)getMinimumLifecycleState {
    if(self.mMaxState == LIFECYCLESTATE_INITIALIZED || self.mParentFragment == nil) {
        return (NSInteger)self.mMaxState;
    }
    return (NSInteger)MIN(self.mMaxState, [self.mParentFragment getMinimumLifecycleState]);
}

-(ViewModelStore *)getViewModelStore {
    if(self.mFragmentManager == nil) {
        return nil;
    }
    if([self getMinimumLifecycleState] == LIFECYCLESTATE_INITIALIZED) {
        return nil;
    }
    return [self.mFragmentManager getViewModelStoreWithF:self];
}

-(void)performAttach {
    for(OnPreAttachedListener *listener in self.mOnPreAttachedListeners) {
        [listener onPreAttached];
    }
    [self.mOnPreAttachedListeners removeAllObjects];
    [self.mChildFragmentManager attachControllerWithHost:self.mHost container:[self createFragmentContainer] parent:self];
    self.mState = FS_ATTACHED;
    self.mCalled = false;
    [self onAttach:[self.mHost getContext]];
    [self.mFragmentManager dispatchOnAttachFragmentWithFragment:self];
    [self.mChildFragmentManager dispatchAttach];
}

-(void)performCreate:(NSMutableDictionary *)savedInstanceState {
    [self.mChildFragmentManager noteStateNotSaved];
    self.mState = FS_CREATED;
    self.mCalled = false;
    LifecycleEventObserverO *leo = [[LifecycleEventObserverO alloc] initWithObject:self];
    leo.onStateChangedO = ^(id<LifecycleOwner> source, LifecycleEvent event) {
        if(event == LIFECYCLEEVENT_ON_STOP) {
            if(self.lgview != nil) {
                //cancel input
            }
        }
    };
    [self.mLifecycleRegistry addObserver:leo];
    [self .mSavedStateRegistryController performRestoreWithSavedStrate:savedInstanceState];
    [self onCreate:savedInstanceState];
    self.mIsCreated = true;
    if(!self.mCalled) {
        return;
    }
    [self.mLifecycleRegistry handleLifecycleEvent:LIFECYCLEEVENT_ON_CREATE];
}

-(void)performCreateView:(LGLayoutParser*) inflater :(LGViewGroup*) container :(NSMutableDictionary *)savedInstanceState {
    [self.mChildFragmentManager noteStateNotSaved];
    self.mPerformedCreateView = true;
    self.mViewLifecycleOwner = [[FragmentViewLifecycleOwner alloc] initWithFragment:self viewModelStore:[self getViewModelStore]];
    self.lgview = [self onCreateView:inflater :container :savedInstanceState];
    if(self.lgview != nil) {
        [self.mViewLifecycleOwner initialize];
        //TODO
        //ViewTreeLifecycle?
        [self.mViewLifecycleOwnerLiveData setValue:self.mViewLifecycleOwner];
    } else {
        if([self.mViewLifecycleOwner isInitialized]) {
            return;
        }
        self.mViewLifecycleOwner = nil;
    }
}

-(void)performViewCreated {
    [self onViewCreated:self.lgview :self.mSavedFragmentState];
    [self.mChildFragmentManager dispatchViewCreated];
}

-(void)performActivityCreated:(NSMutableDictionary *)savedInstanceState {
    [self.mChildFragmentManager noteStateNotSaved];
    self.mState = FS_AWAITING_EXIT_EFFECTS;
    self.mCalled = false;
    [self onActivityCreated:savedInstanceState];
    if(!self.mCalled) {
        return;
    }
    [self restoreViewState];
    [self.mChildFragmentManager dispatchActivityCreated];
}

-(void)restoreViewState {
    if(self.lgview != nil) {
        [self restoreViewState:self.mSavedFragmentState];
    }
    self.mSavedFragmentState = nil;
}

-(void)restoreViewState:(NSMutableDictionary*)savedInstanceState {
    if(self.mSavedViewState != nil) {
        //TODO
        //[self.lgview restoreHierarchyState:self.mSavedViewState];
        self.mSavedViewState = nil;
    }
    if(self.lgview != nil) {
        [self.mViewLifecycleOwner performRestoreWithSavedState:self.mSavedViewState];
        self.mSavedViewRegistryState = nil;
    }
    self.mCalled = false;
    [self onViewStateRestored:savedInstanceState];
    if(self.mCalled == false) {
        return;
    }
    if(self.lgview != nil) {
        [self.mViewLifecycleOwner handleLifecycleEventWithEvent:LIFECYCLEEVENT_ON_CREATE];
    }
}

-(void)performStart {
    [self.mChildFragmentManager noteStateNotSaved];
    [self.mChildFragmentManager execPendingActionsWithAllowStateLoss:true];
    self.mState = FS_STARTED;
    self.mCalled = false;
    [self onStart];
    if(!self.mCalled) {
        return;
    }
    [self.mLifecycleRegistry handleLifecycleEvent:LIFECYCLEEVENT_ON_START];
    if(self.lgview != nil) {
        [self.mViewLifecycleOwner handleLifecycleEventWithEvent:LIFECYCLEEVENT_ON_START];
    }
    [self.mChildFragmentManager dispatchStart];
}

-(void)performResume {
    [self.mChildFragmentManager noteStateNotSaved];
    [self.mChildFragmentManager execPendingActionsWithAllowStateLoss:true];
    self.mState = FS_RESUMED;
    self.mCalled = false;
    [self onResume];
    if(!self.mCalled) {
        return;
    }
    [self.mLifecycleRegistry handleLifecycleEvent:LIFECYCLEEVENT_ON_RESUME];
    if(self.lgview != nil) {
        [self.mViewLifecycleOwner handleLifecycleEventWithEvent:LIFECYCLEEVENT_ON_RESUME];
    }
    [self.mChildFragmentManager dispatchResume];
}

-(void)noteStateNotSaved {
    [self.mChildFragmentManager noteStateNotSaved];
}

-(void)performPrimaryNavigationFragmentChanged {
    BOOL isPrimaryNavigationFragment = [self.mFragmentManager isPrimaryNavigationWithParent:self];
    if(self.mIsPrimaryNavigationFragment == nil || [self.mIsPrimaryNavigationFragment boolValue] != isPrimaryNavigationFragment) {
        self.mIsPrimaryNavigationFragment = [NSNumber numberWithBool:isPrimaryNavigationFragment];
        [self onPrimaryNavigationChanged:isPrimaryNavigationFragment];
        [self.mChildFragmentManager dispatchPrimaryNavigationFragmentChanged];
    }
}

-(void)performSaveInsanceState:(NSMutableDictionary *)outState {
    [self onSaveInstanceState:outState];
    outState = [self.mSavedStateRegistryController performSaveWithOutBundle:outState].mutableCopy;

    FragmentManagerState *p = [self.mChildFragmentManager saveAllStateInternal];
    if(p != nil) {
        [outState setObject:p forKey:SAVED_STATE_TAG];
    }
}

-(void)performPause {
    [self.mChildFragmentManager dispatchPause];
    if(self.lgview != nil) {
        [self.mViewLifecycleOwner handleLifecycleEventWithEvent:LIFECYCLEEVENT_ON_PAUSE];
    }
    [self.mLifecycleRegistry handleLifecycleEvent:LIFECYCLEEVENT_ON_PAUSE];
    self.mState = FS_AWAITING_ENTER_EFFECTS;
    self.mCalled = false;
    [self onPause];
    if(!self.mCalled) {
        return;
    }
}

-(void)performStop {
    [self.mChildFragmentManager dispatchStop];
    if(self.lgview != nil) {
        [self.mViewLifecycleOwner handleLifecycleEventWithEvent:LIFECYCLEEVENT_ON_STOP];
    }
    [self.mLifecycleRegistry handleLifecycleEvent:LIFECYCLEEVENT_ON_STOP];
    self.mState = FS_ACTIVITY_CREATED;
    self.mCalled = false;
    [self onStop];
    if(!self.mCalled) {
        return;
    }
}

-(void)performDestroyView {
    [self.mChildFragmentManager dispatchDestroyView];
    if(self.lgview != nil && [Lifecycle isAtLeast:[[self.mViewLifecycleOwner getLifecycle] getCurrentState] :LIFECYCLESTATE_CREATED]) {
        [self.mViewLifecycleOwner handleLifecycleEventWithEvent:LIFECYCLEEVENT_ON_DESTROY];
    }
    self.mState = FS_CREATED;
    self.mCalled = false;
    [self onDestroyView];
    if(!self.mCalled) {
        return;
    }
    //?TODO mark
    self.mPerformedCreateView = false;
}

-(void)performDestory {
    [self.mChildFragmentManager dispatchDestroy];
    [self.mLifecycleRegistry handleLifecycleEvent:LIFECYCLEEVENT_ON_DESTROY];
    self.mState = FS_ATTACHED;
    self.mCalled = false;
    self.mIsCreated = false;
    [self onDestroy];
    if(!self.mCalled) {
        return;
    }
}

-(void)performDetach {
    self.mState = FS_INITIALIZING;
    self.mCalled = false;
    [self onDetach];
    //self.mLayoutInflater = nil;
    if(!self.mCalled) {
        return;
    }
    if(![self.mChildFragmentManager isDestroyed]) {
        [self.mChildFragmentManager dispatchDestroy];
        self.mChildFragmentManager = [[FragmentManager alloc] init];
    }
}

- (Lifecycle *)getLifecycle {
    return self.mLifecycleRegistry;
}

-(NSString*)GetId
{
    if(self.luaId == nil)
        return @"LuaFragment";
    return self.luaId;
}

+ (NSString*)className
{
    return @"LuaFragment";
}

+(NSMutableDictionary*)luaMethods
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    ClassMethod(create::, LuaFragment, @[[LuaContext class]C [LuaRef class]], @"create", [LuaFragment class])
    ClassMethod(create:::, LuaFragment, @[[LuaContext class]C [LuaRef class]C [NSDictionary class]], @"createWithArgs", [LuaFragment class])
    ClassMethod(createWithUI:::, LuaFragment, @[[LuaContext class]C [LuaRef class]C [LuaRef class]], @"createWithUI", [LuaFragment class])
    
    InstanceMethodNoArg(getContext, LuaContext, @"getContext")
    InstanceMethodNoArg(getForm, LuaForm, @"getForm")
    InstanceMethod(getViewById:, LGView, @[[LuaRef class]], @"getViewById")
    InstanceMethodNoArg(getView, LGView, @"getView")
    InstanceMethodNoRet(setView:, @[[LGView class]], @"setView")
    InstanceMethodNoRet(setViewXML:, @[[LuaRef class]], @"setViewXML")
    InstanceMethodNoRet(setViewId:, @[[NSString class]], @"setViewId")
    InstanceMethodNoRet(setTitle:, @[[NSString class]], @"setTitleInternal")
    InstanceMethodNoRet(setTitleRef:, @[[LuaRef class]], @"setTitle")
    InstanceMethodNoRetNoArg(close, @"close")
    InstanceMethodNoArg(getArgumentsBundle, LuaBundle, @"getArguments")
    InstanceMethodNoArg(getNavController, LuaNavController, @"getNavController")
    InstanceMethodNoArg(isInitialized, LuaBool, @"isInitialized")
    InstanceMethodNoArg(getFragmentManager, FragmentManager, @"getFragmentManager")
    InstanceMethodNoArg(getBindings, NSMutableDictionary, @"getBindings")
    
    return dict;
}

@end
