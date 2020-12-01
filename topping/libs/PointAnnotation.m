#import "PointAnnotation.h"

@implementation PointAnnotation

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate addressDictionary:(NSDictionary *)addressDictionary {
    if ((self = [super initWithCoordinate:coordinate addressDictionary:addressDictionary])) {
        self.coordinate = coordinate;
    }
    return self;
}

@end
