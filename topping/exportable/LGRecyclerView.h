#import <Foundation/Foundation.h>
#import "LuaContext.h"
#import "LGAbsListView.h"
#import "LGRecyclerViewAdapter.h"

@interface LGRecyclerView : LGAbsListView

//Lua
+(LGRecyclerView *)create:(LuaContext *)context;
-(void)setAdapter:(LGRecyclerViewAdapter *)val;
-(void)setAdapterInterface:(LuaTranslator *)ltInit;
-(LGRecyclerViewAdapter *)getAdapter;
-(void)notify;

@property(nonatomic, strong) LGRecyclerViewAdapter *adapter_;
@property(nonatomic, strong) UICollectionViewLayout *flowLayout;


@end
