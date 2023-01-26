#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LuaClass.h"
#import "LuaInterface.h"
#import "LuaContext.h"

@class LGView;
@class LGLayoutParser;
@class LuaRef;

@interface LuaViewInflator : NSObject <LuaClass, LuaInterface> 
{
	
}

+(NSObject*)create:(LuaContext*)lc;
+(LuaViewInflator *)from:(LGLayoutParser*)parser;
-(LGView*)parseFile:(NSString*)filename :(LGView*)parent;
-(LGView*)inflate:(LuaRef*)ref : (LGView*)parent;

@property (nonatomic, retain) LuaContext* context;

@end
