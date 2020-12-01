#import "UIColor+Lum.h"

@implementation UIColor (Lum)

-(BOOL) isDarkColor
{
    CGFloat r = 0, g = 0, b = 0, a = 0;
    [self getRed:&r green:&g blue:&b alpha:&a];
    CGFloat lum = (0.2126 * r) + (0.7152 * g) + (0.0722 * b);
    return lum < 0.5;
}

@end
