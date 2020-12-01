#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface IPTableBaseAdapter : NSObject <UITableViewDataSource, UITableViewDelegate> 
{
	NSString *filename;
}

@property (nonatomic, retain) NSString *filename;

@end
