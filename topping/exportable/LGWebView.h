#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import "LGView.h"

@interface LGWebView : LGView <WKNavigationDelegate>
{
}

+(LGWebView*)create:(LuaContext *)context;
-(void)setConfiguration:(BOOL)enableJavascript :(BOOL)enableDomStorage;
-(void)load:(NSString *)url;
-(void)loadData:(NSString*)data :(NSString*)mimeType :(NSString*)encoding :(NSString*)baseUrl;
-(void)stopLoading;
-(BOOL)isLoading;
-(BOOL)canGoBack;
-(BOOL)canGoForward;
-(void)goBack;
-(void)goForward;
-(void)setRequestAction:(LuaTranslator*)lt;

@property (nonatomic, retain) WKWebView *wv;
@property (nonatomic, strong) LuaTranslator *ltRequestAction;

@end
