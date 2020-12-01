#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LuaClass.h"
#import "LuaInterface.h"

@interface LuaBuffer : NSObject <LuaClass, LuaInterface>
{
}

+(LuaBuffer*)Create:(int)capacity;
-(int)GetByte:(int)index;
-(void)SetByte:(int)index :(int)value;

@property (nonatomic, strong) NSMutableArray *data;

@end
