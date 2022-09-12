#import <Foundation/Foundation.h>
#import "LuaViewModel.h"

@interface ViewModelStore : NSObject

-(void)put:(NSString*)key :(LuaViewModel*)viewModel;
-(LuaViewModel*)get:(NSString*)key;
-(NSArray*)keys;
-(void)clear;

@property (nonatomic, retain) NSMutableDictionary *mMap;

@end

@protocol ViewModelStoreOwner <NSObject>

-(ViewModelStore*)getViewModelStore;

@end
