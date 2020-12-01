#import "LGRecyclerView.h"
#import "Defines.h"
#import "LuaFunction.h"

@implementation LGRecyclerView

-(int) GetContentW
{
    UICollectionView *cv = ((UICollectionView*)self._view);
    if(cv != nil)
    {
        
        /*LGAdapterView *adapterL = (LGAdapterView*)table.delegate;
        if(adapterL != nil)
        {
            return [adapterL GetTotalWidth:0];
        }*/
    }
    return 0;
}

-(int) GetContentH
{
    UICollectionView *cv = ((UICollectionView*)self._view);
    if(cv != nil)
    {
        /*LGAdapterView *adapterL = (LGAdapterView*)table.delegate;
        if(adapterL != nil)
        {
            return [adapterL GetTotalHeight:0];
        }*/
    }
    return 0;
}

-(UIView *) CreateComponent
{
    self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
    UICollectionView *cv = [[UICollectionView alloc] initWithFrame:CGRectMake(self.dX, self.dY, self.dWidth, self.dHeight) collectionViewLayout:self.flowLayout];
    return cv;
}

-(void) SetupComponent:(UIView *)view
{
    UICollectionView *tv = (UICollectionView*)self._view;
    /*if(self.android_divider != nil)
        tv.separatorColor = [[LGColorParser GetInstance] ParseColor:self.android_divider];*/
}

+(LGRecyclerView *)Create:(LuaContext *)context
{
    LGRecyclerView *lst = [[LGRecyclerView alloc] init];
    return lst;
}

-(void)SetAdapter:(LGRecyclerViewAdapter *)val
{
    ((UICollectionView*)self._view).delegate = val;
    ((UICollectionView*)self._view).dataSource = val;
    val.parent = self;
    self.adapter = val;
    LGView *parToFind = self.parent;
    while(parToFind != nil)
    {
        LGView *findView = parToFind.parent;
        if(findView == nil)
            break;
        parToFind = findView;
    }
    
    [((UICollectionView*)self._view) setFrame:CGRectMake(self.dX, self.dY, self.dWidth, self.dHeight)];
    
    [((UICollectionView*)self._view) reloadData];
}

-(LGRecyclerViewAdapter *)GetAdapter
{
    return self.adapter;
}

-(void)Refresh
{
    [((UICollectionView*)self._view) reloadData];
}

-(NSString*)GetId
{
    if(self.lua_id != nil)
        return self.lua_id;
    if(self.android_tag != nil)
        return self.android_tag;
    else
        return [LGRecyclerView className];
}

+ (NSString*)className
{
    return @"LGRecyclerView";
}

+(NSMutableDictionary*)luaMethods
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(Create::))
                                        :@selector(Create::)
                                        :[LGRecyclerView class]
                                        :[NSArray arrayWithObjects:[LuaContext class], [NSString class], nil]
                                        :[LGRecyclerView class]]
             forKey:@"Create"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetAdapter:)) :@selector(SetAdapter:) :nil :MakeArray([LGRecyclerViewAdapter class]C nil)] forKey:@"SetAdapter"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(GetAdapter)) :@selector(GetAdapter) :[LGRecyclerViewAdapter class] :MakeArray(nil)] forKey:@"GetAdapter"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(Refresh)) :@selector(Refresh) :nil :MakeArray(nil)] forKey:@"Refresh"];
    return dict;
}

@end
