#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LuaClass.h"
#import "LuaInterface.h"

@interface LuaGraphics : NSObject<LuaClass, LuaInterface>
{

}

-(void)setPen:(int)r :(int)g :(int) b;
-(void)setPenEx:(int)r :(int)g :(int)b :(float)width;
-(void)setBrush:(int)type :(int)r :(int)g :(int)b;
-(void)setRectStore:(int)id :(int)x :(int)y :(int)width :(int)height;
-(void)drawEllipsePenRectCache;
-(void)drawEllipseRectCache:(int)r :(int)g :(int)b;
-(void)drawEllipseRectCacheEx:(int)r :(int)g :(int)b :(float)width;
-(void)drawEllipsePenCache:(int)x :(int)y :(int)width :(int)height;
-(void)drawEllipse:(int)r :(int)g :(int)b :(int)x :(int)y :(int)width :(int)height;
-(void)drawEllipseEx:(int)r :(int)g :(int)b :(float)penWidth :(int)x :(int)y :(int)width :(int)height;
-(void)drawCirclePenCache:(int)x :(int)y :(int)radius;
-(void)drawCircle:(int)r :(int)g :(int)b :(int)x :(int)y :(int)radius;
-(void)drawCircleEx:(int)r :(int)g :(int)b :(float)width :(int)x :(int)y :(int)radius;
-(void)drawIcon:(NSString*) i :(int)x :(int)y;
-(void)drawImage:(NSString*) i :(int)x :(int)y;
-(void)drawImageRectCacheEx:(NSString*) i :(int)srcX :(int)srcY :(int)srcWidth :(int)srcHeight :(int)rL :(int)gL :(int)bL :(int)rH :(int)gH :(int)bH;
-(void)drawImageRectCache:(NSString*) i;
-(void)drawImageEx:(NSString*) i :(int)x :(int)y :(int)srcX :(int)srcY :(int)srcWidth :(int)srcHeight;
-(void)drawLine:(int)r :(int)g :(int)b :(int)x1 :(int)y1 :(int)x2 :(int)y2;
-(void)drawLineEx:(int)r :(int)g :(int)b :(float)width :(int)x1 :(int)y1 :(int)x2 :(int)y2;
-(void)drawLinePenCache:(int)x1 :(int)y1 :(int)x2 :(int)y2;
-(void)drawLines:(int)r :(int)g :(int)b :(NSString*)points;
-(void)drawLinesEx:(int)r :(int)g :(int)b :(float)width :(NSString*)points;
-(void)drawLinesPenCache:(NSString*) points;
-(void)drawPolygon:(int)r :(int)g :(int)b :(NSString*)points;
-(void)drawPolygonEx:(int)r :(int)g :(int)b :(float)width :(NSString*)points;
-(void)drawPolygonPenCache:(NSString*) points;
-(void)drawRectangle:(int)r :(int)g :(int)b :(int)x :(int)y :(int)width :(int)height;
-(void)drawRectangleEx:(int)r :(int)g :(int)b :(float)widthP :(int)x :(int)y :(int)width :(int)height;
-(void)drawRectangleRectCache:(int)r :(int)g :(int)b;
-(void)drawRectangleRectCacheEx:(int)r :(int)g :(int)b :(float)width;
-(void)drawRectanglePenCache:(int)x :(int)y :(int)width :(int)height;
-(void)drawRectanglePenRectCache;
-(void)drawString:(NSString*) s :(NSString*)f :(float)size :(int)style :(float)x :(float)y :(int)valign :(int)halign :(int)flags;
-(void)fillEllipse:(int)x :(int)y :(int)width :(int)height;
-(void)fillPolygon:(NSString*) points;
-(void)fillRectangle:(int)x :(int)y :(int)width :(int)height;
-(void)fillRegion;
-(void)clear:(int)red :(int)green :(int)blue;
-(void)setClip:(int)x :(int)y :(int)width :(int)height;

@end
