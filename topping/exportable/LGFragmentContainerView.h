#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LGFrameLayout.h"
#import "LuaRef.h"

@class FragmentManager;

@protocol OnApplyWindowInsetsListener <NSObject>

@end

@interface LGFragmentContainerView : LGFrameLayout

+(LGFragmentContainerView*)create:(LuaContext *)context;

-(instancetype)initWithFragmentManager:(FragmentManager*)fragmentManager;

@property (nonatomic, retain) FragmentManager* fm;
@property (nonatomic, retain) NSMutableArray* mDisapperingFragmentChildren;
@property (nonatomic, retain) NSMutableArray* mTransitioningFragmentViews;

//TODO:Window insets?

@property BOOL mDrawDisappearingViewsFirst;

@end
