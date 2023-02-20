#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UITextField (Util)

-(void)setTextAppearance:(NSString*)style;
-(void)setHintTextAppearance:(NSString *)style;

@end

@interface UITextView (Util)

-(void)setTextAppearance:(NSString*)style;

@end

@interface UILabel (Util)

-(void)setTextAppearance:(NSString*)style;

@end
