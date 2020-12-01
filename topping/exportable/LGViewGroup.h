#import <Foundation/Foundation.h>
#import "LGView.h"

@interface LGViewGroup : LGView

-(void)AddSubview:(LGView*)val;
-(void)ClearSubviews;

@property (nonatomic, strong) NSMutableArray *subviews;

@end
