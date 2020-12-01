#import "LuaDefines.h"
#import "Defines.h"
#import "LuaInt.h"
#import "LuaFunction.h"

@implementation LuaDefines

+(NSString*)GetHumanReadableDate:(int)value
{
	NSDate *date = [NSDate dateWithTimeIntervalSince1970:value];
	NSDateComponents *weekdayComponents = [[NSCalendar currentCalendar] components:NSMonthCalendarUnit|NSWeekdayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:date];
	int weekday = [weekdayComponents weekday];	
	int month = [weekdayComponents month];
	int year = [weekdayComponents year];
	int hour = [weekdayComponents hour];
	int minutes = [weekdayComponents minute];
	int second = [weekdayComponents second];
	NSString *toAppend = @"";
	return FUAPPEND(toAppend, ITOS(weekday), @".", ITOS(month), @".", ITOS(year), /*@" ", ITOS(hour), @":", ITOS(minutes), @":", ITOS(second),*/ nil);
}

-(NSString*)GetId
{
	return @"LuaDefines"; 
}

+ (NSString*)className
{
	return @"LuaDefines";
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(GetHumanReadableDate:)) 
										:@selector(GetHumanReadableDate:) 
										:[NSString class]
										:[NSArray arrayWithObjects:[LuaInt class], nil] 
										:[LuaDefines class]] 
			 forKey:@"GetHumanReadableDate"];
	return dict;
}

@end

