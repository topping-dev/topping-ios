#import "LGViewPager.h"
#import <topping/topping-Swift.h>
#import "Topping.h"
#import "MaterialTabs+TabBarView.h"

@implementation TabLayoutOnPageChangeCallback

- (instancetype)initWithTabLayout:(LGTabLayout*)tabLayout
{
    self = [super init];
    if (self) {
        self.tabLayout = tabLayout;
    }
    return self;
}

- (void)onPageChanged:(int)page {
    MDCTabBarView *mtbv = ((MDCTabBarView*)self.tabLayout.tab);
    [mtbv setSelectedItem:[mtbv.items objectAtIndex:page] animated:false];
}

@end

@implementation LGViewPager

-(void)SetupComponent:(UIView *)view {
    [super SetupComponent:view];
    self.pageChangeCallbacks = [NSMutableArray new];
    self.flowLayout = [SnappingLayout new];
    [((SnappingLayout*)self.flowLayout) setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    ((SnappingLayout*)self.flowLayout).sectionInsetReference = UICollectionViewFlowLayoutSectionInsetFromContentInset;
    self.lgview = [LGView Create:self.lc];
    self.lgview.android_layout_width = @"match_parent";
    self.lgview.android_layout_height = @"match_parent";
    self.lgview._view = [[UICollectionView alloc] initWithFrame:CGRectMake(self.dX, self.dY, self.dWidth, self.dHeight) collectionViewLayout:self.flowLayout];
    ((UICollectionView*)self.lgview._view).decelerationRate = UIScrollViewDecelerationRateFast;
}

-(void)ComponentAddMethod:(UIView *)par :(UIView *)me {
    [super ComponentAddMethod:par :me];
    [self AddSubview:self.lgview];
    [self._view addSubview:self.lgview._view];
    [self Resize];
}

-(void)SetAdapter:(id<LGViewPagerAdapter>)adapter {
    [adapter setParentView:self.lgview];
    [adapter setReceiver:self];
    UICollectionView *cv = (UICollectionView*)self.lgview._view;
    if(cv.delegate != nil && [cv.delegate conformsToProtocol:@protocol(LGViewPagerEvents)]) {
        [((id<LGViewPagerEvents>)cv.delegate) onDetachedFromLGViewPager:self];
    }
    cv.dataSource = (id<UICollectionViewDataSource>)adapter;
    cv.delegate = (id<UICollectionViewDelegate>)adapter;
    if([adapter conformsToProtocol:@protocol(LGViewPagerEvents)]) {
        [((id<LGViewPagerEvents>)adapter) onAttachToLGViewPager:self];
    }
    self.adapterValue = adapter;
}

-(void)didSelectTab:(LuaTab *)tab atIndex:(int)pos {
    UICollectionView *cv = (UICollectionView*)self.lgview._view;
    [cv scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:pos inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}

-(void)SetTabLayout:(LGTabLayout*)tabLayout :(LuaTranslator*)ltTabTitle {
    [self registerOnPageChangeCallback:[[TabLayoutOnPageChangeCallback alloc] initWithTabLayout:tabLayout]];
    int count = [self.adapterValue getItemCount];
    for(int i = 0; i < count; i++) {
        [tabLayout AddTab:(LuaTab*)[ltTabTitle Call:[NSNumber numberWithInt:i]]];
    }
    tabLayout.delegate = self;
    [self.adapterValue setScroller:tabLayout];
}

-(void)Notify
{
    [((UICollectionView*)self.lgview._view) reloadData];
}

-(void)ResizeAndInvalidate {
    [super ResizeAndInvalidate];
    [self Notify];
}

-(void)ConfigChange {
    [self Notify];
}

-(NSMutableDictionary *)OnSaveInstanceState {
    NSMutableDictionary *superState = [super OnSaveInstanceState];
    //TODO:Fix state
    return superState;
}

- (void)onPageChanged:(int)page {
    for(id<OnPageChangeCallback> callback in self.pageChangeCallbacks) {
        [callback onPageChanged:page];
    }
}

-(void)registerOnPageChangeCallback:(id<OnPageChangeCallback>) callback {
    [self.pageChangeCallbacks addObject:callback];
}

-(void)unRegisterOnPageChangeCallback:(id<OnPageChangeCallback>) callback {
    [self.pageChangeCallbacks removeObject:callback];
}

-(int)getCurrentItem {
    return (int)[((UICollectionView*)self.lgview._view).indexPathsForVisibleItems objectAtIndex:0].row;
}

-(NSString*)GetId
{
    if(self.lua_id != nil)
        return self.lua_id;
    if(self.android_id != nil)
        return self.android_id;
    return [LGViewGroup className];
}

+ (NSString*)className
{
    return @"LGViewPager";
}

+(NSMutableDictionary*)luaMethods
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    
    InstanceMethodNoRet(SetAdapter:, @[[LGFragmentStateAdapter class]], @"SetAdapter")
    InstanceMethodNoRet(SetTabLayout::, @[[LGTabLayout class]C [LuaTranslator class]], @"SetTabLayout");
    
    return dict;
}

@end
