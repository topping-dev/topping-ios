#import "LGRecyclerViewAdapter.h"
#import "Defines.h"
#import "LGRecyclerView.h"
#import "LuaFunction.h"
#import "LuaValues.h"
#import "LuaTranslator.h"
#import "LGViewPager.h"
#import "ILGRecyclerViewAdapter.h"

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

-(NSObject *)getObject:(NSIndexPath*)indexPath
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
                obj = [view getObject:indexPath];
                break;
            }
            count++;
        }
    }
    return obj;
}

-(int)getCount
{
    if(self.kotlinInterface != nil) {
        return [((NSNumber*)[self.kotlinInterface.ltGetItemCount call]) intValue];
    }
    if(self.values != nil)
        return [self.values count];
    return 0;
}

-(int)getTotalHeight:(int)start
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
            value = [view getTotalHeight:value];
        }
    }
    return value;
}

-(int)getTotalWidth:(int)start
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
            value = [view getTotalWidth:value];
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
        LGView *lgview = (LGView*)[self.ltCreateViewHolder callIn:self.parent, nType, self.lc, nil];
        ((LGViewUICollectionViewCell*)cell).lgview = lgview;
        [lgview addSelfToParent:cell.contentView :nil];
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

        [self.ltItemSelected callIn:self.parent, cell.lgview, [NSNumber numberWithInt:(indexPath.section + 1 * indexPath.row)], [self getObject:indexPath], nil];
    }
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LGViewUICollectionViewCell* cell = [self.cells objectForKey:indexPath];
    
    NSObject *obj = [self getObject:indexPath];
    [self.ltBindViewHolder callIn:cell.lgview, [NSNumber numberWithInt:indexPath.row], obj, nil];
    
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
            type = [((NSNumber*)[self.ltGetItemViewType callIn:[NSNumber numberWithInt:indexPath.row], nil]) intValue];
        }
        cell = (LGViewUICollectionViewCell*)[self generateCell:indexPath :type];
        NSObject *obj = [self getObject:indexPath];
        [self.ltBindViewHolder callIn:cell.lgview, [NSNumber numberWithInt:indexPath.row], obj, nil];
    }

    if(cell.lgview != nil)
    {
        [cell.lgview readWidthHeight];
        int width = cell.lgview.dWidth;
        int height = cell.lgview.dHeight;
        return CGSizeMake(width, height);
    }
    else
        return CGSizeZero;
}

+(LGRecyclerViewAdapter*)create:(LuaContext *)context :(NSString*)lid
{
    LGRecyclerViewAdapter *view = [[LGRecyclerViewAdapter alloc] initWithContext:context :lid];
    return view;
}

-(LGRecyclerViewAdapter*)addSection:(NSString *)header :(NSString*) idV
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

-(void)removeSection:(NSString*) header
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

-(void)addValue:(NSObject *)value
{
    if(self.values == nil)
        self.values = [NSMutableArray array];
    
    [self.values addObject:value];
}

-(void)removeValue:(NSObject *)value
{
    if(self.values == nil)
        return;
    
    [self.values removeObject:value];
}

-(void)clear
{
    if(self.values == nil)
        return;
    
    [self.values removeAllObjects];
}

-(void)notify
{
    [((UICollectionView*)self.parent._view) reloadData];
}

-(void)setOnItemSelected:(LuaTranslator*)lt
{
    self.ltItemSelected = lt;
}

-(void)setOnCreateViewHolder:(LuaTranslator*)lt
{
    self.ltCreateViewHolder = lt;
}

-(void)setOnBindViewHolder:(LuaTranslator*)lt
{
    self.ltBindViewHolder = lt;
}

-(void)setGetItemViewType:(LuaTranslator*)lt
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
    [dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(create::))
                                        :@selector(create::)
                                        :[LGRecyclerViewAdapter class]
                                        :[NSArray arrayWithObjects:[LuaContext class], [NSString class], nil]
                                        :[LGRecyclerViewAdapter class]]
             forKey:@"create"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(addSection::)) :@selector(addSection::) :[LGRecyclerViewAdapter class] :MakeArray([NSString class]C [NSString class]C nil)] forKey:@"addSection"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(removeSection:)) :@selector(removeSection:) :nil :MakeArray([NSString class]C nil)] forKey:@"removeSection"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(addValue:)) :@selector(addValue:) :nil :MakeArray([NSObject class]C nil)] forKey:@"addValue"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(removeValue:)) :@selector(removeValue:) :nil :MakeArray([NSObject class]C nil)] forKey:@"removeValue"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(clear)) :@selector(clear) :nil :MakeArray(nil)] forKey:@"clear"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(notify)) :@selector(notify) :nil :MakeArray(nil)] forKey:@"notify"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(setOnItemSelected:)) :@selector(setOnItemSelected:) :nil :MakeArray([LuaTranslator class]C nil)] forKey:@"setOnItemSelected"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(setOnCreateViewHolder:)) :@selector(setOnCreateViewHolder:) :nil :MakeArray([LuaTranslator class]C nil)] forKey:@"setOnCreateViewHolder"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(setOnBindViewHolder:)) :@selector(setOnBindViewHolder:) :nil :MakeArray([LuaTranslator class]C nil)] forKey:@"setOnBindViewHolder"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(setGetItemViewType:)) :@selector(setGetItemViewType:) :nil :MakeArray([LuaTranslator class]C nil)] forKey:@"setGetItemViewType"];
    return dict;
}

@end
