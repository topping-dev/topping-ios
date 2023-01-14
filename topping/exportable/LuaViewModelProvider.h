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

+(LuaViewModelProvider*)OfForm:(LuaForm*)form;
+(LuaViewModelProvider*)OfFragment:(LuaFragment*)fragment;
- (instancetype)initWithViewModelProvider:(ViewModelProvider*)viewModelProvider;
-(LuaViewModel*)Get:(NSString*)key;
-(void*)Get:(NSString*)key ptr:(void*)ptr;

@property (nonatomic, retain) ViewModelProvider *viewModelProvider;

@end
