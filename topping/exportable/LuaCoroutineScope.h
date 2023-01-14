#import <Foundation/Foundation.h>
#import "LuaClass.h"
#import "LuaInterface.h"
#import "LuaTranslator.h"
#import "LuaValues.h"

@class CancelRunBlock;
@protocol CancelRunBlockDelegate;

@interface LuaJob : NSObject <LuaClass>

-(instancetype)initWithJob:(CancelRunBlock*)job;
-(void)cancel;

@property (nonatomic, retain) CancelRunBlock* job;

@end

@interface LuaCoroutineScope : NSObject <LuaClass, CancelRunBlockDelegate>

-(LuaJob*)launch:(LuaTranslator*)lt;
-(LuaJob*)launchDispatcher:(int)dispatcher :(LuaTranslator*)lt;

@property (nonatomic, retain) NSMutableSet *jobSet;

@end
