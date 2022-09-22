#import "LGNavigationParser.h"
#import "Defines.h"
#import "LGParser.h"
#import "DisplayMetrics.h"
#import "LuaResource.h"
#import "GDataXMLNode.h"
#import <topping/topping-Swift.h>

@implementation NavArgument

@end

@implementation NavOptions

@end

@implementation NavAction

- (instancetype)initWithDestination:(NSString*)destinationId
{
    self = [super init];
    if (self) {
        self.mDestinationId = destinationId;
        self.mNavOptions = nil;
    }
    return self;
}

- (instancetype)initWithDestination:(NSString*)destinationId NavOptions:(NavOptions*)navOptions
{
    self = [super init];
    if (self) {
        self.mDestinationId = destinationId;
        self.mNavOptions = navOptions;
    }
    return self;
}

- (instancetype)initWithDestination:(NSString*)destinationId NavOptions:(NavOptions*)navOptions DefaultArgs:(NSMutableDictionary*)defaultArgs
{
    self = [super init];
    if (self) {
        self.mDestinationId = destinationId;
        self.mNavOptions = navOptions;
        self.mDefaultArguments = defaultArgs;
    }
    return self;
}

@end

@implementation NavDestination

- (instancetype)initWithNavigator:(Navigator*) navigator
{
    self = [super init];
    if (self) {
        self.mNavigatorName = [navigator getName];
    }
    return self;
}

- (instancetype)initWithName:(NSString*) name
{
    self = [super init];
    if (self) {
        self.mNavigatorName = name;
    }
    return self;
}

-(NSMutableDictionary *)addInDefaultArgs:(NSMutableDictionary *)args {
    //TODO check this
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

@end

@implementation NavGraph

-(NavDestination*) findNode:(NSString*) resId {
    return [self findNode:resId :true];
}

-(NavDestination*) findNode:(NSString*) resId :(BOOL)searchParents {
    NavDestination *destination = [self.mNodes objectForKey:resId];
    return destination != nil ? destination : (searchParents && self.mParent != nil) ? [self.mParent findNode:resId] : nil;
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

-(void)Initialize
{
    NSArray *layoutDirectories = [LuaResource GetResourceDirectories:LUA_NAVIGATION_FOLDER];
    self.clearedDirectoryList = [[LGParser GetInstance] Tester:layoutDirectories :LUA_NAVIGATION_FOLDER];
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
        NSArray *files = [LuaResource GetResourceFiles:(NSString*)dr.data];
        [files enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *filename = (NSString *)obj;
            NSString *fNameNoExt = [filename stringByDeletingPathExtension];
            [self.navigationMap setObject:fNameNoExt forKey:fNameNoExt];
        }];
    }
}

+(LGNavigationParser *) GetInstance
{
    return [LGParser GetInstance].pNavigation;
}

-(NavGraph *) ParseXML:(NavController*)controller :(NSString*)path :(NSString *)filename
{
    NSString *fontBundlePath = [[sToppingEngine GetUIRoot] stringByAppendingPathComponent:path];
    NSData *dat = [[LuaResource GetResource:fontBundlePath :filename] GetData];
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

-(NavGraph *)GetNavigation:(NavController*)controller :(NSString *)key {
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
                retVal = [self ParseXML:controller :(NSString*)dr.data :APPEND(name, @".xml")];
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

-(NavGraph*)ParseNavigation:(NavController*)controller :(GDataXMLElement*)root
{
    NSArray *children = [root children];
    
    NavGraph *lnr = [[NavGraph alloc] initWithName:@"navigation"];
    
    lnr.mNodes = [NSMutableDictionary dictionary];
    
    for(GDataXMLNode *rootNode in [root attributes]) {
        if(COMPARE([rootNode name], @"android:id")) {
            lnr.idVal = [rootNode stringValue];
        }
        else if(COMPARE([rootNode name], @"app:startDestination")) {
            lnr.mStartDestinationId = [rootNode stringValue];
        }
    }
       
    for(GDataXMLElement *child in children)
    {
        if(!([[child name] isEqualToString:@"fragment"]
           || [[child name] isEqualToString:@"dialog"]))
            continue;
        
        Navigator *navigator = [[controller getNavigationProvider] getNavigatorWithName:[child name]];
        NavDestination *lne = [navigator createDestination];
        lne.mActions = [NSMutableDictionary dictionary];
        lne.mArguments = [NSMutableDictionary dictionary];
        
        lne.type = [child name];

        NSArray *attrs = [child attributes];
        for(GDataXMLNode *node in attrs)
        {
            if(COMPARE([node name], @"android:id"))
            {
                lne.idVal = [node stringValue];
            }
            else if(COMPARE([node name], @"android:name"))
            {
                lne.name = [node stringValue];
            }
            else if(COMPARE([node name], @"android:label"))
            {
                lne.mLabel = [[LGStringParser GetInstance] GetString:[node stringValue]];
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
                        lna.idVal = REPLACE([nodeChild stringValue], @"+", @"");
                    }
                    else if(COMPARE([nodeChild name], @"app:destination"))
                    {
                        lna.mDestinationId = [nodeChild stringValue];
                    }
                    else if(COMPARE([nodeChild name], @"app:enterAnim"))
                    {
                        lna.mNavOptions.mEnterAnim = [nodeChild stringValue];
                    }
                    else if(COMPARE([nodeChild name], @"app:exitAnim"))
                    {
                        lna.mNavOptions.mExitAnim = [nodeChild stringValue];
                    }
                    else if(COMPARE([nodeChild name], @"app:popEnterAnim"))
                    {
                        lna.mNavOptions.mPopEnterAnim = [nodeChild stringValue];
                    }
                    else if(COMPARE([nodeChild name], @"app:popExitAnim"))
                    {
                        lna.mNavOptions.mPopExitAnim = [nodeChild stringValue];
                    }
                    else if(COMPARE([nodeChild name], @"app:popUpTo"))
                    {
                        lna.mNavOptions.mPopUpTo = [nodeChild stringValue];
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
                
                [lne.mArguments setObject:lna forKey:lna.name];
            }
        }
        lne.mParent = lnr;
        [lnr.mNodes setObject:lne forKey:REPLACE(lne.idVal, @"+", @"")];
    }
    
    return lnr;
}


@end
