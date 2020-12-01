#import "Common.h"
#import "URLDownloader.h"

@implementation URLDownloader

@synthesize connectionDidFinishLoadingCallback;
@synthesize connectionDidFinishLoadingMutableCallback;
@synthesize connectionDidFinishLoadingStrCallback;
@synthesize connectionDidFinishLoadingConnectionStrCallback;
@synthesize connectionDidFailCallback;
@synthesize receivedData;
@synthesize contentType;
@synthesize timeout;

- (NSString *)StartLoad:(NSURL *)url
{
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url
                                                cachePolicy:NSURLRequestReloadIgnoringCacheData
                                            timeoutInterval:timeout];
    // Fetch the JSON response
    NSData *urlData;
    NSURLResponse *response = nil;
    NSError *error = nil;
    
    // Make synchronous request
    urlData = [NSURLConnection sendSynchronousRequest:urlRequest
                                    returningResponse:&response
                                                error:&error];
    
    if(error)
        NSLog([error description]);
    
     // Construct a String around the Data from the response
    return [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
}

-(NSString *)StartLoad:(NSURL *)url :(NSString *)post
{
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url
                                                cachePolicy:NSURLRequestReloadIgnoringCacheData
                                            timeoutInterval:timeout];
    // Fetch the JSON response
    NSData *urlData;
    NSURLResponse *response = nil;
    NSError *error = nil;
    
    // Make synchronous request
    urlData = [NSURLConnection sendSynchronousRequest:urlRequest
                                    returningResponse:&response
                                                error:&error];
    
    if(error)
        NSLog([error description]);
    
     // Construct a String around the Data from the response
    return [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
}

- (void)StartAsyncLoad:(NSURL*)url tag:(NSString*)tag
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    CustomURLConnection *connection = [[CustomURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES tag:tag];
    
    if (connection) {
        if(receivedData == NULL)
            receivedData = [[NSMutableDictionary alloc] init];
        [receivedData setObject:[NSMutableData data] forKey:connection.tag];
    }
}

- (void)StartAsyncLoad:(NSURL*)url tag:(NSString*)tag :(NSString*)post
{
    //[NSString stringWithFormat::@"deviceIdentifier=%@&deviceToken=%@",deviceIdentifier,deviceToken]
    //NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    //NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:NO];
    NSMutableData *postData = [NSMutableData data];
    [postData appendData:[post dataUsingEncoding:NSUTF8StringEncoding]];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:self.contentType forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"MyApp-V1.0" forHTTPHeaderField:@"User-Agent"];
    [request setHTTPBody:postData];
    CustomURLConnection *connection = [[CustomURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES tag:tag];
    
    if (connection) {
        if(receivedData == NULL)
            receivedData = [[NSMutableDictionary alloc] init];
        [receivedData setObject:[NSMutableData data] forKey:connection.tag];
    }
}

-(NSMutableData*)StartForm
{
    self.boundary = [NSString stringWithString:@"---------------------------14737809831466499882746641449"];
    NSMutableData *body = [NSMutableData data];
    return body;
}

-(void)AppendPostData:(NSMutableData *)body :(NSString*)name :(NSString*)value
{
    NSMutableData *postData = [NSMutableData data];
    [postData appendData:[value dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", self.boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"", name] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithString:@"Content-Type: application/x-www-form-urlencoded\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:postData];
}

-(void)AppendImageData:(NSMutableData *)body :(NSString*)name :(NSData*)imageData
{
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", self.boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", name, name] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithString:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[NSData dataWithData:imageData]];
}

-(void)EndForm:(NSMutableData *)body
{
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", self.boundary] dataUsingEncoding:NSUTF8StringEncoding]];
}

-(void)StartAsyncLoadForm:(NSURL*)url tag:(NSString*)tag :(NSMutableData*)body
{
    //NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    //[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    /*
     add some header info now
     we always need a boundary when we post a file
     also we need to set the content type
     
     You might want to generate a random boundary.. this is just the same
     as my output from wireshark on a valid html post
     */

    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", self.boundary];
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    CustomURLConnection *connection = [[CustomURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES tag:tag];
    
    if (connection) {
        if(receivedData == NULL)
            receivedData = [[NSMutableDictionary alloc] init];
        [receivedData setObject:[NSMutableData data] forKey:connection.tag];
    }
}

- (NSMutableData*)dataForConnection:(CustomURLConnection*)connection
{
    NSMutableData *data = [receivedData objectForKey:connection.tag];
    return data;
}

/*- (void)load {
 receivedData = [[NSMutableDictionary alloc] init];
 
 NSURL *url1 = [NSURL URLWithString:@"http://blog.emmerinc.be"];
 NSURL *url2 = [NSURL URLWithString:@"http://www.emmerinc.be"];
 NSURL *url3 = [NSURL URLWithString:@"http://twitter.com/emmerinc"];
 
 [self StartAsyncLoad:url1 tag:@"tag1"];
 [self StartAsyncLoad:url2 tag:@"tag2"];
 [self StartAsyncLoad:url3 tag:@"tag3"];
 }*/

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSMutableData *dataForConnection = [self dataForConnection:(CustomURLConnection*)connection];
    [dataForConnection setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSMutableData *dataForConnection = [self dataForConnection:(CustomURLConnection*)connection];
    [dataForConnection appendData:data];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    connection = nil;
    if(connectionDidFailCallback)
        connectionDidFailCallback();
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if(connectionDidFinishLoadingCallback)
    {
        connectionDidFinishLoadingCallback(connection);
        return;
    }
    
    NSMutableData *dataForConnection = [self dataForConnection:(CustomURLConnection*)connection];
    connection = nil;
    
    if(dataForConnection == nil)
    {
        if(connectionDidFailCallback)
            connectionDidFailCallback();
        return;
    }
    
    if(connectionDidFinishLoadingMutableCallback)
    {
        connectionDidFinishLoadingMutableCallback(dataForConnection);
        return;
    }
    
    NSString *str = [[NSString alloc] initWithData:dataForConnection encoding:NSUTF8StringEncoding];
    
    if(connectionDidFinishLoadingStrCallback)
        connectionDidFinishLoadingStrCallback(str);
    
    if(connectionDidFinishLoadingConnectionStrCallback)
        connectionDidFinishLoadingConnectionStrCallback(connection, str);
}

@end
