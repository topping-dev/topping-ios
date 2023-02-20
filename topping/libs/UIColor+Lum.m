#import "UIColor+Lum.h"

@implementation UIColor (Lum)

+ (UIImage *)imageFromColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

-(BOOL) isDarkColor
{
    CGFloat r = 0, g = 0, b = 0, a = 0;
    [self getRed:&r green:&g blue:&b alpha:&a];
    CGFloat lum = (0.2126 * r) + (0.7152 * g) + (0.0722 * b);
    return lum < 0.5;
}

-(UIColor *)changeAlphaTo:(float)alpha {
    CGFloat r,g,b,a;
    [self getRed:&r green:&g blue:&b alpha:&a];
    
    return [UIColor colorWithRed:r green:g blue:b alpha:alpha];
}

-(UIColor *)changeAlphaToPercent:(int)percent {
    int percentReal = percent;
    if(percentReal < 0) {
        percentReal = 0;
    } else if(percentReal > 100) {
        percentReal = 100;
    }
    CGFloat r,g,b,a;
    [self getRed:&r green:&g blue:&b alpha:&a];
    
    return [UIColor colorWithRed:r green:g blue:b alpha:((1.0f * ((float)percent)) / 100.0f)];
}

@end
