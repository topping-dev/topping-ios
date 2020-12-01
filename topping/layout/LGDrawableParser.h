#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class GDataXMLElement;

@interface LGDrawableReturn : NSObject
{
};

@property(nonatomic, retain) UIImage *img;
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
-(LGDrawableReturn*) ParseDrawable:(NSString *)drawable;
-(LGDrawableReturn*) ParseDrawable:(NSString *)drawable :(int)tileMode;
-(LGDrawableReturn*) ParseXML:(NSString *)filename;
-(LGDrawableReturn*) ParseBitmap:(GDataXMLElement*)root;
-(LGDrawableReturn*) ParseLayer:(GDataXMLElement *)root;
-(LGDrawableReturn*) ParseStateList:(GDataXMLElement *)root;
-(LGDrawableReturn*) ParseShape:(GDataXMLElement *)root;

-(CGPoint) radialIntersectionWithDegrees:(CGFloat)degrees :(CGRect)frame;
-(CGPoint) radialIntersectionWithRadians:(CGFloat)radians :(CGRect)frame;
-(CGPoint) radialIntersectionWithConstrainedRadians:(CGFloat)radians :(CGRect)frame;

@property (nonatomic, retain) NSMutableDictionary *stateListDictionary;
@property (nonatomic, retain) NSMutableArray *clearedDirectoryList;

@end
