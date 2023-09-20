#import "CheckBox.h"

@implementation CheckBox

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self = [super initWithFrame:frame]) {
        NSBundle *bund = [NSBundle bundleWithIdentifier:@"dev.topping.ios"];
        self = [[bund loadNibNamed:@"CheckBox" owner:self options:nil] lastObject];
        [self setFrame:CGRectMake(frame.origin.x,
                                  frame.origin.y,
                                  [self frame].size.width,
                                  [self frame].size.height)];
    }
    return self;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"asd");
}

@end
