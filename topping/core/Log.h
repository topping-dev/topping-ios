#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <execinfo.h>

@interface Log : NSObject
{

}

+(void)Backtrace;
+(void)d:(NSString*)tag :(NSString *)message;
+(void)e:(NSString*)tag :(NSString *)message;

@end

static void Loge(const char* tag, const char* message);
static void Loge(const char* tag, const char* message)
{
	[Log e:[NSString stringWithCString:tag encoding:NSUTF8StringEncoding] :[NSString stringWithCString:message encoding:NSUTF8StringEncoding]];
}

static void Logd(const char* tag, const char* message);
static void Logd(const char* tag, const char* message)
{
	[Log d:[NSString stringWithCString:tag encoding:NSUTF8StringEncoding] :[NSString stringWithCString:message encoding:NSUTF8StringEncoding]];
}
