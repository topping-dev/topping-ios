#import "LuaFragment.h"
#import "Defines.h"
#import "LuaFunction.h"
#import "LuaValues.h"
#import "LGLayoutParser.h"
#import "CommonDelegate.h"
#import "DisplayMetrics.h"
#import "LuaTranslator.h"

@implementation LuaFragment

+(void)Create:(LuaContext*)context :(NSString*)luaId
{
    LuaFragment *lf = [[LuaFragment alloc] init];
    lf.luaId = luaId;
    lf.context = context;
}

+(void)CreateWithUI:(LuaContext *)context :(NSString *)luaId :(NSString*)ui
{
    LuaFragment *lf = [[LuaFragment alloc] init];
    lf.luaId = luaId;
    lf.context = context;
    lf.ui = ui;
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
    self.view = [[LGLayoutParser GetInstance] ParseXML:xml :[DisplayMetrics GetMasterView] :nil :[LuaForm GetActiveForm] :&lgview];
    self.lgview = lgview;
}

-(void)SetViewId:(NSString *)luaId
{
    self.luaId = luaId;
}

-(void)SetTitle:(NSString *)str
{
    [[LuaForm GetActiveForm] SetTitle:str];
}

-(void)Close
{
    [[LuaForm GetActiveForm] Close];
}

-(BOOL)IsInitialized
{
    return YES;
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
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(GetContext)) :@selector(GetContext) :[LuaContext class] :MakeArray(nil)] forKey:@"GetContext"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(GetViewById:)) :@selector(GetViewById:) :[LGView class] :MakeArray([NSString class]C nil)] forKey:@"GetViewById"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(GetView)) :@selector(GetView) :[LGView class] :MakeArray(nil)] forKey:@"GetView"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetView:)) :@selector(SetView:) :nil :MakeArray([LGView class] C nil)] forKey:@"SetView"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetViewXML:)) :@selector(SetViewXML:) :nil :MakeArray([NSString class] C nil)] forKey:@"SetViewXML"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetViewId:)) :@selector(SetViewId:) :nil :MakeArray([NSString class] C nil)] forKey:@"SetViewId"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetTitle:)) :@selector(SetTitle:) :nil :MakeArray([NSString class] C nil)] forKey:@"SetTitle"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(Close)) :@selector(Close) :nil :MakeArray(nil)] forKey:@"Close"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(IsInitialized)) :@selector(IsInitialized) :[LuaBool class] :MakeArray(nil)] forKey:@"IsInitialized"];
    return dict;
}

KEYBOARD_FUNCTIONS_IMPLEMENTATION

@end
