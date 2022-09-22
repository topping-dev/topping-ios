#import "UIImage+Resize.h"

@implementation UIImage (Resize)
- (UIImage *)imageWithSize:(CGSize)newSize
{
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:newSize];
    UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext*_Nonnull myContext) {
        [self drawInRect:(CGRect) {.origin = CGPointZero, .size = newSize}];
    }];
    return [image imageWithRenderingMode:self.renderingMode];
}

- (UIImage *)imageWithSizeAspect:(CGFloat)maxPart
{
    CGFloat ratio = 1;
    if(self.size.height > self.size.width)
    {
        ratio = maxPart / self.size.height;
    }
    else
    {
        ratio = maxPart / self.size.width;
    }
    CGSize newSize = CGSizeMake(self.size.width * ratio, self.size.height * ratio);
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:newSize];
    UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext*_Nonnull myContext) {
        [self drawInRect:(CGRect) {.origin = CGPointZero, .size = newSize}];
    }];
    return [image imageWithRenderingMode:self.renderingMode];
}
@end

