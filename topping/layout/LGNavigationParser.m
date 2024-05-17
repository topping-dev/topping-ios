#import "LGNavigationParser.h"
#import "Defines.h"
#import "LGParser.h"
#import "DisplayMetrics.h"
#import "LuaResource.h"
#import "GDataXMLNode.h"
#import "LuaValues.h"
#import <ToppingIOSKotlinHelper/ToppingIOSKotlinHelper.h>
#import <Topping/Topping-Swift.h>

@implementation NavArgument

@end

@implementation NavOptions

+(NavOptions*)create:(BOOL)singleTop :(LuaRef *)popUpTo :(BOOL)popUpToInclusive :(LuaRef *)enterAnim :(LuaRef *)exitAnim :(LuaRef *)popEnterAnim :(LuaRef *)popExitAnim {
    NavOptions *no = [NavOptions new];
    no.mSingleTop = singleTop;
    no.mPopUpToId = popUpTo.idRef;
    no.mPopUpToInclusive = popUpToInclusive;
    no.mEnterAnim = enterAnim.idRef;
    no.mExitAnim = exitAnim.idRef;
    no.mPopEnterAnim = popEnterAnim.idRef;
    no.mPopExitAnim = popExitAnim.idRef;
    
    return no;
}

+ (NSString *)className {
    return @"LuaNavOptions";
}

+ (NSMutableDictionary *)luaMethods {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    ClassMethod(create:::::::, NavOptions, @[[LuaBool class]C [LuaRef class]C [LuaBool class]C [LuaRef class]C [LuaRef class]C [LuaRef class]C [LuaRef class]], @"create", [LGNavigationParser class])
    
    return dict;
}

@end

@implementation NavAction

- (instancetype)initWithDestination:(NSString*)destinationId
{
    self = [super init];
    if (self) {
        self.mDestinationId = [[LGIdParser getInstance] getId:destinationId];
        self.mNavOptions = nil;
    }
    return self;
}

- (instancetype)initWithDestination:(NSString*)destinationId NavOptions:(NavOptions*)navOptions
{
    self = [super init];
    if (self) {
        self.mDestinationId = [[LGIdParser getInstance] getId:destinationId];
        self.mNavOptions = navOptions;
    }
    return self;
}

- (instancetype)initWithDestination:(NSString*)destinationId NavOptions:(NavOptions*)navOptions DefaultArgs:(LuaBundle*)defaultArgs
{
    self = [super init];
    if (self) {
        self.mDestinationId = [[LGIdParser getInstance] getId:destinationId];
        self.mNavOptions = navOptions;
        self.mDefaultArguments = defaultArgs;
    }
    return self;
}

@end

@implementation DeepLinkMatch

- (instancetype)initWithDestination:(NavDestination*)destination
                                    :(LuaBundle*)matchingArgs
                                    :(BOOL)isExactDeepLink
                                    :(int)matchingPathSegments
                                    :(BOOL)hasMatchingAction
                                    :(int)mimeTypeMatchLevel
{
    self = [super init];
    if (self) {
        self.destination = destination;
        self.matchingArgs = matchingArgs;
        self.isExactDeepLink = isExactDeepLink;
        self.matchingPathSegments = matchingPathSegments;
        self.hasMatchingAction = hasMatchingAction;
        self.mimeTypeMatchLevel = mimeTypeMatchLevel;
    }
    return self;
}

-(NSComparisonResult)compare:(DeepLinkMatch*)other {
    if (self.isExactDeepLink && !other.isExactDeepLink) {
        return 1;
    } else if (!self.isExactDeepLink && other.isExactDeepLink) {
        return -1;
    }
    // Then prefer most exact match path segments
    int pathSegmentDifference = self.matchingPathSegments - other.matchingPathSegments;
    if (pathSegmentDifference > 0) {
        return 1;
    } else if (pathSegmentDifference < 0) {
        return -1;
    }
    if (self.matchingArgs != nil && other.matchingArgs == nil) {
        return 1;
    } else if (self.matchingArgs == nil && other.matchingArgs != nil) {
        return -1;
    }
    if (self.matchingArgs != nil) {
        long sizeDifference = self.matchingArgs.bundle.count - other.matchingArgs.bundle.count;
        if (sizeDifference > 0) {
            return 1;
        } else if (sizeDifference < 0) {
            return -1;
        }
    }
    if (self.hasMatchingAction && !other.hasMatchingAction) {
        return 1;
    } else if (!self.hasMatchingAction && other.hasMatchingAction) {
        return -1;
    }
    return self.mimeTypeMatchLevel - other.mimeTypeMatchLevel;
}

-(BOOL)hasMatchingArgs:(LuaBundle*)arguments {
    return false;
    /*if (arguments == nil || self.matchingArgs == nil) return false;

    for(NSString *key in self.matchingArgs.allKeys) {
        // the arguments must at least contain every argument stored in this deep link
        if ([arguments objectForKey:key] == nil) return false;

        [self.destination.mArguments objectForKey:key];
        val matchingArgValue = type?.get(matchingArgs, key)
        val entryArgValue = type?.get(arguments, key)
        // fine if both argValues are null, i.e. arguments/params with nullable values
        if (matchingArgValue != entryArgValue) return false
    }
    return true;*/
}

@end

@implementation NavDestination

- (instancetype)initWithNavigator:(Navigator*) navigator
{
    self = [super init];
    if (self) {
        self.idVal = @"0";
        self.mNavigatorName = [navigator getName];
        self.deepLinks = [NSMutableArray array];
    }
    return self;
}

- (instancetype)initWithName:(NSString*) name
{
    self = [super init];
    if (self) {
        self.idVal = @"0";
        self.mNavigatorName = name;
        self.deepLinks = [NSMutableArray array];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.idVal = @"0";
        self.deepLinks = [NSMutableArray array];
    }
    return self;
}

-(LuaBundle *)addInDefaultArgs:(LuaBundle *)args {
    /*if(args == nil && (self.mArguments == nil || self.mArguments.count == 0)) {
        return nil;
    }
    NSMutableDictionary *defaultArgs = [NSMutableDictionary dictionary];
    if(self.mArguments != nil) {
        for(NSString *key in self.mArguments) {
            NavArgument *argument = [self.mArguments objectForKey:key];
            defaultArgs setObject:(nonnull id) forKey:(nonnull id<NSCopying>)
        }
    }*/
    return args;
}

-(NavAction*)getAction:(NSString*) idVal {
    NavAction *destination = self.mActions == nil ? nil : [self.mActions objectForKey:idVal];
    return destination != nil ? destination : (self.mParent != nil) ? [self.mParent getAction:idVal] : nil;
}

-(DeepLinkMatch*)matchDeepLink:(NSString*)route {
    /*val request = NavDeepLinkRequest.Builder.fromUri(createRoute(route).toUri()).build()
            val matchingDeepLink = if (this is NavGraph) {
                matchDeepLinkExcludingChildren(request)
            } else {
                matchDeepLink(request)
            }
            return matchingDeepLink*/
    return nil;
}

-(BOOL)hasRoute:(NSString *)route :(LuaBundle *)arguments {
    if([self.route isEqualToString:route])
        return true;
    
    DeepLinkMatch *matchingDeepLink = [self matchDeepLink:route];
    if(matchingDeepLink == nil)
        return false;
    
    if(matchingDeepLink.destination != self) return false;
    
    return [matchingDeepLink hasMatchingArgs:arguments];
}

-(NSString *)createRoute:(NSString *)route {
    NSString *routeVal = @"";
    if (route != nil)
        routeVal = APPEND(@"android-app://androidx.navigation/", route);
    return routeVal;
}

-(void)setRoute:(NSString *)route {
    _route = route;
}

@end

@implementation NavGraph

-(instancetype)initWithNavigator:(Navigator *)navigator {
    self = [super initWithNavigator:navigator];
    self.idVal = @"0";
    self.mNodes = [NSMutableDictionary dictionary];
    return self;
}

-(instancetype)initWithName:(NSString *)name {
    self = [super initWithName:name];
    self.idVal = @"0";
    self.mNodes = [NSMutableDictionary dictionary];
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.idVal = @"0";
        self.mNodes = [NSMutableDictionary dictionary];
    }
    return self;
}

-(NavDestination*) findNode:(NSString*) resId {
    return [self findNode:resId :true];
}

-(NavDestination*) findNode:(NSString*) resId :(BOOL)searchParents {
    NavDestination *destination = [self.mNodes objectForKey:resId];
    return destination != nil ? destination : (searchParents && self.mParent != nil) ? [self.mParent findNode:resId] : nil;
}

-(NavDestination*) findNodeRoute:(NSString*) route {
    return [self findNodeRoute:route :true];
}

-(NavDestination*) findNodeRoute:(NSString*) route :(BOOL)searchParents {
    NSString *internalRoute = [self createRoute:route];
    NavDestination *destination = [self.mNodes objectForKey:internalRoute];
    return destination != nil ? destination : (searchParents && self.mParent != nil) ? [self.mParent findNodeRoute:internalRoute] : nil;
}

@end

@implementation LGNavigationParser

@synthesize navigationMap;

- (id) init
{
    self = [super init];
    if (self != nil) {
    }
    return self;
}

-(void)initialize
{
    NSArray *layoutDirectories = [LuaResource getResourceDirectories:LUA_NAVIGATION_FOLDER];
    self.clearedDirectoryList = [[LGParser getInstance] tester:layoutDirectories :LUA_NAVIGATION_FOLDER];
    [self.clearedDirectoryList sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2)
     {
         NSString *aData = (NSString*)((DynamicResource*)obj1).data;
         NSString *bData = (NSString*)((DynamicResource*)obj2).data;
         if(COMPARE(aData, bData))
             return NSOrderedSame;
         else if(aData.length > bData.length)
             return NSOrderedAscending;
         else
             return NSOrderedDescending;
     }];
    self.navigationMap = [NSMutableDictionary dictionary];
    for(DynamicResource *dr in self.clearedDirectoryList)
    {
        NSArray *files = [LuaResource getResourceFiles:(NSString*)dr.data];
        [files enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *filename = (NSString *)obj;
            NSString *fNameNoExt = [filename stringByDeletingPathExtension];
            [self.navigationMap setObject:fNameNoExt forKey:fNameNoExt];
        }];
    }
}

+(LGNavigationParser *) getInstance
{
    return [LGParser getInstance].pNavigation;
}

-(NavGraph *) parseXML:(NavController*)controller :(NSString*)path :(NSString *)filename
{
    NSString *fontBundlePath = [[sToppingEngine getUIRoot] stringByAppendingPathComponent:path];
    NSData *dat = [[LuaResource getResource:fontBundlePath :filename] getData];
    GDataXMLDocument *xml = [[GDataXMLDocument alloc] initWithData:dat error:nil];
    if(xml == nil)
    {
        NSLog(@"Cannot read xml file %@", filename);
        return nil;
    }
    
    GDataXMLElement *root = [xml rootElement];
    if(COMPARE([root name], @"navigation"))
    {
        return [self ParseNavigation:controller :root];
    }
    
    return nil;
}

-(NavGraph *)getNavigation:(NavController*)controller :(NSString *)key {
    if(key == nil)
        return nil;
    if(self.navigationCache == nil) {
        self.navigationCache = [NSMutableDictionary dictionary];
    }
    
    NSArray *arr = SPLIT(key, @"/");
    NavGraph *retVal = [self.navigationCache objectForKey:key];
    if(retVal != nil)
        return retVal;
    if(CONTAINS([arr objectAtIndex:0], @"navigation"))
    {
        if([arr count] > 1)
        {
            NSString *name = [arr objectAtIndex:1];
            for(DynamicResource *dr in self.clearedDirectoryList)
            {
                retVal = [self parseXML:[controller getNavigationProvider] :(NSString*)dr.data :APPEND(name, @".xml")];
                if(retVal != nil)
                {
                    break;
                }
            }
        }
    }
    [self.navigationCache setObject:retVal forKey:key];
    return retVal;
}

-(NavGraph *)getNavigationProvider:(NSString *)key :(id<TNavigatorProvider>)provider {
    if(key == nil)
        return nil;
    if(self.navigationCache == nil) {
        self.navigationCache = [NSMutableDictionary dictionary];
    }
    
    NSArray *arr = SPLIT(key, @"/");
    NavGraph *retVal = [self.navigationCache objectForKey:key];
    if(retVal != nil)
        return retVal;
    if(CONTAINS([arr objectAtIndex:0], @"navigation"))
    {
        if([arr count] > 1)
        {
            NSString *name = [arr objectAtIndex:1];
            for(DynamicResource *dr in self.clearedDirectoryList)
            {
                retVal = [self parseXML:provider :(NSString*)dr.data :APPEND(name, @".xml")];
                if(retVal != nil)
                {
                    break;
                }
            }
        }
    }
    [self.navigationCache setObject:retVal forKey:key];
    return retVal;
}

-(NavGraph*)ParseNavigation:(id<TNavigatorProvider>)provider :(GDataXMLElement*)root
{
    NSArray *children = [root children];
    
    NavGraph *lnr = [[NavGraph alloc] initWithName:@"navigation"];
    
    lnr.mNodes = [NSMutableDictionary dictionary];
    
    for(GDataXMLNode *rootNode in [root attributes]) {
        if(COMPARE([rootNode name], @"android:id")) {
            lnr.idVal = [[LGIdParser getInstance] getId:[rootNode stringValue]];
        }
        else if(COMPARE([rootNode name], @"app:startDestination")) {
            lnr.mStartDestinationId = [[LGIdParser getInstance] getId:[rootNode stringValue]];
        }
    }
       
    for(GDataXMLElement *child in children)
    {
        if(!([[child name] isEqualToString:@"fragment"]
           || [[child name] isEqualToString:@"dialog"]))
            continue;
        
        Navigator *navigator = [provider getNavigatorWithName:[child name]];
        NavDestination *lne = [navigator createDestination];
        lne.mActions = [NSMutableDictionary dictionary];
        lne.mArguments = [NSMutableDictionary dictionary];
        
        lne.type = [child name];

        NSArray *attrs = [child attributes];
        for(GDataXMLNode *node in attrs)
        {
            if(COMPARE([node name], @"android:id"))
            {
                lne.idVal = [[LGIdParser getInstance] getId:[node stringValue]];
            }
            else if(COMPARE([node name], @"android:name"))
            {
                lne.name = [node stringValue];
            }
            else if(COMPARE([node name], @"android:label"))
            {
                lne.mLabel = [[LGStringParser getInstance] getString:[node stringValue]];
            }
        }
        for(GDataXMLElement *childChild in [child children])
        {
            NSString *childChildName = [childChild name];
            
            if([childChildName isEqualToString:@"action"])
            {
                NavAction *lna = [NavAction new];
                lna.mNavOptions = [NavOptions new];
                NSArray *attrsChild = [childChild attributes];
                for(GDataXMLNode *nodeChild in attrsChild)
                {
                    if(COMPARE([nodeChild name], @"android:id"))
                    {
                        lna.idVal = [[LGIdParser getInstance] getId:[nodeChild stringValue]];
                    }
                    else if(COMPARE([nodeChild name], @"app:destination"))
                    {
                        lna.mDestinationId = [[LGIdParser getInstance] getId:[nodeChild stringValue]];
                    }
                    else if(COMPARE([nodeChild name], @"app:enterAnim"))
                    {
                        lna.mNavOptions.mEnterAnim = [[LGIdParser getInstance] getId:[nodeChild stringValue]];
                    }
                    else if(COMPARE([nodeChild name], @"app:exitAnim"))
                    {
                        lna.mNavOptions.mExitAnim = [[LGIdParser getInstance] getId:[nodeChild stringValue]];
                    }
                    else if(COMPARE([nodeChild name], @"app:popEnterAnim"))
                    {
                        lna.mNavOptions.mPopEnterAnim = [[LGIdParser getInstance] getId:[nodeChild stringValue]];
                    }
                    else if(COMPARE([nodeChild name], @"app:popExitAnim"))
                    {
                        lna.mNavOptions.mPopExitAnim = [[LGIdParser getInstance] getId:[nodeChild stringValue]];
                    }
                    else if(COMPARE([nodeChild name], @"app:popUpTo"))
                    {
                        lna.mNavOptions.mPopUpToId = [[LGIdParser getInstance] getId:[nodeChild stringValue]];
                    }
                    else if(COMPARE([nodeChild name], @"app:popUpInclusive"))
                    {
                        lna.mNavOptions.mPopUpToInclusive = [[nodeChild stringValue] boolValue];
                    }
                }
                
                [lne.mActions setObject:lna forKey:lna.idVal];
            }
            else if([childChildName isEqualToString:@"argument"])
            {
                NavArgument *lna = [NavArgument new];
                NSArray *attrsChild = [childChild attributes];
                for(GDataXMLNode *nodeChild in attrsChild)
                {
                    if(COMPARE([nodeChild name], @"android:name"))
                    {
                        lna.name = [nodeChild stringValue];
                    }
                    else if(COMPARE([nodeChild name], @"app:argType"))
                    {
                        lna.mType = [nodeChild stringValue];
                    }
                    else if(COMPARE([nodeChild name], @"app:nullable"))
                    {
                        lna.mIsNullable = [[nodeChild stringValue] boolValue];
                    }
                }
                
                [lne.mArguments.bundle setObject:lna forKey:lna.name];
            }
        }
        lne.mParent = lnr;
        [lnr.mNodes setObject:lne forKey:[[LGIdParser getInstance] getId:lne.idVal]];
    }
    
    return lnr;
}


@end
