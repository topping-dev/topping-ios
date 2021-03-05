#import <Foundation/Foundation.h>
#ifdef KLIB
#import "BEMCheckBox.h"
#else
#import <BEMCheckBox/BEMCheckBox.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface BEMCheckBoxText : UILabel

@property (nonatomic, strong) BEMCheckBox *checkbox;
@property (nonatomic) UIEdgeInsets checkboxTextInset;
@property (nonatomic) BOOL textInit;
@property (nonatomic) CGSize checkboxSize;

@end

NS_ASSUME_NONNULL_END
