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

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.context = [[LuaContext alloc] init];
        [self.context Setup:self];
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
	LuaForm *form = [[LuaForm alloc] init];
	form.luaId = luaId;
	form.context = context;
	[context.navController pushViewController:form animated:YES];
}

+(void)CreateWithUI:(LuaContext *)context :(NSString *)luaId :(NSString*)ui
{
	LuaForm *form = [[LuaForm alloc] init];
	form.luaId = luaId;
	form.context = context;
	form.ui = ui;
	[context.navController pushViewController:form animated:YES];
}

+(NSObject*)CreateForTab:(LuaContext*)context :(NSString*)luaId
{
	LuaForm *form = [[LuaForm alloc] init];
	form.luaId = luaId;
	form.context = context;
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
}

-(void) viewWillAppear:(BOOL)animated
{
	[CommonDelegate SetActiveForm:self];
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

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(LuaContext*)GetContext
{
	return self.context;
}

-(LGView*)GetViewById:(NSString*)lId
{
    if(lId == nil)
        return nil;
	return [_lgview GetViewById:lId];
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
    //TODO:Check this
	self.view = [[LGLayoutParser GetInstance] ParseXML:xml :[DisplayMetrics GetMasterView] :nil :self :&lgview];
	self.lgview = lgview;
}

-(void)SetTitle:(NSString *)str
{
	self.title = str;
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
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(GetViewById:)) :@selector(GetViewById:) :[LGView class] :MakeArray([NSString class]C nil)] forKey:@"GetViewById"];
    InstanceMethodNoArg(GetBindings, MakeArray([NSDictionary class]C nil), @"GetBindings")
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(GetView)) :@selector(GetView) :[LGView class] :MakeArray(nil)] forKey:@"GetView"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetView:)) :@selector(SetView:) :nil :MakeArray([LGView class] C nil)] forKey:@"SetView"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetViewXML:)) :@selector(SetViewXML:) :nil :MakeArray([NSString class] C nil)] forKey:@"SetViewXML"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetTitle:)) :@selector(SetTitle:) :nil :MakeArray([NSString class] C nil)] forKey:@"SetTitle"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(Close)) :@selector(Close) :nil :MakeArray(nil)] forKey:@"Close"];
    InstanceMethodNoArg(getLifecycleInner, LuaLifecycle, @"GetLifecycle")
    InstanceMethodNoArg(GetFragmentManager, FragmentManager, @"GetFragmentManager")
	return dict;
}

KEYBOARD_FUNCTIONS_IMPLEMENTATION

@end
