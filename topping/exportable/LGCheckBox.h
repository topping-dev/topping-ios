#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LGCompoundButton.h"
#import "CheckBox.h"

@interface LGCheckBox : LGCompoundButton
{

}

//Lua
+(LGCheckBox*)Create:(LuaContext *)context;
-(BOOL)IsChecked;
-(void)SetOnCheckedChangedListener:(LuaTranslator*)lt;

@property (nonatomic, strong) CheckBox *checkbox;
@property (nonatomic) CGSize checkboxSize;
@property (nonatomic, strong) LuaTranslator *ltCheckedChanged;

@end
