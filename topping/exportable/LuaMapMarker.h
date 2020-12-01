#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LuaInterface.h"
#import "LuaClass.h"
#import "LuaColor.h"
#import "LuaContext.h"
#import "LuaPoint.h"
#import "PointAnnotation.h"
#import "PointAnnotationView.h"

@interface LuaMapMarker : PointAnnotation<LuaClass, LuaInterface>
{
}

-(void)SetDraggable:(bool)draggableP;
-(void)SetPosition:(LuaPoint*)point;
-(void)SetPositionEx:(float)x :(float)y;
-(void)SetSnippet:(NSString*)value;
-(void)SetTitle:(NSString*)value;
-(void)SetVisible:(bool)value;

@property (nonatomic, retain) NSString *title, *snippet;
@property (nonatomic) bool draggable;
@property (nonatomic, retain) NSString *path, *name;
@property (nonatomic) CLLocationCoordinate2D centerOffset;
@property (nonatomic, retain) PointAnnotationView *view;

@end
