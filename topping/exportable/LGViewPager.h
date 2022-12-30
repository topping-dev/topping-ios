#import <Foundation/Foundation.h>
#import "LGViewGroup.h"

@class LGViewPager;
@class LGTabLayout;
@protocol LGTabBarDelegate;

@protocol LGViewPagerAdapter <NSObject>

-(void)setParentView:(LGView*)parent;
-(void)setReceiver:(LGView*)view;
-(int)getItemCount;

@end

@protocol LGViewPagerEvents <NSObject>

-(void)onAttachToLGViewPager:(LGViewPager*)viewPager;
-(void)onDetachedFromLGViewPager:(LGViewPager*)viewPager;

@end

@protocol OnPageChangeCallback <NSObject>

-(void)onPageChanged:(int)page;

@end

@interface OnPageListener : NSObject <OnPageChangeCallback>

@end

@interface TabLayoutOnPageChangeCallback : NSObject <OnPageChangeCallback>

@property LGTabLayout *tabLayout;

@end

@interface LGViewPager : LGViewGroup <OnPageChangeCallback, LGTabBarDelegate>

-(void)registerOnPageChangeCallback:(id<OnPageChangeCallback>) callback;
-(void)unRegisterOnPageChangeCallback:(id<OnPageChangeCallback>) callback;
-(int)getCurrentItem;

@property (nonatomic, retain) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, retain) LGView *lgview;
@property (nonatomic, retain) NSMutableArray *items;
@property (nonatomic, retain) LuaTranslator *ltTabSelectedListener;
@property (nonatomic, retain) NSMutableArray *pageChangeCallbacks;
@property (nonatomic, retain) id<LGViewPagerAdapter> adapterValue;

@end
