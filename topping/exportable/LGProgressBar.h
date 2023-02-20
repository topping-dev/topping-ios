#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LGView.h"

@interface LGProgressBar : LGView
{
}

//Lua
+(LGProgressBar*)create:(LuaContext *)context;
-(void)setProgress:(int)progress;
-(void)setMax:(int)max;
-(void)setIndeterminate:(bool)val;

@property(nonatomic, retain) NSString *android_animationResolution;
@property(nonatomic, retain) NSString *android_indeterminate;
@property(nonatomic, retain) NSString *android_indeterminateBehavior;
@property(nonatomic, retain) NSString *android_indeterminateDrawable;
@property(nonatomic, retain) NSString *android_indeterminateDuration;
@property(nonatomic, retain) NSString *android_max;
@property(nonatomic, retain) NSString *android_maxHeight;
@property(nonatomic, retain) NSString *android_maxWidth;
@property(nonatomic, retain) NSString *android_progress;
@property(nonatomic, retain) NSString *android_progressDrawable;
@property(nonatomic, retain) NSString *android_secondaryProgress;
@property(nonatomic, retain) NSString *iosHorizontalProgress;
@property(nonatomic, retain) NSString *iosDarkProgress;
@property(nonatomic, retain) NSString *iosSmallProgress;

@property(nonatomic) BOOL horizontal;
@property(nonatomic) int maxProgress;

@end
