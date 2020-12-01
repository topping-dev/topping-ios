#import "PolyAnnotationView.h"

@implementation PolyAnnotationView

-(void) regionChanged
{
    NSLog(@"Region Changed");
    
    // move the internal route view.
    CGPoint origin = CGPointMake(0, 0);
    origin = [self.mapView convertPoint:origin toView:self];
}

@end
