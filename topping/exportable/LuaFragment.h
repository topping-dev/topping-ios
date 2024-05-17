#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LuaInterface.h"
#import "LuaClass.h"
#import "KeyboardHelper.h"
#import "LuaContext.h"
#import "LGView.h"
#import "ViewModelStore.h"
#import "ILuaFragment.h"

#define SAVED_STATE_TAG @"android:support:fragments"

@class LGView;
@class FragmentManager;
@class LGLayoutParser;
@class LGViewGroup;
@class FragmentViewLifecycleOwner;
@class LuaMutableLiveData;
@class SavedStateRegistryController;
@protocol ViewModelProviderFactory;
@protocol SavedStateRegistryOwner;
@protocol FragmentContainer;

@interface LuaFragmentContainer : NSObject <FragmentContainer>

-(instancetype)initWithFragment:(LuaFragment*)fragment;

@property (nonatomic, retain) LuaFragment* fragment;

@end

@interface OnPreAttachedListener : NSObject

-(void)onPreAttached;

@end

typedef NS_ENUM(NSInteger, FragmentState)
{
    FS_INITIALIZING = -1,
    FS_ATTACHED,
    FS_CREATED,
    FS_VIEW_CREATED,
    FS_AWAITING_EXIT_EFFECTS,
    FS_ACTIVITY_CREATED,
    FS_STARTED,
    FS_AWAITING_ENTER_EFFECTS,
    FS_RESUMED
};

@interface LuaFragment : NSObject <LuaClass, LuaInterface, LifecycleOwner, SavedStateRegistryOwner, ViewModelStoreOwner>
{
}

+(LuaFragment*)create:(LuaContext*)context :(LuaRef*)luaId;
+(LuaFragment*)create:(LuaContext*)context :(LuaRef*)luaId :(LuaBundle*)arguments;
+(LuaFragment*)createWithUI:(LuaContext*)context :(LuaRef*)luaId :(LuaRef *)ui :(LuaBundle*)arguments;
-(LuaContext*)getContext;
-(LuaForm*)getForm;
-(FragmentManager*)getFragmentManager;
-(LGView*)getViewById:(LuaRef*)lId;
-(LGView*)getViewByIdInternal:(NSString*)sId;
-(LGView*)getView;
-(void)setView:(LGView*)v;
-(void)setViewId:(NSString*)luaId;
-(void)setViewXML:(LuaRef *)xml;
-(void)setTitle:(NSString *)str;
-(void)setTitleRef:(LuaRef *)ref;
-(void)close;
-(LuaNavController*)getNavController;
-(BOOL)isInitialized;
-(NSDictionary*)getBindings;

-(void)onCreate:(LuaBundle*)savedInstanceState;
-(LGView*)onCreateView:(LGLayoutParser*)inflater :(LGViewGroup*)container :(LuaBundle*)savedInstanceState;
-(void)onViewCreated:(LGView*)view :(LuaBundle*)savedInstanceState;
-(void)onActivityCreated:(LuaBundle*)savedInstanceState;

-(void)initState;
-(FragmentManager*)getParentFragmentManager;
-(FragmentManager*)getChildFragmentManager;
-(LuaFragment*)findFragmentByWho:(NSString*)who;
-(BOOL)isInBackStack;
-(void)setArguments:(LuaBundle*)args;
-(LuaBundle*)getArguments;
-(BOOL)isStateSaved;
-(void)onHiddenChanged:(BOOL) hidden;
-(BOOL)isHidden;
-(void)setPopDirection:(BOOL) direction;
-(void)setNextTransition:(NSInteger) transition;
-(void)setAnimations:(NSString*)enter :(NSString*)exit :(NSString*)popEnter :(NSString*)popExit;
-(LGLayoutParser*)getLayoutInflater;
-(LGLayoutParser*)getLayoutInflater:(LuaBundle*) savedInstanceState;
-(LGLayoutParser*)performGetLayoutInflater:(LuaBundle*) savedInstanceState;
-(LGLayoutParser*)onGetLayoutInflater:(LuaBundle*) savedInstanceState;
-(id<ViewModelProviderFactory>)getDefaultViewModelProviderFactory;

-(id<FragmentContainer>)createFragmentContainer;
-(void)onInflate:(LuaContext*)context :(NSDictionary*)attrs :(LuaBundle*)savedInstanceState;
-(void)onInflateForm:(LuaForm*)form :(NSDictionary*)attrs :(LuaBundle*)savedInstanceState;
-(void)onAttachFragment:(LuaFragment *)fragment;
-(void)onPrimaryNavigationFragmentChanged:(BOOL)isPrimaryNavigationFragment;
-(void)onAttach:(LuaContext *)context;
-(void)restoreChildFragmentState:(LuaBundle*) savedInstanceState;
-(void)onStart;
-(void)onResume;
-(void)onSaveInstanceState:(LuaBundle*) outState;
-(void)onPause;
-(void)onStop;
-(void)onLowMemory;
-(void)onDestroyView;
-(void)onDestroy;
-(void)performAttach;
-(void)performCreate:(LuaBundle*) savedInstanceState;
-(void)performCreateView:(LGLayoutParser*) inflater :(LGViewGroup*) container :(LuaBundle *)savedInstanceState;
-(void)performViewCreated;
-(void)performActivityCreated:(LuaBundle *)savedInstanceState;
-(void)restoreViewState;
-(void)performStart;
-(void)performResume;
-(void)noteStateNotSaved;
-(void)performPrimaryNavigationFragmentChanged;
-(void)performSaveInsanceState:(LuaBundle*)outState;
-(void)performPause;
-(void)performStop;
-(void)performDestroyView;
-(void)performDestory;
-(void)performDetach;

-(LuaLifecycleOwner*)getLifecycleOwner;

@property(nonatomic, retain) NSString *luaId;
@property(nonatomic, retain) LuaContext *context;
@property(nonatomic, retain) LGView *lgview;
@property(nonatomic, retain) LuaRef *ui;

@property (nonatomic, retain) FragmentHostCallback *mHost;
@property (nonatomic, retain) FragmentManager *mFragmentManager;
@property (nonatomic, retain) FragmentManager *mChildFragmentManager;
@property (nonatomic, retain) FragmentViewLifecycleOwner *mViewLifecycleOwner;
@property (nonatomic, retain) LuaMutableLiveData *mViewLifecycleOwnerLiveData;
@property (nonatomic, retain) id<ViewModelProviderFactory> mDefaultFactory;
@property (nonatomic, retain) SavedStateRegistryController *mSavedStateRegistryController;
@property (nonatomic, retain) NSMutableDictionary *mOnPreAttachedListeners;
@property (nonatomic, retain) LuaBundle *mSavedFragmentState;
@property (nonatomic, retain) LuaBundle *mSavedViewState;
@property (nonatomic, retain) NSMutableDictionary *mSavedViewRegistryState;
@property (nonatomic, retain) NSNumber *mSavedUserVisibleHint;
@property LifecycleState mMaxState;
@property (nonatomic, retain) LifecycleRegistry *mLifecycleRegistry;
@property (nonatomic, retain) LuaBundle *mArguments;
@property (nonatomic, retain) LuaFragment *mTarget;
@property NSInteger mTargetRequestCode;
@property (nonatomic, retain) NSString *mTargetWho;
@property (nonatomic, retain) NSString *mWho;
@property (nonatomic, retain) NSString *mPreviousWho;
@property (nonatomic, retain) LuaFragment *mParentFragment;
@property NSInteger mBackStackNesting;

@property NSInteger mState;
@property (nonatomic, retain) LGViewGroup *mContainer;
@property (nonatomic, retain) NSString* mContainerId;
@property (nonatomic, retain) NSString* mFragmentId;
@property(nonatomic, retain) NSString *mTag;
@property Boolean mFromLayout;
@property Boolean mInLayout;
@property Boolean mPerformedCreateView;
@property Boolean mAdded;
@property Boolean mRemoving;
@property Boolean mDeferStart;
@property Boolean mBeingSaved;
@property Boolean mHidden;
@property Boolean mHiddenChanged;
@property Boolean mRestored;
@property Boolean mIsCreated;
@property Boolean mRetainInstance;
@property Boolean mRetainInstanceChangedWhileDetached;
@property Boolean mDetached;
@property Boolean mCalled;
@property (nonatomic, retain) NSNumber *mIsPrimaryNavigationFragment;
@property (nonatomic, retain) ILuaFragment *kotlinInterface;
@property (nonatomic, retain) LuaViewModelProvider *viewModelProvider;

@end
