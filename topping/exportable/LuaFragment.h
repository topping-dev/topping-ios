#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LuaInterface.h"
#import "LuaClass.h"
#import "KeyboardHelper.h"
#import "LuaContext.h"
#import "LGView.h"
#import "ViewModelStore.h"

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

typedef enum FragmentEvents
{
    FRAGMENT_EVENT_CREATE,
    FRAGMENT_EVENT_CREATE_VIEW,
    FRAGMENT_EVENT_VIEW_CREATED,
    FRAGMENT_EVENT_RESUME,
    FRAGMENT_EVENT_PAUSE,
    FRAGMENT_EVENT_DESTROY,
    FRAGMENT_EVENT_COUNT
} FragmentEvents;

@interface LuaFragment : NSObject <LuaClass, LuaInterface, LifecycleOwner, SavedStateRegistryOwner, ViewModelStoreOwner>
{
}

+(NSObject*)OnFragmentEvent:(NSObject*)pGui :(int) EventType :(LuaContext*)lc :(int)ArgCount, ...;
+(LuaFragment*)Create:(LuaContext*)context :(NSString*)luaId;
+(LuaFragment*)Create:(LuaContext*)context :(NSString*)luaId :(NSMutableDictionary*)arguments;
+(LuaFragment*)CreateWithUI:(LuaContext*)context :(NSString*)luaId :(NSString *)ui;
-(LuaContext*)GetContext;
-(LuaForm*)GetForm;
-(FragmentManager*)GetFragmentManager;
-(LGView*)GetViewById:(NSString*)lId;
-(LGView*)GetView;
-(void)SetView:(LGView*)v;
-(void)SetViewId:(NSString*)luaId;
-(void)SetViewXML:(NSString *)xml;
-(void)SetTitle:(NSString *)str;
-(void)Close;
-(BOOL)IsInitialized;

-(void)onCreate:(NSMutableDictionary*)savedInstanceState;
-(LGView*)onCreateView:(LGLayoutParser*)inflater :(LGViewGroup*)container :(NSMutableDictionary*)savedInstanceState;
-(void)onViewCreated:(LGView*)view :(NSMutableDictionary*)savedInstanceState;
-(void)onActivityCreated:(NSMutableDictionary*)savedInstanceState;

-(void)initState;
-(FragmentManager*)getParentFragmentManager;
-(FragmentManager*)getChildFragmentManager;
-(LuaFragment*)findFragmentByWho:(NSString*)who;
-(BOOL)isInBackStack;
-(void)setArguments:(NSMutableDictionary*)args;
-(NSMutableDictionary*)getArguments;
-(BOOL)isStateSaved;
-(void)onHiddenChanged:(BOOL) hidden;
-(BOOL)isHidden;
-(void)setPopDirection:(BOOL) direction;
-(void)setNextTransition:(NSInteger) transition;
-(void)setAnimations:(NSString*)enter :(NSString*)exit :(NSString*)popEnter :(NSString*)popExit;
-(LGLayoutParser*)getLayoutInflater;
-(LGLayoutParser*)getLayoutInflater:(NSMutableDictionary*) savedInstanceState;
-(LGLayoutParser*)performGetLayoutInflater:(NSMutableDictionary*) savedInstanceState;
-(LGLayoutParser*)onGetLayoutInflater:(NSMutableDictionary*) savedInstanceState;
-(id<ViewModelProviderFactory>)getDefaultViewModelProviderFactory;

-(id<FragmentContainer>)createFragmentContainer;
-(void)onInflate:(LuaContext*)context :(NSDictionary*)attrs :(NSMutableDictionary*)savedInstanceState;
-(void)onInflateForm:(LuaForm*)form :(NSDictionary*)attrs :(NSMutableDictionary*)savedInstanceState;
-(void)onAttachFragment:(LuaFragment *)fragment;
-(void)onPrimaryNavigationFragmentChanged:(BOOL)isPrimaryNavigationFragment;
-(void)onAttach:(LuaContext *)context;
-(void)restoreChildFragmentState:(NSMutableDictionary*) savedInstanceState;
-(void)onStart;
-(void)onResume;
-(void)onSaveInstanceState:(NSMutableDictionary*) outState;
-(void)onPause;
-(void)onStop;
-(void)onLowMemory;
-(void)onDestroyView;
-(void)onDestroy;
-(void)performAttach;
-(void)performCreate:(NSMutableDictionary*) savedInstanceState;
-(void)performCreateView:(LGLayoutParser*) inflater :(LGViewGroup*) container :(NSMutableDictionary *)savedInstanceState;
-(void)performViewCreated;
-(void)performActivityCreated:(NSMutableDictionary *)savedInstanceState;
-(void)restoreViewState;
-(void)performStart;
-(void)performResume;
-(void)noteStateNotSaved;
-(void)performPrimaryNavigationFragmentChanged;
-(void)performSaveInsanceState:(NSMutableDictionary*)outState;
-(void)performPause;
-(void)performStop;
-(void)performDestroyView;
-(void)performDestory;
-(void)performDetach;

@property(nonatomic, retain) NSString *luaId;
@property(nonatomic, retain) LuaContext *context;
@property(nonatomic, retain) LGView *lgview;
@property(nonatomic, retain) NSString *ui;

@property (nonatomic, retain) FragmentHostCallback *mHost;
@property (nonatomic, retain) FragmentManager *mFragmentManager;
@property (nonatomic, retain) FragmentManager *mChildFragmentManager;
@property (nonatomic, retain) FragmentViewLifecycleOwner *mViewLifecycleOwner;
@property (nonatomic, retain) LuaMutableLiveData *mViewLifecycleOwnerLiveData;
@property (nonatomic, retain) id<ViewModelProviderFactory> mDefaultFactory;
@property (nonatomic, retain) SavedStateRegistryController *mSavedStateRegistryController;
@property (nonatomic, retain) NSMutableDictionary *mOnPreAttachedListeners;
@property (nonatomic, retain) NSMutableDictionary *mSavedFragmentState;
@property (nonatomic, retain) NSMutableDictionary *mSavedViewState;
@property (nonatomic, retain) NSMutableDictionary *mSavedViewRegistryState;
@property (nonatomic, retain) NSNumber *mSavedUserVisibleHint;
@property LifecycleState mMaxState;
@property (nonatomic, retain) LifecycleRegistry *mLifecycleRegistry;
@property (nonatomic, retain) NSMutableDictionary *mArguments;
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

@end
