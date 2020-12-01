#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface DisplayMetrics : NSObject 
{

}

+(UIView *)GetMasterView;
+(void)SetMasterView:(UIView *)view;
+(void)SetDensity:(float)d :(float)sd;
+(int)readSize:(NSString *)sz;

@end
