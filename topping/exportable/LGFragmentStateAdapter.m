#import "LGFragmentStateAdapter.h"
#import "LGFrameLayout.h"
#import "Defines.h"
#import "LGViewPager.h"
#import "Defines.h"
#import <Topping/Topping-Swift.h>

@implementation OnPostEventListener_DUMMY

- (void)onPost { }

@end

@implementation FragmentTransactionCallback

-(id<OnPostEventListener>)onFragmentPreAdded:(LuaFragment*)fragment {
    return self.dummy;
}

-(id<OnPostEventListener>)onFragmentPreSavedInstanceState:(LuaFragment*)fragment {
    return self.dummy;
}

-(id<OnPostEventListener>)onFragmentPreRemoved:(LuaFragment*)fragment {
    return self.dummy;
}

-(id<OnPostEventListener>)onFragmentMaxLifecyclePreUpdated:(LuaFragment*)fragment :(LifecycleState)maxLifecycleState {
    return self.dummy;
}

@end

@implementation FragmentMaxLifecycleEnforcerPageChangeCallback

- (instancetype)initWithEnforcer:(FragmentMaxLifecycleEnforcer *)enforcer
{
    self = [super init];
    if (self) {
        self.enforcer = enforcer;
    }
    return self;
}

-(void)onPageChanged:(int)page {
    [self.enforcer updateFragmentMaxLifecycle:false];
}
    
@end

@implementation FragmentMaxLifecycleEnforcerLifecycleCallback

- (instancetype)initWithEnforcer:(FragmentMaxLifecycleEnforcer *)enforcer
{
    self = [super init];
    if (self) {
        self.enforcer = enforcer;
    }
    return self;
}

-(void)onStateChanged:(id<LifecycleOwner>)source :(LifecycleEvent)event {
    [self.enforcer updateFragmentMaxLifecycle:false];
}

- (NSString *)getKey {
    if(self.key == nil) {
        self.key = [[NSUUID UUID] UUIDString];
    }
    return self.key;
}


@end

@implementation FragmentMaxLifecycleEnforcer

- (instancetype)initWithAdapter:(LGFragmentStateAdapter *)adapter
{
    self = [super init];
    if (self) {
        self.adapter = adapter;
    }
    return self;
}

-(void)register:(LGViewPager *)viewPager {
    self.viewPager = [self inferViewPager:viewPager];
    
    self.pageChangeCallback = [[FragmentMaxLifecycleEnforcerPageChangeCallback alloc] initWithEnforcer:self];
    [self.viewPager registerOnPageChangeCallback:self.pageChangeCallback];
    
    //[self.viewPager dataobserver]
    
    self.lifecycleObserver = [[FragmentMaxLifecycleEnforcerLifecycleCallback alloc] initWithEnforcer:self];
    [self.adapter.lifecycle.lifecycle addObserver:self.lifecycleObserver];
}

-(void)unregister:(LGViewPager *)viewPager {
    [self.viewPager unRegisterOnPageChangeCallback:self.pageChangeCallback];
    //TODO:Data
    [self.adapter.lifecycle.lifecycle removeObserver:self.lifecycleObserver];
}

-(void)updateFragmentMaxLifecycle:(BOOL)dataSetChanged {
    if([self.adapter shouldDelayFragmentTransactions])
        return;
    
    if(self.adapter.fragments.count == 0 || [self.adapter getItemCount] == 0)
        return;
    
    int currentItem = [self.viewPager getCurrentItem];
    if(currentItem > [self.adapter getItemCount]) {
        return;
    }
    
    NSString* currentItemId = [self.adapter getItemId:currentItem];
    if(currentItemId == self.adapter.primaryItemId && !dataSetChanged)
        return;
    
    LuaFragment *currentItemFragment = [self.adapter.fragments objectForKey:currentItemId];
    if(currentItemFragment == nil || !currentItemFragment.mAdded) {
        return;
    }
    
    self.adapter.primaryItemId = currentItemId;
    FragmentTransaction *transaction = [self.adapter.fragmentManager beginTransaction];
    
    LuaFragment *toResume = nil;
    for(int i = 0; i < self.adapter.fragments.count; i++) {
        NSString *itemId = [self.adapter.fragments keyAtIndex:i];
        LuaFragment *fragment = [self.adapter.fragments objectForKey:itemId];
        
        if(!fragment.mAdded)
            continue;
        
        if(itemId != self.adapter.primaryItemId) {
            [transaction setMaxLifecycleWithFragment:fragment state:LIFECYCLESTATE_STARTED];
        } else {
            toResume = fragment;
        }
        
        //TODO: menu visibility
        //fragment.setMenuVisibility(itemId == mPrimaryItemId);
    }
    
    if(toResume != nil) {
        [transaction setMaxLifecycleWithFragment:toResume state:LIFECYCLESTATE_RESUMED];
    }
    
    if(![transaction isEmpty]) {
        [transaction commitNow];
    }
}

-(LGViewPager *)inferViewPager:(LGViewPager *)viewPager {
    return nil;
}

@end

@implementation FragmentStateLifecycleCallback

- (instancetype)initWithContext:(LuaContext *)context :(LuaFragment*)fragment :(LGFrameLayout*)frameLayout :(LGFragmentStateAdapter*)adapter
{
    self = [super init];
    if (self) {
        self.lc = context;
        self.fragment = fragment;
        self.frameLayout = frameLayout;
        self.adapter = adapter;
    }
    return self;
}

- (void)onFragmentActivityCreatedWithFm:(FragmentManager * _Nonnull)fm f:(LuaFragment * _Nonnull)f savedInstanceState:(NSDictionary<NSString *,id> * _Nullable)savedInstanceState {
    
}

- (void)onFragmentAttachedWithFm:(FragmentManager * _Nonnull)fm f:(LuaFragment * _Nonnull)f context:(LuaContext * _Nonnull)context {
    
}

- (void)onFragmentCreatedWithFm:(FragmentManager * _Nonnull)fm f:(LuaFragment * _Nonnull)f savedInstanceState:(NSDictionary<NSString *,id> * _Nullable)savedInstanceState {
}

- (void)onFragmentDestroyedWithFm:(FragmentManager * _Nonnull)fm f:(LuaFragment * _Nonnull)f {
    
}

- (void)onFragmentDetachedWithFm:(FragmentManager * _Nonnull)fm f:(LuaFragment * _Nonnull)f {
    
}

- (void)onFragmentPausedWithFm:(FragmentManager * _Nonnull)fm f:(LuaFragment * _Nonnull)f {
    
}

- (void)onFragmentPreAttachedWithFm:(FragmentManager * _Nonnull)fm f:(LuaFragment * _Nonnull)f context:(LuaContext * _Nonnull)context {
    
}

- (void)onFragmentPreCreatedWithFm:(FragmentManager * _Nonnull)fm f:(LuaFragment * _Nonnull)f savedInstanceState:(NSDictionary<NSString *,id> * _Nullable)savedInstanceState {
    
}

- (void)onFragmentResumedWithFm:(FragmentManager * _Nonnull)fm f:(LuaFragment * _Nonnull)f {
    
}

- (void)onFragmentSaveInstanceStateWithFm:(FragmentManager * _Nonnull)fm f:(LuaFragment * _Nonnull)f outState:(NSDictionary<NSString *,id> * _Nonnull)outState {
    
}

- (void)onFragmentStartedWithFm:(FragmentManager * _Nonnull)fm f:(LuaFragment * _Nonnull)f {
    
}

- (void)onFragmentStoppedWithFm:(FragmentManager * _Nonnull)fm f:(LuaFragment * _Nonnull)f {
    
}

- (void)onFragmentViewCreatedWithFm:(FragmentManager * _Nonnull)fm f:(LuaFragment * _Nonnull)f v:(LGView * _Nonnull)v savedInstanceState:(NSDictionary<NSString *,id> * _Nullable)savedInstanceState {
    if(self.fragment == f) {
        [fm unregisterFragmentLifecycleCallbacksWithCb:self];
        [self.adapter addViewToContainer:v :self.frameLayout];
    }
}

- (void)onFragmentViewDestroyedWithFm:(FragmentManager * _Nonnull)fm f:(LuaFragment * _Nonnull)f {
    
}

@end

@implementation FragmentStateLifecycleObserver

- (instancetype)initWithAdapter:(LGFragmentStateAdapter *)adapter :(LuaFragmentUICollectionViewCell*)cell
{
    self = [super init];
    if (self) {
        self.adapter = adapter;
        self.cell = cell;
    }
    return self;
}

-(NSString *)getKey {
    if(self.key == nil) {
        self.key = [[NSUUID UUID] UUIDString];
    }
    return self.key;
}

-(void)onStateChanged:(id<LifecycleOwner>)source :(LifecycleEvent)event {
    if([self.adapter shouldDelayFragmentTransactions])
        return;
    [[source getLifecycle] removeObserver:self];
    
}

@end

@implementation LuaFragmentUICollectionViewCell

@end

@implementation LGFragmentStateAdapter

+(LGFragmentStateAdapter *)createFromForm:(LuaForm *)form {
    return [[LGFragmentStateAdapter alloc] initWithForm:form];
}

+(LGFragmentStateAdapter *)createFromFragment:(LuaFragment *)fragment {
    return [[LGFragmentStateAdapter alloc] initWithFragment:fragment];
}

+(LGFragmentStateAdapter *)create:(LuaContext *)context :(FragmentManager *)fragmentManager :(LuaLifecycle *)lifecycle {
    return [[LGFragmentStateAdapter alloc] initWithFragmentManager:context :fragmentManager :lifecycle];
}

- (instancetype)initWithForm:(LuaForm *)form {
    return [self initWithFragmentManager:form.context :[form getSupportFragmentManager] :[LuaLifecycle createForm:form]];
}

-(instancetype)initWithFragment:(LuaFragment *)fragment {
    return [self initWithFragmentManager:fragment.context :fragment.mFragmentManager :[LuaLifecycle createFragment:fragment]];
}

-(instancetype)initWithFragmentManager:(LuaContext*)context :(FragmentManager *)fragmentManager :(LuaLifecycle *)lifecycle {
    self = [super init];
    if (self) {
        self.KEY_PREFIX_FRAGMENT = @"f#";
        self.KEY_PREFIX_STATE = @"s#";
        self.lc = context;
        self.fragmentManager = fragmentManager;
        self.lifecycle = lifecycle;
        self.hasStaleFragments = false;
        self.itemIdToViewHolder = [[MutableOrderedDictionary alloc] init];
        self.fragments = [[MutableOrderedDictionary alloc] init];
        self.savedStates = [[MutableOrderedDictionary alloc] init];
        self.cells = [[MutableOrderedDictionary alloc] init];
    }
    return self;
}

-(LuaFragment *)createFragment:(int)position {
    if(self.ltCreateFragment != nil)
        return (LuaFragment*)[self.ltCreateFragment callIn:[NSNumber numberWithInt:position], nil];
    return nil;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self getItemCount];
}

-(UICollectionViewCell *)generateCell:(NSIndexPath*)indexPath
{
    LuaFragmentUICollectionViewCell *cell;

    @try {
        cell = [((UICollectionView*)self.parent._view) dequeueReusableCellWithReuseIdentifier:APPEND(@"LuaFragmentCell", LTOS(indexPath.row))  forIndexPath:indexPath];
    } @catch (NSException *exception) {
    } @finally {
        if(cell == nil) {
            [((UICollectionView*)self.parent._view) registerClass:[LuaFragmentUICollectionViewCell class] forCellWithReuseIdentifier:APPEND(@"LuaFragmentCell", LTOS(indexPath.row))];
            cell = [((UICollectionView*)self.parent._view) dequeueReusableCellWithReuseIdentifier:APPEND(@"LuaFragmentCell", LTOS(indexPath.row)) forIndexPath:indexPath];
        }
    }
    
    [self.cells setObject:cell atIndexedSubscript:indexPath.row];
    [self ensureFragment:indexPath.row];
    
    NSString *itemId = [cell.fragment.luaId stringByAppendingString:LTOS(indexPath.row)];
    NSString *viewHolderId = cell.frameLayout.lua_id;
    NSString *boundItemId = [self itemForViewHolder:viewHolderId];
    if(boundItemId != nil && boundItemId != itemId) {
        [self removeFragment:boundItemId];
        [self.itemIdToViewHolder removeObjectForKey:boundItemId];
    }
    
    [self.itemIdToViewHolder setObject:viewHolderId forKey:itemId];
    
    return cell;
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    LuaFragmentUICollectionViewCell* cell = [self.cells objectAtIndex:indexPath.row];
    if(cell == nil)
    {
        cell = (LGViewUICollectionViewCell*)[self generateCell:indexPath];
    }
    
    [self placeFragmentInCell:cell];
    
    return cell;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.parent.dWidth, self.parent.dHeight);
    //return [self.parent GetView].frame.size;
}

-(NSString*)itemForViewHolder:(NSString*)viewHolderId {
    NSString *boundItemId = nil;
    
    for(int i = 0; i < self.itemIdToViewHolder.count; i++) {
        if([self.itemIdToViewHolder objectAtIndex:i] == viewHolderId) {
            if(boundItemId != nil) {
                //TODO:Excep
                return nil;
            }
            boundItemId = [self.itemIdToViewHolder objectAtIndex:i];
        }
    }
    
    return boundItemId;
}

-(void)ensureFragment:(int)position {
    LuaFragmentUICollectionViewCell *cell = (LuaFragmentUICollectionViewCell*)[self.cells objectAtIndex:position];
    NSString *itemId = [cell.fragment.luaId stringByAppendingString:ITOS(position)];
    if(itemId == nil || [self.fragments objectForKey:itemId] == nil)
    {
        LuaFragment *fragment = [self createFragment:position];
        if(itemId == nil) {
            itemId = [fragment.luaId stringByAppendingString:ITOS(position)];
        }
        SavedState *state = [self.savedStates objectAtIndex:position];
        if(state != nil && state.mState != nil)
            fragment.mSavedFragmentState = [[NSMutableDictionary alloc] initWithDictionary:state.mState];
        else
            fragment.mSavedFragmentState = nil;
        [self.fragments setObject:fragment forKey:itemId];
        
        LGFrameLayout *frameLayout = [LGFrameLayout create:self.lc];
        frameLayout.android_layout_width = @"match_parent";
        frameLayout.android_layout_height = @"match_parent";
        frameLayout.lua_id = [[NSUUID UUID] UUIDString];
        frameLayout._view = [frameLayout createComponent];
        [frameLayout setupComponent:frameLayout._view];
        
        [frameLayout addSelfToParent:cell.contentView :nil];
        
        cell.frameLayout = frameLayout;
        cell.fragment = fragment;
    }
}

-(void)placeFragmentInCell:(LuaFragmentUICollectionViewCell*)cell {
    LGFrameLayout *container = cell.frameLayout;
    LGView *view = [cell.fragment getView];
    
    if(cell.fragment.mAdded && view == nil)
    {
        [self scheduleViewAttach:cell.fragment :cell.frameLayout];
        return;
    }
    
    if(cell.fragment.mAdded && view.parent != nil) {
        if(view.parent != cell.frameLayout) {
            [self addViewToContainer:view :container];
        }
        [cell.frameLayout resizeAndInvalidate];
        return;
    }
    
    if(cell.fragment.mAdded) {
        [self addViewToContainer:view :container];
    }
    
    if(![self shouldDelayFragmentTransactions]) {
        [self scheduleViewAttach:cell.fragment :container];
        [[[[self.fragmentManager beginTransaction] addWithFragment:cell.fragment tag:[@"f" stringByAppendingString:cell.fragment.luaId]] setMaxLifecycleWithFragment:cell.fragment state:LIFECYCLESTATE_STARTED] commitNow];
        [self.maxLifecyleEnforcer updateFragmentMaxLifecycle:false];
        
    } else {
        if([self.fragmentManager isDestroyed])
        {
            return;
        }
        
        [self.lifecycle.lifecycle addObserver:[[FragmentStateLifecycleObserver alloc] initWithAdapter:self :cell]];
    }
}

-(void)removeFragment:(NSString*)itemId
{
    LuaFragment *fragment = [self.fragments objectForKey:itemId];
    
    if(fragment == nil)
        return;
    
    if([fragment getView] != nil) {
        LGViewGroup *parent = (LGViewGroup*)[fragment getView].parent;
        if(parent != nil)
           [parent removeAllSubViews];
    }
    
    [self.savedStates removeObjectForKey:itemId];
    
    if(!fragment.mAdded) {
        [self.fragments removeObjectForKey:itemId];
        return;
    }
    
    if([self shouldDelayFragmentTransactions]) {
        self.hasStaleFragments = true;
        return;
    }
    
    if(fragment.mAdded && [self containsItem:itemId]) {
        [self.savedStates setObject:[self.fragmentManager saveFragmentInstanceStateWithFragment:fragment] forKey:itemId];
    }
    
    [[[self.fragmentManager beginTransaction] removeWithFragment:fragment] commitNow];
    [self.fragments removeObjectForKey:itemId];
}

-(int)getItemCount {
    if(self.ltGetItemCount != nil) {
        return [((NSNumber*)[self.ltGetItemCount call]) intValue];
    }
    return 0;
}

-(BOOL)containsItem:(NSString*)itemId
{
    return itemId != nil && [itemId intValue] < [self getItemCount];
}

-(void)setParentView:(LGView *)parent {
    self.parent = parent;
}

-(void)setReceiver:(LGView *)view {
    self.receiverDelegate = view;
}

-(void)setScroller:(id<OnScrollCallback>)delegate {
    self.scrollDelegate = delegate;
}

-(void)onAttachToLGViewPager:(LGViewPager *)viewPager {
    self.maxLifecyleEnforcer = [[FragmentMaxLifecycleEnforcer alloc] initWithAdapter:self];
    [self.maxLifecyleEnforcer register:viewPager];
}

-(void)onDetachedFromLGViewPager:(LGViewPager *)viewPager {
    [self.maxLifecyleEnforcer unregister:viewPager];
    self.maxLifecyleEnforcer = nil;
}

-(BOOL)shouldDelayFragmentTransactions {
    return [self.fragmentManager isStateSaved];
}

-(void)scheduleViewAttach:(LuaFragment*)fragment :(LGFrameLayout*)container {
    FragmentStateLifecycleCallback *fslc = [[FragmentStateLifecycleCallback alloc] initWithContext:self.lc :fragment :container :self];
    [self.fragmentManager registerFragmentLifecycleCallbacksWithCb:fslc recursive:false];
}

-(void)addViewToContainer:(LGView*)v :(LGFrameLayout*) container
{
    if(v.parent == container)
        return;
    
    if(container.subviews.count > 0) {
        [container removeAllSubViews];
    }
    
    if(v.parent != nil) {
        [((LGViewGroup*)v.parent) removeSubview:v];
    }
    
    [container addSubview:v];
    [container componentAddMethod:container._view :v._view];
    [self.lc.form.lgview resizeAndInvalidate];
    if([self.receiverDelegate isKindOfClass:[LGViewPager class]]) {
        [((LGViewPager*)self.receiverDelegate) notify];
    }
}

-(NSString*)getItemId:(int)position {
    return ((LuaFragmentUICollectionViewCell*)[self.cells objectAtIndex:position]).fragment.luaId;
}

- (void)restoreState:(NSMutableDictionary *)savedState {
    
}

- (NSMutableDictionary *)saveState {
    return nil;
}

- (void)setQuantumPage:(int)quantumPage {
    _quantumPage = quantumPage;
    if([self.receiverDelegate conformsToProtocol:@protocol(OnPageChangeCallback)]) {
        [((id<OnPageChangeCallback>)self.receiverDelegate) onPageChanged:quantumPage];
    }
}

- (void)setPossibleQuantumPage:(int)possibleQuantumPage {
    int oldValue = _possibleQuantumPage;
    _possibleQuantumPage = possibleQuantumPage;
    if(oldValue != possibleQuantumPage) {
        self.quantumPage = possibleQuantumPage;
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if(!decelerate)
        self.possibleQuantumPage = [self currentPageEventIfInBetween:scrollView];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.possibleQuantumPage = [self currentPageEventIfInBetween:scrollView];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(self.scrollDelegate != nil) {
        [self.scrollDelegate didScroll:scrollView.contentOffset];
    }
}

-(int)currentPageEventIfInBetween:(UIScrollView*)scrollView
{
    return (int)((scrollView.contentOffset.x + (0.5 * scrollView.frame.size.width)) / scrollView.frame.size.width);
}

-(void)setCreateFragment:(LuaTranslator *)lt {
    self.ltCreateFragment = lt;
}

-(void)setGetItemCount:(LuaTranslator *)lt {
    self.ltGetItemCount = lt;
}

-(NSString*)GetId
{
    return [LGFragmentStateAdapter className];
}

+ (NSString*)className
{
    return @"LGFragmentStateAdapter";
}

+(NSMutableDictionary*)luaMethods
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    
    ClassMethod(createFromForm:, LGFragmentStateAdapter, @[[LuaForm class]], @"createFromForm", [LGFragmentStateAdapter class])
    ClassMethod(createFromFragment:, LGFragmentStateAdapter, @[[LuaFragment class]], @"createFromFragment", [LGFragmentStateAdapter class])
    ClassMethod(create:::, LGFragmentStateAdapter, @[[LuaContext class]C [FragmentManager class]C [LuaLifecycle class]], @"create", [LGFragmentStateAdapter class])
    
    InstanceMethodNoRet(setCreateFragment:, @[[LuaTranslator class]], @"setCreateFragment")
    InstanceMethodNoRet(setGetItemCount:, @[[LuaTranslator class]], @"setGetItemCount")
    
    return dict;
}

@end
