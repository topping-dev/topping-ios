#import "LGWebView.h"
#import "Defines.h"
#import "LGColorParser.h"
#import "LGValueParser.h"
#import "LuaFunction.h"
#import "LuaTranslator.h"

@implementation LGWebView

-(UIView*)CreateComponent
{
	self.wv = [[WKWebView alloc] initWithFrame:CGRectMake(self.dX, self.dY, self.dWidth, self.dHeight)];
    self.wv.navigationDelegate = self;
	return self.wv;
}

-(void)SetupComponent:(UIView *)view
{
    [super SetupComponent:view];
}

-(void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if(self.ltRequestAction == nil) {
        decisionHandler(WKNavigationActionPolicyAllow);
        return;
    }
    NSURLRequest *request = navigationAction.request;
    //TODO pass LuaRequest here and mutate headers etc.
    BOOL result = [self.ltRequestAction CallIn:[request.URL absoluteString], nil];
    if(result)
        decisionHandler(WKNavigationActionPolicyAllow);
    else
        decisionHandler(WKNavigationActionPolicyCancel);
}

+(LGWebView*)Create:(LuaContext *)context
{
    LGWebView *lst = [[LGWebView alloc] init];
	return lst;
}

-(void)SetConfiguration:(BOOL)enableJavascript :(BOOL)enableDomStorage {
    
}

-(void)Load:(NSString *)url {
    [self.wv loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

-(void)LoadData:(NSString*)data :(NSString*)mimeType :(NSString*)encoding :(NSString*)baseUrl {
    NSStringEncoding encodingEnum = NSUTF8StringEncoding;
    if(COMPARE(encoding, @"utf16"))
        encodingEnum = NSUTF16StringEncoding;
    else if(COMPARE(encoding, @"unicode"))
        encodingEnum = NSUnicodeStringEncoding;
    else if(COMPARE(encoding, @"ascii"))
        encodingEnum = NSASCIIStringEncoding;
    [self.wv loadData:[data dataUsingEncoding:encodingEnum] MIMEType:mimeType characterEncodingName:encoding baseURL:[NSURL URLWithString:baseUrl]];
}

-(void)StopLoading {
    [self.wv stopLoading];
}

-(BOOL)IsLoading {
    return self.wv.loading;
}

-(BOOL)CanGoBack {
    return self.wv.canGoBack;
}

-(BOOL)CanGoForward {
    return self.wv.canGoForward;
}

-(void)GoBack {
    [self.wv goBack];
}

-(void)GoForward {
    [self.wv goForward];
}

-(void)SetRequestAction:(LuaTranslator*)lt {
    self.ltRequestAction = lt;
}

-(NSString*)GetId
{
    if(self.lua_id != nil)
        return self.lua_id;
    if(self.android_id != nil)
        return self.android_id;
    return [LGWebView className];
}

+ (NSString*)className
{
	return @"LGWebView";
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    
    ClassMethod(Create:, LGWebView, @[ [LuaContext class] ], @"Create", [LGWebView class])
    InstanceMethodNoRet(SetConfiguration::, @[ [NSString class]C [NSString class] ], @"SetConfiguration")
    InstanceMethodNoRet(Load:, @[ [NSString class] ], @"Load")
    InstanceMethodNoRet(LoadData::::, @[ [NSString class]C [NSString class]C [NSString class]C [NSString class] ], @"LoadData")
    InstanceMethodNoRetNoArg(StopLoading, @"StopLoading")
    InstanceMethodNoArg(IsLoading, LuaBool, @"IsLoading")
    InstanceMethodNoArg(CanGoBack, LuaBool, @"CanGoBack")
    InstanceMethodNoArg(CanGoForward, LuaBool, @"CanGoForward")
    InstanceMethodNoRetNoArg(GoBack, @"GoBack")
    InstanceMethodNoRetNoArg(GoForward, @"GoForward")
    InstanceMethodNoRet(SetRequestAction:, @[ [LuaTranslator class] ], @"SetRequestAction")

	return dict;
}

@end
