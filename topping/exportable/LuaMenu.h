#import <Foundation/Foundation.h>
#import "LuaClass.h"
#import "LuaInterface.h"
#import "LuaRef.h"

@interface LuaMenu : NSObject <LuaClass>

+(LuaMenu*)create;

-(void)setTitle:(NSString*)text;

-(void)setTitleRef:(LuaRef*)text;

-(void)setIcon:(LuaRef*)icon;

-(void)setIntent:(LuaTranslator*)lt;

@property (nonatomic, retain) NSString* idVal;
@property (nonatomic, retain) NSString* title_;
@property (nonatomic, retain) LuaRef* iconRes;

@end
