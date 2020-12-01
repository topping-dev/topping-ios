#import <Foundation/Foundation.h>
#import "CustomURLConnection.h"

typedef void (^ConnectionDidFinishLoadingBlock)(NSURLConnection *connection);
typedef void (^ConnectionDidFinishLoadingMutableBlock)(NSMutableData *data);
typedef void (^ConnectionDidFinishLoadingStrBlock)(NSString *str);
typedef void (^ConnectionDidFinishLoadingConnectionStrBlock)(NSURLConnection *connection, NSString *str);
typedef void (^ConnectionDidFailCallback)();

@interface URLDownloader : NSObject
{
}

@property(copy) ConnectionDidFinishLoadingBlock connectionDidFinishLoadingCallback;
@property(copy) ConnectionDidFinishLoadingMutableBlock connectionDidFinishLoadingMutableCallback;
@property(copy) ConnectionDidFinishLoadingStrBlock connectionDidFinishLoadingStrCallback;
@property(copy) ConnectionDidFinishLoadingConnectionStrBlock connectionDidFinishLoadingConnectionStrCallback;
@property(copy) ConnectionDidFailCallback connectionDidFailCallback;
@property (nonatomic) NSMutableDictionary *receivedData;
@property (nonatomic) NSString *contentType;
@property (nonatomic) NSString *boundary;
@property int timeout;

- (NSString *)StartLoad:(NSURL *)url;
- (NSString *)StartLoad:(NSURL *)url :(NSString *)post;
- (void)StartAsyncLoad:(NSURL*)url tag:(NSString*)tag;
- (void)StartAsyncLoad:(NSURL*)url tag:(NSString*)tag :(NSString*)post;
- (NSMutableData*)StartForm;
- (void)AppendPostData:(NSMutableData *)body :(NSString*)name :(NSString*)value;
- (void)AppendImageData:(NSMutableData *)body :(NSString*)name :(NSData*)imageData;
- (void)EndForm:(NSMutableData *)body;
- (void)StartAsyncLoadForm:(NSURL*)url tag:(NSString*)tag :(NSMutableData*)body;
- (NSMutableData*)dataForConnection:(CustomURLConnection*)connection;
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;

@end
