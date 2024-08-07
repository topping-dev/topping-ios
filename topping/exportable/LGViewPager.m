#import "LGViewPager.h"
#import <ToppingIOSKotlinHelper/ToppingIOSKotlinHelper.h>
#import <Topping/Topping-Swift.h>
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

-(void)setupComponent:(UIView *)view {
    [super setupComponent:view];
    self.pageChangeCallbacks = [NSMutableArray new];
    self.flowLayout = [SnappingLayout new];
    [((SnappingLayout*)self.flowLayout) setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    ((SnappingLayout*)self.flowLayout).sectionInsetReference = UICollectionViewFlowLayoutSectionInsetFromContentInset;
    self.lgview = [LGView create:self.lc];
    self.lgview.android_layout_width = @"match_parent";
    self.lgview.android_layout_height = @"match_parent";
    self.lgview._view = [[UICollectionView alloc] initWithFrame:CGRectMake(self.dX, self.dY, self.dWidth, self.dHeight) collectionViewLayout:self.flowLayout];
    ((UICollectionView*)self.lgview._view).decelerationRate = UIScrollViewDecelerationRateFast;
}

-(void)componentAddMethod:(UIView *)par :(UIView *)me {
    [super componentAddMethod:par :me];
    [self addSubview:self.lgview];
    [self._view addSubview:self.lgview._view];
    [self resize];
}

-(void)setAdapter:(id<LGViewPagerAdapter>)adapter {
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

-(void)setTabLayout:(LGTabLayout*)tabLayout :(LuaTranslator*)ltTabTitle {
    [self registerOnPageChangeCallback:[[TabLayoutOnPageChangeCallback alloc] initWithTabLayout:tabLayout]];
    int count = [self.adapterValue getItemCount];
    for(int i = 0; i < count; i++) {
        [tabLayout addTab:(LuaTab*)[ltTabTitle call:[NSNumber numberWithInt:i]]];
    }
    tabLayout.delegate = self;
    [self.adapterValue setScroller:tabLayout];
}

-(void)notify
{
    [((UICollectionView*)self.lgview._view) reloadData];
}

-(void)resizeAndInvalidate {
    [super resizeAndInvalidate];
    [self notify];
}

-(void)configChange {
    [self notify];
}

-(LuaBundle *)onSaveInstanceState {
    LuaBundle *superState = [super onSaveInstanceState];
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
    
    InstanceMethodNoRet(setAdapter:, @[[LGFragmentStateAdapter class]], @"setAdapter")
    InstanceMethodNoRet(setTabLayout::, @[[LGTabLayout class]C [LuaTranslator class]], @"setTabLayout");
    
    return dict;
}

@end
