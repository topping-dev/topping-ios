#import "LGMapView.h"
#import "Defines.h"
#import "MapHelper.h"
#import "LuaResource.h"

@implementation LGMapView

-(void)InitProperties
{
	[super InitProperties];
}

-(UIView*)CreateComponent
{
    self.mapView = [[MKMapView alloc] init];
    self.mapView.frame = CGRectMake(self.dX, self.dY, self.dWidth, self.dHeight);
    return self.mapView;
}

+(LGMapView*)Create:(LuaContext *)context :(NSString *)apiKey
{
    LGMapView* view = [[LGMapView alloc] init];
    view.api_key = apiKey;
    return view;
}

-(LuaMapCircle*)AddCircle:(LuaPoint*)geoLoc :(double)radius :(LuaColor*)strokeColor :(LuaColor*) fillColor
{
    CLLocationCoordinate2D centerCoord;
    centerCoord.latitude = [geoLoc GetX];
    centerCoord.longitude = [geoLoc GetY];
    CLLocationCoordinate2D radiusPoint = [MapHelper GetRadiusPoint:centerCoord :radius / 100];
    LuaMapCircle * lmc = [LuaMapCircle circleWithCenterCoordinate:centerCoord radiusCoordinate:radiusPoint mapView:self.mapView];
    [lmc SetCenter:geoLoc];
    [lmc SetRadius:radius];
    [lmc SetStrokeColor:strokeColor];
    [lmc SetFillColor:fillColor];
    [self.mapView addAnnotation:lmc];
    return lmc;
}

-(LuaMapMarker*)AddMarker:(LuaPoint*)geoLoc :(NSString*)path :(NSString*)icon
{
    CLLocationCoordinate2D centerCoord;
    centerCoord.latitude = [geoLoc GetX];
    centerCoord.longitude = [geoLoc GetY];
    LuaMapMarker *lmm = [[LuaMapMarker alloc] initWithCoordinate:centerCoord addressDictionary:nil];
    lmm.path = path;
    lmm.name = icon;
    [self.mapView addAnnotation:lmm];
    return lmm;
}

-(LuaMapMarker*)AddMarkerEx:(LuaPoint*)geoLoc :(NSString*)path :(NSString*)icon :(LuaPoint*)anchor
{
    CLLocationCoordinate2D centerCoord;
    centerCoord.latitude = [geoLoc GetX];
    centerCoord.longitude = [geoLoc GetY];
    LuaMapMarker *lmm = [[LuaMapMarker alloc] initWithCoordinate:centerCoord addressDictionary:nil];
    lmm.path = path;
    lmm.name = icon;
    CLLocationCoordinate2D anchorC;
    anchorC.latitude = [anchor GetX];
    anchorC.longitude = [anchor GetY];
    lmm.centerOffset = anchorC;
    [self.mapView addAnnotation:lmm];
    return lmm;
}

-(LuaMapImage*)AddImage:(LuaPoint*)geoLoc :(NSString*)path :(NSString*)icon :(float)width
{
    LuaMapImage *lmi = [[LuaMapImage alloc] init];
    CLLocationCoordinate2D centerCoord;
    centerCoord.latitude = [geoLoc GetX];
    centerCoord.longitude = [geoLoc GetY];
    lmi.image = [[PointAnnotation alloc] initWithCoordinate:centerCoord addressDictionary:nil];
    lmi.path = path;
    lmi.name = icon;
    [lmi SetDimensions:width];
    [self.mapView addAnnotation:lmi];
    return lmi;
}

-(LuaMapPolyline*)AddPolyline:(NSMutableDictionary*)points :(LuaColor*)color
{
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:[points count]];
    for(NSObject* key in points)
    {
        LuaPoint *point = [points objectForKey:key];
        CLLocationCoordinate2D value;
        value.latitude = [point GetX];
        value.longitude = [point GetY];
        NSValue *val = [NSValue valueWithBytes:&value objCType:@encode(CLLocationCoordinate2D)];
        [arr addObject:val];
    }
    LuaMapPolyline *lmp = [LuaMapPolyline polyWithCoordinatesArr:self.mapView :arr];
    [lmp SetColor:color];
    [self.mapView addAnnotation:lmp];
    return lmp;
}

-(LuaMapPolygon*)AddPolygon:(NSMutableDictionary*)points :(LuaColor*)strokeColor :(LuaColor*)fillColor
{
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:[points count]];
    for(NSObject* key in points)
    {
        LuaPoint *point = [points objectForKey:key];
        CLLocationCoordinate2D value;
        value.latitude = [point GetX];
        value.longitude = [point GetY];
        NSValue *val = [NSValue valueWithBytes:&value objCType:@encode(CLLocationCoordinate2D)];
        [arr addObject:val];
    }
    LuaMapPolygon *lmp = [LuaMapPolygon polyWithCoordinatesArr:self.mapView :arr];
    [lmp SetStrokeColor:strokeColor];
    [lmp SetFillColor:fillColor];
    [self.mapView addAnnotation:lmp];
    return lmp;
}


//Geocode delegate eventsz
- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error
{
	NSLog(@"Reverse Geocoder Error");
}

//Overlay events
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
	return NULL;
}

//Annotation Events
- (MKAnnotationView *)mapView:(MKMapView *)mapViewP viewForAnnotation:(id <MKAnnotation>)annotation
{
    MKAnnotationView *viewToRet;
    if([annotation isKindOfClass:[LuaMapCircle class]])
    {
        LuaMapCircle *ann = (LuaMapCircle*)annotation;
        ann.view = [[CircleAnnotationView alloc] initWithFrame:CGRectMake(0, 0, self.mapView.frame.size.width, self.mapView.frame.size.height)];
        //[routeView autorelease];
        ann.view.annotation = annotation;
        ann.view.mapView = self.mapView;
        
        ann.view.strokeColor = ann.strokeColor;
        ann.view.fillColor = ann.fillColor;
        ann.view.lineWidth = ann.lineWidth;
        viewToRet = ann.view;
    }
    else if([annotation isKindOfClass:[LuaMapImage class]])
    {
        LuaMapImage *ann = (LuaMapImage*)annotation;
        ann.view = [PointAnnotationView annotationViewWithAnnotation:ann reuseIdentifier:@"LuaMapCircle" mapView:self.mapView];
        ann.view.image = [UIImage imageWithData:[[LuaResource GetResource:ann.path :ann.name] GetData]];
		ann.view.canShowCallout = YES;
		ann.view.animatesDrop = NO;
		ann.view.draggable = ann.view.draggable;
		ann.view.centerOffset = CGPointMake(-ann.view.image.size.width / 4, ann.view.image.size.height / 2);
		
        viewToRet = ann.view;
    }
    else if([annotation isKindOfClass:[LuaMapMarker class]])
    {
        LuaMapMarker *ann = (LuaMapMarker*)annotation;
        ann.view = [PointAnnotationView annotationViewWithAnnotation:ann reuseIdentifier:@"LuaMapCircle" mapView:self.mapView];
        ann.view.image = [UIImage imageWithData:[[LuaResource GetResource:ann.path :ann.name] GetData]];
		ann.view.canShowCallout = YES;
		ann.view.animatesDrop = NO;
		ann.view.draggable = ann.view.draggable;
		ann.view.centerOffset = CGPointMake(-ann.view.image.size.width / 4, ann.view.image.size.height / 2);
		
        viewToRet = ann.view;
    }
    else if([annotation isKindOfClass:[LuaMapPolygon class]])
    {
        LuaMapPolygon *ann = (LuaMapPolygon*)annotation;
        ann.view = [[PolyAnnotationView alloc] initWithFrame:CGRectMake(0, 0, self.mapView.frame.size.width, self.mapView.frame.size.height)];
        //[routeView autorelease];
        ann.view.annotation = annotation;
        ann.view.mapView = self.mapView;
        
        ann.view.strokeColor = ann.strokeColor;
        ann.view.fillColor = ann.fillColor;
        ann.view.lineWidth = ann.lineWidth;
        
        viewToRet = ann.view;
    }
    else if([annotation isKindOfClass:[LuaMapPolyline class]])
    {
        LuaMapPolyline *ann = (LuaMapPolyline*)annotation;
        ann.view = [[PolyAnnotationView alloc] initWithFrame:CGRectMake(0, 0, self.mapView.frame.size.width, self.mapView.frame.size.height)];
        //[routeView autorelease];
        ann.view.annotation = annotation;
        ann.view.mapView = self.mapView;
        
        ann.view.strokeColor = ann.strokeColor;
        ann.view.lineWidth = ann.lineWidth;
        
        viewToRet = ann.view;
    }
    
    //Add to list
    if(self.annotationViewArr == nil)
        self.annotationViewArr = [NSMutableArray array];
    
    [self.annotationViewArr addObject:viewToRet];
    
    return viewToRet;
}

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    for(MKAnnotationView *annView in self.annotationViewArr)
    {
        [annView setNeedsDisplay];
        if([annView isKindOfClass:[CircleAnnotationView class]])
            [((CircleAnnotationView*)annView) regionChanged];
        else if([annView isKindOfClass:[PolyAnnotationView class]])
            [((PolyAnnotationView*)annView) regionChanged];     
    }
    [self.mapView setNeedsDisplay];
    if(self.mapView.region.span.longitudeDelta < 0.0034f
	   || self.mapView.region.span.latitudeDelta < 0.0026f)
	{
		MKCoordinateRegion region;
		MKCoordinateSpan span;
		span.latitudeDelta = 0.0017f;
		span.longitudeDelta = 0.0013f;
		region.span = span;
		region.center = self.mapView.region.center;
		
		[self.mapView setRegion:region];
	}
}

-(void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
	for(MKAnnotationView *annView in self.annotationViewArr)
    {
        [annView setNeedsDisplay];
        if([annView isKindOfClass:[CircleAnnotationView class]])
            [((CircleAnnotationView*)annView) regionChanged];
        else if([annView isKindOfClass:[PolyAnnotationView class]])
            [((PolyAnnotationView*)annView) regionChanged];
    }
    [self.mapView setNeedsDisplay];
}

-(NSString*)GetId
{
    if(self.lua_id != nil)
        return self.lua_id;
    if(self.android_id != nil)
        return self.android_id;
    if(self.android_tag != nil)
        return self.android_tag;
    return [LGMapView className];
}

+ (NSString*)className
{
	return @"LGMapView";
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	/*[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(RegisterEventFunction::))
									   :@selector(RegisterEventFunction::)
									   :nil
									   :[NSArray arrayWithObjects:[NSString class], [LuaTranslator class], nil]]
			 forKey:@"RegisterEventFunction"];
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(Create:))
										:@selector(Create:)
										:[LGTextView class]
										:[NSArray arrayWithObjects:[LuaContext class], [NSString class], nil]
										:[LGTextView class]]
			 forKey:@"Create"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetText:))
									   :@selector(SetText:)
									   :nil
									   :MakeArray([NSString class]C nil)]
			 forKey:@"SetText"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetTextColor:))
									   :@selector(SetTextColor:)
									   :nil
									   :MakeArray([NSString class]C nil)]
			 forKey:@"SetTextColor"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(GetText))
									   :@selector(GetText)
									   :[NSString class]
									   :MakeArray(nil)]
			 forKey:@"GetText"];*/
	return dict;
}

@end
