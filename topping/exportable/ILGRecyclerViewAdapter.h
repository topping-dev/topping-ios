#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LuaClass.h"
#import "LuaInterface.h"
#import "LuaTranslator.h"

@interface ILGRecyclerViewAdapter : NSObject <LuaClass, LuaInterface>
{
}

+(ILGRecyclerViewAdapter*)create;

@property (nonatomic, retain) LuaTranslator *ltGetItemCount;
@property (nonatomic, retain) LuaTranslator *ltOnCreateViewHolder;
@property (nonatomic, retain) LuaTranslator *ltOnBindViewHolder;
@property (nonatomic, retain) LuaTranslator *ltGetItemViewType;
@property (nonatomic, retain) LuaTranslator *ltOnItemSelected;

@end
