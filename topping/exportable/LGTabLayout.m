#import "LGTabLayout.h"
#import <topping/topping-Swift.h>
#import "Topping.h"
#import "LGColorParser.h"
#import "LGDimensionParser.h"
#import "LGDrawableParser.h"
#import "MaterialTabs+TabBarView.h"
#import <math.h>

@implementation LGTabLayout

- (int)GetContentH
{
    if(self.tab != nil)
    {
        return ((MDCTabBarView*)self.tab).contentSize.height;
    }
    return 49;
}

- (int)GetContentW
{
    if(self.tab != nil)
    {
        return ((MDCTabBarView*)self.tab).contentSize.width;
    }
    return [super GetContentW];
}

-(UIView *)CreateComponent
{
    self.tab = [[MDCTabBarView alloc] initWithFrame:CGRectMake(self.dX, self.dY, self.dWidth, self.dHeight)];
    ((MDCTabBarView*)self.tab).tabBarDelegate = self;
    
    self.items = [NSMutableArray new];
    
    return self.tab;
}

-(void)SetupComponent:(UIView *)view
{
    if(self.app_tabBackground == nil) {
        self.app_tabBackground = @"@color/colorPrimary";
    }
    if(self.app_tabGravity != nil) {
        //[self.tab setMode:]
    }
    if(self.app_tabIndicatorColor != nil) {
        [((MDCTabBarView*)self.tab) setSelectionIndicatorStrokeColor:[[LGColorParser GetInstance] ParseColor:self.app_tabIndicatorColor]];
    }
    if(self.app_tabMode != nil) {
        int mode = [self.app_tabMode intValue];
        if(mode == 0) {
            ((MDCTabBarView*)self.tab).preferredLayoutStyle = MDCTabBarViewLayoutStyleScrollable;
        } else {
            ((MDCTabBarView*)self.tab).preferredLayoutStyle = MDCTabBarViewLayoutStyleFixed;
        }
    }
    
    [super SetupComponent:self.tab];
}

-(void)UpdateTabs {
    NSMutableArray *arr = [NSMutableArray array];
    LuaTab *firstTab = nil;
    for(LuaTab* tab in self.items) {
        if(firstTab == nil)
            firstTab = tab;
        [arr addObject:tab.item];
    }
    [((MDCTabBarView*)self.tab) setItems:arr];
    [self.tab layoutSubviews];
    if(self.items.count == 1) {
        [((MDCTabBarView*)self.tab) setSelectedItem:(UITabBarItem*)firstTab.item animated:NO];
    }
    [self ResizeAndInvalidate];
}

-(void)AddTab:(LuaTab*)tab {
    [self.items addObject:tab];
    [self UpdateTabs];
}

-(LuaTab*)GetTabAtIndex:(int)position {
    return [self.items objectAtIndex:position];
}

-(int)GetTabCount {
    return (int)self.items.count;
}

-(void)RemoveTabAtPosition:(int)position {
    [self.items removeObjectAtIndex:position];
    [self UpdateTabs];
}

-(void)RemoveTab:(LuaTab*)tab {
    [self.items removeObject:tab];
    [self UpdateTabs];
}

-(void)RemoveAllTabs {
    [self.items removeAllObjects];
    [self UpdateTabs];
}

-(void)SelectTab:(LuaTab*)tab {
    [((MDCTabBarView*)self.tab) setSelectedItem:(MDCTabBarItem*)tab.item];
}

-(void)SelectTabAtIndex:(int)position {
    [self SelectTab:[self.items objectAtIndex:position]];
}

-(void)SetTabSelectedListener:(LuaTranslator*)lt {
    self.ltTabSelectedListener = lt;
}

-(int)getTabIndexForUITabBarItem:(UITabBarItem*)item {
    int count = 0;
    for(LuaTab *tabItem in self.items) {
        if(tabItem.item == item)
        {
            return count;
        }
        count++;
    }
    return -1;
}

-(LuaTab*)getTabForUITabBarItem:(UITabBarItem*)item {
    for(LuaTab *tabItem in self.items) {
        if(tabItem.item == item)
        {
            return tabItem;
        }
    }
    return nil;
}

-(void)tabBarView:(MDCTabBarView *)tabBarView didSelectItem:(UITabBarItem *)item {
    if(self.delegate != nil) {
        [self.delegate didSelectTab:[self getTabForUITabBarItem:item] atIndex:[self getTabIndexForUITabBarItem:item]];
    }
    
    if(self.ltTabSelectedListener == nil)
        return;
    
    LuaTab *tabItem = [self getTabForUITabBarItem:item];
    if(tabItem != nil)
    {
        [self.ltTabSelectedListener Call:self :tabItem];
    }
}

-(BOOL)tabBarView:(MDCTabBarView *)tabBarView shouldSelectItem:(UITabBarItem *)item {
    return true;
}

-(void)didScroll:(CGPoint)contentOffset {
    if(((MDCTabBarView*)self.tab).preferredLayoutStyle == MDCTabBarViewLayoutStyleFixed)
    {
        CGPoint nextMove = CGPointZero;
        if(self.lastContentOffset.x <= contentOffset.x) {
            nextMove = [((MDCTabBarView*)self.tab) calculateMovement:1 :-1];
        } else {
            nextMove = [((MDCTabBarView*)self.tab) calculateMovement:-1 :-1];
        }
        self.lastContentOffset = contentOffset;
        CGRect frameToSet = [((MDCTabBarView*)self.tab) getSelectionIndicatorView].frame;
        [((MDCTabBarView*)self.tab) getSelectionIndicatorView].frame = CGRectMake((contentOffset.x / self.items.count), frameToSet.origin.y, frameToSet.size.width, frameToSet.size.height);
    }
    else {
        CGPoint nextMove = CGPointZero;
        if(self.lastContentOffset.x <= contentOffset.x) {
            nextMove = [((MDCTabBarView*)self.tab) calculateMovement:0 :-1];
        } else {
            nextMove = [((MDCTabBarView*)self.tab) calculateMovement:-1 :-1];
        }
        self.lastContentOffset = contentOffset;
        CGRect frameToSet = [((MDCTabBarView*)self.tab) getSelectionIndicatorView].frame;
        float contentModX = contentOffset.x / ([((MDCTabBarView*)self.tab).items indexOfObject:((MDCTabBarView*)self.tab).selectedItem] + 1);
        float calc = ((contentModX / self.tab.frame.size.width) * frameToSet.size.width) + nextMove.x;
        [((MDCTabBarView*)self.tab) getSelectionIndicatorView].frame = CGRectMake(calc, frameToSet.origin.y, frameToSet.size.width, frameToSet.size.height);
    }
}

-(NSString*)GetId
{
    if(self.lua_id != nil)
        return self.lua_id;
    if(self.android_id != nil)
        return self.android_id;
    return [LGTabLayout className];
}

+ (NSString*)className
{
    return @"LGTabLayout";
}

+(NSMutableDictionary*)luaMethods
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    
    InstanceMethodNoRet(AddTab:, @[[LuaTab class]], @"AddTab")
    InstanceMethod(GetTabAtIndex:, LuaTab, @[[LuaInt class]], @"GetTabAtIndex")
    InstanceMethodNoArg(GetTabCount, LuaInt, @"GetTabCount")
    InstanceMethodNoRet(RemoveTabAtPosition:, @[[LuaInt class]], @"RemoveTabAtPosition")
    InstanceMethodNoRet(RemoveTab:, @[[LuaTab class]], @"RemoveTab")
    InstanceMethodNoRetNoArg(RemoveAllTabs, @"RemoveAllTabs")
    InstanceMethodNoRet(SelectTab:, @[[LuaTab class]], @"SelectTab")
    InstanceMethodNoRet(SelectTabAtIndex:, @[[LuaInt class]], @"SelectTabAtIndex")
    InstanceMethodNoRet(SetTabSelectedListener:, @[[LuaTranslator class]], @"SetTabSelectedListener")
    
    return dict;
}

@end
