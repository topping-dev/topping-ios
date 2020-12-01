#import <Foundation/Foundation.h>
#import "LuaContext.h"
#import "LGView.h"
#import "LGRecyclerViewAdapter.h"

@interface LGRecyclerView : LGView

//Lua
+(LGRecyclerView *)Create:(LuaContext *)context;
-(void)SetAdapter:(LGRecyclerViewAdapter *)val;
-(LGRecyclerViewAdapter *)GetAdapter;
-(void)Refresh;

@property(nonatomic, strong) LGRecyclerViewAdapter *adapter;
@property(nonatomic, strong) UICollectionViewLayout *flowLayout;


@end
