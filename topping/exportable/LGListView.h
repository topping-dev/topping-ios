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
+(LGListView *)create:(LuaContext *)context;
-(void)setAdapter:(LGAdapterView *)val;
-(LGAdapterView *)getAdapter;
-(void)refresh;

@property(nonatomic, retain) NSString *android_divider;
@property(nonatomic, retain) NSNumber *android_dividerHeight;
@property(nonatomic, retain) NSString *android_entries;
@property(nonatomic, retain) LGAdapterView *adapter_;

@end
