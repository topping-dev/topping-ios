#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import "LGView.h"

@interface LGWebView : LGView <WKNavigationDelegate>
{
}

+(LGWebView*)Create:(LuaContext *)context;
-(void)SetConfiguration:(BOOL)enableJavascript :(BOOL)enableDomStorage;
-(void)Load:(NSString *)url;
-(void)LoadData:(NSString*)data :(NSString*)mimeType :(NSString*)encoding :(NSString*)baseUrl;
-(void)StopLoading;
-(BOOL)IsLoading;
-(BOOL)CanGoBack;
-(BOOL)CanGoForward;
-(void)GoBack;
-(void)GoForward;
-(void)SetRequestAction:(LuaTranslator*)lt;

@property (nonatomic, retain) WKWebView *wv;
@property (nonatomic, strong) LuaTranslator *ltRequestAction;

@end
