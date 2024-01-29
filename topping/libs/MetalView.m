#import "MetalView.h"

@implementation MetalViewInternalDelegate

-(instancetype)initWithView:(LGView *)view {
    self = [super init];
    if (self) {
        self.wrapper = view;
    }
    return self;
}

-(void)drawInMTKView:(MTKView *)view {
    if(self.wrapper.forceOverrideDrawRect)
    {
        self.wrapper.forceOverrideDrawRectBlock(view.frame);
    }
}

- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size {
    
}


@end

@implementation MetalView

- (instancetype)initWithFrame:(CGRect)frameRect device:(id<MTLDevice>)device :(LGView*)view {
    self = [super initWithFrame:frameRect device:device];
    if (self) {
        self.metalLayer = (CAMetalLayer*)self.layer;
        self.metalViewInternalDelegate = [[MetalViewInternalDelegate alloc] initWithView:view];
        self.redrawer = [[TIOSKHMetalRedrawer alloc] initWithMetalLayer:self.metalLayer
           drawCallback:^(TIOSKHSkikoSurface * _Nonnull surface) {
            if(self.metalViewDelegate != nil)
                [self.metalViewDelegate onRender:surface.canvas :surface.width :surface.height :CFAbsoluteTimeGetCurrent()];
           }
           tickCallback:^(CADisplayLink * _Nonnull link) {
            if(self.metalViewDelegate != nil)
                [self.metalViewDelegate tick:link];
           }
       addDisplayLinkToRunLoop:nil disposeCallback:^(TIOSKHMetalRedrawer * _Nonnull drawer) {
        }];
        self.delegate = self.metalViewInternalDelegate;
        self.wrapper = view;
    }
    return self;
}

-(void)didMoveToWindow {
    NSLog(@"contentScale factor = %f", self.contentScaleFactor);
    self.contentScaleFactor = 1;
    NSLog(@"contentScale factor set = %f", self.contentScaleFactor);
    self.redrawer.maximumFramesPerSecond = self.window.screen.maximumFramesPerSecond;
}


@end
