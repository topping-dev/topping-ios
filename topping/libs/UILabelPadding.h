#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UILabelPadding : UILabel

@property (nonatomic, assign) UIEdgeInsets insets;
- (void)resizeHeightToFitText;

@end
