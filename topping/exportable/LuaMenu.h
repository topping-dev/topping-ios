#import <Foundation/Foundation.h>
#import "LuaClass.h"
#import "LuaInterface.h"
#import "LuaRef.h"

typedef NS_ENUM(NSInteger, CheckableBehavior) {
    CheckableBehaviorSingle,
    CheckableBehaviorAll,
    CheckableBehaviorNone
};

typedef NS_ENUM(NSInteger, ShowAsAction) {
    ShowAsActionIfRoom,
    ShowAsActionNever,
    ShowAsActionWithText,
    ShowAsActionAlways,
    ShowAsActionCollapseActionView
};

@interface LuaMenu : NSObject <LuaClass>

+(LuaMenu*)create:(LuaContext*)lc :(LuaRef*)idVal;

-(LuaRef*)getItemId;

-(void)setTitle:(NSString*)text;

-(void)setTitleRef:(LuaRef*)text;

-(void)setIcon:(LuaRef*)icon;

-(void)setIntent:(LuaTranslator*)lt;

@property (nonatomic) BOOL visible, enabled, checkable;
@property (nonatomic, retain) NSString* idVal;
@property (nonatomic, retain) NSString* title_;
@property (nonatomic, retain) LuaRef* iconRes;
@property (nonatomic) CheckableBehavior checkableBehavior;
@property (nonatomic) ShowAsAction showAsAction;
@property (nonatomic, retain) NSMutableArray *children;
@property (nonatomic, retain) LuaMenu *parent;

@end
