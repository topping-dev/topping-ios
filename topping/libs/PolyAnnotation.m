#import "PolyAnnotation.h"


@implementation PolyAnnotation

-(MKCoordinateRegion) region
{
    MKCoordinateRegion region;
    region.center = self.coordinate;
    region.span = self.span;
    
    return region;
}

@end
