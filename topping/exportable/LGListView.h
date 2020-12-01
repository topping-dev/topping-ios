#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LGAbsListView.h"
#import "LGAdapterView.h"

@interface LGListView : LGAbsListView 
{
	/*NSNumber *footerDividersEnabled
	 NSNumber *headerDividersEnabled*/
}

//Lua
+(LGListView *)Create:(LuaContext *)context;
-(void)SetAdapter:(LGAdapterView *)val;
-(LGAdapterView *)GetAdapter;
-(void)Refresh;

@property(nonatomic, retain) NSString *android_divider;
@property(nonatomic, retain) NSNumber *android_dividerHeight;
@property(nonatomic, retain) NSString *android_entries;
@property(nonatomic, retain) LGAdapterView *adapter;

@end
