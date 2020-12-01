#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LuaClass.h"
#import "LuaInterface.h"

@interface LuaRect : NSObject <LuaClass, LuaInterface>
{
    CGRect rect;
}

+(LuaRect*)CreateRect;
+(LuaRect*)CreateRectPar:(float)left :(float)top :(float)right :(float)bottom;
-(void)Set:(float)left :(float)top :(float)right :(float)bottom;
-(float)GetLeft;
-(float)GetRight;
-(float)GetTop;
-(float)GetBottom;

@end
