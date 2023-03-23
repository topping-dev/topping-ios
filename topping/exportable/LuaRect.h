#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LuaClass.h"
#import "LuaInterface.h"

@interface LuaRect : NSObject <LuaClass, LuaInterface>
{
    CGRect rect;
}

+(LuaRect*)create;
+(LuaRect*)createPar:(float)left :(float)top :(float)right :(float)bottom;
-(void)set:(float)left :(float)top :(float)right :(float)bottom;
-(float)getLeft;
-(float)getRight;
-(float)getTop;
-(float)getBottom;
-(CGRect)getCGRect;

@property (nonatomic) float left, right, top, bottom;

@end
