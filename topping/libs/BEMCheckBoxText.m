#import <CoreText/CoreText.h>
#import "BEMCheckBoxText.h"
#import "Defines.h"
#import <BEMCheckBox/BEMCheckBox.h>

@implementation BEMCheckBoxText

-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    if(self.text != nil)
    {
        if(!self.textInit)
        {
            self.textInit = YES;
            self.label = [[UILabel alloc] initWithFrame:CGRectMake(self.checkboxTextInset.left, 0, self.frame.size.width - self.checkboxTextInset.left, self.frame.size.height)];
            self.label.backgroundColor = [UIColor clearColor];
            [self addSubview:self.label];
        }
        self.label.font = self.font;
        self.label.textColor = self.textColor;
        self.label.text = self.text;
    }
}

@end
