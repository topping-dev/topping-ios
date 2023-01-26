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

+(LGComboBox*)create:(LuaContext *)context;
-(void) addItem:(NSString *)name :(NSObject *)value;
-(void) setItems:(NSMutableDictionary *)values;
-(void) showCancel:(int)value;
-(NSString*) getSelectedName;
-(NSObject*) getSelectedTag;
-(void) setSelectedIndex:(int)index;
-(void)setOnComboChangedListener:(LuaTranslator*)lt;

@property(nonatomic) BOOL showCancel;
@property(nonatomic, strong) ComboData *selected;
@property(nonatomic, strong) NSMutableArray *comboArray;
@property(nonatomic, strong) LuaTranslator *ltCBoxValueChanged;

@end
