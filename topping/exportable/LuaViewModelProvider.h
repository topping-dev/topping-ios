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
    NSMutableDictionary *viewModelStore;
}

+(LuaViewModelProvider*)OfForm:(LuaForm*)form;
+(LuaViewModelProvider*)OfFragment:(LuaFragment*)fragment;
- (instancetype)initWithViewModelProvider:(ViewModelProvider*)viewModelProvider;
-(LuaViewModel*)Get:(NSString*)tag;

@property (nonatomic, retain) ViewModelProvider *viewModelProvider;

@end
