#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface DisplayMetrics : NSObject 
{

}

+(UIView *)getMasterView;
+(void)setMasterView:(UIView *)view;
+(CGRect)getBaseFrame;
+(void)setBaseFrame:(CGRect)frame;
+(float)getStatusBarHeight;
+(void)setStatusBarHeight:(float)height;
+(void)setDensity:(float)d :(float)sd;
+(float)dpToSp:(float)value;
+(float)spToDp:(float)value;
+(int)readSize:(NSString *)sz;

@end
