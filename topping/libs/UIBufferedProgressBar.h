#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define INDETERMINATE_BEHAVIOUR_REPEAT 1
#define INDETERMINATE_BEHAVIOUR_CYCLE 2

@interface UIBufferedProgressBar : UIProgressView
{
    int fillOffsetX;
    int fillOffsetTopY;
    int fillOffsetBottomY;
    bool useCustom;
    UIImage *backgroundImage;
    UIImage *progressImage;
    UIImage *secondaryProgressImage;
    
    BOOL indeterminate;
    int indeterminateBehaviour;
    double indeterminateCounter;
    double indeterminateDuration;
    BOOL indeterminateMoveRight;
    int progressValue;
    double secondaryProgress;
    int progressSecondValue;
    int progressMax;
}

-(void)SetBackgroundImage:(NSString *)str;
-(void)SetProgressImage:(NSString *)str;
-(void)SetSecondaryProgressImage:(NSString *)str;

@property(nonatomic) int fillOffsetX;
@property(nonatomic) int fillOffsetTopY;
@property(nonatomic) int fillOffsetBottomY;
@property(nonatomic) bool useCustom;
@property(nonatomic, retain) UIImage *backgroundImage;
@property(nonatomic, retain) UIImage *progressImage;
@property(nonatomic, retain) UIImage *secondaryProgressImage;
@property(nonatomic) BOOL indeterminate;
@property(nonatomic) int indeterminateBehaviour;
@property(nonatomic) double indeterminateDuration;
@property(nonatomic) int progressValue;
@property(nonatomic) double secondaryProgress;
@property(nonatomic) int progressSecondValue;
@property(nonatomic) int progressMax;

@end
