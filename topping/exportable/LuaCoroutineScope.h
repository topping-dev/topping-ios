#import <Foundation/Foundation.h>
#import "LuaClass.h"
#import "LuaInterface.h"
#import "LuaTranslator.h"
#import "LuaValues.h"

@class CoroutineScope;
@class CancelRunBlock;
@protocol CancelRunBlockDelegate;

@interface LuaJob : NSObject <LuaClass>

-(instancetype)initWithJob:(CancelRunBlock*)job;
-(void)cancel;
-(void)delay:(long)milliseconds;

@property (nonatomic, retain) CancelRunBlock* job;

@end

@interface LuaCoroutineScope : NSObject <LuaClass, CancelRunBlockDelegate>

-initWithScope:(CoroutineScope*)scope;
-(LuaJob*)launch:(LuaTranslator*)lt;
-(LuaJob*)launchDispatcher:(int)dispatcher :(LuaTranslator*)lt;

@property (nonatomic, retain) NSMutableSet *jobSet;
@property (nonatomic, retain) CoroutineScope *scope;

@end
