#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIColor (Lum)

+ (UIImage *)imageFromColor:(UIColor *)color;
-(BOOL) isDarkColor;
-(UIColor*) changeAlphaTo:(float)alpha;
-(UIColor*) changeAlphaToPercent:(int)percent;

@end
