#import <Foundation/Foundation.h>
#import "LGViewGroup.h"
#import "NSQueue.h"

#define STRUE @"-1"
#define LEFT_OF 0
#define RIGHT_OF 1
#define ABOVE 2
#define BELOW 3
#define ALIGN_BASELINE 4
#define ALIGN_LEFT 5
#define ALIGN_TOP 6
#define ALIGN_RIGHT 7
#define ALIGN_BOTTOM 8
#define ALIGN_PARENT_LEFT 9
#define ALIGN_PARENT_TOP 10
#define ALIGN_PARENT_RIGHT 11
#define ALIGN_PARENT_BOTTOM 12
#define CENTER_IN_PARENT 13
#define CENTER_HORIZONTAL 14
#define CENTER_VERTICAL 15
#define START_OF 16
#define END_OF 17
#define ALIGN_START 18
#define ALIGN_END 19
#define ALIGN_PARENT_START 20
#define ALIGN_PARENT_END 21
#define VERB_COUNT 22
#define VALUE_NOT_SET INT_MIN

@interface RLNode : NSObject

+(RLNode*)acquire:(LGView*)view;
-(void)releaseV;

@property(nonatomic, retain) LGView* view;
@property(nonatomic, retain) MutableOrderedDictionary *dependents;
@property(nonatomic, retain) NSMutableDictionary *dependencies;

@end

@interface RLDependencyGraph : NSObject

@property(nonatomic, retain) NSMutableArray *mNodes;

@property(nonatomic, retain) NSMutableDictionary *mKeyNodes;

@property(nonatomic, retain) NSDeque *mRoots;

-(void)clear;
-(void)add:(LGView*) view;
-(NSMutableArray*)getSortedViews:(NSMutableArray*)sorted, ...;
-(NSDeque*)findRoots:(NSMutableArray*)rulesFilter;

@end

@interface LGRelativeLayoutParams : NSObject

-(void)addRule:(int)verb;
-(void)addRule:(int)verb :(NSString*)subject;
-(void)removeRule:(int)verb;
-(int)getRule:(int)verb;
-(BOOL)hasRelativeRules;
-(BOOL)isRelativeRule:(int)rule;
-(void)resolveLayoutDirection:(BOOL)isRtl;
-(BOOL)shouldResolveLayoutDirection:(BOOL)isRtl;
-(void)resolveRules:(BOOL)isRtl;
-(NSMutableArray*)getRules:(BOOL)isRtl;

@property (nonatomic, retain) NSMutableArray *rules, *initialRules;
@property (nonatomic) BOOL mNeedsLayoutResolution, mRulesChanged, mIsRtlCompatibilityMode, alignWithParent;
@property (nonatomic) int mLeft, mTop, mRight, mBottom;

@end

@interface LGRelativeLayout : LGViewGroup

+(LGRelativeLayout*)create:(LuaContext *)context;

@property (nonatomic, retain) NSArray *RULES_VERTICAL, *RULES_HORIZONTAL;

@property (nonatomic, retain) LGView* mBaselineView;

@property (nonatomic) int gravity;
@property (nonatomic) CGRect mContentBounds, mSelfBounds;

@property (nonatomic, retain) NSString *mIgnoreGravity;

@property (nonatomic, retain) NSOrderedSet *mTopToBottomLeftToRightSet;

@property (nonatomic) BOOL mDirtyHierarchy;
@property (nonatomic, retain) NSMutableArray *mSortedHorizontalChildren;
@property (nonatomic, retain) NSMutableArray *mSortedVerticalChildren;

@property (nonatomic, retain) RLDependencyGraph *mGraph;

@property (nonatomic) BOOL mAllowBrokenMeasureSpecs;

@property (nonatomic) BOOL mMeasureVerticalWithPaddingMargin;

@property (nonatomic) int DEFAULT_WIDTH;

@end
