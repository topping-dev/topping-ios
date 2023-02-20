#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define MDCInkStyleUnbounded 1

@interface MDCButton : UIButton

@property (nonatomic, retain) UIColor *inkColor;
@property (nonatomic) BOOL enableRippleBehavior;
@property (nonatomic) int inkStyle;

@end
