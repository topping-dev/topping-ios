#import <Foundation/Foundation.h>
#import "LuaClass.h"
#import "LuaInterface.h"
#import "LuaBundle.h"

@class LuaForm;

@interface LuaFormIntent : NSObject <LuaClass>

- (instancetype)initWithBundle:(LuaBundle*)bundle;
- (LuaBundle*)getBundle;
- (void)setFlags:(int)flags;

@property (nonatomic, retain) LuaBundle *bundle;
@property (nonatomic) int flags;
@property (nonatomic, retain) LuaForm *form;

@end
