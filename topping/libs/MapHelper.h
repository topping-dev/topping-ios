#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Common.h"

#define MAPHELPER_PRECISION float
#if MAPHELPER_PRECISION == float
#define SIN sinf
#define ASIN asinf
#define COS cosf
#define ACOS acosf
#define TAN tanf
#define ATAN atanf
#define ATAN2 atan2f
#define SQRT sqrtf
#else
#define SIN sin
#define ASIN asin
#define COS cos
#define ACOS acos
#define TAN tan
#define ATAN atan
#define ATAN2 atan2
#define SQRT sqrt
#endif


@interface MapHelper : NSObject
{

}

//Using this site for reference
//http://www.movable-type.co.uk/scripts/latlong.html
+(CLLocationCoordinate2D) GetRadiusPoint:(CLLocationCoordinate2D)val :(MAPHELPER_PRECISION)distanceInKM :(MAPHELPER_PRECISION)bearingAngle;
+(CLLocationCoordinate2D) GetRadiusPoint:(CLLocationCoordinate2D)val :(MAPHELPER_PRECISION)distanceInKM;

+(MAPHELPER_PRECISION) GetDistanceBetweenTwoPoints:(CLLocationCoordinate2D)p1 :(CLLocationCoordinate2D)p2;


@end
