#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LuaClass.h"
#import "LuaRef.h"

@class GDataXMLElement;
@class Navigator;
@class NavController;
@protocol TNavigatorProvider;

@interface NavArgument : NSObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *mType;
@property BOOL mIsNullable;
@property (nonatomic, retain) id mDefaultValue;
@property (nonatomic, retain) id typeObject;

@end

@interface NavOptions : NSObject <LuaClass>

+(NavOptions*)create:(BOOL)singleTop :(LuaRef*)popUpTo :(BOOL)popUpToInclusive :(LuaRef*)enterAnim :(LuaRef*)exitAnim :(LuaRef*)popEnterAnim :(LuaRef*)popExitAnim;

@property BOOL mSingleTop;
@property (nonatomic, retain) NSString *mEnterAnim;
@property (nonatomic, retain) NSString *mExitAnim;
@property (nonatomic, retain) NSString *mPopEnterAnim;
@property (nonatomic, retain) NSString *mPopExitAnim;
@property (nonatomic, retain) NSString *mPopUpToId;
@property (nonatomic, retain) NSString *mPopUpToRoute;
@property BOOL mPopUpToInclusive;
@property BOOL mPopUpToSaveState;
@property BOOL mRestoreState;

@end

@interface NavAction : NSObject

- (instancetype)initWithDestination:(NSString*)destinationId;
- (instancetype)initWithDestination:(NSString*)destinationId NavOptions:(NavOptions*)navOptions;
- (instancetype)initWithDestination:(NSString*)destinationId NavOptions:(NavOptions*)navOptions DefaultArgs:(LuaBundle*)defaultArgs;

@property (nonatomic, retain) NSString *idVal;
@property (nonatomic, retain) NSString *mDestinationId;
@property (nonatomic, retain) NavOptions *mNavOptions;
@property (nonatomic, retain) LuaBundle *mDefaultArguments;

@end

@class NavGraph;
@class NavDestination;

@interface DeepLinkMatch: NSObject

- (instancetype)initWithDestination:(NavDestination*)destination
                                    :(LuaBundle*)matchingArgs
                                    :(BOOL)isExactDeepLink
                                    :(int)matchingPathSegments
                                    :(BOOL)hasMatchingAction
                                   :(int)mimeTypeMatchLevel;
-(NSComparisonResult)compare:(DeepLinkMatch*)other;
-(BOOL)hasMatchingArgs:(LuaBundle*)arguments;

@property (nonatomic, retain) NavDestination *destination;
@property (nonatomic, retain) LuaBundle *matchingArgs;
@property (nonatomic) BOOL isExactDeepLink;
@property (nonatomic) int matchingPathSegments;
@property (nonatomic) BOOL hasMatchingAction;
@property (nonatomic) int mimeTypeMatchLevel;

@end

@interface NavDestination : NSObject

- (instancetype)initWithNavigator:(Navigator*) navigator;
- (instancetype)initWithName:(NSString*) name;
- (LuaBundle*)addInDefaultArgs:(LuaBundle*)args;
- (NavAction*)getAction:(NSString*) idVal;
- (BOOL)hasRoute:(NSString*)route :(LuaBundle*)arguments;
- (NSString*)createRoute:(NSString*)route;

@property (nonatomic, retain) NSString *mNavigatorName;
@property (nonatomic, retain) NavGraph *mParent;
@property (nonatomic, retain) NSString *idVal;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *mLabel;
@property (nonatomic, retain) NSString *route;

@property(nonatomic, retain) NSMutableDictionary *mActions;
@property(nonatomic, retain) LuaBundle *mArguments;
@property(nonatomic, retain) LuaBundle *customArgs;
@property(nonatomic, retain) NSMutableArray *deepLinks;

@end

@interface NavGraph : NavDestination

-(NavDestination*) findNode:(NSString*) resId;
-(NavDestination*) findNode:(NSString*) resId :(BOOL)searchParents;
-(NavDestination*) findNodeRoute:(NSString *)route;
-(NavDestination*) findNodeRoute:(NSString *)route :(BOOL)searchParents;

@property (nonatomic, retain) NSString *mStartDestinationId;
@property (nonatomic, retain) NSString *mStartDestinationRoute;
@property (nonatomic, retain) NSMutableDictionary *mNodes;

@end

@interface LGNavigationParser : NSObject
{
}

-(void)initialize;
+(LGNavigationParser*) getInstance;
-(NavGraph *) getNavigation:(NavController*)controller :(NSString*)key;
-(NavGraph *) getNavigationProvider:(NSString*)key :(id<TNavigatorProvider>)provider;
-(NavGraph *) parseXML:(NavController*)controller :(NSString*)path :(NSString *)filename;

@property (nonatomic, retain) NSMutableArray *clearedDirectoryList;
@property (nonatomic, retain) NSMutableDictionary *navigationCache;
@property (nonatomic, retain) NSMutableDictionary *navigationMap;

@end
