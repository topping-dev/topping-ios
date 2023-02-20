#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LuaForm.h"

@class GDataXMLElement;
@class LGView;

@interface LGLayoutParser : NSObject
{
}

+(LGLayoutParser*) getInstance;
-(void)initialize;
-(LGView*) getViewFromName:(NSString*)name :(NSArray*)attrs :(LGView*)parent;
-(UIView*) parseRef:(LuaRef *)filename :(UIView*)parentView :(LGView*)parent :(LuaForm*)cont :(LGView **)lgview;
-(UIView*) parseData:(NSData*)data :(UIView*)parentView :(LGView*)parent :(LuaForm*)cont :(LGView **)lgview;
-(UIView*) parseXML:(NSString *)filename :(UIView*)parentView :(LGView*)parent :(LuaForm*)cont :(LGView **)lgview;
-(LGView*) parseUI:(NSString*)name :(UIView*)parentView :(LGView*)parent :(LuaForm*)cont :(NSArray *)attrs;
-(LGView*) parseChildXML:(LGView*)parent :(GDataXMLElement*)view;
-(UIView*) generateUIViewFromLGView:(LGView*)view :(UIView*)parentView :(LGView*)parent :(LuaForm*)cont;
-(void) applyOverrides:(LGView*)parent :(LGView*)lgview;
-(NSDictionary *)getKeys;

@property (nonatomic, retain) NSString* lastFileName;
@property (nonatomic, retain) NSMutableArray *clearedDirectoryList;
@property (nonatomic, retain) NSMutableDictionary *layoutMap;

@end
