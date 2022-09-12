#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class GDataXMLElement;
@class Navigator;

@interface NavArgument : NSObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *mType;
@property BOOL mIsNullable;
@property (nonatomic, retain) NSObject *mDefaultValue;

@end

@interface NavOptions : NSObject

@property BOOL mSingleTop;
@property (nonatomic, retain) NSString *mEnterAnim;
@property (nonatomic, retain) NSString *mExitAnim;
@property (nonatomic, retain) NSString *mPopEnterAnim;
@property (nonatomic, retain) NSString *mPopExitAnim;
@property (nonatomic, retain) NSString *mPopUpTo;
@property BOOL mPopUpToInclusive;

@end

@interface NavAction : NSObject

- (instancetype)initWithDestination:(NSString*)destinationId;
- (instancetype)initWithDestination:(NSString*)destinationId NavOptions:(NavOptions*)navOptions;
- (instancetype)initWithDestination:(NSString*)destinationId NavOptions:(NavOptions*)navOptions DefaultArgs:(NSMutableDictionary*)defaultArgs;

@property (nonatomic, retain) NSString *idVal;
@property (nonatomic, retain) NSString *mDestinationId;
@property (nonatomic, retain) NavOptions *mNavOptions;
@property (nonatomic, retain) NSMutableDictionary *mDefaultArguments;

@end

@class NavGraph;

@interface NavDestination : NSObject

- (instancetype)initWithNavigator:(Navigator*) navigator;
- (instancetype)initWithName:(NSString*) name;
- (NSMutableDictionary*)addInDefaultArgs:(NSMutableDictionary*)args;
- (NavAction*)getAction:(NSString*) idVal;

@property (nonatomic, retain) NSString *mNavigatorName;
@property (nonatomic, retain) NavGraph *mParent;
@property (nonatomic, retain) NSString *idVal;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *mLabel;

@property(nonatomic, retain) NSMutableDictionary *mActions;
@property(nonatomic, retain) NSMutableDictionary *mArguments;

@end

@interface NavGraph : NavDestination

-(NavDestination*) findNode:(NSString*) resId;
-(NavDestination*) findNode:(NSString*) resId :(BOOL)searchParents;

@property (nonatomic, retain) NSString *idVal;
@property (nonatomic, retain) NSString *mStartDestinationId;
@property (nonatomic, retain) NSMutableDictionary *mNodes;

@end

@interface LGNavigationParser : NSObject
{
}

-(void)Initialize;
+(LGNavigationParser*) GetInstance;
-(NavGraph *) GetNavigation: (NSString*)key;
-(NavGraph *) ParseXML:(NSString*)path :(NSString *)filename;

@property (nonatomic, retain) NSMutableArray *clearedDirectoryList;
@property (nonatomic, retain) NSMutableDictionary *navigationCache;
@property (nonatomic, retain) NSMutableDictionary *navigationMap;

@end
