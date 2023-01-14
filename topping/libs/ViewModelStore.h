#import <Foundation/Foundation.h>
#import "LuaViewModel.h"

@interface ViewModelStore : NSObject

-(void)put:(NSString*)key :(NSObject*)viewModel;
-(void)put:(NSString*)key ptr:(void*)viewModel;
-(LuaViewModel*)get:(NSString*)key;
-(void*)getPtr:(NSString*)key;
-(NSObject*)getObj:(NSString*)key;
-(NSArray*)keys;
-(void)clear;

@property (nonatomic, retain) NSMutableDictionary *mMap;

@end

@protocol ViewModelStoreOwner <NSObject>

-(ViewModelStore*)getViewModelStore;

@end
