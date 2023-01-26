#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LuaClass.h"

@class LGListView;
@protocol LuaInterface;

@interface LGAdapterView : UITableViewCell <LuaClass, LuaInterface, UITableViewDelegate, UITableViewDataSource>
{
}

-(UITableViewCell*)generateCell:(NSIndexPath*)indexPath;

-(NSObject *)getObject:(NSIndexPath*)indexPath;
-(int)getCount;
-(int)getTotalHeight:(int)start;
-(int)getTotalWidth:(int)start;

+(LGAdapterView*)create:(LuaContext *)context :(NSString*)lid;
-(LGAdapterView*)addSection:(NSString *)header :(NSString*) idV;
-(void)removeSection:(NSString*) header;
-(void)addValue:(NSObject *)value;
-(void)removeValue:(NSObject *)value;
-(void)removeAllValues;
-(void)clear;
-(void)setOnAdapterView:(LuaTranslator *)lt;
-(void)setOnItemSelected:(LuaTranslator *)lt;

@property (nonatomic, strong) NSString *lua_id;
@property (nonatomic, strong) LuaContext *lc;
@property (nonatomic, strong) LGListView *parent;
@property (nonatomic, strong) NSMutableDictionary *sections;
@property (nonatomic, strong) NSMutableDictionary *headers;
@property (nonatomic, strong) NSMutableArray *values;

@property (nonatomic, strong) NSMutableDictionary *cells;
@property (nonatomic, strong) NSMutableDictionary *views;

@property(nonatomic, strong) LuaTranslator *ltOnAdapterView, *ltItemSelected;

@end
