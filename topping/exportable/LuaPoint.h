#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LuaClass.h"
#import "LuaInterface.h"

@interface LuaPoint : NSObject <LuaClass, LuaInterface>
{
    CGPoint point;
}

+(LuaPoint*)CreatePoint;
+(LuaPoint*)CreatePointPar:(float)x :(float)y;
-(void)Set:(float)x :(float)y;
-(float)GetX;
-(float)GetY;

@end
