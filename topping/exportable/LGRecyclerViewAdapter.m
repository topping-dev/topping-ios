#import "LGRecyclerViewAdapter.h"
#import "Defines.h"
#import "LGRecyclerView.h"
#import "LuaFunction.h"
#import "LuaValues.h"
#import "LuaTranslator.h"
#import "LGViewPager.h"

@implementation LGViewUICollectionViewCell

@end

@implementation LGRecyclerViewAdapter

- (instancetype)initWithContext:(LuaContext *)context :(NSString*)lua_id
{
    self = [super init];
    if (self) {
        self.lc = context;
        self.lua_id = lua_id;
        self.cells = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(NSObject *)GetObject:(NSIndexPath*)indexPath
{
    NSObject *obj = nil;
    if(self.sections == nil)
        obj = [self.values objectAtIndex:indexPath.row];
    else
    {
        int count = 0;
        for(NSString *key in self.sections)
        {
            if(count == indexPath.section)
            {
                LGRecyclerViewAdapter *view = [self.sections objectForKey:key];
                obj = [view GetObject:indexPath];
                break;
            }
            count++;
        }
    }
    return obj;
}

-(int)GetCount
{
    if(self.values != nil)
        return [self.values count];
    return 0;
}

-(int)GetTotalHeight:(int)start
{
    int value = start;
    if(self.sections == nil)
    {
        /*for(NSObject *key in self.views)
        {
            NSObject *obj = [self.views objectForKey:key];
            value += [((LGView*)obj) GetContentH];
        }*/
    }
    else
    {
        for(NSString *key in self.sections)
        {
            LGRecyclerViewAdapter *view = [self.sections objectForKey:key];
            value = [view GetTotalHeight:value];
        }
    }
    return value;
}

-(int)GetTotalWidth:(int)start
{
    int value = start;
    if(self.sections == nil)
    {
        /*for(NSObject *key in self.views)
        {
            NSObject *obj = [self.views objectForKey:key];
            value += [((LGView*)obj) GetContentW];
        }*/
    }
    else
    {
        for(NSString *key in self.sections)
        {
            LGRecyclerViewAdapter *view = [self.sections objectForKey:key];
            value = [view GetTotalWidth:value];
        }
    }
    return value;
}

-(UICollectionViewCell *)generateCell:(NSIndexPath*)indexPath :(int)type
{
    NSString *MyIdentifier = self.lua_id;
    NSNumber *nType = [NSNumber numberWithInt:type];
    
    LGViewUICollectionViewCell *cell;

    @try {
        cell = [((UICollectionView*)self.parent._view) dequeueReusableCellWithReuseIdentifier:APPEND(MyIdentifier, [nType stringValue]) forIndexPath:indexPath];
    } @catch (NSException *exception) {
        [((UICollectionView*)self.parent._view) registerClass:[LGViewUICollectionViewCell class] forCellWithReuseIdentifier:APPEND(MyIdentifier, [nType stringValue])];
        cell = [((UICollectionView*)self.parent._view) dequeueReusableCellWithReuseIdentifier:APPEND(MyIdentifier, [nType stringValue]) forIndexPath:indexPath];
    }
    
    if(cell.lgview == nil) {
        LGView *lgview = (LGView*)[self.ltCreateViewHolder CallIn:self.parent, nType, self.lc, nil];
        ((LGViewUICollectionViewCell*)cell).lgview = lgview;
        [lgview AddSelfToParent:cell.contentView :nil];
    }
    
    [self.cells setObject:cell forKey:indexPath];
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.ltItemSelected != nil)
    {
        LGViewUICollectionViewCell* cell = [self.cells objectForKey:indexPath];
        if(cell.lgview == nil)
        {
            return;
        }

        [self.ltItemSelected CallIn:self.parent, cell.lgview, [NSNumber numberWithInt:(indexPath.section + 1 * indexPath.row)], [self GetObject:indexPath], nil];
    }
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LGViewUICollectionViewCell* cell = [self.cells objectForKey:indexPath];
    
    NSObject *obj = [self GetObject:indexPath];
    [self.ltBindViewHolder CallIn:cell.lgview, [NSNumber numberWithInt:indexPath.row], obj, nil];
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if(self.onPageChangedListener != nil) {
        [self.onPageChangedListener onPageChanged:indexPath.row];
    }
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.values.count;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LGViewUICollectionViewCell* cell = [self.cells objectForKey:indexPath];
    if(cell == nil)
    {
        int type = 0;
        if(self.ltGetItemViewType != nil)
        {
            type = [((NSNumber*)[self.ltGetItemViewType CallIn:[NSNumber numberWithInt:indexPath.row], nil]) intValue];
        }
        cell = (LGViewUICollectionViewCell*)[self generateCell:indexPath :type];
        NSObject *obj = [self GetObject:indexPath];
        [self.ltBindViewHolder CallIn:cell.lgview, [NSNumber numberWithInt:indexPath.row], obj, nil];
    }

    if(cell.lgview != nil)
    {
        [cell.lgview ReadWidthHeight];
        int width = cell.lgview.dWidth;
        int height = cell.lgview.dHeight;
        return CGSizeMake(width, height);
    }
    else
        return CGSizeZero;
}

+(LGRecyclerViewAdapter*)Create:(LuaContext *)context :(NSString*)lid
{
    LGRecyclerViewAdapter *view = [[LGRecyclerViewAdapter alloc] initWithContext:context :lid];
    return view;
}

-(LGRecyclerViewAdapter*)AddSection:(NSString *)header :(NSString*) idV
{
    if(self.sections == nil)
        self.sections = [[NSMutableDictionary alloc] init];
    
    if(self.headers == nil)
        self.headers = [[NSMutableDictionary alloc] init];
    
    LGRecyclerViewAdapter *view = [[LGRecyclerViewAdapter alloc] init];
    view.lua_id = idV;
    [self.sections setObject:view forKey:header];
    [self.headers setObject:header forKey:idV];
    
    return view;
}

-(void)RemoveSection:(NSString*) header
{
    if(self.sections != nil)
        [self.sections removeObjectForKey:header];
    
    if(self.headers != nil)
    {
        NSString *keyToRemove = nil;
        for(NSString *key in self.headers)
        {
            NSString *headerIn = [self.headers objectForKey:key];
            
            if([header compare:headerIn] == 0)
            {
                keyToRemove = key;
                break;
            }
        }
        
        if(keyToRemove != nil)
            [self.headers removeObjectForKey:keyToRemove];
    }
}

-(void)AddValue:(NSObject *)value
{
    if(self.values == nil)
        self.values = [NSMutableArray array];
    
    [self.values addObject:value];
}

-(void)RemoveValue:(NSObject *)value
{
    if(self.values == nil)
        return;
    
    [self.values removeObject:value];
}

-(void)Clear
{
    if(self.values == nil)
        return;
    
    [self.values removeAllObjects];
}

-(void)Notify
{
    [((UICollectionView*)self.parent._view) reloadData];
}

-(void)SetOnItemSelected:(LuaTranslator*)lt
{
    self.ltItemSelected = lt;
}

-(void)SetOnCreateViewHolder:(LuaTranslator*)lt
{
    self.ltCreateViewHolder = lt;
}

-(void)SetOnBindViewHolder:(LuaTranslator*)lt
{
    self.ltBindViewHolder = lt;
}

-(void)SetGetItemViewType:(LuaTranslator*)lt
{
    self.ltGetItemViewType = lt;
}

-(NSString*)GetId
{
    if(self.lua_id != nil)
        return self.lua_id;
    return [LGRecyclerViewAdapter className];
}

+ (NSString*)className
{
    return @"LGRecyclerViewAdapter";
}

+(NSMutableDictionary*)luaMethods
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(Create::))
                                        :@selector(Create::)
                                        :[LGRecyclerViewAdapter class]
                                        :[NSArray arrayWithObjects:[LuaContext class], [NSString class], nil]
                                        :[LGRecyclerViewAdapter class]]
             forKey:@"Create"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(AddSection::)) :@selector(AddSection::) :[LGRecyclerViewAdapter class] :MakeArray([NSString class]C [NSString class]C nil)] forKey:@"AddSection"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(RemoveSection:)) :@selector(RemoveSection:) :nil :MakeArray([NSString class]C nil)] forKey:@"RemoveSection"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(AddValue:)) :@selector(AddValue:) :nil :MakeArray([NSObject class]C nil)] forKey:@"AddValue"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(RemoveValue:)) :@selector(RemoveValue:) :nil :MakeArray([NSObject class]C nil)] forKey:@"RemoveValue"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(Clear)) :@selector(Clear) :nil :MakeArray(nil)] forKey:@"Clear"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(Notify)) :@selector(Notify) :nil :MakeArray(nil)] forKey:@"Notify"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetOnItemSelected:)) :@selector(SetOnItemSelected:) :nil :MakeArray([LuaTranslator class]C nil)] forKey:@"SetOnItemSelected"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetOnCreateViewHolder:)) :@selector(SetOnCreateViewHolder:) :nil :MakeArray([LuaTranslator class]C nil)] forKey:@"SetOnCreateViewHolder"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetOnBindViewHolder:)) :@selector(SetOnBindViewHolder:) :nil :MakeArray([LuaTranslator class]C nil)] forKey:@"SetOnBindViewHolder"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetGetItemViewType:)) :@selector(SetGetItemViewType:) :nil :MakeArray([LuaTranslator class]C nil)] forKey:@"SetGetItemViewType"];
    return dict;
}

@end
