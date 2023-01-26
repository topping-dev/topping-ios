#import "LGWebView.h"
#import "Defines.h"
#import "LGColorParser.h"
#import "LGValueParser.h"
#import "LuaFunction.h"
#import "LuaTranslator.h"

@implementation LGWebView

-(UIView*)createComponent
{
	self.wv = [[WKWebView alloc] initWithFrame:CGRectMake(self.dX, self.dY, self.dWidth, self.dHeight)];
    self.wv.navigationDelegate = self;
	return self.wv;
}

-(void)setupComponent:(UIView *)view
{
    [super setupComponent:view];
}

-(void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if(self.ltRequestAction == nil) {
        decisionHandler(WKNavigationActionPolicyAllow);
        return;
    }
    NSURLRequest *request = navigationAction.request;
    //TODO pass LuaRequest here and mutate headers etc.
    BOOL result = [self.ltRequestAction callIn:[request.URL absoluteString], nil];
    if(result)
        decisionHandler(WKNavigationActionPolicyAllow);
    else
        decisionHandler(WKNavigationActionPolicyCancel);
}

+(LGWebView*)create:(LuaContext *)context
{
    LGWebView *lst = [[LGWebView alloc] init];
	return lst;
}

-(void)setConfiguration:(BOOL)enableJavascript :(BOOL)enableDomStorage {
    
}

-(void)load:(NSString *)url {
    [self.wv loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

-(void)loadData:(NSString*)data :(NSString*)mimeType :(NSString*)encoding :(NSString*)baseUrl {
    NSStringEncoding encodingEnum = NSUTF8StringEncoding;
    if(COMPARE(encoding, @"utf16"))
        encodingEnum = NSUTF16StringEncoding;
    else if(COMPARE(encoding, @"unicode"))
        encodingEnum = NSUnicodeStringEncoding;
    else if(COMPARE(encoding, @"ascii"))
        encodingEnum = NSASCIIStringEncoding;
    [self.wv loadData:[data dataUsingEncoding:encodingEnum] MIMEType:mimeType characterEncodingName:encoding baseURL:[NSURL URLWithString:baseUrl]];
}

-(void)stopLoading {
    [self.wv stopLoading];
}

-(BOOL)isLoading {
    return self.wv.loading;
}

-(BOOL)canGoBack {
    return self.wv.canGoBack;
}

-(BOOL)canGoForward {
    return self.wv.canGoForward;
}

-(void)goBack {
    [self.wv goBack];
}

-(void)goForward {
    [self.wv goForward];
}

-(void)setRequestAction:(LuaTranslator*)lt {
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
    
    ClassMethod(create:, LGWebView, @[ [LuaContext class] ], @"create", [LGWebView class])
    InstanceMethodNoRet(setConfiguration::, @[ [NSString class]C [NSString class] ], @"setConfiguration")
    InstanceMethodNoRet(load:, @[ [NSString class] ], @"load")
    InstanceMethodNoRet(loadData::::, @[ [NSString class]C [NSString class]C [NSString class]C [NSString class] ], @"loadData")
    InstanceMethodNoRetNoArg(stopLoading, @"stopLoading")
    InstanceMethodNoArg(isLoading, LuaBool, @"isLoading")
    InstanceMethodNoArg(canGoBack, LuaBool, @"canGoBack")
    InstanceMethodNoArg(canGoForward, LuaBool, @"canGoForward")
    InstanceMethodNoRetNoArg(goBack, @"goBack")
    InstanceMethodNoRetNoArg(goForward, @"goForward")
    InstanceMethodNoRet(setRequestAction:, @[ [LuaTranslator class] ], @"setRequestAction")

	return dict;
}

@end
