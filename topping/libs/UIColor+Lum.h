#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIColor (Lum)

-(BOOL) isDarkColor;
-(UIColor*) changeAlphaTo:(float)alpha;
-(UIColor*) changeAlphaToPercent:(int)percent;

@end
