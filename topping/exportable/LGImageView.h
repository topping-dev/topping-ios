#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LGView.h"
#import "LuaContext.h"
#import "LuaStream.h"
#import "LuaRef.h"

@protocol TIOSKHTImageView;

@interface LGImageView : LGView <TIOSKHTImageView>
{
}

//Lua
+(LGImageView*)create:(LuaContext *)context :(NSString*)lid;
-(void)setImage:(LuaStream *)stream;
-(void)setImageRef:(LuaRef *)ref;

@property(nonatomic, retain) NSString *android_adjustViewBounds;
@property(nonatomic, retain) NSString *android_baselineAlignBottom;
@property(nonatomic, retain) NSString *android_cropToPadding;
@property(nonatomic, retain) NSString *android_maxHeight;
@property(nonatomic, retain) NSString *android_maxWidth;
@property(nonatomic, retain) NSString *android_scaleType;
@property(nonatomic, retain) NSString *android_src;

@property(nonatomic, retain) UIImage *orgImage;
@property(nonatomic, retain) NSObject *ldr;

@end
