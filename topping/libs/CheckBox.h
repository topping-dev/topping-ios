//
//  CheckBox.h
//  Topping
//
//  Created by Edo on 18.04.2021.
//  Copyright © 2021 Deadknight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CheckBox : UIView

@property (strong, nonatomic) IBOutlet UILabel *title;
@property (strong, nonatomic) IBOutlet UISwitch *sw;

@end
