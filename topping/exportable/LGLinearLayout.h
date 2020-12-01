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

+(LGLinearLayout*)Create:(LuaContext *)context;

@property (nonatomic, retain) NSString *android_orientation;
@property (nonatomic, retain) NSNumber *android_weightSum;

@property (nonatomic) int extra;
@property (nonatomic) float percentGone;

@end
