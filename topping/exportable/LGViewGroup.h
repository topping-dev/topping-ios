#import <Foundation/Foundation.h>
#import "LGView.h"

@interface LGViewGroup : LGView

-(void)addSubview:(LGView*)val;
-(void)addSubview:(LGView*)val :(NSInteger)index;
-(void)removeSubview:(LGView*)val;
-(void)removeAllSubViews;
-(NSMutableDictionary*)getBindings;

-(int)getParentWidthSpec;
-(int)getParentHeightSpec;
-(void)measureChildWithMargins:(LGView*)child :(int)parentWidthMeasureSpec :(int)widthUsed :(int)parentHeightMeasureSpec :(int)heightUsed;
+(int)getChildMeasureSpec:(int)spec :(int)padding :(int)childDimension;

@property (nonatomic, strong) NSMutableArray *subviews;
@property (nonatomic, strong) NSMutableDictionary *subviewMap;

@end
