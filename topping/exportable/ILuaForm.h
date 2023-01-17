#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LuaClass.h"
#import "LuaInterface.h"
#import "LuaTranslator.h"

@interface ILuaForm : NSObject <LuaClass, LuaInterface>
{
}

+(ILuaForm*)Create;

@property (nonatomic, retain) LuaTranslator *ltOnCreate;
@property (nonatomic, retain) LuaTranslator *ltOnResume;
@property (nonatomic, retain) LuaTranslator *ltOnPause;
@property (nonatomic, retain) LuaTranslator *ltOnDestroy;

@end
