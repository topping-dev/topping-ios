#import "LuaHttpClient.h"
#import "LuaFunction.h"
#import "LuaValues.h"
#import "LuaTranslator.h"
#import "Defines.h"

@implementation LuaHttpClient

@synthesize client;

+(LuaHttpClient*)Create:(NSString *)tag
{
	LuaHttpClient *httpclient = [[LuaHttpClient alloc] init];
	httpclient.client = [[URLDownloader alloc] init];
//	httpclient.client.tag = tag;
	return httpclient;
}

-(void) SetContentType:(NSString *)type
{
	self.client.contentType = type;
}

-(LuaNativeObject*)StartForm
{
	LuaNativeObject *lno = [[LuaNativeObject alloc] init];
	lno.obj = [client StartForm];
	return lno;
}

-(void)AppendPostData:(LuaNativeObject*)formData :(NSString*)name :(NSString*)value
{
	[client AppendPostData:((NSMutableData*)formData.obj) :name :value];
}

-(void)AppendFileData:(LuaNativeObject*)formData :(NSString*)name :(NSObject*)file
{
	[client AppendImageData:((NSMutableData*)formData.obj) :name :((NSData*)file)];
}

-(void)EndForm:(LuaNativeObject*)formData
{
	[client EndForm:((NSMutableData*)formData.obj)];
}

-(void)StartAsyncLoadForm:(NSString*)url :(LuaNativeObject*)formData :(NSString*)tag
{
	NSURL *urlO = [NSURL URLWithString:url];
	[client StartAsyncLoadForm:urlO tag:tag :((NSMutableData*)formData.obj)];
    formData = nil;
}

-(void)StartAsyncLoad:(NSString*)url :(NSString*)data :(NSString*)tag
{
	NSURL *urlO = [NSURL URLWithString:url];
	[client StartAsyncLoad:urlO tag:tag :data];
}

-(void)StartAsyncLoadGet:(NSString*)url :(NSString *)tag
{
	NSURL *urlO = [NSURL URLWithString:url];
	[client StartAsyncLoad:urlO tag:tag];
}

-(NSString*)StartLoad:(NSString*)url :(NSString*)data
{
	NSURL *urlO = [NSURL URLWithString:url];
	return [client StartLoad:urlO :data];
}

-(NSString*)StartLoadGet:(NSString*)url
{
	NSURL *urlO = [NSURL URLWithString:url];
	return [client StartLoad:urlO];
}

-(void)SetTimeout:(int)timeout
{
	client.timeout = timeout;
}

-(void)SetOnFinishListener:(LuaTranslator *)lt
{
    self.ltOnFinishListener = lt;
    __block LuaHttpClient *bself = self;
    client.connectionDidFinishLoadingStrCallback = ^(NSString *str)
    {
        [bself.ltOnFinishListener CallIn:str, nil];
    };
}

-(void)SetOnFailListener:(LuaTranslator *)lt
{
    self.ltOnFailListener = lt;
    __block LuaHttpClient *bself = self;
    client.connectionDidFailCallback = ^()
    {
        [bself.ltOnFailListener CallIn:@"Fail", nil];
    };
}

-(NSString*)GetId
{
	return @"LuaHttpClient"; 
}

+ (NSString*)className
{
	return @"LuaHttpClient";
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(Create:)) 
										:@selector(Create:) 
										:[LuaHttpClient class]
										:[NSArray arrayWithObjects:[NSString class], nil] 
										:[LuaHttpClient class]] 
			 forKey:@"Create"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetContentType:)) :@selector(SetContentType:) :nil	:MakeArray([NSString class]C nil)] forKey:@"SetContentType"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(StartForm)) :@selector(StartForm) :[LuaNativeObject class]	:MakeArray(nil)] forKey:@"StartForm"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(AppendPostData:::)) :@selector(AppendPostData:::) :nil	:MakeArray([LuaNativeObject class]C [NSString class]C [NSString class]C nil)] forKey:@"AppendPostData"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(AppendFileData:::)) :@selector(AppendFileData:::) :nil	:MakeArray([LuaNativeObject class]C [NSString class]C [NSObject class]C nil)] forKey:@"AppendFileData"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(EndForm:)) :@selector(EndForm:) :nil :MakeArray([LuaNativeObject class]C nil)] forKey:@"EndForm"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(StartAsyncLoadForm:::)) :@selector(StartAsyncLoadForm:::) :nil	:MakeArray([NSString class]C [LuaNativeObject class]C [NSString class]C nil)] forKey:@"StartAsyncLoadForm"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(StartAsyncLoad:::)) :@selector(StartAsyncLoad:::) :nil	:MakeArray([NSString class]C [NSString class]C [NSString class]C nil)] forKey:@"StartAsyncLoad"];	
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(StartAsyncLoadGet::)) :@selector(StartAsyncLoadGet::) :nil	:MakeArray([NSString class]C [NSString class]C nil)] forKey:@"StartAsyncLoadGet"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(StartLoad::)) :@selector(StartLoad::) :[NSString class]	:MakeArray([NSString class]C [NSString class]C nil)] forKey:@"StartLoad"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(StartLoadGet:)) :@selector(StartLoadGet:) :[NSString class]	:MakeArray([NSString class]C nil)] forKey:@"StartLoadGet"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetTimeout:)) :@selector(SetTimeout:) :nil	:MakeArray([LuaInt class]C nil)] forKey:@"SetTimeout"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetOnFinishListener:)) :@selector(SetOnFinishListener:) :nil :MakeArray([LuaInt class]C nil)] forKey:@"SetOnFinishListener"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetOnFailListener:)) :@selector(SetOnFailListener:) :nil :MakeArray([LuaInt class]C nil)] forKey:@"SetOnFailListener"];
	
	return dict;
}

@end
