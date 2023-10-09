#import "LGRecyclerView.h"
#import "Defines.h"
#import "LuaFunction.h"
#import "ILGRecyclerViewAdapter.h"

@implementation LGRecyclerView

-(int) getContentW
{
    if(self.adapter_ != nil)
    {
        /*LGAdapterView *adapterL = (LGAdapterView*)table.delegate;
        if(adapterL != nil)
        {
            return [adapterL GetTotalWidth:0];
        }*/
    }
    return [super getContentW];
}

-(int) getContentH
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
    return [super getContentH];
}

-(UIView *) createComponent
{
    self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
    ((UICollectionViewFlowLayout*)self.flowLayout).sectionInsetReference = UICollectionViewFlowLayoutSectionInsetFromContentInset;
    UICollectionView *cv = [[UICollectionView alloc] initWithFrame:CGRectMake(self.dX, self.dY, self.dWidth, self.dHeight) collectionViewLayout:self.flowLayout];
    return cv;
}

-(void) setupComponent:(UIView *)view
{
    UICollectionView *tv = (UICollectionView*)self._view;
    tv.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
    /*if(self.android_divider != nil)
        tv.separatorColor = [[LGColorParser GetInstance] ParseColor:self.android_divider];*/
}

+(LGRecyclerView *)create:(LuaContext *)context
{
    LGRecyclerView *lst = [[LGRecyclerView alloc] init];
    lst.lc = context;
    return lst;
}

-(void)setAdapter:(LGRecyclerViewAdapter *)val
{
    ((UICollectionView*)self._view).delegate = val;
    ((UICollectionView*)self._view).dataSource = val;
    val.parent = self;
    self.adapter_ = val;
    
    [((UICollectionView*)self._view) setFrame:CGRectMake(self.dX, self.dY, self.dWidth, self.dHeight)];
    
    [((UICollectionView*)self._view) reloadData];
    
    /*LGView *parToFind = self.parent;
    while(parToFind != nil)
    {
        LGView *findView = parToFind.parent;
        if(findView == nil)
            break;
        parToFind = findView;
    }
    if(parToFind != nil)
       [parToFind ResizeAndInvalidate];*/
}

-(void)setAdapterInterface:(LuaTranslator *)ltInit {
    LGRecyclerViewAdapter *adapter = [LGRecyclerViewAdapter create:self.lc :@""];
    adapter.kotlinInterface = (ILGRecyclerViewAdapter*)[ltInit call:adapter];
    [adapter setOnCreateViewHolder:adapter.kotlinInterface.ltOnCreateViewHolder];
    [adapter setOnBindViewHolder:adapter.kotlinInterface.ltOnBindViewHolder];
    [adapter setGetItemViewType:adapter.kotlinInterface.ltGetItemViewType];
    [adapter setOnItemSelected:adapter.kotlinInterface.ltOnItemSelected];
}

-(LGRecyclerViewAdapter *)getAdapter
{
    return self.adapter_;
}

-(void)notify
{
    [((UICollectionView*)self._view) reloadData];
}

-(void)configChange {
    [self notify];
}

-(NSString*)GetId
{
    if(self.lua_id != nil)
        return self.lua_id;
    if(self.android_id != nil)
        return self.android_id;
    return [LGRecyclerView className];
}

+ (NSString*)className
{
    return @"LGRecyclerView";
}

+(NSMutableDictionary*)luaMethods
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(create:))
                                        :@selector(create:)
                                        :[LGRecyclerView class]
                                        :[NSArray arrayWithObjects:[LuaContext class], [NSString class], nil]
                                        :[LGRecyclerView class]]
             forKey:@"create"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(setAdapter:)) :@selector(setAdapter:) :nil :MakeArray([LGRecyclerViewAdapter class]C nil)] forKey:@"setAdapter"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(getAdapter)) :@selector(getAdapter) :[LGRecyclerViewAdapter class] :MakeArray(nil)] forKey:@"getAdapter"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(notify)) :@selector(notify) :nil :MakeArray(nil)] forKey:@"notify"];
    return dict;
}

@end
