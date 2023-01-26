#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LuaClass.h"
#import "LuaInterface.h"

@class LuaForm;
@class LuaFragment;
@class LuaViewModel;
@class ViewModelProvider;

@interface LuaViewModelProvider : NSObject <LuaClass, LuaInterface>
{
}

+(LuaViewModelProvider*)ofForm:(LuaForm*)form;
+(LuaViewModelProvider*)ofFragment:(LuaFragment*)fragment;
- (instancetype)initWithViewModelProvider:(ViewModelProvider*)viewModelProvider;
-(LuaViewModel*)get:(NSString*)key;
-(void*)get:(NSString*)key ptr:(void*)ptr;

@property (nonatomic, retain) ViewModelProvider *viewModelProvider;

@end
