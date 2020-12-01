#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LGTextView.h"
#import "LuaTranslator.h"

@interface Data : NSObject
{
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSObject *tag;

@end

@interface LGComboBox : LGTextView
{
}

+(LGComboBox*)Create:(LuaContext *)context;
-(void) AddComboItem:(NSString *)name :(NSObject *)value;
-(void) ShowCancel:(int)value;
-(NSString*) GetSelectedName;
-(NSObject*) GetSelectedTag;
-(void) SetSelected:(int)index;
-(void)SetOnComboChangedListener:(LuaTranslator*)lt;

@property(nonatomic) BOOL showCancel;
@property(nonatomic, strong) Data *selected;
@property(nonatomic, strong) NSMutableArray *comboArray;
@property(nonatomic, strong) LuaTranslator *ltCBoxValueChanged;

@end
