#import <CoreText/CoreText.h>
#import "BEMCheckBoxText.h"
#import "Defines.h"
#import <BEMCheckBox/BEMCheckBox.h>
#import "LGDimensionParser.h"

@implementation BEMCheckBoxText

-(instancetype)initWithFrame:(CGRect)frame
{
    BEMCheckBoxText *cb = [super initWithFrame:frame];
    self.checkbox = [[BEMCheckBox alloc] initWithFrame:CGRectMake(0, [[LGDimensionParser GetInstance] GetDimension:@"5dp"], self.checkboxSize.width, self.checkboxSize.height)];
    [cb addSubview:self.checkbox];
    [cb bringSubviewToFront:self.checkbox];
    self.userInteractionEnabled = YES;
    return cb;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (event.type == UIEventTypeTouches)
    {
        [self.checkbox performSelector:NSSelectorFromString(@"handleTapCheckBox:") withObject:nil];
    }
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    return YES;
}

-(CGSize)intrinsicContentSize
{
    self.numberOfLines = 0;
    CGSize s = [super intrinsicContentSize];
    s.height = s.height + self.checkboxTextInset.top + self.checkboxTextInset.bottom;
    s.width = s.width + self.checkboxTextInset.left + self.checkboxTextInset.right;
    return s;
}

-(void)drawTextInRect:(CGRect)rect
{
    CGRect r = UIEdgeInsetsInsetRect(rect, self.checkboxTextInset);
    [super drawTextInRect:r];
}

-(CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines
{
    CGRect tr = UIEdgeInsetsInsetRect(bounds, self.checkboxTextInset);
    return [super textRectForBounds:tr limitedToNumberOfLines:0];
}

@end
