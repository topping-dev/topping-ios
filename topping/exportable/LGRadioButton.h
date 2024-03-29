#include <UIKit/UIKit.h>
#include <Foundation/Foundation.h>
#import "LGCompoundButton.h"
#import "LuaTranslator.h"

@interface LGRadioButton : LGCompoundButton 
{

}

-(void)resizeSegmentsToFitTitles:(UISegmentedControl*)segCtrl;

+(LGRadioButton*)create:(LuaContext *)context;

@end
