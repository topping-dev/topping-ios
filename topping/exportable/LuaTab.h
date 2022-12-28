#import <Foundation/Foundation.h>
#import "LuaClass.h"
#import "LuaInterface.h"
#import "LuaRef.h"
#import "LuaStream.h"
#import "LGView.h"

@interface LuaTab : LGView <LuaClass>

+(LuaTab*)Create;

-(void)SetText:(NSString*)text;

-(void)SetTextRef:(LuaRef*)text;

-(void)SetIcon:(LuaRef*)icon;

-(void)SetIconStream:(LuaStream*)icon;

-(void)SetCustomView:(LGView*)view;

@property (nonatomic, retain) NSString* android_icon;
@property (nonatomic, retain) NSString* android_layout;
@property (nonatomic, retain) NSString* android_text;

@property(nonatomic, retain) UIBarItem* item;
@property(nonatomic, retain) LGView* customView;

@end
