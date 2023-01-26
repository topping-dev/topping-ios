#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LGLinearLayout.h"

@interface LGRadioGroup : LGLinearLayout 
{

}

+(LGRadioGroup*)create:(LuaContext *)context;
-(void)setOnCheckedChangedListener:(LuaTranslator*) lt;

@property(nonatomic, strong) LuaTranslator *ltOnCheckedChanged;

@end
