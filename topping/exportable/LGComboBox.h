#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LGEditText.h"
#import "LuaTranslator.h"

@interface ComboData : NSObject
{
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSObject *tag;

@end

@interface LGComboBox : LGEditText
{
}

+(LGComboBox*)Create:(LuaContext *)context;
-(void) AddItem:(NSString *)name :(NSObject *)value;
-(void) SetItems:(NSMutableDictionary *)values;
-(void) ShowCancel:(int)value;
-(NSString*) GetSelectedName;
-(NSObject*) GetSelectedTag;
-(void) SetSelected:(int)index;
-(void)SetOnComboChangedListener:(LuaTranslator*)lt;

@property(nonatomic) BOOL showCancel;
@property(nonatomic, strong) ComboData *selected;
@property(nonatomic, strong) NSMutableArray *comboArray;
@property(nonatomic, strong) LuaTranslator *ltCBoxValueChanged;

@end
