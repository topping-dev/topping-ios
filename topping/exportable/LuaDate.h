#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LuaInterface.h"
#import "LuaClass.h"
#import "LuaContext.h"

@interface LuaDate : NSObject<LuaClass, LuaInterface>
{
    NSDate *date;
}

+(LuaDate*)Now;
+(LuaDate*)CreateDate:(int)day :(int)month :(int)year;
+(LuaDate*)CreateDateWithTime:(int)day :(int)month :(int)year :(int)hour :(int)minute :(int)second;
-(int)GetDay;
-(void)SetDay:(int)day;
-(int)GetMonth;
-(void)SetMonth:(int)month;
-(int)GetYear;
-(void)SetYear:(int)year;
-(int)GetHour;
-(void)SetHour:(int)hour;
-(int)GetMinute;
-(void)SetMinute:(int)minute;
-(int)GetSecond;
-(void)SetSecond:(int)second;
-(int)GetMilliSecond;
-(void)SetMilliSecond:(int)ms;
-(NSString*)ToString:(NSString *)frmt;

@property(nonatomic, retain) NSDate *date;

@end
