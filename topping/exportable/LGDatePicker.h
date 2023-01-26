#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LGView.h"
#import "LuaTranslator.h"

@interface LGDatePicker : LGView
{
	
}

//Lua
+(LGDatePicker*)create:(LuaContext *)context;
-(void)setOnDateChangedListener:(LuaTranslator *)lt;
-(void)show;
-(int)getDay;
-(int)getMonth;
-(int)getYear;
-(void)updateDate:(int)day :(int)month :(int)year;

@property (nonatomic, strong) LuaTranslator *ltChanged;
@property (nonatomic, strong) UITextField *hiddenTextField;
@property (nonatomic) int day_;
@property (nonatomic) int month_;
@property (nonatomic) int year_;


@end
