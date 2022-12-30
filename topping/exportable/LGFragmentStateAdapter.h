#import <Foundation/Foundation.h>
#import "LGRecyclerView.h"
#import "LGFrameLayout.h"
#import "LuaFragment.h"

@protocol FragmentLifecycleCallbacks;
@protocol LGViewPagerAdapter;
@protocol LGViewPagerEvents;
@protocol OnPageChangeCallback;
@class LGViewPager;
@class LGFragmentStateAdapter;
@class LuaFragmentUICollectionViewCell;

@interface AdapterDataObserver : NSObject

-(void)onChanged;

@end

@protocol StatefulAdapter <NSObject>

-(NSMutableDictionary*)saveState;

-(void)restoreState:(NSMutableDictionary*)savedState;

@end

@protocol OnPostEventListener <NSObject>
    -(void)onPost;
@end

@interface OnPostEventListener_DUMMY : NSObject <OnPostEventListener>

@end

@interface FragmentTransactionCallback : NSObject

-(id<OnPostEventListener>)onFragmentPreAdded:(LuaFragment*)fragment;
-(id<OnPostEventListener>)onFragmentPreSavedInstanceState:(LuaFragment*)fragment;
-(id<OnPostEventListener>)onFragmentPreRemoved:(LuaFragment*)fragment;
-(id<OnPostEventListener>)onFragmentMaxLifecyclePreUpdated:(LuaFragment*)fragment :(LifecycleState)maxLifecycleState;

@property (nonatomic, strong) OnPostEventListener_DUMMY *dummy;


@end

@interface FragmentEventDispatcher : NSObject



@end

@class FragmentMaxLifecycleEnforcer;

@interface FragmentMaxLifecycleEnforcerPageChangeCallback : NSObject <OnPageChangeCallback>

- (instancetype)initWithEnforcer:(FragmentMaxLifecycleEnforcer *)enforcer;

@property (nonatomic, strong) FragmentMaxLifecycleEnforcer *enforcer;

@end

@interface FragmentMaxLifecycleEnforcerLifecycleCallback : NSObject <LifecycleEventObserver>

- (instancetype)initWithEnforcer:(FragmentMaxLifecycleEnforcer *)enforcer;

@property (nonatomic, strong) FragmentMaxLifecycleEnforcer *enforcer;

@end

@interface FragmentMaxLifecycleEnforcer : NSObject

-(void)register:(LGViewPager*)viewPager;
-(void)unregister:(LGViewPager*)viewPager;
-(void)updateFragmentMaxLifecycle:(BOOL) dataSetChanged;
-(LGViewPager*)inferViewPager:(LGViewPager*)recyclerView;

@property (nonatomic, strong) LGFragmentStateAdapter *adapter;
@property (nonatomic, strong) id<OnPageChangeCallback> pageChangeCallback;
@property (nonatomic, strong) AdapterDataObserver *dataObserver;
@property (nonatomic, strong) id<LifecycleEventObserver> lifecycleObserver;
@property (nonatomic, strong) LGViewPager *viewPager;

@end

@interface FragmentStateLifecycleCallback : NSObject <FragmentLifecycleCallbacks>

@property (nonatomic, strong) LuaContext *lc;
@property (nonatomic, strong) LuaFragment *fragment;
@property (nonatomic, strong) LGFrameLayout *frameLayout;
@property (nonatomic, strong) LGFragmentStateAdapter *adapter;

@end

@interface FragmentStateLifecycleObserver : NSObject <LifecycleEventObserver>

- (instancetype)initWithAdapter:(LGFragmentStateAdapter *)adapter :(LuaFragmentUICollectionViewCell*)cell;

@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) LGFragmentStateAdapter *adapter;
@property (nonatomic, strong) LuaFragmentUICollectionViewCell *cell;

@end

@interface LuaFragmentUICollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) LGFrameLayout *frameLayout;
@property (nonatomic, strong) LuaFragment *fragment;

@end

@interface LGFragmentStateAdapter : NSObject <LuaClass, LuaInterface, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, LGViewPagerEvents, LGViewPagerAdapter, StatefulAdapter>

+(LGFragmentStateAdapter*)Create:(LuaContext*)context :(FragmentManager*)fragmentManager :(LuaLifecycle*)lifecycle;
+(LGFragmentStateAdapter*)CreateFromForm:(LuaForm*)form;
+(LGFragmentStateAdapter*)CreateFromFragment:(LuaFragment*)form;

-(instancetype)initWithForm:(LuaForm *)form;
-(instancetype)initWithFragment:(LuaFragment *)fragment;
-(instancetype)initWithFragmentManager:(LuaContext*)context :(FragmentManager*)fragmentManager :(LuaLifecycle*)lifecycle;

-(void)addViewToContainer:(LGView*)v :(LGFrameLayout*) container;
-(LuaFragment*)createFragment:(int)position;
-(BOOL)shouldDelayFragmentTransactions;
-(int)getItemCount;
-(NSString*)getItemId:(int)position;

-(void)SetCreateFragment:(LuaTranslator*)lt;
-(void)SetGetItemCount:(LuaTranslator*)lt;

@property (nonatomic, strong) NSString* KEY_PREFIX_FRAGMENT;
@property (nonatomic, strong) NSString* KEY_PREFIX_STATE;
@property (nonatomic, strong) LuaLifecycle* lifecycle;
@property (nonatomic, strong) FragmentManager *fragmentManager;
@property (nonatomic, strong) LuaContext *lc;
@property (nonatomic, strong) LGView *parent;
@property (nonatomic, strong) LGView *receiverDelegate;
@property (nonatomic, strong) MutableOrderedDictionary *savedStates;
@property (nonatomic, strong) FragmentMaxLifecycleEnforcer *maxLifecyleEnforcer;
@property (nonatomic) BOOL hasStaleFragments;
@property (nonatomic, strong) NSString *primaryItemId;

@property (nonatomic, strong) MutableOrderedDictionary *itemIdToViewHolder;
@property (nonatomic, strong) MutableOrderedDictionary *fragments;
@property (nonatomic, strong) MutableOrderedDictionary *cells;

@property (nonatomic) int quantumPage;
@property (nonatomic) int possibleQuantumPage;

@property (nonatomic, strong) LuaTranslator *ltCreateFragment;
@property (nonatomic, strong) LuaTranslator *ltGetItemCount;

@end
