#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LuaRef.h"

@class GDataXMLElement;
@protocol ThemeProviding;
@protocol ResourceProviding;

@interface VectorTheme : NSObject <ThemeProviding, ResourceProviding>

- (instancetype)initWithColor:(UIColor*)color;

@property (nonatomic, retain) UIColor *color;

@end

@interface LGDrawableReturn : NSObject
{
};

-(UIImage*)getImage:(CGSize)size;
-(UIImage*)getImageForState:(CGSize)size :(int)state :(UIImage*)def;

@property(nonatomic, retain) UIImage *img;
@property(nonatomic, retain) NSObject *vector;
@property(nonatomic) BOOL tile;

@property(nonatomic) BOOL hasState;
@property(nonatomic) BOOL state_pressed;
@property(nonatomic) BOOL state_focused;
@property(nonatomic) BOOL state_hovered;
@property(nonatomic) BOOL state_selected;
@property(nonatomic) BOOL state_checkable;
@property(nonatomic) BOOL state_checked;
@property(nonatomic) BOOL state_enabled;
@property(nonatomic) BOOL state_activated;
@property(nonatomic) BOOL state_window_focused;

@end

@interface LGDrawableParser : NSObject 
{
}

+(LGDrawableParser*) getInstance;
-(void)initialize;
-(LGDrawableReturn*) parseDrawableRef:(LuaRef *)drawable;
-(LGDrawableReturn*) parseDrawableRef:(LuaRef *)drawable :(int)tileMode;
-(LGDrawableReturn*) parseDrawable:(NSString *)drawable;
-(LGDrawableReturn*) parseDrawable:(NSString *)drawable :(int)tileMode;
-(LGDrawableReturn*) parseXML:(NSString *)filename :(int)tileMode;
-(LGDrawableReturn*) parseVector:(NSData*)data;
-(LGDrawableReturn*) parseBitmap:(GDataXMLElement*)root;
-(LGDrawableReturn*) parseLayer:(GDataXMLElement *)root;
-(LGDrawableReturn*) parseStateList:(GDataXMLElement *)root;
-(LGDrawableReturn*) parseShape:(GDataXMLElement *)root;

-(CGPoint) radialIntersectionWithDegrees:(CGFloat)degrees :(CGRect)frame;
-(CGPoint) radialIntersectionWithRadians:(CGFloat)radians :(CGRect)frame;
-(CGPoint) radialIntersectionWithConstrainedRadians:(CGFloat)radians :(CGRect)frame;
-(NSDictionary *)getKeys;

@property (nonatomic, retain) NSMutableDictionary *stateListDictionary;
@property (nonatomic, retain) NSMutableArray *clearedDirectoryList;
@property (nonatomic, retain) NSMutableDictionary *drawableMap;

@end
