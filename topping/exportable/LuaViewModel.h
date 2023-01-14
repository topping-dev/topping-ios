#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LuaClass.h"
#import "LuaInterface.h"
#import "LuaCoroutineScope.h"

@interface ClosableCoroutineScope : LuaCoroutineScope

-(void)close;

@end

@interface LuaViewModel : NSObject <LuaClass, LuaInterface>
{
    
}

-(void)SetObject:(NSString*)key :(NSObject*)obj;
-(NSObject*)GetObject:(NSString*)key;
-(void)onCleared;
-(void)clear;
-(NSObject*)setTagIfAbsent:(NSString*)key :(NSObject*)value;
-(NSObject*)getTag:(NSString*)key;
-(LuaCoroutineScope*)getViewModelScope;

@property (nonatomic, retain) NSMutableDictionary *objectMap;
@property (nonatomic, retain) NSMutableDictionary *mBagOfTags;
@property BOOL mCleared;

@end
