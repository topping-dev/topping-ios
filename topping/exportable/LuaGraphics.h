#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LuaClass.h"
#import "LuaInterface.h"

@interface LuaGraphics : NSObject<LuaClass, LuaInterface>
{

}

-(void)SetPen:(int)r :(int)g :(int) b;
-(void)SetPenEx:(int)r :(int)g :(int)b :(float)width;
-(void)SetBrush:(int)type :(int)r :(int)g :(int)b;
-(void)SetRectStore:(int)id :(int)x :(int)y :(int)width :(int)height;
-(void)DrawEllipsePenRectCache;
-(void)DrawEllipseRectCache:(int)r :(int)g :(int)b;
-(void)DrawEllipseRectCacheEx:(int)r :(int)g :(int)b :(float)width;
-(void)DrawEllipsePenCache:(int)x :(int)y :(int)width :(int)height;
-(void)DrawEllipse:(int)r :(int)g :(int)b :(int)x :(int)y :(int)width :(int)height;
-(void)DrawEllipseEx:(int)r :(int)g :(int)b :(float)penWidth :(int)x :(int)y :(int)width :(int)height;
-(void)DrawCirclePenCache:(int)x :(int)y :(int)radius;
-(void)DrawCircle:(int)r :(int)g :(int)b :(int)x :(int)y :(int)radius;
-(void)DrawCircleEx:(int)r :(int)g :(int)b :(float)width :(int)x :(int)y :(int)radius;
-(void)DrawIcon:(NSString*) i :(int)x :(int)y;
-(void)DrawImage:(NSString*) i :(int)x :(int)y;
-(void)DrawImageRectCacheEx:(NSString*) i :(int)srcX :(int)srcY :(int)srcWidth :(int)srcHeight :(int)rL :(int)gL :(int)bL :(int)rH :(int)gH :(int)bH;
-(void)DrawImageRectCache:(NSString*) i;
-(void)DrawImageEx:(NSString*) i :(int)x :(int)y :(int)srcX :(int)srcY :(int)srcWidth :(int)srcHeight;
-(void)DrawLine:(int)r :(int)g :(int)b :(int)x1 :(int)y1 :(int)x2 :(int)y2;
-(void)DrawLineEx:(int)r :(int)g :(int)b :(float)width :(int)x1 :(int)y1 :(int)x2 :(int)y2;
-(void)DrawLinePenCache:(int)x1 :(int)y1 :(int)x2 :(int)y2;
-(void)DrawLines:(int)r :(int)g :(int)b :(NSString*)points;
-(void)DrawLinesEx:(int)r :(int)g :(int)b :(float)width :(NSString*)points;
-(void)DrawLinesPenCache:(NSString*) points;
-(void)DrawPolygon:(int)r :(int)g :(int)b :(NSString*)points;
-(void)DrawPolygonEx:(int)r :(int)g :(int)b :(float)width :(NSString*)points;
-(void)DrawPolygonPenCache:(NSString*) points;
-(void)DrawRectangle:(int)r :(int)g :(int)b :(int)x :(int)y :(int)width :(int)height;
-(void)DrawRectangleEx:(int)r :(int)g :(int)b :(float)widthP :(int)x :(int)y :(int)width :(int)height;
-(void)DrawRectangleRectCache:(int)r :(int)g :(int)b;
-(void)DrawRectangleRectCacheEx:(int)r :(int)g :(int)b :(float)width;
-(void)DrawRectanglePenCache:(int)x :(int)y :(int)width :(int)height;
-(void)DrawRectanglePenRectCache;
-(void)DrawString:(NSString*) s :(NSString*)f :(float)size :(int)style :(float)x :(float)y :(int)valign :(int)halign :(int)flags;
-(void)FillEllipse:(int)x :(int)y :(int)width :(int)height;
-(void)FillPolygon:(NSString*) points;
-(void)FillRectangle:(int)x :(int)y :(int)width :(int)height;
-(void)FillRegion;
-(void)Clear:(int)red :(int)green :(int)blue;
-(void)SetClip:(int)x :(int)y :(int)width :(int)height;

@end
