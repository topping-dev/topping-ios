#import "LuaHttpClient.h"
#import "LuaFunction.h"
#import "LuaValues.h"
#import "LuaTranslator.h"
#import "Defines.h"

@implementation LuaHttpClient

@synthesize client;

+(LuaHttpClient*)create:(NSString *)tag
{
	LuaHttpClient *httpclient = [[LuaHttpClient alloc] init];
	httpclient.client = [[URLDownloader alloc] init];
//	httpclient.client.tag = tag;
	return httpclient;
}

-(void) setContentType:(NSString *)type
{
	self.client.contentType = type;
}

-(LuaNativeObject*)startForm
{
	LuaNativeObject *lno = [[LuaNativeObject alloc] init];
	lno.obj = [client StartForm];
	return lno;
}

-(void)appendPostData:(LuaNativeObject*)formData :(NSString*)name :(NSString*)value
{
	[client AppendPostData:((NSMutableData*)formData.obj) :name :value];
}

-(void)appendFileData:(LuaNativeObject*)formData :(NSString*)name :(NSObject*)file
{
	[client AppendImageData:((NSMutableData*)formData.obj) :name :((NSData*)file)];
}

-(void)endForm:(LuaNativeObject*)formData
{
	[client EndForm:((NSMutableData*)formData.obj)];
}

-(void)startAsyncLoadForm:(NSString*)url :(LuaNativeObject*)formData :(NSString*)tag
{
	NSURL *urlO = [NSURL URLWithString:url];
	[client StartAsyncLoadForm:urlO tag:tag :((NSMutableData*)formData.obj)];
    formData = nil;
}

-(void)startAsyncLoad:(NSString*)url :(NSString*)data :(NSString*)tag
{
	NSURL *urlO = [NSURL URLWithString:url];
	[client StartAsyncLoad:urlO tag:tag :data];
}

-(void)startAsyncLoadGet:(NSString*)url :(NSString *)tag
{
	NSURL *urlO = [NSURL URLWithString:url];
	[client StartAsyncLoad:urlO tag:tag];
}

-(NSString*)startLoad:(NSString*)url :(NSString*)data
{
	NSURL *urlO = [NSURL URLWithString:url];
	return [client StartLoad:urlO :data];
}

-(NSString*)startLoadGet:(NSString*)url
{
	NSURL *urlO = [NSURL URLWithString:url];
	return [client StartLoad:urlO];
}

-(void)setTimeout:(int)timeout
{
	client.timeout = timeout;
}

-(void)setOnFinishListener:(LuaTranslator *)lt
{
    self.ltOnFinishListener = lt;
    __block LuaHttpClient *bself = self;
    client.connectionDidFinishLoadingStrCallback = ^(NSString *str)
    {
        [bself.ltOnFinishListener callIn:str, nil];
    };
}

-(void)setOnFailListener:(LuaTranslator *)lt
{
    self.ltOnFailListener = lt;
    __block LuaHttpClient *bself = self;
    client.connectionDidFailCallback = ^()
    {
        [bself.ltOnFailListener callIn:@"Fail", nil];
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
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(create:)) 
										:@selector(create:) 
										:[LuaHttpClient class]
										:[NSArray arrayWithObjects:[NSString class], nil] 
										:[LuaHttpClient class]] 
			 forKey:@"create"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(setContentType:)) :@selector(setContentType:) :nil	:MakeArray([NSString class]C nil)] forKey:@"setContentType"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(startForm)) :@selector(startForm) :[LuaNativeObject class]	:MakeArray(nil)] forKey:@"startForm"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(appendPostData:::)) :@selector(appendPostData:::) :nil	:MakeArray([LuaNativeObject class]C [NSString class]C [NSString class]C nil)] forKey:@"appendPostData"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(appendFileData:::)) :@selector(appendFileData:::) :nil	:MakeArray([LuaNativeObject class]C [NSString class]C [NSObject class]C nil)] forKey:@"appendFileData"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(endForm:)) :@selector(endForm:) :nil :MakeArray([LuaNativeObject class]C nil)] forKey:@"endForm"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(startAsyncLoadForm:::)) :@selector(startAsyncLoadForm:::) :nil	:MakeArray([NSString class]C [LuaNativeObject class]C [NSString class]C nil)] forKey:@"startAsyncLoadForm"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(startAsyncLoad:::)) :@selector(startAsyncLoad:::) :nil	:MakeArray([NSString class]C [NSString class]C [NSString class]C nil)] forKey:@"startAsyncLoad"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(startAsyncLoadGet::)) :@selector(startAsyncLoadGet::) :nil	:MakeArray([NSString class]C [NSString class]C nil)] forKey:@"startAsyncLoadGet"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(startLoad::)) :@selector(startLoad::) :[NSString class]	:MakeArray([NSString class]C [NSString class]C nil)] forKey:@"startLoad"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(startLoadGet:)) :@selector(startLoadGet:) :[NSString class]	:MakeArray([NSString class]C nil)] forKey:@"startLoadGet"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(setTimeout:)) :@selector(setTimeout:) :nil	:MakeArray([LuaInt class]C nil)] forKey:@"setTimeout"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(setOnFinishListener:)) :@selector(setOnFinishListener:) :nil :MakeArray([LuaInt class]C nil)] forKey:@"setOnFinishListener"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(setOnFailListener:)) :@selector(setOnFailListener:) :nil :MakeArray([LuaInt class]C nil)] forKey:@"setOnFailListener"];
	
	return dict;
}

@end
