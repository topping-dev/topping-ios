#import <Foundation/Foundation.h>
#import "LuaClass.h"
#import "LuaInterface.h"
#import "LuaContext.h"

@class LGView;
@class LGRecyclerView;
@protocol LuaInterface;
@protocol OnPageChangeCallback;
@class ILGRecyclerViewAdapter;

@protocol LGRecyclerViewAdapterDelegate <NSObject>

-(void)onItemSelected:(LGView*)parent :(LGView*)cell :(int)position;
-(LGView*)onCreateViewHolder:(LGView*)parent :(int)type :(LuaContext*)context;
-(void)onBindViewHolder:(LGView*)cell :(int)position;
-(int)getItemViewType:(int)position;

@end

@interface LGViewUICollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) LGView *lgview;

@end

@interface LGRecyclerViewAdapter : NSObject <LuaClass, LuaInterface, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

- (instancetype)initWithContext:(LuaContext *)context :(NSString*)lua_id;

-(UICollectionViewCell *)getCellForIndex:(int)index;
-(NSObject *)getObject:(NSIndexPath*)indexPath;
-(NSObject *)getValue:(int)position;
-(int)getCount;
-(int)getTotalHeight:(int)start;
-(int)getTotalWidth:(int)start;

+(LGRecyclerViewAdapter*)create:(LuaContext *)context :(NSString*)lid;
-(LGRecyclerViewAdapter*)addSection:(NSString *)header :(NSString*) idV;
-(void)removeSection:(NSString*) header;
-(void)addValue:(NSObject *)value;
-(void)removeValue:(NSObject *)value;
-(void)clear;
-(void)notify;
-(void)setOnItemSelected:(LuaTranslator*)lt;
-(void)setOnCreateViewHolder:(LuaTranslator*)lt;
-(void)setOnBindViewHolder:(LuaTranslator*)lt;
-(void)setGetItemViewType:(LuaTranslator*)lt;

@property (nonatomic, strong) NSString *lua_id;
@property (nonatomic, strong) LuaContext *lc;
@property (nonatomic, strong) LGRecyclerView *parent;
@property (nonatomic, strong) NSMutableDictionary *sections;
@property (nonatomic, strong) NSMutableDictionary *headers;
@property (nonatomic, strong) NSMutableArray *values;

@property (nonatomic, strong) NSMutableDictionary *cells;

@property(nonatomic, strong) LuaTranslator *ltItemSelected, *ltCreateViewHolder, *ltBindViewHolder, *ltGetItemViewType;

@property(nonatomic, strong) id<OnPageChangeCallback> onPageChangedListener;

@property(nonatomic, strong) id<LGRecyclerViewAdapterDelegate> delegate;
@property(nonatomic, strong) ILGRecyclerViewAdapter *kotlinInterface;

@end
