#import "ViewTreeObserver.h"

@implementation ViewTreeObserver

-(void)addOnWindowAttachListener:(id<ViewTreeObserverOnWindowAttachListener>)listener
{
    if(self.mWindowAttachListeners == nil)
        self.mWindowAttachListeners = [NSMutableArray new];
    
    [self.mWindowAttachListeners addObject:listener];
}

-(void)removeOnWindowAttachListener:(id<ViewTreeObserverOnWindowAttachListener>)listener
{
    [self.mWindowAttachListeners removeObject:listener];
}

- (void)dispatchWindowAttach:(BOOL)attached {
    for(id<ViewTreeObserverOnWindowAttachListener> listener in self.mWindowAttachListeners)
    {
        if(attached)
            [listener onWindowAttached];
        else
            [listener onWindowDetached];
    }
}

-(void)addOnGlobalLayoutListener:(id<ViewTreeObserverOnGlobalLayoutListener>)listener
{
    if(self.mGlobalLayoutListeners == nil)
        self.mGlobalLayoutListeners = [NSMutableArray new];
    
    [self.mGlobalLayoutListeners addObject:listener];
}

-(void)removeOnGlobalLayoutListener:(id<ViewTreeObserverOnGlobalLayoutListener>)listener
{
    [self.mGlobalLayoutListeners removeObject:listener];
}

- (void)dispatchGlobalLayout {
    for(id<ViewTreeObserverOnGlobalLayoutListener> listener in self.mGlobalLayoutListeners)
    {
        [listener onGlobalLayout];
    }
}

-(void)addOnPreDrawListener:(id<ViewTreeObserverOnPreDrawListener>)listener
{
    if(self.mPreDrawListeners == nil)
        self.mPreDrawListeners = [NSMutableArray new];
    
    [self.mPreDrawListeners addObject:listener];
}

-(void)removeOnPreDrawListener:(id<ViewTreeObserverOnPreDrawListener>)listener
{
    [self.mPreDrawListeners removeObject:listener];
}

- (void)dispatchPreDraw {
    for(id<ViewTreeObserverOnPreDrawListener> listener in self.mPreDrawListeners)
    {
        [listener onPreDraw];
    }
}

-(void)addOnDrawListener:(id<ViewTreeObserverOnDrawListener>)listener
{
    if(self.mDrawListeners == nil)
        self.mDrawListeners = [NSMutableArray new];
    
    [self.mDrawListeners addObject:listener];
}

-(void)removeOnDrawListener:(id<ViewTreeObserverOnDrawListener>)listener
{
    [self.mDrawListeners removeObject:listener];
}

-(void)dispatchDraw {
    for(id<ViewTreeObserverOnDrawListener> listener in self.mDrawListeners)
    {
        [listener onDraw];
    }
}

-(void)addOnTouchModeChangeListener:(id<ViewTreeObserverOnTouchModeChangeListener>)listener
{
    if(self.mTouchModeListeners == nil)
        self.mTouchModeListeners = [NSMutableArray new];
    
    [self.mTouchModeListeners addObject:listener];
}

-(void)removeOnTouchModeChangeListener:(id<ViewTreeObserverOnTouchModeChangeListener>)listener
{
    [self.mTouchModeListeners removeObject:listener];
}

-(void)dispatchTouchModeChange:(BOOL)isInTouchMode {
    for(id<ViewTreeObserverOnTouchModeChangeListener> listener in self.mTouchModeListeners)
    {
        [listener onTouchModeChanged:isInTouchMode];
    }
}

-(void)addOnScrollChangedListener:(id<ViewTreeObserverOnScrollChangedListener>)listener
{
    if(self.mScrollChangeListeners == nil)
        self.mScrollChangeListeners = [NSMutableArray new];
    
    [self.mScrollChangeListeners addObject:listener];
}

-(void)removeOnScrollChangedListener:(id<ViewTreeObserverOnScrollChangedListener>)listener
{
    [self.mScrollChangeListeners removeObject:listener];
}

- (void)dispatchScrollChanged {
    for(id<ViewTreeObserverOnScrollChangedListener> listener in self.mScrollChangeListeners)
    {
        [listener onScrollChanged];
    }
}

@end
