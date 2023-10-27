#import <Foundation/Foundation.h>

@protocol ViewTreeObserverOnWindowAttachListener <NSObject>

-(void)onWindowAttached;
-(void)onWindowDetached;

@end

@protocol ViewTreeObserverOnGlobalLayoutListener <NSObject>

-(void)onGlobalLayout;

@end

@protocol ViewTreeObserverOnPreDrawListener <NSObject>

-(void)onPreDraw;

@end

@protocol ViewTreeObserverOnDrawListener <NSObject>

-(void)onDraw;

@end

@protocol ViewTreeObserverOnTouchModeChangeListener <NSObject>

-(void)onTouchModeChanged:(BOOL)isInTouchMode;

@end

@protocol ViewTreeObserverOnScrollChangedListener <NSObject>

-(void)onScrollChanged;

@end

@interface ViewTreeObserver : NSObject

-(void)addOnWindowAttachListener:(id<ViewTreeObserverOnWindowAttachListener>)listener;
-(void)removeOnWindowAttachListener:(id<ViewTreeObserverOnWindowAttachListener>)listener;
-(void)dispatchWindowAttach:(BOOL)attached;

-(void)addOnGlobalLayoutListener:(id<ViewTreeObserverOnGlobalLayoutListener>)listener;
-(void)removeOnGlobalLayoutListener:(id<ViewTreeObserverOnGlobalLayoutListener>)listener;
-(void)dispatchGlobalLayout;

-(void)addOnPreDrawListener:(id<ViewTreeObserverOnPreDrawListener>)listener;
-(void)removeOnPreDrawhListener:(id<ViewTreeObserverOnPreDrawListener>)listener;
-(void)dispatchPreDraw;

-(void)addOnDrawListener:(id<ViewTreeObserverOnDrawListener>)listener;
-(void)removeOnDrawListener:(id<ViewTreeObserverOnDrawListener>)listener;
-(void)dispatchDraw;

-(void)addOnTouchModeChangeListener:(id<ViewTreeObserverOnTouchModeChangeListener>)listener;
-(void)removeOnTouchModeChangeListener:(id<ViewTreeObserverOnTouchModeChangeListener>)listener;
-(void)dispatchTouchModeChange:(BOOL)isInTouchMode;

-(void)addOnScrollChangedListener:(id<ViewTreeObserverOnScrollChangedListener>)listener;
-(void)removeOnScrollChangedListener:(id<ViewTreeObserverOnScrollChangedListener>)listener;
-(void)dispatchScrollChanged;

@property(nonatomic, retain) NSMutableArray *mWindowAttachListeners;
@property(nonatomic, retain) NSMutableArray *mGlobalLayoutListeners;
@property(nonatomic, retain) NSMutableArray *mPreDrawListeners;
@property(nonatomic, retain) NSMutableArray *mDrawListeners;
@property(nonatomic, retain) NSMutableArray *mTouchModeListeners;
@property(nonatomic, retain) NSMutableArray *mScrollChangeListeners;

@end
