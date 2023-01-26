#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LGView.h"
#import "LuaContext.h"
#import "LuaStream.h"
#import "LuaRef.h"

@interface LGImageView : LGView 
{
}

//Lua
+(LGImageView*)create:(LuaContext *)context :(NSString*)lid;
-(void)setImage:(LuaStream *)stream;
-(void)setImageRef:(LuaRef *)ref;

@property(nonatomic, retain) NSNumber *android_adjustViewBounds;
@property(nonatomic, retain) NSNumber *android_baselineAlignBottom;
@property(nonatomic, retain) NSNumber *android_cropToPadding;
@property(nonatomic, retain) NSString *android_maxHeight;
@property(nonatomic, retain) NSString *android_maxWidth;
@property(nonatomic, retain) NSString *android_scaleType;
@property(nonatomic, retain) NSString *android_src;

@end
