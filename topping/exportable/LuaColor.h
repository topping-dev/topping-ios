#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LuaClass.h"
#import "LuaInterface.h"

@interface LuaColor : NSObject <LuaClass, LuaInterface>
{
    UIColor* colorValue;
}

+(LuaColor*)fromString:(NSString*)colorStr;
+(LuaColor*)createFromARGB:(int)alpha :(int)red :(int)green :(int)blue;
+(LuaColor*)createFromRGB:(int)red :(int)green :(int)blue;
+(LuaColor*)colorFromInt:(int)color;
+(unsigned int)alpha:(unsigned int) color;
+(int)red:(int) color;
+(int)green:(int) color;
+(int)blue:(int) color;
-(int)getColorValue;

@property (nonatomic, retain) UIColor* colorValue;

@end
