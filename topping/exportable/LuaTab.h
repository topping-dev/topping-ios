#import <Foundation/Foundation.h>
#import "LuaClass.h"
#import "LuaInterface.h"
#import "LuaRef.h"
#import "LuaStream.h"
#import "LGView.h"

@interface LuaTab : LGView <LuaClass>

+(LuaTab*)create;

-(void)setText:(NSString*)text;

-(void)setTextRef:(LuaRef*)text;

-(void)setIcon:(LuaRef*)icon;

-(void)setIconStream:(LuaStream*)icon;

-(void)setCustomView:(LGView*)view;

@property (nonatomic, retain) NSString* android_icon;
@property (nonatomic, retain) NSString* android_layout;
@property (nonatomic, retain) NSString* android_text;

@property(nonatomic, retain) UIBarItem* item;
@property(nonatomic, retain) LGView* customView_;

@end
