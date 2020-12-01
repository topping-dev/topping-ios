#import "Common.h"
#import "MapHelper.h"

@implementation MapHelper

+(CLLocationCoordinate2D) GetRadiusPoint:(CLLocationCoordinate2D)val :(MAPHELPER_PRECISION)distanceInKM :(MAPHELPER_PRECISION)bearingAngle
{
    bearingAngle = DEGREES_TO_RADIANS(bearingAngle);
    MAPHELPER_PRECISION lat2 = ASIN(sin(val.latitude) * COS(distanceInKM/RADIUS_OF_EARTH_KM) +
                       COS(val.latitude) * SIN(distanceInKM/RADIUS_OF_EARTH_KM) * COS(bearingAngle));
    MAPHELPER_PRECISION lon2 = val.longitude + ATAN2(sin(bearingAngle) * SIN(distanceInKM/RADIUS_OF_EARTH_KM) * COS(val.latitude),
                                        COS(distanceInKM/RADIUS_OF_EARTH_KM) - SIN(val.latitude) * SIN(lat2));
    
    CLLocationCoordinate2D retVal;
    retVal.latitude = lat2;
    retVal.longitude = lon2;
    
    return retVal;
}

+(CLLocationCoordinate2D) GetRadiusPoint:(CLLocationCoordinate2D)val :(MAPHELPER_PRECISION)distanceInKM
{
    MAPHELPER_PRECISION bearingAngle = DEGREES_TO_RADIANS(90);
    MAPHELPER_PRECISION radialDistance = distanceInKM/RADIUS_OF_EARTH_KM;
    MAPHELPER_PRECISION lat1 = DEGREES_TO_RADIANS(val.latitude);
    MAPHELPER_PRECISION lon1 = DEGREES_TO_RADIANS(val.longitude);
    MAPHELPER_PRECISION lat2 = ASIN((SIN(lat1) * COS(radialDistance)) +
                       (COS(lat1) * SIN(radialDistance) * COS(bearingAngle)));
    MAPHELPER_PRECISION lon2 = lon1 + ATAN2(SIN(bearingAngle) * SIN(radialDistance) * COS(lat1),
                                        COS(radialDistance) - SIN(lat1) * SIN(lat2));
    
    //lon2 = ((int)(lon2 + (3 * M_PI)))%((int)(2 * M_PI)) - M_PI;
    
    CLLocationCoordinate2D retVal;
    retVal.latitude = RADIANS_TO_DEGREES(lat2);
    retVal.longitude = RADIANS_TO_DEGREES(lon2);
    
    return retVal;
}

+(MAPHELPER_PRECISION) GetDistanceBetweenTwoPoints:(CLLocationCoordinate2D)p1 :(CLLocationCoordinate2D)p2
{
    MAPHELPER_PRECISION lat1 = DEGREES_TO_RADIANS(p1.latitude);
    MAPHELPER_PRECISION lon1 = DEGREES_TO_RADIANS(p1.longitude);
    MAPHELPER_PRECISION lat2 = DEGREES_TO_RADIANS(p2.latitude);
    MAPHELPER_PRECISION lon2 = DEGREES_TO_RADIANS(p2.longitude);
    MAPHELPER_PRECISION dLat = lat2 - lat1;
    MAPHELPER_PRECISION dLon = lon2 - lon1;
    
    MAPHELPER_PRECISION a = SIN(dLat/2) * SIN(dLat/2) +
    COS(lat1) * COS(lat2) *
    SIN(dLon/2) * SIN(dLon/2);
    MAPHELPER_PRECISION c = 2 * ATAN2(SQRT(a), SQRT(1-a));
    return (RADIUS_OF_EARTH_KM * c);
}

@end
