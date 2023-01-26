#import <Foundation/Foundation.h>
#import "LGView.h"

@interface LGViewGroup : LGView

-(void)addSubview:(LGView*)val;
-(void)addSubview:(LGView*)val :(NSInteger)index;
-(void)removeSubview:(LGView*)val;
-(void)removeAllSubViews;
-(void)clearSubviews;
-(NSMutableDictionary*)getBindings;

@property (nonatomic, strong) NSMutableArray *subviews;
@property (nonatomic, strong) NSMutableDictionary *subviewMap;

@end
