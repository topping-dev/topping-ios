#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LuaInterface.h"
#import "LuaClass.h"
#import "LuaContext.h"

@interface LuaDate : NSObject<LuaClass, LuaInterface>
{
    NSDate *date;
}

+(LuaDate*)now;
+(LuaDate*)createDate:(int)day :(int)month :(int)year;
+(LuaDate*)createDateWithTime:(int)day :(int)month :(int)year :(int)hour :(int)minute :(int)second;
-(int)getDay;
-(void)setDay:(int)day;
-(int)getMonth;
-(void)setMonth:(int)month;
-(int)getYear;
-(void)setYear:(int)year;
-(int)getHour;
-(void)setHour:(int)hour;
-(int)getMinute;
-(void)setMinute:(int)minute;
-(int)getSecond;
-(void)setSecond:(int)second;
-(int)getMilliSecond;
-(void)setMilliSecond:(int)ms;
-(NSString*)toString:(NSString *)frmt;

@property(nonatomic, retain) NSDate *date;

@end
