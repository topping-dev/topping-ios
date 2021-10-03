//
//  CheckBox.m
//  Topping
//
//  Created by Edo on 18.04.2021.
//  Copyright © 2021 Deadknight. All rights reserved.
//

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

@end
