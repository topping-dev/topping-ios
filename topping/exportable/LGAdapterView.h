#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LuaClass.h"

@class LGListView;
@protocol LuaInterface;

@interface LGAdapterView : UITableViewCell <LuaClass, LuaInterface, UITableViewDelegate, UITableViewDataSource>
{
}

-(UITableViewCell*)generateCell:(NSIndexPath*)indexPath;

-(NSObject *)GetObject:(NSIndexPath*)indexPath;
-(int)GetCount;
-(int)GetTotalHeight:(int)start;
-(int)GetTotalWidth:(int)start;

+(LGAdapterView*)Create:(LuaContext *)context :(NSString*)lid;
-(LGAdapterView*)AddSection:(NSString *)header :(NSString*) idV;
-(void)RemoveSection:(NSString*) header;
-(void)AddValue:(NSObject *)value;
-(void)RemoveValue:(NSObject *)value;
-(void)RemoveAllValues;
-(void)Clear;
-(void)SetOnAdapterView:(LuaTranslator *)lt;
-(void)SetOnItemSelected:(LuaTranslator *)lt;

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
