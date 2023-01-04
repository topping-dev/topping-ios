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

-(UIImage*)GetImage:(CGSize)size;

@property(nonatomic, retain) UIImage *img;
@property(nonatomic, retain) NSObject *vector;
@property(nonatomic, retain) UIColor *color;
@property(nonatomic, retain) NSString *state;
@property(nonatomic) BOOL tile;

@end

typedef NS_OPTIONS(NSUInteger, UIControlStateExtra) {
    UIControlStateCheckable             = 1 << 3,
    UIControlStateChecked               = 1 << 4,
    UIControlStateActivated             = 1 << 5,
    UIControlStateWindowFocused         = 1 << 6,
};

@interface LGDrawableParser : NSObject 
{
}

+(LGDrawableParser*) GetInstance;
-(void)Initialize;
-(LGDrawableReturn*) ParseDrawableRef:(LuaRef *)drawable;
-(LGDrawableReturn*) ParseDrawableRef:(LuaRef *)drawable :(int)tileMode;
-(LGDrawableReturn*) ParseDrawable:(NSString *)drawable;
-(LGDrawableReturn*) ParseDrawable:(NSString *)drawable :(int)tileMode;
-(LGDrawableReturn*) ParseXML:(NSString *)filename :(int)tileMode;
-(LGDrawableReturn*) ParseVector:(NSData*)data;
-(LGDrawableReturn*) ParseBitmap:(GDataXMLElement*)root;
-(LGDrawableReturn*) ParseLayer:(GDataXMLElement *)root;
-(LGDrawableReturn*) ParseStateList:(GDataXMLElement *)root;
-(LGDrawableReturn*) ParseShape:(GDataXMLElement *)root;

-(CGPoint) radialIntersectionWithDegrees:(CGFloat)degrees :(CGRect)frame;
-(CGPoint) radialIntersectionWithRadians:(CGFloat)radians :(CGRect)frame;
-(CGPoint) radialIntersectionWithConstrainedRadians:(CGFloat)radians :(CGRect)frame;
-(NSDictionary *)GetKeys;

@property (nonatomic, retain) NSMutableDictionary *stateListDictionary;
@property (nonatomic, retain) NSMutableArray *clearedDirectoryList;
@property (nonatomic, retain) NSMutableDictionary *drawableMap;

@end
