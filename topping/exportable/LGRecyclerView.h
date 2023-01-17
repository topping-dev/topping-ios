#import <Foundation/Foundation.h>
#import "LuaContext.h"
#import "LGView.h"
#import "LGRecyclerViewAdapter.h"

@interface LGRecyclerView : LGView

//Lua
+(LGRecyclerView *)Create:(LuaContext *)context;
-(void)SetAdapter:(LGRecyclerViewAdapter *)val;
-(void)SetAdapterInterface:(LuaTranslator *)ltInit;
-(LGRecyclerViewAdapter *)GetAdapter;
-(void)Notify;

@property(nonatomic, strong) LGRecyclerViewAdapter *adapter;
@property(nonatomic, strong) UICollectionViewLayout *flowLayout;


@end
