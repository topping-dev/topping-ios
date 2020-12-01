#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "LGView.h"
#import "LuaColor.h"
#import "LuaMapCircle.h"
#import "LuaMapImage.h"
#import "LuaMapMarker.h"
#import "LuaMapPolygon.h"
#import "LuaMapPolyline.h"
#import "LuaPoint.h"

@interface LGMapView : LGView<MKMapViewDelegate,MKReverseGeocoderDelegate>
{
}

+(LGMapView*)Create:(LuaContext *)context :(NSString *)apiKey;
-(LuaMapCircle*)AddCircle:(LuaPoint*)geoLoc :(double)radius :(LuaColor*)strokeColor :(LuaColor*) fillColor;
-(LuaMapMarker*)AddMarker:(LuaPoint*)geoLoc :(NSString*)path :(NSString*)icon;
-(LuaMapMarker*)AddMarkerEx:(LuaPoint*)geoLoc :(NSString*)path :(NSString*)icon :(LuaPoint*)anchor;
-(LuaMapImage*)AddImage:(LuaPoint*)geoLoc :(NSString*)path :(NSString*)icon :(float)width;
-(LuaMapPolyline*)AddPolyline:(NSMutableDictionary*)points :(LuaColor*)color;
-(LuaMapPolygon*)AddPolygon:(NSMutableDictionary*)points :(LuaColor*)strokeColor :(LuaColor*)fillColor;

@property (nonatomic, retain) MKMapView *mapView;
@property (nonatomic, retain) NSMutableArray *annotationViewArr;
@property (nonatomic, retain) NSString *api_key;

@end
