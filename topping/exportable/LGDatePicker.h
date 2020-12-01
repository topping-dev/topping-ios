#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LGView.h"
#import "LuaTranslator.h"

@interface LGDatePicker : LGView
{
	
}

//Lua
+(LGDatePicker*)Create:(LuaContext *)context;
-(void)SetOnDateChangedListener:(LuaTranslator *)lt;
-(void)Show;
-(int)GetDay;
-(int)GetMonth;
-(int)GetYear;
-(void)UpdateDate:(int)day :(int)month :(int)year;

@property (nonatomic, strong) LuaTranslator *ltChanged;
@property (nonatomic, strong) UITextField *hiddenTextField;
@property (nonatomic) int day;
@property (nonatomic) int month;
@property (nonatomic) int year;


@end
