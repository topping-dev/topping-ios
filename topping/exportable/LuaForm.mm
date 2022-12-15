#import "LuaForm.h"
#import "Defines.h"
#import "LuaFunction.h"
#import "LuaValues.h"
#import "LGLayoutParser.h"
#import "CommonDelegate.h"
#import "DisplayMetrics.h"
#import "LuaTranslator.h"
#import <topping/topping-Swift.h>

@implementation LuaForm

static NSMutableDictionary* eventMap = [NSMutableDictionary dictionary];

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
        
        [[self getSavedStateRegistry] registerSavedStateProviderWithKey:@"android:support:fragments" provider:[[LuaFormSavedStateProvider alloc] initWithForm:self]];
        
        self.mStopped = true;
    }
    return self;
}

+(BOOL)OnFormEvent:(NSObject*)pGui :(int) EventType :(LuaContext*)lc :(int)ArgCount, ...
{
    NSObject <LuaInterface> *s = (NSObject <LuaInterface> *)pGui;
    LuaTranslator *ltToCall;
    ltToCall = [eventMap objectForKey:APPEND([s GetId], ITOS(EventType))];
    if(ltToCall != nil)
    {
        va_list ap;
        va_start(ap, ArgCount);
        [ltToCall CallInSelf:pGui :lc :ap];
        va_end(ap);
        return YES;
    }
    return NO;
}

+(void)RegisterFormEventRef:(LuaRef *)luaId :(int)event :(LuaTranslator *)lt
{
    [LuaForm RegisterFormEvent:[luaId GetCleanId] :event :lt];
}

+(void)RegisterFormEvent:(NSString *)luaId :(int)event :(LuaTranslator *)lt
{
    [eventMap setObject:lt forKey:APPEND(luaId, ITOS(event))];
}

+(void)Create:(LuaContext*)context :(NSString*)luaId
{
	LuaForm *form = [[LuaForm alloc] initWithContext:context];
	form.luaId = luaId;
	[context.navController pushViewController:form animated:YES];
}

+(void)CreateWithUI:(LuaContext *)context :(NSString *)luaId :(NSString*)ui
{
	LuaForm *form = [[LuaForm alloc] initWithContext:context];
	form.luaId = luaId;
	form.ui = ui;
	[context.navController pushViewController:form animated:YES];
}

+(NSObject*)CreateForTab:(LuaContext*)context :(NSString*)luaId
{
	LuaForm *form = [[LuaForm alloc] initWithContext:context];
	form.luaId = luaId;
	return form;
}

+(LuaForm*)GetActiveForm
{
	return [CommonDelegate GetActiveForm];
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    if([CommonDelegate GetInstance].statusBarIsDark)
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
	self.view.frame = [DisplayMetrics GetMasterView].frame;
	if(self.ui != nil)
		[self SetViewXML:self.ui];
    
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
    
    UIColor *statusBarColor = (UIColor*)[[LGStyleParser GetInstance] GetStyleValue:[sToppingEngine GetAppStyle] :@"colorPrimaryDark"];
    if(statusBarColor != nil)
    {
        UIView *statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, -[DisplayMetrics GetStatusBarHeight], [UIScreen mainScreen].bounds.size.width, [DisplayMetrics GetStatusBarHeight])];
        statusBarView.backgroundColor = statusBarColor;
        BOOL statusBarIsDark = [CommonDelegate GetInstance].statusBarIsDark;
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
	[CommonDelegate SetActiveForm:self];
    [DisplayMetrics SetMasterView:self.view];
    
    if(self.view.superview != nil && !self.rootConstraintsSet) {
        [self setConstraints];
    }
    
	[super viewWillAppear:animated];
	[KeyboardHelper KeyboardEnableEvents:self];
    
    //onResume
    self.mResumed = true;
    [self.mFragments noteStateNotSaved];
    [self.mFragments execPendingActions];
    if(!self.createCalled)
    {
        self.createCalled = true;
        [LuaForm OnFormEvent:self :FORM_EVENT_CREATE :self.context :0, nil];
    }
    [self.lifecycleRegistry handleLifecycleEvent:LIFECYCLEEVENT_ON_RESUME];
    [self.mFragments dispatchResume];
    [LuaForm OnFormEvent:self :FORM_EVENT_RESUME :self.context :0, nil];
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
	[LuaForm OnFormEvent:self :FORM_EVENT_PAUSE :self.context :0, nil];
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
    [LuaForm OnFormEvent:self :FORM_EVENT_DESTROY :self.context :0, nil];
    [self.lifecycleRegistry handleLifecycleEvent:LIFECYCLEEVENT_ON_DESTROY];
}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        //NSLog(@"Transition Size %@", NSStringFromCGSize(size));
        [self.lgview ResizeAndInvalidate];
    }];
}

-(void)viewDidLayoutSubviews {
    /*NSLog(@"superview 2 %@ %@", self.luaId, self.view.superview);
    NSLog(@"superview frame %@ %@", self.luaId, NSStringFromCGRect(self.view.frame));
    NSLog(@"superview class string %@", NSStringFromClass([self.view.superview class]));*/
    [self.lgview viewDidLayoutSubviews];
    [self.lgview ResizeAndInvalidate];
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
    NSString *val = (NSString*)[[LGStyleParser GetInstance] GetStyleValue:[sToppingEngine GetAppStyle] :@"iosBottomSafeArea"];
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

-(LuaContext*)GetContext
{
	return self.context;
}

-(LGView*)GetViewById:(LuaRef*)lId
{
	return [_lgview GetViewById:lId];
}

-(LGView*)GetViewByIdInternal:(NSString *)sId
{
    return [_lgview GetViewByIdInternal:sId];
}

-(NSDictionary*)GetBindings
{
    if([self.lgview isKindOfClass:[LGViewGroup class]])
    {
        return [((LGViewGroup*)self.lgview) GetBindings];
    }
    return [NSDictionary dictionary];
}

-(LGView *)GetView
{
	return self.lgview;
}

-(void)SetView:(LGView*)v
{
	self.lgview = v;
	self.view = [v GetView];
}

-(void)SetViewXML:(NSString *)xml
{
	LGView *lgview;
    [self AddMainView:[[LGLayoutParser GetInstance] ParseXML:xml :[DisplayMetrics GetMasterView] :nil :self :&lgview]];
	self.lgview = lgview;
}

-(void)SetTitle:(NSString *)str
{
	self.title = str;
}

-(void)SetTitleRef:(LuaRef *)ref
{
    NSString *val = (NSString*)[[LGValueParser GetInstance] GetValue:ref.idRef];
    [self SetTitle:val];
}

-(void)Close
{
	[self.context.navController popViewControllerAnimated:YES];
}

- (BOOL)isChangingConfigurations {
    return true;
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

-(FragmentManager*)GetFragmentManager {
    return [self.mFragments getSupportFragmentManager];
}

-(Lifecycle *)getLifecycle {
    return [self.lifecycleOwner getLifecycle];
}

-(LuaLifecycle *)getLifecycleInner {
    return [LuaLifecycle CreateForm:self];
}

-(void)AddMainView:(UIView *)viewToAdd {
    [self.view addSubview:viewToAdd];
    [viewToAdd setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSLayoutConstraint *constraint;
    constraint = [self.view.safeAreaLayoutGuide.topAnchor constraintEqualToAnchor:viewToAdd.topAnchor];
    constraint.priority = UILayoutPriority(999);
    constraint.active = true;
    constraint = [self.view.safeAreaLayoutGuide.rightAnchor constraintEqualToAnchor:viewToAdd.rightAnchor];
    constraint.priority = UILayoutPriority(999);
    constraint.active = true;
    NSString *val = (NSString*)[[LGStyleParser GetInstance] GetStyleValue:[sToppingEngine GetAppStyle] :@"iosBottomSafeArea"];
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

+(NSMutableDictionary*)luaStaticVars
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[NSNumber numberWithInt:0] forKey:@"FORM_EVENT_CREATE"];
    [dict setObject:[NSNumber numberWithInt:1] forKey:@"FORM_EVENT_RESUME"];
    [dict setObject:[NSNumber numberWithInt:2] forKey:@"FORM_EVENT_PAUSE"];
    [dict setObject:[NSNumber numberWithInt:3] forKey:@"FORM_EVENT_DESTROY"];
    [dict setObject:[NSNumber numberWithInt:4] forKey:@"FORM_EVENT_UPDATE"];
    [dict setObject:[NSNumber numberWithInt:5] forKey:@"FORM_EVENT_PAINT"];
    [dict setObject:[NSNumber numberWithInt:6] forKey:@"FORM_EVENT_MOUSEDOWN"];
    [dict setObject:[NSNumber numberWithInt:7] forKey:@"FORM_EVENT_MOUSEUP"];
    [dict setObject:[NSNumber numberWithInt:8] forKey:@"FORM_EVENT_MOUSEMOVE"];
    [dict setObject:[NSNumber numberWithInt:9] forKey:@"FORM_EVENT_KEYDOWN"];
    [dict setObject:[NSNumber numberWithInt:10] forKey:@"FORM_EVENT_KEYUP"];
    [dict setObject:[NSNumber numberWithInt:11] forKey:@"FORM_EVENT_NFC"];
    return dict;
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(RegisterFormEvent:::))
                               :@selector(RegisterFormEvent:::)
                               :nil
                               :[NSArray arrayWithObjects:[NSString class], [LuaInt class], [LuaTranslator class], nil]
                               :[LuaForm class]]
             forKey:@"RegisterFormEvent"];
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(Create::)) 
										:@selector(Create::) 
										:nil
										:[NSArray arrayWithObjects:[LuaContext class], [NSString class], nil] 
										:[LuaForm class]] 
			 forKey:@"Create"];
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(CreateWithUI:::)) 
										:@selector(CreateWithUI:::) 
										:nil
										:[NSArray arrayWithObjects:[LuaContext class], [NSString class], [NSString class], nil] 
										:[LuaForm class]] 
			 forKey:@"CreateWithUI"];
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(CreateForTab::)) 
										:@selector(CreateForTab::) 
										:[NSObject class]
										:[NSArray arrayWithObjects:[LuaContext class], [NSString class], nil] 
										:[LuaForm class]] 
			 forKey:@"CreateForTab"];
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(GetActiveForm)) 
										:@selector(GetActiveForm) 
										:[NSObject class]
										:[NSArray arrayWithObjects:nil] 
										:[LuaForm class]] 
			 forKey:@"GetActiveForm"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(GetContext)) :@selector(GetContext) :[LuaContext class] :MakeArray(nil)] forKey:@"GetContext"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(GetViewById:)) :@selector(GetViewById:) :[LGView class] :MakeArray([LuaRef class]C nil)] forKey:@"GetViewById"];
    InstanceMethodNoArg(GetBindings, MakeArray([NSDictionary class]C nil), @"GetBindings")
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(GetView)) :@selector(GetView) :[LGView class] :MakeArray(nil)] forKey:@"GetView"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetView:)) :@selector(SetView:) :nil :MakeArray([LGView class] C nil)] forKey:@"SetView"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetViewXML:)) :@selector(SetViewXML:) :nil :MakeArray([NSString class] C nil)] forKey:@"SetViewXML"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetTitle:)) :@selector(SetTitle:) :nil :MakeArray([NSString class] C nil)] forKey:@"SetTitle"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetTitleRef:)) :@selector(SetTitleRef:) :nil :MakeArray([LuaRef class] C nil)] forKey:@"SetTitleRef"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(Close)) :@selector(Close) :nil :MakeArray(nil)] forKey:@"Close"];
    InstanceMethodNoArg(getLifecycleInner, LuaLifecycle, @"GetLifecycle")
    InstanceMethodNoArg(GetFragmentManager, FragmentManager, @"GetFragmentManager")
	return dict;
}

KEYBOARD_FUNCTIONS_IMPLEMENTATION

@end
