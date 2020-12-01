#import <Foundation/Foundation.h>
#ifdef KLIB
#import "BEMCheckBox.h"
#else
#import <BEMCheckBox/BEMCheckBox.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface BEMCheckBoxText : BEMCheckBox

@property (nonatomic, strong) UILabel *label;
@property (nonatomic) UIEdgeInsets checkboxTextInset;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic) BOOL textInit;

@end

NS_ASSUME_NONNULL_END
