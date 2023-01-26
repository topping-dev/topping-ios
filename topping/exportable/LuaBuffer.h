#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LuaClass.h"
#import "LuaInterface.h"

@interface LuaBuffer : NSObject <LuaClass, LuaInterface>
{
}

+(LuaBuffer*)create:(int)capacity;
-(int)getByte:(int)index;
-(void)setByte:(int)index :(int)value;

@property (nonatomic, strong) NSMutableArray *data;

@end
