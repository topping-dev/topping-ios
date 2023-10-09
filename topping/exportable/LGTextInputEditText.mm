#import "LGTextInputEditText.h"
#import "Defines.h"
#import <QuartzCore/QuartzCore.h>
#import "DisplayMetrics.h"
#import "LuaFunction.h"
#import "LGColorParser.h"
#import "LGDrawableParser.h"
#import "LGDimensionParser.h"
#import "LGStyleParser.h"
#import "LGValueParser.h"
#import "LGStringParser.h"
#import "LuaTranslator.h"
#import "MDCFilledTextField.h"
#import "MDCOutlinedTextField.h"
#import "TextField+Util.h"
#import "UIImage+Dropdown.h"

@implementation LGTextInputEditText

-(UIView*)createComponent
{
    self.multiLine = false;
    if(self.android_inputType != nil)
    {
        if(CONTAINS(self.android_inputType, @"textMultiLine"))
        {
            self.multiLine = true;
        }
    }
    
    if(self.editTextType == 0) {
        return [[MDCFilledTextField alloc] initWithFrame:CGRectMake(self.dX, self.dY, self.dWidth, self.dHeight)];
    } else {
        return [[MDCOutlinedTextField alloc] initWithFrame:CGRectMake(self.dX, self.dY, self.dWidth, self.dHeight)];
    }
}

-(void)setupComponent:(UIView *)view
{
    [super setupComponent:view];
    [self.layer removeFromSuperlayer];
    
    MDCBaseTextField *btf = (MDCBaseTextField*)self._view;
    btf.placeholder = @"";
    
    if(self.android_hint != nil) {
        btf.label.text = [[LGStringParser getInstance] getString:self.android_hint];
    }
    
    if(self.editTextType == 1) {
        MDCOutlinedTextField *otf = (MDCOutlinedTextField*)view;
        if(self.app_boxStrokeColor != nil) {
            LGColorState *lcs = [[LGColorParser getInstance] getColorState:self.app_boxStrokeColor];
            if(lcs != nil) {
                [otf setOutlineColor:[lcs getColorForState:UIControlStateNormal :[otf outlineColorForState:MDCTextControlStateNormal]] forState:MDCTextControlStateNormal];
                [otf setOutlineColor:[lcs getColorForState:UIControlStateFocused :[otf outlineColorForState:MDCTextControlStateEditing]] forState:MDCTextControlStateEditing];
                [otf setOutlineColor:[lcs getColorForState:UIControlStateDisabled :[otf outlineColorForState:MDCTextControlStateDisabled]] forState:MDCTextControlStateDisabled];
            }
            else {
                UIColor *color = [[LGColorParser getInstance] parseColor:self.app_boxStrokeColor];
                [otf setOutlineColor:color forState:MDCTextControlStateNormal];
                [otf setOutlineColor:color forState:MDCTextControlStateEditing];
                [otf setOutlineColor:color forState:MDCTextControlStateDisabled];
            }
        }
        if(self.app_boxStrokeWidth != nil) {
            [otf setOutlineWidth:[[LGDimensionParser getInstance] getDimension:self.app_boxStrokeWidth] forState:MDCTextControlStateNormal];
        }
        if(self.app_boxStrokeWidthFocused != nil) {
            [otf setOutlineWidth:[[LGDimensionParser getInstance] getDimension:self.app_boxStrokeWidthFocused] forState:MDCTextControlStateEditing];
        }
    }
    if(self.app_hintTextAppearance != nil) {
        [btf.label setTextAppearance:self.app_hintTextAppearance];
    }
    if(self.app_hintTextColor != nil) {
        UIColor *color = [[LGColorParser getInstance] parseColor:self.app_hintTextColor];
        btf.label.attributedText = [[NSAttributedString alloc] initWithString:btf.placeholder attributes:@{NSForegroundColorAttributeName: color}];
    }
    if(self.app_startIconDrawable != nil) {
        LGDrawableReturn *ldr = [[LGDrawableParser getInstance] parseDrawable:self.app_startIconDrawable];
        if(ldr.img != nil) {
            UIImage *image = [ldr.img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            btf.leadingView = [[UIImageView alloc] initWithImage:image];
            if(self.app_startIconTint != nil) {
                UIColor *color = [[LGColorParser getInstance] parseColor:self.app_startIconTint];
                [btf.leadingView setTintColor:color];
            }
            if(self.app_startIconCheckable != nil) {
                //TODO
            }
        }
    }
    if(self.app_endIconDrawable != nil) {
        LGDrawableReturn *ldr = [[LGDrawableParser getInstance] parseDrawable:self.app_endIconDrawable];
        if(ldr.img != nil) {
            UIImage *image = [ldr.img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            btf.leadingView = [[UIImageView alloc] initWithImage:image];
            if(self.app_endIconTint != nil) {
                UIColor *color = [[LGColorParser getInstance] parseColor:self.app_endIconTint];
                [btf.leadingView setTintColor:color];
            }
            if(self.app_endIconCheckable != nil) {
                //TODO
            }
        }
    }
    if(self.app_helperTextEnabled != nil && [self.app_helperTextEnabled isEqualToString:@"true"]) {
        if(self.app_helperText != nil) {
            btf.leadingAssistiveLabel.text = [[LGStringParser getInstance] getString:self.app_helperText];
        }
        if(self.app_helperTextColor != nil) {
            UIColor *color = [[LGColorParser getInstance] parseColor:self.app_helperTextColor];
            btf.leadingAssistiveLabel.textColor = color;
        }
        if(self.app_helperTextAppearance != nil) {
            [btf.leadingAssistiveLabel setTextAppearance:self.app_helperTextAppearance];
        }
    }
    
    if([self.parentStyle containsString:@"ExposedDropdownMenu"]) {
        self.downArrow = [UIImage downArrow];
        self.upArrow = [UIImage upArrow];
        btf.trailingView = [[UIImageView alloc] initWithImage:self.downArrow];
        btf.trailingView.frame = CGRectMake(0, 0, 20, 20);
        btf.trailingViewMode = UITextFieldViewModeAlways;
        
        [btf addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapDropdown)]];
    }
    
    //@property(nonatomic, strong) NSString *app_endIconMode;
}

-(void)onTapDropdown
{
    if(self.ltOnDropdownClickListener != nil) {
        if(!self.isOpen) {
            [self.ltOnDropdownClickListener call];
        }
        self.isOpen = !self.isOpen;
    }
}

-(int)getContentW
{
    int l = [self getStringSize].width + self.dPaddingLeft + self.dPaddingRight + self.insets.left + self.insets.right;
    if (l > [DisplayMetrics getBaseFrame].size.width)
        l = [DisplayMetrics getBaseFrame].size.width - self.dX;
    return l;
}

-(int)getContentH
{
    MDCBaseTextField *btf = (MDCBaseTextField*)self._view;
    if(btf == nil)
        return 30;
    else
    {
        [btf sizeToFit];
        return btf.frame.size.height;
    }
}

-(IBAction)onClickReturn:(id)sender
{
    [sender resignFirstResponder];
}

-(void)onTouchOutside:(UITapGestureRecognizer*)gesture
{
    @try
    {
        gesture.cancelsTouchesInView = NO;
        if(gesture.state == UIGestureRecognizerStateEnded)
        {
            if(self.selectedKeyboardTextField != nil)
                [self.selectedKeyboardTextField resignFirstResponder];
            if(self.selectedKeyboardTextView != nil)
                [self.selectedKeyboardTextView resignFirstResponder];
            gesture.cancelsTouchesInView = NO;
        }
    }
    @catch(NSException *ex)
    {
    }
}

-(void)resize {
    [super resize];
    
    self.layer.frame = CGRectMake(0, self._view.frame.size.height - 1, self._view.frame.size.width, 1);
}

-(void)setViewMovedUp:(BOOL)movedUp :(NSNotification*)notif
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];

    CGRect rect = self._view.frame;
    CGRect t = CGRectMake(0, 0, 0, self.moveDifference);
    if (movedUp)
    {
        rect.origin.y -= t.size.height;
        rect.size.height += t.size.height;
    }
    else
    {
        rect.origin.y += t.size.height;
        rect.size.height -= t.size.height;
    }
    self._view.frame = rect;
       
    [UIView commitAnimations];
}

- (void)keyboardWillShow:(NSNotification *)notif
{
    CGRect t;
    [((NSValue*)[notif.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey]) getValue:&t];
    t = [self._view convertRect:t toView:nil];
       
    if(self.selectedKeyboardTextField != nil)
    {
        int screenY = self.selectedKeyboardTextField.frame.origin.y;
           
        if([self._view isKindOfClass:[UIScrollView class]])
        {
            screenY = self.selectedKeyboardTextField.frame.origin.y + self._view.frame.origin.y - ((UIScrollView *)self._view).contentOffset.y;
               
                int screenHeight = self._view.frame.size.height;
                    int visibleScreenHeight = screenHeight - t.size.width;
                       
                        if(screenY > visibleScreenHeight)
                        {
                            self.moveDifference = screenY - visibleScreenHeight + self.selectedKeyboardTextField.frame.size.height;
                                [self setViewMovedUp:YES:notif];
                                    self.movedUpField = YES;
                        }
        }
        else
        {
            screenY = self.selectedKeyboardTextField.frame.origin.y + self._view.frame.origin.y;
               
            int screenHeight = self._view.frame.size.height;
            int visibleScreenHeight = screenHeight - t.size.width;
                   
            if(screenY > visibleScreenHeight)
            {
                self.moveDifference = screenY - visibleScreenHeight + self.selectedKeyboardTextField.frame.size.height;
                    [self setViewMovedUp:YES:notif];
                        self.movedUpField = YES;
            }
        }
    }
    else
    {
        int screenY = self.selectedKeyboardTextView.frame.origin.y;
           
        if([self._view isKindOfClass:[UIScrollView class]])
        {
            screenY = self.selectedKeyboardTextView.frame.origin.y + self._view.frame.origin.y - ((UIScrollView *)self._view).contentOffset.y;
               
            int screenHeight = self._view.frame.size.height;
            int visibleScreenHeight = screenHeight - t.size.width;
                   
            if(screenY > visibleScreenHeight)
            {
                self.moveDifference = screenY - visibleScreenHeight + self.selectedKeyboardTextView.frame.size.height;
                    [self setViewMovedUp:YES:notif];
                        self.movedUpField = YES;
            }
        }
        else
        {
            screenY = self.selectedKeyboardTextView.frame.origin.y + self._view.frame.origin.y;
               
            int screenHeight = self._view.frame.size.height;
            int visibleScreenHeight = screenHeight - t.size.width;
                   
            if(screenY > visibleScreenHeight)
            {
                self.moveDifference = screenY - visibleScreenHeight + self.selectedKeyboardTextView.frame.size.height;
                    [self setViewMovedUp:YES:notif];
                        self.movedUpField = YES;
            }
        }
    }
}

-(void)keyboardWillHide:(NSNotification *)notif
{
    if(self.movedUpField)
    {
        self.movedUpField = NO;
        [self setViewMovedUp:NO:notif];
        self.selectedKeyboardTextField = nil;
        self.selectedKeyboardTextView = nil;
    }
}

-(IBAction)editingBegin:(id)sender
{
    if(self.selectedKeyboardTextView != nil)
        [self keyboardWillHide:nil];
    self.selectedKeyboardTextView = nil;
    self.selectedKeyboardTextField = (UITextField*)sender;
}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if(self.selectedKeyboardTextField != nil)
        [self keyboardWillHide:nil];
    self.selectedKeyboardTextField = nil;
    self.selectedKeyboardTextView = textView;
    if(self.ltBeforeTextChangedListener != nil)
        [self.ltBeforeTextChangedListener callIn:textView.text];
    return textView.editable;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if(self.ltAfterTextChangedListener != nil)
        [self.ltAfterTextChangedListener callIn:textView.text];
}

-(void)textViewDidChange:(UITextView *)textView
{
    if(self.ltTextChangedListener != nil)
        [self.ltTextChangedListener callIn:textView.text];
}

//Lua
+(LGEditText*)create:(LuaContext *)context
{
	LGEditText *lst = [[LGEditText alloc] init];
    lst.lc = context;
	[lst initProperties];
	return lst;
}

-(NSString *)getText
{
    MDCBaseTextField *btf = (MDCBaseTextField*)self._view;
    return btf.text;
}

-(void)setTextInternal:(NSString *)val
{
    MDCBaseTextField *btf = (MDCBaseTextField*)self._view;
    btf.text = val;
    self.android_text = val;
    [self resizeOnText];
}

-(void)setText:(LuaRef *)ref
{
    NSString *val = (NSString*)[[LGValueParser getInstance] getValue:ref.idRef];
    [self setTextInternal:val];
}

-(void)setTextColor:(NSString *)color
{
    MDCBaseTextField *btf = (MDCBaseTextField*)self._view;
    [btf setTextColor:[[LGColorParser getInstance] parseColor:color]];
}

-(void)setTextColorRef:(LuaRef *)ref
{
    UIColor *val = (UIColor*)[[LGValueParser getInstance] getValue:ref.idRef];
    MDCBaseTextField *btf = (MDCBaseTextField*)self._view;
    btf.textColor = val;
}

-(void)setTextChangedListener:(LuaTranslator*)lt
{
    self.ltTextChangedListener = lt;
    MDCBaseTextField *btf = (MDCBaseTextField*)self._view;
    [btf addTarget:lt action:lt.selector forControlEvents:UIControlEventEditingChanged];
}

-(void)setBeforeTextChangedListener:(LuaTranslator*)lt
{
    self.ltBeforeTextChangedListener = lt;
    MDCBaseTextField *btf = (MDCBaseTextField*)self._view;
    [btf addTarget:lt action:lt.selector forControlEvents:UIControlEventEditingDidBegin];
}

-(void)setAfterTextChangedListener:(LuaTranslator*)lt
{
    self.ltAfterTextChangedListener = lt;
    MDCBaseTextField *btf = (MDCBaseTextField*)self._view;
    [btf addTarget:lt action:lt.selector forControlEvents:UIControlEventEditingDidEnd];
}

-(void)setOnDropdownClickListemer:(LuaTranslator*)lt
{
    self.ltOnDropdownClickListener = lt;
}

-(NSString*)GetId
{
    if(self.lua_id != nil)
        return self.lua_id;
    if(self.android_id != nil)
        return self.android_id;
    return [LGTextInputEditText className];
}

+ (NSString*)className
{
    return @"LGTextInputEditText";
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    ClassMethod(create:, LGTextInputEditText, @[[LuaContext class]], @"create", [LGTextInputEditText class])
    InstanceMethodNoRet(setOnDropdownClickListemer:, @[[LuaTranslator class]], @"setOnDropdownClickListener")
	return dict;
}

@end
