#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LuaForm.h"

@class GDataXMLElement;
@class LGView;

@interface LGLayoutParser : NSObject
{
}

+(LGLayoutParser*) GetInstance;
-(void)Initialize;
-(LGView*) GetViewFromName:(NSString*)name :(NSArray*)attrs;
-(UIView*) ParseXML:(NSString *)filename :(UIView*)parentView :(LGView*)parent :(LuaForm*)cont :(LGView **)lgview;
-(LGView*) ParseUI:(NSString*)name :(UIView*)parentView :(LGView*)parent :(LuaForm*)cont :(NSArray *)attrs;
-(LGView*) ParseChildXML:(LGView*)view :(GDataXMLElement*)parent;
-(UIView*) GenerateUIViewFromLGView:(LGView*)view :(UIView*)parentView :(LGView*)parent :(LuaForm*)cont;

@property (nonatomic, retain) NSString* lastFileName;
@property (nonatomic, retain) NSMutableArray *clearedDirectoryList;

@end
