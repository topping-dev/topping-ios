#import "LuaDate.h"
#import "LuaFunction.h"
#import "LuaTranslator.h"
#import "LuaValues.h"

@implementation LuaDate

@synthesize date;

+(LuaDate *)Now
{
    LuaDate *ld = [[LuaDate alloc] init];
    ld.date = [NSDate date];
    return ld;
}

+(LuaDate *)CreateDate:(int)day :(int)month :(int)year
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

+(LuaDate *)CreateDateWithTime:(int)day :(int)month :(int)year :(int)hour :(int)minute :(int)second
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

-(int)GetDay
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:
                                        NSCalendarUnitDay fromDate:self.date];
    return [dateComponents day];

}

-(void)SetDay:(int)day
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitDay fromDate:self.date];
    [dateComponents setDay:day];
    self.date = [calendar dateFromComponents:dateComponents];
}

-(int)GetMonth
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitMonth fromDate:self.date];
    return [dateComponents month];
}

-(void)SetMonth:(int)month
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitMonth fromDate:self.date];
    [dateComponents setMonth:month];
    self.date = [calendar dateFromComponents:dateComponents];
}

-(int)GetYear
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitYear fromDate:self.date];
    return [dateComponents year];
}

-(void)SetYear:(int)year
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitYear fromDate:self.date];
    [dateComponents setYear:year];
    self.date = [calendar dateFromComponents:dateComponents];
}

-(int)GetHour
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitHour fromDate:self.date];
    return [dateComponents hour];
}

-(void)SetHour:(int)hour
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitHour fromDate:self.date];
    [dateComponents setHour:hour];
    self.date = [calendar dateFromComponents:dateComponents];
}

-(int)GetMinute
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitMinute fromDate:self.date];
    return [dateComponents minute];
}

-(void)SetMinute:(int)minute
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitMinute fromDate:self.date];
    [dateComponents setMinute:minute];
    self.date = [calendar dateFromComponents:dateComponents];
}

-(int)GetSecond
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitSecond fromDate:self.date];
    return [dateComponents second];
}

-(void)SetSecond:(int)second
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitSecond fromDate:self.date];
    [dateComponents setSecond:second];
    self.date = [calendar dateFromComponents:dateComponents];
}

-(int)GetMilliSecond
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:
                                        (NSCalendarUnitNanosecond)
                                                   fromDate:self.date];
    
    return [dateComponents nanosecond] / 1000000;
}

-(void)SetMilliSecond:(int)ms
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:
                                        (NSCalendarUnitNanosecond)
                                                   fromDate:self.date];
    
    [dateComponents setNanosecond:ms * 1000000];
    self.date = [calendar dateFromComponents:dateComponents];
}

-(NSString *)ToString:(NSString *)frmt
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
    [dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(Now))
										:@selector(Now)
										:[LuaDate class]
										:MakeArray(nil)
										:[LuaDate class]]
     
			 forKey:@"Now"];
    [dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(CreateDate:::))
										:@selector(CreateDate:::)
										:[LuaDate class]
										:MakeArray([LuaInt class]C [LuaInt class]C [LuaInt class]C nil)
										:[LuaDate class]]
     
			 forKey:@"CreateDate"];
    [dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(CreateDateWithTime::::::))
                                        :@selector(CreateDateWithTime::::::)
										:[LuaDate class]
										:MakeArray([LuaInt class]C [LuaInt class]C [LuaInt class]C [LuaInt class]C [LuaInt class]C [LuaInt class]C nil)
										:[LuaDate class]]
     
			 forKey:@"CreateDateWithTime"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(GetDay)) :@selector(GetDay) :[LuaInt class] :MakeArray(nil)] forKey:@"GetDay"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetDay:)) :@selector(SetDay:) :nil :MakeArray([LuaInt class]C nil)] forKey:@"SetDay"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(GetMonth)) :@selector(GetMonth) :[LuaInt class] :MakeArray(nil)] forKey:@"GetMonth"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetMonth:)) :@selector(SetMonth:) :nil :MakeArray([LuaInt class]C nil)] forKey:@"SetMonth"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(GetYear)) :@selector(GetYear) :[LuaInt class] :MakeArray(nil)] forKey:@"GetYear"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetYear:)) :@selector(SetYear:) :nil :MakeArray([LuaInt class]C nil)] forKey:@"SetYear"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(GetHour)) :@selector(GetHour) :[LuaInt class] :MakeArray(nil)] forKey:@"GetHour"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetHour:)) :@selector(SetHour:) :nil :MakeArray([LuaInt class]C nil)] forKey:@"SetHour"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(GetMinute)) :@selector(GetMinute) :[LuaInt class] :MakeArray(nil)] forKey:@"GetMinute"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetMinute:)) :@selector(SetMinute:) :nil :MakeArray([LuaInt class]C nil)] forKey:@"SetMinute"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(GetSecond)) :@selector(GetSecond) :[LuaInt class] :MakeArray(nil)] forKey:@"GetSecond"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetSecond:)) :@selector(SetSecond:) :nil :MakeArray([LuaInt class]C nil)] forKey:@"SetSecond"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(GetMilliSecond)) :@selector(GetMilliSecond) :[LuaInt class] :MakeArray(nil)] forKey:@"GetMilliSecond"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetMilliSecond:)) :@selector(SetMilliSecond:) :nil :MakeArray([LuaInt class]C nil)] forKey:@"SetMilliSecond"];
   	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(ToString:)) :@selector(ToString:) :[NSString class] :MakeArray([NSString class]C nil)] forKey:@"ToString"];
    
	return dict;
}

@end
