#import <Foundation/Foundation.h>
#import "LuaClass.h"
#import "LuaInterface.h"
#import "LuaRef.h"

@interface LuaMenu : NSObject <LuaClass>

+(LuaMenu*)Create;

-(void)SetTitle:(NSString*)text;

-(void)SetTitleRef:(LuaRef*)text;

-(void)SetIcon:(LuaRef*)icon;

-(void)SetIntent:(LuaTranslator*)lt;

@property (nonatomic, retain) NSString* idVal;
@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) LuaRef* iconRes;

@end
