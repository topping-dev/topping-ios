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
-(UIView*) ParseXML:(NSString *)filename :(UIView*)parentView :(LGView*)parent :(LuaForm*)cont :(LGView **)lgview;
-(LGView*) ParseChildXML:(LGView*)view :(GDataXMLElement*)parent;
-(UIView*) GenerateUIViewFromLGView:(LGView*)view :(UIView*)parentView :(LGView*)parent :(LuaForm*)cont;

@property (nonatomic, retain) NSString* lastFileName;
@property (nonatomic, retain) NSMutableArray *clearedDirectoryList;

@end
