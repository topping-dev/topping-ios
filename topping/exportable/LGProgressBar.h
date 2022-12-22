#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LGView.h"

@interface LGProgressBar : LGView
{
}

//Lua
+(LGProgressBar*)Create:(LuaContext *)context;
-(void)SetProgress:(int)progress;
-(void)SetMax:(int)max;
-(void)SetIndeterminate:(bool)val;

@property(nonatomic, retain) NSNumber *android_animationResolution;
@property(nonatomic, retain) NSNumber *android_indeterminate;
@property(nonatomic, retain) NSNumber *android_indeterminateBehavior;
@property(nonatomic, retain) NSString *android_indeterminateDrawable;
@property(nonatomic, retain) NSNumber *android_indeterminateDuration;
@property(nonatomic, retain) NSNumber *android_max;
@property(nonatomic, retain) NSString *android_maxHeight;
@property(nonatomic, retain) NSString *android_maxWidth;
@property(nonatomic, retain) NSNumber *android_progress;
@property(nonatomic, retain) NSString *android_progressDrawable;
@property(nonatomic, retain) NSNumber *android_secondaryProgress;
@property(nonatomic, retain) NSNumber *iosHorizontalProgress;
@property(nonatomic, retain) NSNumber *iosDarkProgress;
@property(nonatomic, retain) NSNumber *iosSmallProgress;

@property(nonatomic) BOOL horizontal;
@property(nonatomic) int maxProgress;

@end
