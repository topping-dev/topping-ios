#import <Foundation/Foundation.h>
#import "LGView.h"

@interface LGViewGroup : LGView

-(void)AddSubview:(LGView*)val;
-(void)ClearSubviews;
-(NSMutableDictionary*)GetBindings;

@property (nonatomic, strong) NSMutableArray *subviews;
@property (nonatomic, strong) NSMutableDictionary *subviewMap;

@end
