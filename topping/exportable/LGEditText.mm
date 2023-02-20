#import "LGEditText.h"
#import "Defines.h"
#import <QuartzCore/QuartzCore.h>
#import "DisplayMetrics.h"
#import "LuaFunction.h"
#import "LGColorParser.h"
#import "LGDimensionParser.h"
#import "LGValueParser.h"
#import "LGStringParser.h"
#import "LuaTranslator.h"
#import "TextField+Util.h"

@implementation LGEditText

-(void)initProperties
{
    [super initProperties];
    
    int val = [[LGDimensionParser getInstance] getDimension:@"1dp"];
    self.insets = UIEdgeInsetsMake(val, val * 2, val * 2, val / 2);

    self.fontSize = [UIFont labelFontSize];
}

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
    
    if(self.multiLine)
    {
        UITextView *field = [[UITextView alloc] init];
        field.frame = CGRectMake(self.dX, self.dY, self.dWidth, self.dHeight);

        [field setAutocorrectionType:UITextAutocorrectionTypeNo];
        
        [KeyboardHelper KeyboardSetEventForTextView:field :self.cont];
        
        return field;
    }
    else
    {
        UITextField *field = [[UITextField alloc] init];
        field.frame = CGRectMake(self.dX, self.dY, self.dWidth, self.dHeight);
            
        [field setAutocorrectionType:UITextAutocorrectionTypeNo];
        
        [KeyboardHelper KeyboardSetEventForTextField:field :self.cont];
        
        return field;
    }
}

-(void)setupComponent:(UIView *)view
{
    if(self.multiLine)
    {
        UITextView *tf = (UITextView*)self._view;
        tf.delegate = self;
        self.layer = [[CALayer alloc] init];
        self.layer.backgroundColor = tf.textColor.CGColor;
        self.layer.frame = CGRectMake(0, tf.frame.size.height - 1, tf.frame.size.width, 1);
        [tf.layer addSublayer:self.layer];
        
        if(self.android_text != nil)
            tf.text = [[LGStringParser getInstance] getString:self.android_text];
        
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
            tf.textColor = [[LGColorParser getInstance] parseColor:self.colorAccent];
        if(self.android_textColor != nil)
            tf.textColor = [[LGColorParser getInstance] parseColor:self.android_textColor];

        if(self.android_textSize != nil)
            tf.font = [tf.font fontWithSize:[[LGDimensionParser getInstance] getDimension:self.android_textSize]];

        if(self.dGravity & GRAVITY_START)
            [tf setTextAlignment:NSTextAlignmentLeft];
        else if(self.dGravity & GRAVITY_END)
            [tf setTextAlignment:NSTextAlignmentRight];
        else if(self.dGravity & GRAVITY_CENTER)
            [tf setTextAlignment:NSTextAlignmentCenter];
        
        if(self.android_textAppearance != nil) {
            [tf setTextAppearance:self.android_textAppearance];
        }
    }
    else
    {
        UITextField *tf = (UITextField*)self._view;
        self.layer = [[CALayer alloc] init];
        self.layer.backgroundColor = tf.textColor.CGColor;
        self.layer.frame = CGRectMake(0, tf.frame.size.height - 1, tf.frame.size.width, 1);
        [tf.layer addSublayer:self.layer];
        
        if(self.android_text != nil)
            tf.text = [[LGStringParser getInstance] getString:self.android_text];
        if(self.android_hint != nil)
            tf.placeholder = [[LGStringParser getInstance] getString:self.android_hint];
        
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
                tf.textColor = [[LGColorParser getInstance] parseColor:self.colorAccent];
            if(self.android_textColor != nil)
                tf.textColor = [[LGColorParser getInstance] parseColor:self.android_textColor];

            if(self.android_textSize != nil)
                tf.font = [tf.font fontWithSize:[[LGDimensionParser getInstance] getDimension:self.android_textSize]];

            if(self.dGravity & GRAVITY_START)
                [tf setTextAlignment:NSTextAlignmentLeft];
            else if(self.dGravity & GRAVITY_END)
                [tf setTextAlignment:NSTextAlignmentRight];
            else if(self.dGravity & GRAVITY_CENTER)
                [tf setTextAlignment:NSTextAlignmentCenter];
            
            if(self.android_textAppearance != nil) {
                [tf setTextAppearance:self.android_textAppearance];
            }
        }
    }
	
	[super setupComponent:view];
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
	CGSize textSize = [self getStringSize];
    int th = textSize.height;
    NSMutableArray *texts = [self buildLineBreaks:self.android_text];
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
	[lst initProperties];
	return lst;
}

-(NSString *)getText
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

-(void)setTextInternal:(NSString *)val
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
    [self resizeOnText];
}

-(void)setText:(LuaRef *)ref
{
    NSString *val = (NSString*)[[LGValueParser getInstance] getValue:ref.idRef];
    [self setTextInternal:val];
}

-(void)setTextColor:(NSString *)color
{
    if(self.multiLine)
    {
        UITextView *field = (UITextView*)self._view;
        [field setTextColor:[[LGColorParser getInstance] parseColor:color]];
    }
    else
    {
        UITextField *field = (UITextField*)self._view;
        [field setTextColor:[[LGColorParser getInstance] parseColor:color]];
    }
}

-(void)setTextColorRef:(LuaRef *)ref
{
    UIColor *val = (UIColor*)[[LGValueParser getInstance] getValue:ref.idRef];
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

-(void)setTextChangedListener:(LuaTranslator*)lt
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

-(void)setBeforeTextChangedListener:(LuaTranslator*)lt
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

-(void)setAfterTextChangedListener:(LuaTranslator*)lt
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
    return [LGEditText className];
}

+ (NSString*)className
{
	return @"LGEditText";
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(create:)) 
										:@selector(create:)
										:[LGEditText class]
										:[NSArray arrayWithObjects:[LuaContext class], nil] 
										:[LGEditText class]] 
			 forKey:@"create"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(setTextChangedListener:)) :@selector(setTextChangedListener:) :[LGView class] :MakeArray([LuaTranslator class]C nil)] forKey:@"setTextChangedListener"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(setBeforeTextChangedListener:)) :@selector(setBeforeTextChangedListener:) :[LGView class] :MakeArray([LuaTranslator class]C nil)] forKey:@"setBeforeTextChangedListener"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(setAfterTextChangedListener:)) :@selector(setAfterTextChangedListener:) :[LGView class] :MakeArray([LuaTranslator class]C nil)] forKey:@"setAfterTextChangedListener"];
	return dict;
}

@end
