#import "LuaDate.h"
#import "LuaFunction.h"
#import "LuaTranslator.h"
#import "LuaValues.h"

@implementation LuaDate

@synthesize date;

+(LuaDate *)now
{
    LuaDate *ld = [[LuaDate alloc] init];
    ld.date = [NSDate date];
    return ld;
}

+(LuaDate *)createDate:(int)day :(int)month :(int)year
{
    LuaDate *ld = [[LuaDate alloc] init];
    ld.date = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:
                                        (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)
                                                   fromDate:ld.date];
    [dateComponents setDay:day];
    [dateComponents setMonth:month];
    [dateComponents setYear:year];
    ld.date = [calendar dateFromComponents:dateComponents];
    return ld;
}

+(LuaDate *)createDateWithTime:(int)day :(int)month :(int)year :(int)hour :(int)minute :(int)second
{
    LuaDate *ld = [[LuaDate alloc] init];
    ld.date = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:
                                        (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay |
                                         NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond)
                                                   fromDate:ld.date];
    [dateComponents setDay:day];
    [dateComponents setMonth:month];
    [dateComponents setYear:year];
    [dateComponents setHour:hour];
    [dateComponents setMinute:minute];
    [dateComponents setSecond:second];
    ld.date = [calendar dateFromComponents:dateComponents];
    return ld;
}

-(int)getDay
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:
                                        NSCalendarUnitDay fromDate:self.date];
    return [dateComponents day];

}

-(void)setDay:(int)day
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitDay fromDate:self.date];
    [dateComponents setDay:day];
    self.date = [calendar dateFromComponents:dateComponents];
}

-(int)getMonth
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitMonth fromDate:self.date];
    return [dateComponents month];
}

-(void)setMonth:(int)month
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitMonth fromDate:self.date];
    [dateComponents setMonth:month];
    self.date = [calendar dateFromComponents:dateComponents];
}

-(int)getYear
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitYear fromDate:self.date];
    return [dateComponents year];
}

-(void)setYear:(int)year
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitYear fromDate:self.date];
    [dateComponents setYear:year];
    self.date = [calendar dateFromComponents:dateComponents];
}

-(int)getHour
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitHour fromDate:self.date];
    return [dateComponents hour];
}

-(void)setHour:(int)hour
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitHour fromDate:self.date];
    [dateComponents setHour:hour];
    self.date = [calendar dateFromComponents:dateComponents];
}

-(int)getMinute
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitMinute fromDate:self.date];
    return [dateComponents minute];
}

-(void)setMinute:(int)minute
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitMinute fromDate:self.date];
    [dateComponents setMinute:minute];
    self.date = [calendar dateFromComponents:dateComponents];
}

-(int)getSecond
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitSecond fromDate:self.date];
    return [dateComponents second];
}

-(void)setSecond:(int)second
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitSecond fromDate:self.date];
    [dateComponents setSecond:second];
    self.date = [calendar dateFromComponents:dateComponents];
}

-(int)getMilliSecond
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:
                                        (NSCalendarUnitNanosecond)
                                                   fromDate:self.date];
    
    return [dateComponents nanosecond] / 1000000;
}

-(void)setMilliSecond:(int)ms
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:
                                        (NSCalendarUnitNanosecond)
                                                   fromDate:self.date];
    
    [dateComponents setNanosecond:ms * 1000000];
    self.date = [calendar dateFromComponents:dateComponents];
}

-(NSString *)toString:(NSString *)frmt
{
    //TODO:fix this
    return @"Not Implemented";
}

-(NSString*)GetId
{
	return @"LuaDate";
}

+ (NSString*)className
{
	return @"LuaDate";
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(now))
										:@selector(now)
										:[LuaDate class]
										:MakeArray(nil)
										:[LuaDate class]]
     
			 forKey:@"now"];
    [dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(createDate:::))
										:@selector(createDate:::)
										:[LuaDate class]
										:MakeArray([LuaInt class]C [LuaInt class]C [LuaInt class]C nil)
										:[LuaDate class]]
     
			 forKey:@"createDate"];
    [dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(createDateWithTime::::::))
                                        :@selector(createDateWithTime::::::)
										:[LuaDate class]
										:MakeArray([LuaInt class]C [LuaInt class]C [LuaInt class]C [LuaInt class]C [LuaInt class]C [LuaInt class]C nil)
										:[LuaDate class]]
     
			 forKey:@"createDateWithTime"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(getDay)) :@selector(getDay) :[LuaInt class] :MakeArray(nil)] forKey:@"getDay"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(setDay:)) :@selector(setDay:) :nil :MakeArray([LuaInt class]C nil)] forKey:@"setDay"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(getMonth)) :@selector(getMonth) :[LuaInt class] :MakeArray(nil)] forKey:@"getMonth"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(setMonth:)) :@selector(setMonth:) :nil :MakeArray([LuaInt class]C nil)] forKey:@"setMonth"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(getYear)) :@selector(getYear) :[LuaInt class] :MakeArray(nil)] forKey:@"getYear"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(setYear:)) :@selector(setYear:) :nil :MakeArray([LuaInt class]C nil)] forKey:@"setYear"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(getHour)) :@selector(getHour) :[LuaInt class] :MakeArray(nil)] forKey:@"getHour"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(setHour:)) :@selector(setHour:) :nil :MakeArray([LuaInt class]C nil)] forKey:@"setHour"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(getMinute)) :@selector(getMinute) :[LuaInt class] :MakeArray(nil)] forKey:@"getMinute"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(setMinute:)) :@selector(setMinute:) :nil :MakeArray([LuaInt class]C nil)] forKey:@"setMinute"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(getSecond)) :@selector(getSecond) :[LuaInt class] :MakeArray(nil)] forKey:@"getSecond"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(setSecond:)) :@selector(setSecond:) :nil :MakeArray([LuaInt class]C nil)] forKey:@"setSecond"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(getMilliSecond)) :@selector(getMilliSecond) :[LuaInt class] :MakeArray(nil)] forKey:@"getMilliSecond"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(setMilliSecond:)) :@selector(setMilliSecond:) :nil :MakeArray([LuaInt class]C nil)] forKey:@"setMilliSecond"];
   	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(toString:)) :@selector(toString:) :[NSString class] :MakeArray([NSString class]C nil)] forKey:@"toString"];
    
	return dict;
}

@end
