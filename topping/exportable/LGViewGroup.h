#import <Foundation/Foundation.h>
#import "LGView.h"

@interface LGViewGroup : LGView

-(void)AddSubview:(LGView*)val;
-(void)AddSubview:(LGView*)val :(NSInteger)index;
-(void)RemoveSubview:(LGView*)val;
-(void)ClearSubviews;
-(NSMutableDictionary*)GetBindings;

@property (nonatomic, strong) NSMutableArray *subviews;
@property (nonatomic, strong) NSMutableDictionary *subviewMap;

@end
