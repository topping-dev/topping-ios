#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIImage (Resize)

- (UIImage *)imageWithSize:(CGSize)newSize;
- (UIImage *)imageWithSizeAspect:(CGFloat)newSize;

@end
