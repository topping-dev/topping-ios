#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LuaClass.h"
#import "LuaInterface.h"

@interface LuaColor : NSObject <LuaClass, LuaInterface>
{
    UIColor* colorValue;
}

+(LuaColor*)FromString:(NSString*)colorStr;
+(LuaColor*)CreateFromARGB:(int)alpha :(int)red :(int)green :(int)blue;
+(LuaColor*)CreateFromRGB:(int)red :(int)green :(int)blue;
+(LuaColor*)ColorFromInt:(int)color;
+(unsigned int)Alpha:(unsigned int) color;
+(int)Red:(int) color;
+(int)Green:(int) color;
+(int)Blue:(int) color;
-(int)GetColorValue;

@property (nonatomic, retain) UIColor* colorValue;

@end
