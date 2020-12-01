#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LGLinearLayout.h"

@interface LGRadioGroup : LGLinearLayout 
{

}

+(LGRadioGroup*)Create:(LuaContext *)context;
-(void)SetOnCheckedChangedListener:(LuaTranslator*) lt;

@property(nonatomic, strong) LuaTranslator *ltOnCheckedChanged;

@end
