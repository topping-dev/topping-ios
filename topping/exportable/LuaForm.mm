#import "LuaForm.h"
#import "Defines.h"
#import "LuaFunction.h"
#import "LuaValues.h"
#import "LGLayoutParser.h"
#import "CommonDelegate.h"
#import "DisplayMetrics.h"
#import "LuaTranslator.h"

@implementation LuaForm

static NSMutableDictionary* eventMap = [NSMutableDictionary dictionary];

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
	else
        [LuaForm OnFormEvent:self :FORM_EVENT_CREATE :self.context :0, nil];
	[KeyboardHelper KeyboardEnableEventForView:self.view :self];
}

-(void) viewWillAppear:(BOOL)animated
{
	[CommonDelegate SetActiveForm:self];
	[super viewWillAppear:animated];
	[KeyboardHelper KeyboardEnableEvents:self];
    [LuaForm OnFormEvent:self :FORM_EVENT_RESUME :self.context :0, nil];
}

-(void) viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[KeyboardHelper KeyboardDisableEvents:self :self.selectedKeyboardTextView];
	[LuaForm OnFormEvent:self :FORM_EVENT_PAUSE :self.context :0, nil];
}

-(void) viewDidUnload
{
	[super viewDidUnload];
	[LuaForm OnFormEvent:self :FORM_EVENT_DESTROY :self.context :0, nil];
}

-(LuaContext*)GetContext
{
	return self.context;
}

-(LGView*)GetViewById:(NSString*)lId
{
	return [_lgview GetViewById:lId];
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
    [dict setObject:[NSNumber numberWithInt:1] forKey:@"FORM_EVENT_CREATE"];
    [dict setObject:[NSNumber numberWithInt:2] forKey:@"FORM_EVENT_RESUME"];
    [dict setObject:[NSNumber numberWithInt:3] forKey:@"FORM_EVENT_PAUSE"];
    [dict setObject:[NSNumber numberWithInt:4] forKey:@"FORM_EVENT_DESTROY"];
    [dict setObject:[NSNumber numberWithInt:5] forKey:@"FORM_EVENT_UPDATE"];
    [dict setObject:[NSNumber numberWithInt:6] forKey:@"FORM_EVENT_PAINT"];
    [dict setObject:[NSNumber numberWithInt:7] forKey:@"FORM_EVENT_MOUSEDOWN"];
    [dict setObject:[NSNumber numberWithInt:8] forKey:@"FORM_EVENT_MOUSEUP"];
    [dict setObject:[NSNumber numberWithInt:9] forKey:@"FORM_EVENT_MOUSEMOVE"];
    [dict setObject:[NSNumber numberWithInt:10] forKey:@"FORM_EVENT_KEYDOWN"];
    [dict setObject:[NSNumber numberWithInt:11] forKey:@"FORM_EVENT_KEYUP"];
    [dict setObject:[NSNumber numberWithInt:12] forKey:@"FORM_EVENT_NFC"];
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
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(GetView)) :@selector(GetView) :[LGView class] :MakeArray(nil)] forKey:@"GetView"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetView:)) :@selector(SetView:) :nil :MakeArray([LGView class] C nil)] forKey:@"SetView"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetViewXML:)) :@selector(SetViewXML:) :nil :MakeArray([NSString class] C nil)] forKey:@"SetViewXML"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetTitle:)) :@selector(SetTitle:) :nil :MakeArray([NSString class] C nil)] forKey:@"SetTitle"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(Close)) :@selector(Close) :nil :MakeArray(nil)] forKey:@"Close"];
	return dict;
}

KEYBOARD_FUNCTIONS_IMPLEMENTATION

@end
