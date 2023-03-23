#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LuaClass.h"
#import "LuaInterface.h"

@interface LuaPoint : NSObject <LuaClass, LuaInterface>
{
    CGPoint point;
}

+(LuaPoint*)create;
+(LuaPoint*)createPar:(float)x :(float)y;
-(void)set:(float)x :(float)y;
-(float)getX;
-(float)getY;

@end
