#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LuaInterface.h"
#import "LuaClass.h"
#import "LuaNativeObject.h"
#import "LuaObjectStore.h"
#import "URLDownloader.h"

/**
 * Class that handles HTTP POST and GET requests
 */
@interface LuaHttpClient : NSObject <LuaClass, LuaInterface>
{
	URLDownloader *client;
}

/**
 * Creates LuaHttpClient Object From Lua.
 * @param tag Tag that htmlclient will used.
 */
+(LuaHttpClient*)Create:(NSString *)tag;
/**
 * Set Content type
 * @param content type
 */
-(void)SetContentType:(NSString *)type;
/**
 * Start Form data.
 * This is used to create multipart form data. After this use AppendPostData or AppendImageData.
 * To end form use EndForm.
 * @return Form data
 */
-(LuaNativeObject*)StartForm;
/**
 * Add data to form.
 * @param formData Form data created by StartForm.
 * @param name id of the data.
 * @param value value of the data.
 */
-(void)AppendPostData:(LuaNativeObject*)formData :(NSString*)name :(NSString*)value;
/**
 * Add file to form.
 * @param formData Form data created by StartForm.
 * @param name id of the data.
 * @param file data of the file.
 */
-(void)AppendFileData:(LuaNativeObject*)formData :(NSString*)name :(NSObject*)file;
/**
 * Finishes the form data created.
 * @param formData Form data created by StartForm.
 */
-(void)EndForm:(LuaNativeObject*)formData;
/**
 * Start asynchronous load of form.
 * @param url url to send.
 * @param formData Form data finished by EndForm.
 * @param tag tag that is used to identify connection.
 */
-(void)StartAsyncLoadForm:(NSString*)url :(LuaNativeObject*)formData :(NSString*)tag;
/**
 * Start asynchronous load.
 * @param url url to send.
 * @param data post data string.
 * @param tag tag that is used to identify connection.
 */
-(void)StartAsyncLoad:(NSString*)url :(NSString*)data :(NSString*)tag;
/**
 * Start asynchronous load.
 * @param url url to send.
 * @param tag tag that is used to identify connection.
 */
-(void)StartAsyncLoadGet:(NSString*)url :(NSString *)tag;
/**
 * Start synchronous load.
 * @param url url to send.
 * @param data post data string.
 * @return string value of returned data.
 */
-(NSString*)StartLoad:(NSString*)url :(NSString*)data;
/**
 * Start synchronous load.
 * @param url url to send.
 * @return string value of returned data.
 */
-(NSString*)StartLoadGet:(NSString*)url;
/**
 * Set timeout of connection
 * @param timeout timeout value seconds
 */
-(void)SetTimeout:(int)timeout;

-(void)SetOnFinishListener:(LuaTranslator*) lt;
-(void)SetOnFailListener:(LuaTranslator*) lt;

/**
 * Http Client.
 */
@property (nonatomic, retain) URLDownloader *client;
@property (nonatomic, strong) LuaTranslator *ltOnFinishListener, *ltOnFailListener;

@end
