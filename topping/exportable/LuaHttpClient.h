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
+(LuaHttpClient*)create:(NSString *)tag;
/**
 * Set Content type
 * @param content type
 */
-(void)setContentType:(NSString *)type;
/**
 * Start Form data.
 * This is used to create multipart form data. After this use AppendPostData or AppendImageData.
 * To end form use EndForm.
 * @return Form data
 */
-(LuaNativeObject*)startForm;
/**
 * Add data to form.
 * @param formData Form data created by StartForm.
 * @param name id of the data.
 * @param value value of the data.
 */
-(void)appendPostData:(LuaNativeObject*)formData :(NSString*)name :(NSString*)value;
/**
 * Add file to form.
 * @param formData Form data created by StartForm.
 * @param name id of the data.
 * @param file data of the file.
 */
-(void)appendFileData:(LuaNativeObject*)formData :(NSString*)name :(NSObject*)file;
/**
 * Finishes the form data created.
 * @param formData Form data created by StartForm.
 */
-(void)endForm:(LuaNativeObject*)formData;
/**
 * Start asynchronous load of form.
 * @param url url to send.
 * @param formData Form data finished by EndForm.
 * @param tag tag that is used to identify connection.
 */
-(void)startAsyncLoadForm:(NSString*)url :(LuaNativeObject*)formData :(NSString*)tag;
/**
 * Start asynchronous load.
 * @param url url to send.
 * @param data post data string.
 * @param tag tag that is used to identify connection.
 */
-(void)startAsyncLoad:(NSString*)url :(NSString*)data :(NSString*)tag;
/**
 * Start asynchronous load.
 * @param url url to send.
 * @param tag tag that is used to identify connection.
 */
-(void)startAsyncLoadGet:(NSString*)url :(NSString *)tag;
/**
 * Start synchronous load.
 * @param url url to send.
 * @param data post data string.
 * @return string value of returned data.
 */
-(NSString*)startLoad:(NSString*)url :(NSString*)data;
/**
 * Start synchronous load.
 * @param url url to send.
 * @return string value of returned data.
 */
-(NSString*)startLoadGet:(NSString*)url;
/**
 * Set timeout of connection
 * @param timeout timeout value seconds
 */
-(void)setTimeout:(int)timeout;

-(void)setOnFinishListener:(LuaTranslator*) lt;
-(void)setOnFailListener:(LuaTranslator*) lt;

/**
 * Http Client.
 */
@property (nonatomic, retain) URLDownloader *client;
@property (nonatomic, strong) LuaTranslator *ltOnFinishListener, *ltOnFailListener;

@end
