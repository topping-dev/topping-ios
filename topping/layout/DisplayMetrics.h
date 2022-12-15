#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface DisplayMetrics : NSObject 
{

}

+(UIView *)GetMasterView;
+(void)SetMasterView:(UIView *)view;
+(CGRect)GetBaseFrame;
+(void)SetBaseFrame:(CGRect)frame;
+(float)GetStatusBarHeight;
+(void)SetStatusBarHeight:(float)height;
+(void)SetDensity:(float)d :(float)sd;
+(int)readSize:(NSString *)sz;

@end
