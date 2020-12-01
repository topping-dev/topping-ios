#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface DataToBeDownloaded : NSObject 
{
	NSString *baseUrl;
	NSString *resourcePath;
	NSString *name;
	NSString *relativeLink;
	int type;
	int action;
	NSString *time;
}

@property (nonatomic, retain) IBOutlet NSString *baseUrl;
@property (nonatomic, retain) IBOutlet NSString *resourcePath;
@property (nonatomic, retain) IBOutlet NSString *name;
@property (nonatomic, retain) IBOutlet NSString *relativeLink;
@property (nonatomic, assign) int type;
@property (nonatomic, assign) int action;
@property (nonatomic, retain) IBOutlet NSString *time;
@end
