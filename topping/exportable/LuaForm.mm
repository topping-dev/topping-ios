#import "LuaForm.h"
#import "LuaEvent.h"
#import "Defines.h"
#import "LuaFunction.h"
#import "LuaValues.h"
#import "LGLayoutParser.h"
#import "CommonDelegate.h"
#import "DisplayMetrics.h"
#import "LuaTranslator.h"
#import <topping/topping-Swift.h>

@implementation LuaForm

- (instancetype)initWithContext:(LuaContext *)context
{
    self = [super init];
    if (self) {
        self.context = context;
        self.viewModelProvider = [LuaViewModelProvider new];
        self.lifecycleOwner = [LuaLifecycleOwner new];
        self.lifecycleRegistry = [[LifecycleRegistry alloc] initWithOwner:self.lifecycleOwner];
        self.onBackPressedDispatcher = [[LuaFormOnBackPressedDispatcher alloc] initWithForm: self];
        self.mFragments = [FragmentController createControllerWithFragmentHostCallback:[[LuaFormHostCallback alloc] initWithForm:self]];
        [LGParser getInstance].pLayout = [[LGFragmentLayoutParser alloc] initWithFragmentManager:[self getSupportFragmentManager]];
        
        [[self getSavedStateRegistry] registerSavedStateProviderWithKey:@"android:support:fragments" provider:[[LuaFormSavedStateProvider alloc] initWithForm:self]];
        
        self.mStopped = true;
    }
    return self;
}

+(LuaFormIntent*)create:(LuaContext*)context :(LuaRef*)luaId
{
	LuaForm *form = [[LuaForm alloc] initWithContext:context];
	form.luaId = [luaId getCleanId];
    LuaFormIntent *formIntent = [[LuaFormIntent alloc] initWithBundle:[LuaBundle new]];
    formIntent.form = form;
    return formIntent;
}

+(LuaFormIntent*)createWithUI:(LuaContext *)context :(LuaRef *)luaId :(LuaRef*)ui
{
	LuaForm *form = [[LuaForm alloc] initWithContext:context];
	form.luaId = [luaId getCleanId];
    form.ui = ui;
    LuaFormIntent *formIntent = [[LuaFormIntent alloc] initWithBundle:[LuaBundle new]];
    formIntent.form = form;
    return formIntent;
}

+(LuaForm*)getActiveForm
{
	return [CommonDelegate getActiveForm];
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    if([CommonDelegate getInstance].statusBarIsDark)
        return UIStatusBarStyleLightContent;
    else
        return UIStatusBarStyleDefault;
}

-(BOOL)prefersStatusBarHidden
{
    return NO;
}

-(void) viewDidLoad
{
    [super viewDidLoad];
    //IOS 7 toolbar fix
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
	//CGRect fullFrame = [[UIScreen mainScreen] applicationFrame];
	//self.view.frame  = fullFrame;
	self.view.frame = [DisplayMetrics getMasterView].frame;
	if(self.ui != nil)
		[self setViewXML:self.ui];
    
    //onCreate
    self.mStopped = false;
    [self.lifecycleRegistry handleLifecycleEvent:LIFECYCLEEVENT_ON_CREATE];
    [self.mFragments dispatchCreate];
    
    //onStart
    self.mStopped = false;
    if(!self.mCreated) {
        self.mCreated = true;
        [self.mFragments dispatchActivityCreated];
    }
    [self.mFragments noteStateNotSaved];
    [self.mFragments execPendingActions];
    [self.lifecycleRegistry handleLifecycleEvent:LIFECYCLEEVENT_ON_START];
    [self.mFragments dispatchStart];
    [self.mFragments execPendingActions];
    
    [KeyboardHelper KeyboardEnableEventForView:self.view :self];
    
    UIColor *statusBarColor = (UIColor*)[[LGStyleParser getInstance] getStyleValue:[sToppingEngine getAppStyle] :@"colorPrimaryDark"];
    if(statusBarColor != nil)
    {
        UIView *statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, -[DisplayMetrics getStatusBarHeight], [UIScreen mainScreen].bounds.size.width, [DisplayMetrics getStatusBarHeight])];
        statusBarView.backgroundColor = statusBarColor;
        BOOL statusBarIsDark = [CommonDelegate getInstance].statusBarIsDark;
        if(!self.context.navController.isNavigationBarHidden)
        {
            if(statusBarIsDark)
                self.context.navController.navigationBar.barStyle = UIBarStyleBlack;
            else
                self.context.navController.navigationBar.barStyle = UIBarStyleDefault;
            [self.context.navController.navigationBar addSubview:statusBarView];
        }
        else
            [self.view insertSubview:statusBarView atIndex:0];
    }
}

-(void) viewWillAppear:(BOOL)animated
{
	[CommonDelegate setActiveForm:self];
    [DisplayMetrics setMasterView:self.view];
    
    if(self.view.superview != nil && !self.rootConstraintsSet) {
        [self setConstraints];
    }
    
	[super viewWillAppear:animated];
	[KeyboardHelper KeyboardEnableEvents:self];
    
    //onResume
    self.mResumed = true;
    [self.mFragments noteStateNotSaved];
    [self.mFragments execPendingActions];
    [self onCreate];
    [self.lifecycleRegistry handleLifecycleEvent:LIFECYCLEEVENT_ON_RESUME];
    [self.mFragments dispatchResume];
    [LuaEvent onUIEvent:self :UI_EVENT_RESUME :self.context :0, nil];
    if(self.kotlinInterface != nil) {
        [self.kotlinInterface.ltOnResume call];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    if(self.view.superview != nil && !self.rootConstraintsSet && [NSStringFromClass([self.view.superview class]) isEqualToString:@"UIViewControllerWrapperView"]) {
        [self setConstraints];
    }
}

-(void) viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[KeyboardHelper KeyboardDisableEvents:self :self.selectedKeyboardTextView];
    
    //onPause
	[LuaEvent onUIEvent:self :UI_EVENT_PAUSE :self.context :0, nil];
    if(self.kotlinInterface != nil) {
        [self.kotlinInterface.ltOnPause call];
    }
    [self.mFragments dispatchPause];
    [self.lifecycleRegistry handleLifecycleEvent:LIFECYCLEEVENT_ON_PAUSE];
    
    //onStop
    self.mStopped = true;
    [self markFragmentsCreated];
    [self.mFragments dispatchStop];
    [self.lifecycleRegistry handleLifecycleEvent:LIFECYCLEEVENT_ON_STOP];
    self.rootConstraintsSet = false;
}

-(void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.lifecycleRegistry handleLifecycleEvent:LIFECYCLEEVENT_ON_STOP];
    
    [self.mFragments noteStateNotSaved];
    
    //onDestroy
    [self.mFragments dispatchDestroy];
    [LuaEvent onUIEvent:self :UI_EVENT_DESTROY :self.context :0, nil];
    if(self.kotlinInterface != nil) {
        [self.kotlinInterface.ltOnDestroy call];
    }
    [self.lifecycleRegistry handleLifecycleEvent:LIFECYCLEEVENT_ON_DESTROY];
}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        //NSLog(@"Transition Size %@", NSStringFromCGSize(size));
        [self.lgview resizeAndInvalidate];
        [self.lgview configChange];
    }];
}

-(void)viewDidLayoutSubviews {
    /*NSLog(@"superview 2 %@ %@", self.luaId, self.view.superview);
    NSLog(@"superview frame %@ %@", self.luaId, NSStringFromCGRect(self.view.frame));
    NSLog(@"superview class string %@", NSStringFromClass([self.view.superview class]));*/
    [self.lgview viewDidLayoutSubviews];
    [self.lgview resizeAndInvalidate];
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)setConstraints {
    self.rootConstraintsSet = true;
    [self.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSLayoutConstraint *constraint;
    if(self.context.navController.isNavigationBarHidden)
    {
        constraint = [self.view.superview.safeAreaLayoutGuide.topAnchor constraintEqualToAnchor:self.view.topAnchor];
    }
    else
    {
        constraint = [self.view.superview.safeAreaLayoutGuide.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:-self.context.navController.navigationBar.frame.size.height];
    }
    constraint.priority = UILayoutPriority(999);
    constraint.active = true;
    constraint = [self.view.superview.safeAreaLayoutGuide.rightAnchor constraintEqualToAnchor:self.view.rightAnchor];
    constraint.priority = UILayoutPriority(999);
    constraint.active = true;
    NSString *val = (NSString*)[[LGStyleParser getInstance] getStyleValue:[sToppingEngine getAppStyle] :@"iosBottomSafeArea"];
    if([val isEqualToString:@"true"]) {
        constraint = [self.view.superview.safeAreaLayoutGuide.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor];
        constraint.priority = UILayoutPriority(999);
        constraint.active = true;
    }
    else {
        constraint = [self.view.superview.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor];
        constraint.priority = UILayoutPriority(999);
        constraint.active = true;
    }
    constraint = [self.view.superview.safeAreaLayoutGuide.leftAnchor constraintEqualToAnchor:self.view.leftAnchor];
    constraint.priority = UILayoutPriority(999);
    constraint.active = true;
}

-(LuaContext*)getContext
{
	return self.context;
}

-(LGView*)getViewById:(LuaRef*)lId
{
	return [_lgview getViewById:lId];
}

-(LGView*)getViewByIdInternal:(NSString *)sId
{
    return [_lgview getViewByIdInternal:sId];
}

-(NSDictionary*)getBindings
{
    if([self.lgview isKindOfClass:[LGViewGroup class]])
    {
        return [((LGViewGroup*)self.lgview) getBindings];
    }
    return [NSDictionary dictionary];
}

-(LGView *)getLuaView
{
	return self.lgview;
}

-(void)setLuaView:(LGView*)v
{
	self.lgview = v;
    [self addMainView:[v getView]];
}

-(void)setViewXML:(LuaRef *)xml
{
	LGView *lgview;
    [self addMainView:[[LGLayoutParser getInstance] parseRef:xml :[DisplayMetrics getMasterView] :nil :self :&lgview]];
	self.lgview = lgview;
}

-(void)setTitle:(NSString *)str
{
	self.title = str;
}

-(void)setTitleRef:(LuaRef *)ref
{
    NSString *val = (NSString*)[[LGValueParser getInstance] getValue:ref.idRef];
    [self setTitle:val];
}

-(void)close
{
	[self.context.navController popViewControllerAnimated:YES];
}

- (BOOL)isChangingConfigurations {
    return true;
}

- (void)onCreate {
    if(!self.createCalled)
    {
        self.createCalled = true;
        self.kotlinInterface = [LuaEvent getFormInstance:self.luaId :self];
        [LuaEvent onUIEvent:self :UI_EVENT_CREATE :self.context :0, nil];
        if(self.kotlinInterface != nil) {
            [self.kotlinInterface.ltOnCreate call];
        }
    }
}

-(void)onBackPressed {
    
}

-(ViewModelStore *)getViewModelStore {
    if(self.viewModelStore == nil) {
        self.viewModelStore = [[ViewModelStore alloc] init];
    }
    return self.viewModelStore;
}

-(SavedStateRegistry*)getSavedStateRegistry {
    return [self.savedStateRegistryController getSavedStateRegistry];
}

-(FragmentManager*)getSupportFragmentManager {
    return [self.mFragments getSupportFragmentManager];
}

-(void)markFragmentsCreated {
    BOOL reiterate;
    do {
        reiterate = [self markState:[self getSupportFragmentManager] :LIFECYCLESTATE_CREATED];
    } while(reiterate);
}

-(BOOL)markState:(FragmentManager*)manager :(LifecycleState)state {
    BOOL hadNotMarked = false;
    NSMutableArray* fragments = [manager getFragments];
    for(LuaFragment *fragment : fragments) {
        if(fragment == nil)
            continue;
        if(fragment.mHost != nil) {
            FragmentManager* childFragmentManager = [fragment getChildFragmentManager];
            hadNotMarked |= [self markState:childFragmentManager :state];
        }
        if(fragment.mViewLifecycleOwner != nil && [Lifecycle isAtLeast:[[fragment.mViewLifecycleOwner getLifecycle] getCurrentState] :LIFECYCLESTATE_STARTED])  {
            [fragment.mViewLifecycleOwner setCurrentStateWithState:state];
            hadNotMarked = true;
        }
        if([Lifecycle isAtLeast:[fragment.mLifecycleRegistry getCurrentState] :LIFECYCLESTATE_STARTED]) {
            [fragment.mLifecycleRegistry setCurrentState:state];
            hadNotMarked = true;
        }
    }
    return hadNotMarked;
}

-(FragmentManager*)getFragmentManager {
    return [self.mFragments getSupportFragmentManager];
}

-(Lifecycle *)getLifecycle {
    return [self.lifecycleOwner getLifecycle];
}

-(LuaLifecycle *)getLifecycleInner {
    return [LuaLifecycle createForm:self];
}

-(void)addMainView:(UIView *)viewToAdd {
    if(self.view == nil || viewToAdd == nil)
        return;
    for(int i = 0; i < self.view.subviews.count; i++) {
        UIView *subview = [self.view.subviews objectAtIndex:i];
        [subview removeFromSuperview];
    }
    [self.view addSubview:viewToAdd];
    [viewToAdd setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSLayoutConstraint *constraint;
    constraint = [self.view.safeAreaLayoutGuide.topAnchor constraintEqualToAnchor:viewToAdd.topAnchor];
    constraint.priority = UILayoutPriority(999);
    constraint.active = true;
    constraint = [self.view.safeAreaLayoutGuide.rightAnchor constraintEqualToAnchor:viewToAdd.rightAnchor];
    constraint.priority = UILayoutPriority(999);
    constraint.active = true;
    NSString *val = (NSString*)[[LGStyleParser getInstance] getStyleValue:[sToppingEngine getAppStyle] :@"iosBottomSafeArea"];
    if([val isEqualToString:@"true"]) {
        constraint = [self.view.safeAreaLayoutGuide.bottomAnchor constraintEqualToAnchor:viewToAdd.bottomAnchor];
        constraint.priority = UILayoutPriority(999);
        constraint.active = true;
    }
    else {
        constraint = [self.view.bottomAnchor constraintEqualToAnchor:viewToAdd.bottomAnchor];
        constraint.priority = UILayoutPriority(999);
        constraint.active = true;
    }
    constraint = [self.view.safeAreaLayoutGuide.leftAnchor constraintEqualToAnchor:viewToAdd.leftAnchor];
    constraint.priority = UILayoutPriority(999);
    constraint.active = true;
}

-(NSString*)GetId
{
	if(self.luaId == nil)
		return @"LuaForm";
	return self.luaId;
}

+ (NSString*)className
{
	return @"LuaForm";
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    ClassMethod(create::, LuaNativeObject, @[[LuaContext class]C [LuaRef class]], @"create", [LuaForm class])
    ClassMethod(createWithUI:::, LuaNativeObject, @[[LuaContext class]C [LuaRef class]C [LuaRef class]], @"createWithUI", [LuaForm class])
    ClassMethodNoArg(getActiveForm, [LuaForm class], @"getActiveForm", [LuaForm class])

    InstanceMethodNoArg(getContext, LuaContext, @"getContext")
    InstanceMethod(getViewById:, LGView, @[[LuaRef class]], @"getViewById")
    InstanceMethodNoArg(getBindings, NSDictionary, @"getBindings")
    InstanceMethodNoArg(getLuaView, LGView, @"getView")
    InstanceMethodNoRet(setLuaView:, @[[LGView class]], @"setView")
    InstanceMethodNoRet(setViewXML:, @[[LuaRef class]], @"setViewXML")
    InstanceMethodNoRet(setTitle:, @[[NSString class]], @"setTitle")
    InstanceMethodNoRet(setTitleRef:, @[[LuaRef class]], @"setTitleRef")
    InstanceMethodNoRetNoArg(close, @"close")
    InstanceMethodNoArg(getLifecycleInner, LuaLifecycle, @"getLifecycle")
    InstanceMethodNoArg(getSupportFragmentManager, FragmentManager, @"getFragmentManager")
    
	return dict;
}

KEYBOARD_FUNCTIONS_IMPLEMENTATION

@end
