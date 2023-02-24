#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LGViewGroup.h"
#import "LuaContext.h"

enum LAYOUTORIENTATION
{
	HORIZONTAL,
	VERTICAL
};

@interface LGLinearLayout : LGViewGroup
{
}

+(LGLinearLayout*)create:(LuaContext *)context;

@property (nonatomic, retain) NSString *android_orientation;
@property (nonatomic, retain) NSString *android_weightSum;
@property (nonatomic, retain) NSString *android_baseAligned;
@property (nonatomic, retain) NSString *android_baseAlignedChildIndex;
@property (nonatomic, retain) NSString *android_measureWithLargestChild;

//For material
@property (nonatomic, retain) NSString *android_hint;

@property (nonatomic) int extra;
@property (nonatomic) float percentGone;
@property (nonatomic) BOOL mBaseAligned;
@property (nonatomic) int mBaselineAlignedChildIndex;
@property (nonatomic) int mBaselineChildTop;
@property (nonatomic) int mTotalLength;
@property (nonatomic) float mWeightSum;
@property (nonatomic) BOOL mUseLargestChild;
@property (nonatomic, retain) NSMutableArray *mMaxAscent;
@property (nonatomic, retain) NSMutableArray *mMaxDescent;
@property (nonatomic) int orientation;
@property (nonatomic) int mDividerWidth;
@property (nonatomic) int mDividerHeight;


@end
