#import <Foundation/Foundation.h>
#import "LuaClass.h"
#import "LuaInterface.h"
#import "LuaContext.h"

@class LGRecyclerView;
@protocol LuaInterface;

@interface LGRecyclerViewAdapter : UICollectionViewCell <LuaClass, LuaInterface, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

-(NSObject *)GetObject:(NSIndexPath*)indexPath;
-(int)GetCount;
-(int)GetTotalHeight:(int)start;
-(int)GetTotalWidth:(int)start;

+(LGRecyclerViewAdapter*)Create:(LuaContext *)context :(NSString*)lid;
-(LGRecyclerViewAdapter*)AddSection:(NSString *)header :(NSString*) idV;
-(void)RemoveSection:(NSString*) header;
-(void)AddValue:(NSObject *)value;
-(void)RemoveValue:(NSObject *)value;
-(void)Clear;
-(void)Notify;
-(void)SetOnItemSelected:(LuaTranslator*)lt;
-(void)SetOnCreateViewHolder:(LuaTranslator*)lt;
-(void)SetOnBindViewHolder:(LuaTranslator*)lt;
-(void)SetGetItemViewType:(LuaTranslator*)lt;

@property (nonatomic, strong) NSString *lua_id;
@property (nonatomic, strong) LuaContext *lc;
@property (nonatomic, strong) LGRecyclerView *parent;
@property (nonatomic, strong) NSMutableDictionary *sections;
@property (nonatomic, strong) NSMutableDictionary *headers;
@property (nonatomic, strong) NSMutableArray *values;

@property (nonatomic, strong) NSMutableDictionary *createdViews;
@property (nonatomic, strong) NSMutableDictionary *cells;
@property (nonatomic, strong) NSMutableDictionary *views;

@property(nonatomic, strong) LuaTranslator *ltItemSelected, *ltCreateViewHolder, *ltBindViewHolder, *ltGetItemViewType;

@end
