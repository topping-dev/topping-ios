#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LuaInterface.h"
#import "LuaClass.h"
#import "LuaColor.h"
#import "LuaContext.h"
#import "LuaPoint.h"
#import "PointAnnotation.h"
#import "PointAnnotationView.h"

@interface LuaMapImage : PointAnnotation<LuaClass, LuaInterface>
{
}

-(void)SetBearing:(float)bearing;
-(void)SetDimensions:(float)dimensions;
-(void)SetDimensionsEx:(float)width :(float)height;
-(void)SetPosition:(LuaPoint*) point;
-(void)SetPositionEx:(float)x :(float)y;
-(void)SetTransparency:(float)transparency;
-(void)SetVisible:(bool)value;
-(void)SetZIndex:(float)index;

@property(nonatomic, retain) PointAnnotation *image;
@property(nonatomic, retain) NSString *path, *name;
@property(nonatomic, retain) PointAnnotationView *view;

@end
