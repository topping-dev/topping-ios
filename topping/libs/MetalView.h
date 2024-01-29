#import <Foundation/Foundation.h>
#import <MetalKit/MetalKit.h>
#import <Metal/Metal.h>
#import <ToppingIOSKotlinHelper/ToppingIOSKotlinHelper.h>
#import "LGView.h"

@protocol MetalViewDelegate <NSObject>

-(void)tick:(CADisplayLink*)link;
-(void)onRender:(TIOSKHSkikoCanvas*)canvas :(int)width :(int)height :(long)nanoTime;

@end

@interface MetalViewInternalDelegate : NSObject <MTKViewDelegate>

- (instancetype)initWithView:(LGView*)view;

@property (nonatomic, retain) LGView *wrapper;

@end

@interface MetalView : MTKView

- (instancetype)initWithFrame:(CGRect)frameRect device:(id<MTLDevice>)device :(LGView*)view;

@property (nonatomic, retain) CAMetalLayer *metalLayer;
@property (nonatomic, retain) TIOSKHMetalRedrawer *redrawer;
@property (nonatomic, retain) id<MetalViewDelegate> metalViewDelegate;
@property (nonatomic, retain) MetalViewInternalDelegate *metalViewInternalDelegate;
@property (nonatomic, retain) LGView *wrapper;


@end
