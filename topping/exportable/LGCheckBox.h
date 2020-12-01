#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LGCompoundButton.h"

#import "BEMCheckBoxText.h"

@interface LGCheckBox : LGCompoundButton<BEMCheckBoxDelegate>
{

}

//Lua
+(LGCheckBox*)Create:(LuaContext *)context;
-(BOOL)IsChecked;
-(void)SetOnCheckedChangedListener:(LuaTranslator*)lt;

@property (nonatomic, strong) BEMCheckBoxText *checkbox;
@property (nonatomic) CGSize checkboxSize;
@property (nonatomic, strong) LuaTranslator *ltCheckedChanged;

@end
