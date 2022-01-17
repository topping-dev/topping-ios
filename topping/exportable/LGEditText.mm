#import "LGEditText.h"
#import "Defines.h"
#import <QuartzCore/QuartzCore.h>
#import "DisplayMetrics.h"
#import "LuaFunction.h"
#import "LGColorParser.h"
#import "LGDimensionParser.h"
#import "LGValueParser.h"
#import "LuaTranslator.h"

@implementation LGEditText

-(void)InitProperties
{
    [super InitProperties];
    
    int val = [[LGDimensionParser GetInstance] GetDimension:@"1dp"];
    self.insets = UIEdgeInsetsMake(val, val * 2, val * 2, val / 2);

    self.fontSize = [UIFont labelFontSize];
}

-(UIView*)CreateComponent
{
    self.multiLine = false;
    if(self.android_inputType != nil)
    {
        if(CONTAINS(self.android_inputType, @"textMultiLine"))
        {
            self.multiLine = true;
        }
    }
    
    if(self.multiLine)
    {
        UITextView *field = [[UITextView alloc] init];
        field.frame = CGRectMake(self.dX, self.dY, self.dWidth, self.dHeight);
        field.text = self.android_text;
        //field.placeholder = self.hint;
        
        [field setAutocorrectionType:UITextAutocorrectionTypeNo];
        
        [KeyboardHelper KeyboardSetEventForTextView:field :self.cont];
        
        return field;
    }
    else
    {
        UITextField *field = [[UITextField alloc] init];
        field.frame = CGRectMake(self.dX, self.dY, self.dWidth, self.dHeight);
        field.text = self.android_text;
        field.placeholder = self.android_hint;
            
        [field setAutocorrectionType:UITextAutocorrectionTypeNo];
        
        [KeyboardHelper KeyboardSetEventForTextField:field :self.cont];
        
        return field;
    }
}

-(void)SetupComponent:(UIView *)view
{
    if(self.multiLine)
    {
        UITextView *tf = (UITextView*)self._view;
        tf.delegate = self;
        CALayer *layer = [[CALayer alloc] init];
        layer.backgroundColor = tf.textColor.CGColor;
        layer.frame = CGRectMake(0, tf.frame.size.height - 1, tf.frame.size.width, 1);
        [tf.layer addSublayer:layer];
        
        if(self.android_inputType != nil)
        {
            NSArray *arr = SPLIT(self.android_inputType, @"|");
            for(NSString *it in arr)
            {
                if(COMPARE(it, @"text"))
                {
                    tf.secureTextEntry = NO;
                }
                else if(COMPARE(it, @"textCapCharacters"))
                    tf.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
                else if(COMPARE(it, @"textCapWords"))
                    tf.autocapitalizationType = UITextAutocapitalizationTypeWords;
                else if(COMPARE(it, @"textCapSentences"))
                    tf.autocapitalizationType = UITextAutocapitalizationTypeSentences;
                else if(COMPARE(it, @"textAutoCorrect")
                        || COMPARE(it, @"textAutoComplete"))
                    tf.autocorrectionType = UITextAutocorrectionTypeYes;
                else if(COMPARE(it, @"textMultiLine"))
                {
                    //TODO: text needed to be initalized for this
                }
                else if(COMPARE(it, @"textNoSuggestions"))
                    tf.autocorrectionType = UITextAutocorrectionTypeNo;
                else if(COMPARE(it, @"textUri"))
                    tf.keyboardType = UIKeyboardTypeURL;
                else if(COMPARE(it, @"textEmailAddress")
                        || COMPARE(it, @"textEmailSubject"))
                    tf.keyboardType = UIKeyboardTypeEmailAddress;
                else if(COMPARE(it, @"textPersonName"))
                    tf.keyboardType = UIKeyboardTypeNamePhonePad;
                else if(COMPARE(it, @"textPostalAddress")
                        || COMPARE(it, @"textVisiblePassword")
                        || COMPARE(it, @"datetime")
                        || COMPARE(it, @"date")
                        || COMPARE(it, @"time"))
                    tf.keyboardType = UIKeyboardTypeDefault;
                else if(COMPARE(it, @"textPassword"))
                    tf.secureTextEntry = YES;
                else if(COMPARE(it, @"number")
                        || COMPARE(it, @"numberSigned"))
                    tf.keyboardType = UIKeyboardTypeNumberPad;
                else if(COMPARE(it, @"numberDecimal"))
                    tf.keyboardType = UIKeyboardTypeDecimalPad;
                else if(COMPARE(it, @"numberPassword"))
                {
                    tf.secureTextEntry = YES;
                    tf.keyboardType = UIKeyboardTypeNumberPad;
                }
                else if(COMPARE(it, @"phone"))
                    tf.keyboardType = UIKeyboardTypePhonePad;                
            }
        }
        
        if(self.colorAccent != nil)
            tf.textColor = [[LGColorParser GetInstance] ParseColor:self.colorAccent];
        if(self.android_textColor != nil)
            tf.textColor = [[LGColorParser GetInstance] ParseColor:self.android_textColor];

        if(self.android_textSize != nil)
            tf.font = [tf.font fontWithSize:[[LGDimensionParser GetInstance] GetDimension:self.android_textSize]];

        if(self.dGravity & GRAVITY_START)
            [tf setTextAlignment:NSTextAlignmentLeft];
        else if(self.dGravity & GRAVITY_END)
            [tf setTextAlignment:NSTextAlignmentRight];
        else if(self.dGravity & GRAVITY_CENTER)
            [tf setTextAlignment:NSTextAlignmentCenter];
    }
    else
    {
        UITextField *tf = (UITextField*)self._view;
        CALayer *layer = [[CALayer alloc] init];
        layer.backgroundColor = tf.textColor.CGColor;
        layer.frame = CGRectMake(0, tf.frame.size.height - 1, tf.frame.size.width, 1);
        [tf.layer addSublayer:layer];
        
        if(self.android_inputType != nil)
        {
            NSArray *arr = SPLIT(self.android_inputType, @"|");
            for(NSString *it in arr)
            {
                if(COMPARE(it, @"text"))
                {
                    tf.secureTextEntry = NO;
                }
                else if(COMPARE(it, @"textCapCharacters"))
                    tf.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
                else if(COMPARE(it, @"textCapWords"))
                    tf.autocapitalizationType = UITextAutocapitalizationTypeWords;
                else if(COMPARE(it, @"textCapSentences"))
                    tf.autocapitalizationType = UITextAutocapitalizationTypeSentences;
                else if(COMPARE(it, @"textAutoCorrect")
                        || COMPARE(it, @"textAutoComplete"))
                    tf.autocorrectionType = UITextAutocorrectionTypeYes;
                else if(COMPARE(it, @"textMultiLine"))
                {
                    //TODO: text needed to be initalized for this
                }
                else if(COMPARE(it, @"textNoSuggestions"))
                    tf.autocorrectionType = UITextAutocorrectionTypeNo;
                else if(COMPARE(it, @"textUri"))
                    tf.keyboardType = UIKeyboardTypeURL;
                else if(COMPARE(it, @"textEmailAddress")
                        || COMPARE(it, @"textEmailSubject"))
                    tf.keyboardType = UIKeyboardTypeEmailAddress;
                else if(COMPARE(it, @"textPersonName"))
                    tf.keyboardType = UIKeyboardTypeNamePhonePad;
                else if(COMPARE(it, @"textPostalAddress")
                        || COMPARE(it, @"textVisiblePassword")
                        || COMPARE(it, @"datetime")
                        || COMPARE(it, @"date")
                        || COMPARE(it, @"time"))
                    tf.keyboardType = UIKeyboardTypeDefault;
                else if(COMPARE(it, @"textPassword"))
                    tf.secureTextEntry = YES;
                else if(COMPARE(it, @"number")
                        || COMPARE(it, @"numberSigned"))
                    tf.keyboardType = UIKeyboardTypeNumberPad;
                else if(COMPARE(it, @"numberDecimal"))
                    tf.keyboardType = UIKeyboardTypeDecimalPad;
                else if(COMPARE(it, @"numberPassword"))
                {
                    tf.secureTextEntry = YES;
                    tf.keyboardType = UIKeyboardTypeNumberPad;
                }
                else if(COMPARE(it, @"phone"))
                    tf.keyboardType = UIKeyboardTypePhonePad;                
            }
            
            if(self.colorAccent != nil)
                tf.textColor = [[LGColorParser GetInstance] ParseColor:self.colorAccent];
            if(self.android_textColor != nil)
                tf.textColor = [[LGColorParser GetInstance] ParseColor:self.android_textColor];

            if(self.android_textSize != nil)
                tf.font = [tf.font fontWithSize:[[LGDimensionParser GetInstance] GetDimension:self.android_textSize]];

            if(self.dGravity & GRAVITY_START)
                [tf setTextAlignment:NSTextAlignmentLeft];
            else if(self.dGravity & GRAVITY_END)
                [tf setTextAlignment:NSTextAlignmentRight];
            else if(self.dGravity & GRAVITY_CENTER)
                [tf setTextAlignment:NSTextAlignmentCenter];
        }
    }
	
	[super SetupComponent:view];
}

-(int)GetContentW
{
    int l = [self GetStringSize].width + self.dPaddingLeft + self.dPaddingRight + self.insets.left + self.insets.right;
    if (l > [DisplayMetrics GetMasterView].frame.size.width)
        l = [DisplayMetrics GetMasterView].frame.size.width - self.dX;
    return l;
}

-(int)GetContentH
{
	CGSize textSize = [self GetStringSize];
    int th = textSize.height;
    NSMutableArray *texts = [self BuildLineBreaks:self.android_text];
    NSUInteger mult = texts.count;
    if(mult == 0)
        mult = 1;
    if(self.android_minLines != nil && [self.android_minLines intValue] > 0 && mult < [self.android_minLines intValue])
        mult = [self.android_minLines intValue];
        
    int h = (mult * th) + self.dPaddingTop + self.dPaddingBottom + self.insets.top + self.insets.bottom;
    return h;
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

-(void)setViewMovedUp:(BOOL)movedUp:(NSNotification*)notif
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
    [[notif.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&t];
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
        [self.ltBeforeTextChangedListener CallIn:textView.text];
    return textView.editable;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if(self.ltAfterTextChangedListener != nil)
        [self.ltAfterTextChangedListener CallIn:textView.text];
}

-(void)textViewDidChange:(UITextView *)textView
{
    if(self.ltTextChangedListener != nil)
        [self.ltTextChangedListener CallIn:textView.text];
}

//Lua
+(LGEditText*)Create:(LuaContext *)context
{
	LGEditText *lst = [[LGEditText alloc] init];
	[lst InitProperties];
	return lst;
}

-(NSString *)GetText
{
    if(self.multiLine)
    {
        UITextView *field = (UITextView*)self._view;
        return field.text;
    }
    else
    {
        UITextField *field = (UITextField*)self._view;
        return field.text;
    }
}

-(void)SetText:(NSString *)val
{
    if(self.multiLine)
    {
        UITextView *field = (UITextView*)self._view;
        [field setText:val];
    }
    else
    {
        UITextField *field = (UITextField*)self._view;
        [field setText:val];
    }
    self.android_text = val;
    [self ResizeOnText];
}

-(void)SetTextRef:(LuaRef *)ref
{
    NSString *val = (NSString*)[[LGValueParser GetInstance] GetValue:ref.idRef];
    [self SetText:val];
}

-(void)SetTextColor:(NSString *)color
{
    if(self.multiLine)
    {
        UITextView *field = (UITextView*)self._view;
        [field setTextColor:[[LGColorParser GetInstance] ParseColor:color]];
    }
    else
    {
        UITextField *field = (UITextField*)self._view;
        [field setTextColor:[[LGColorParser GetInstance] ParseColor:color]];
    }
}

-(void)SetTextColorRef:(LuaRef *)ref
{
    UIColor *val = (UIColor*)[[LGValueParser GetInstance] GetValue:ref.idRef];
    if(self.multiLine)
    {
        UITextView *field = (UITextView*)self._view;
        [field setTextColor:val];
    }
    else
    {
        UITextField *field = (UITextField*)self._view;
        [field setTextColor:val];
    }
}

-(void)SetTextChangedListener:(LuaTranslator*)lt
{
    self.ltTextChangedListener = lt;
    if(self.multiLine)
    {
    }
    else
    {
        UITextField *field = (UITextField*)self._view;
        [field addTarget:lt action:lt.selector forControlEvents:UIControlEventEditingChanged];
    }
}

-(void)SetBeforeTextChangedListener:(LuaTranslator*)lt
{
    self.ltBeforeTextChangedListener = lt;
    if(self.multiLine)
    {
    }
    else
    {
        UITextField *field = (UITextField*)self._view;
        [field addTarget:lt action:lt.selector forControlEvents:UIControlEventEditingDidBegin];
    }
}

-(void)SetAfterTextChangedListener:(LuaTranslator*)lt
{
    self.ltAfterTextChangedListener = lt;
    if(self.multiLine)
    {
        
    }
    else
    {
        UITextField *field = (UITextField*)self._view;
        [field addTarget:lt action:lt.selector forControlEvents:UIControlEventEditingDidEnd];
    }
}

-(NSString*)GetId
{
    if(self.lua_id != nil)
        return self.lua_id;
    if(self.android_id != nil)
        return self.android_id;
    if(self.android_tag != nil)
        return self.android_tag;
    return [LGEditText className];
}

+ (NSString*)className
{
	return @"LGEditText";
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(Create:)) 
										:@selector(Create:)
										:[LGEditText class]
										:[NSArray arrayWithObjects:[LuaContext class], [NSString class], nil] 
										:[LGEditText class]] 
			 forKey:@"Create"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetTextChangedListener:)) :@selector(SetTextChangedListener:) :[LGView class] :MakeArray([LuaTranslator class]C nil)] forKey:@"SetTextChangedListener"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetBeforeTextChangedListener:)) :@selector(SetBeforeTextChangedListener:) :[LGView class] :MakeArray([LuaTranslator class]C nil)] forKey:@"SetBeforeTextChangedListener"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetAfterTextChangedListener:)) :@selector(SetAfterTextChangedListener:) :[LGView class] :MakeArray([LuaTranslator class]C nil)] forKey:@"SetAfterTextChangedListener"];
	return dict;
}

@end
