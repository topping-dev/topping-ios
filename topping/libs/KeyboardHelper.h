#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface KeyboardHelper : NSObject
{
    
}

+(void)KeyboardEnableEvents:(UIViewController*)slf;
+(void)KeyboardDisableEvents:(UIViewController *)slf :(id)selKeyTextField;
+(void)KeyboardSetEventForTextField:(id)obj :(UIViewController *)slf;
+(void)KeyboardSetEventForTextView:(UITextView*)obj :(UIViewController*)slf;
+(void)KeyboardEnableEventForView:(id)view :(UIViewController *)slf;
+(void)KeyboardDisableEventForView:(UIView *)view;

//Keyboard
#define KEYBOARD_PROPERTIES @property(nonatomic, strong) UITextField *selectedKeyboardTextField; \
@property(nonatomic, strong) UITextView *selectedKeyboardTextView; \
@property(nonatomic) bool movedUpField; \
@property(nonatomic) int moveDifference;

#define KEYBOARD_FUNCTIONS -(IBAction)onClickReturn:(id)sender; \
-(void)onTouchOutside:(UITapGestureRecognizer*)gesture; \
-(void)setViewMovedUp:(BOOL)movedUp:(NSNotification*)notif; \
-(void)keyboardWillShow:(NSNotification *)notif; \
-(void)keyboardWillHide:(NSNotification *)notif; \
-(IBAction)editingBegin:(id)sender;

#define KEYBOARD_FUNCTIONS_IMPLEMENTATION \
-(IBAction)onClickReturn:(id)sender \
{ \
    [sender resignFirstResponder]; \
} \
\
-(void)onTouchOutside:(UITapGestureRecognizer*)gesture \
{ \
    @try { \
        gesture.cancelsTouchesInView = NO; \
        if(gesture.state == UIGestureRecognizerStateEnded) \
        { \
            if(self.selectedKeyboardTextField != nil) \
                [self.selectedKeyboardTextField resignFirstResponder]; \
                    if(self.selectedKeyboardTextView != nil) \
                        [self.selectedKeyboardTextView resignFirstResponder]; \
                            gesture.cancelsTouchesInView = NO; \
        } } \
    @catch(NSException *ex) \
    { \
    } \
} \
\
-(void)setViewMovedUp:(BOOL)movedUp:(NSNotification*)notif \
{ \
    [UIView beginAnimations:nil context:NULL]; \
        [UIView setAnimationDuration:0.5]; \
            \
            CGRect rect = self.view.frame; \
                CGRect t = CGRectMake(0, 0, 0, self.moveDifference); \
                    if (movedUp) \
                    { \
                        rect.origin.y -= t.size.height; \
                            rect.size.height += t.size.height; \
                    } \
                    else \
                    { \
                        rect.origin.y += t.size.height; \
                            rect.size.height -= t.size.height; \
                    } \
                    self.view.frame = rect; \
                        \
                        [UIView commitAnimations]; \
} \
\
- (void)keyboardWillShow:(NSNotification *)notif \
{ \
    CGRect t; \
        [((NSValue*)[notif.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey]) getValue:&t]; \
            t = [self.view convertRect:t toView:nil]; \
                \
                if(self.selectedKeyboardTextField != nil) \
                { \
                    int screenY = self.selectedKeyboardTextField.frame.origin.y; \
                        \
                        if([self.view isKindOfClass:[UIScrollView class]]) \
                        { \
                            screenY = self.selectedKeyboardTextField.frame.origin.y + self.view.frame.origin.y - ((UIScrollView *)self.view).contentOffset.y; \
                                \
                                int screenHeight = self.view.frame.size.height; \
                                    int visibleScreenHeight = screenHeight - t.size.width; \
                                        \
                                        if(screenY > visibleScreenHeight) \
                                        { \
                                            self.moveDifference = screenY - visibleScreenHeight + self.selectedKeyboardTextField.frame.size.height; \
                                                [self setViewMovedUp:YES:notif]; \
                                                    self.movedUpField = YES; \
                                        } \
                        } \
                        else \
                        { \
                            screenY = self.selectedKeyboardTextField.frame.origin.y + self.view.frame.origin.y; \
                                \
                                int screenHeight = self.view.frame.size.height; \
                                    int visibleScreenHeight = screenHeight - t.size.width; \
                                        \
                                        if(screenY > visibleScreenHeight) \
                                        { \
                                            self.moveDifference = screenY - visibleScreenHeight + self.selectedKeyboardTextField.frame.size.height; \
                                                [self setViewMovedUp:YES:notif]; \
                                                    self.movedUpField = YES; \
                                        } \
                        } \
                } \
                else \
                { \
                    int screenY = self.selectedKeyboardTextView.frame.origin.y; \
                        \
                        if([self.view isKindOfClass:[UIScrollView class]]) \
                        { \
                            screenY = self.selectedKeyboardTextView.frame.origin.y + self.view.frame.origin.y - ((UIScrollView *)self.view).contentOffset.y; \
                                \
                                int screenHeight = self.view.frame.size.height; \
                                    int visibleScreenHeight = screenHeight - t.size.width; \
                                        \
                                        if(screenY > visibleScreenHeight) \
                                        { \
                                            self.moveDifference = screenY - visibleScreenHeight + self.selectedKeyboardTextView.frame.size.height; \
                                                [self setViewMovedUp:YES:notif]; \
                                                    self.movedUpField = YES; \
                                        } \
                        } \
                        else \
                        { \
                            screenY = self.selectedKeyboardTextView.frame.origin.y + self.view.frame.origin.y; \
                                \
                                int screenHeight = self.view.frame.size.height; \
                                    int visibleScreenHeight = screenHeight - t.size.width; \
                                        \
                                        if(screenY > visibleScreenHeight) \
                                        { \
                                            self.moveDifference = screenY - visibleScreenHeight + self.selectedKeyboardTextView.frame.size.height; \
                                                [self setViewMovedUp:YES:notif]; \
                                                    self.movedUpField = YES; \
                                        } \
                        } \
                } \
} \
\
-(void)keyboardWillHide:(NSNotification *)notif \
{ \
    if(self.movedUpField) \
    { \
        self.movedUpField = NO; \
            [self setViewMovedUp:NO:notif]; \
                self.selectedKeyboardTextField = nil; \
                    self.selectedKeyboardTextView = nil; \
    } \
} \
\
-(IBAction)editingBegin:(id)sender \
{ \
    if(self.selectedKeyboardTextView != nil) \
        [self keyboardWillHide:nil]; \
    self.selectedKeyboardTextView = nil; \
    self.selectedKeyboardTextField = (UITextField*)sender; \
} \
\
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView { \
    if(self.selectedKeyboardTextField != nil) \
        [self keyboardWillHide:nil]; \
    self.selectedKeyboardTextField = nil; \
    self.selectedKeyboardTextView = textView; \
    return textView.editable; \
} \
\
- (void)textViewDidBeginEditing:(UITextView *)textView \
{ \
    \
}

#define KEYBOARD_FUNCTIONS_IMPLEMENTATION_UNDERSCORE \
-(IBAction)onClickReturn:(id)sender \
{ \
    [sender resignFirstResponder]; \
} \
\
-(void)onTouchOutside:(UITapGestureRecognizer*)gesture \
{ \
    @try { \
        gesture.cancelsTouchesInView = NO; \
        if(gesture.state == UIGestureRecognizerStateEnded) \
        { \
            if(self.selectedKeyboardTextField != nil) \
                [self.selectedKeyboardTextField resignFirstResponder]; \
                    if(self.selectedKeyboardTextView != nil) \
                        [self.selectedKeyboardTextView resignFirstResponder]; \
                            gesture.cancelsTouchesInView = NO; \
        } } \
    @catch(NSException *ex) \
    { \
    } \
} \
\
-(void)setViewMovedUp:(BOOL)movedUp:(NSNotification*)notif \
{ \
    [UIView beginAnimations:nil context:NULL]; \
        [UIView setAnimationDuration:0.5]; \
            \
            CGRect rect = self._view.frame; \
                CGRect t = CGRectMake(0, 0, 0, self.moveDifference); \
                    if (movedUp) \
                    { \
                        rect.origin.y -= t.size.height; \
                            rect.size.height += t.size.height; \
                    } \
                    else \
                    { \
                        rect.origin.y += t.size.height; \
                            rect.size.height -= t.size.height; \
                    } \
                    self._view.frame = rect; \
                        \
                        [UIView commitAnimations]; \
} \
\
- (void)keyboardWillShow:(NSNotification *)notif \
{ \
    CGRect t; \
        [[notif.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&t]; \
            t = [self._view convertRect:t toView:nil]; \
                \
                if(self.selectedKeyboardTextField != nil) \
                { \
                    int screenY = self.selectedKeyboardTextField.frame.origin.y; \
                        \
                        if([self._view isKindOfClass:[UIScrollView class]]) \
                        { \
                            screenY = self.selectedKeyboardTextField.frame.origin.y + self._view.frame.origin.y - ((UIScrollView *)self._view).contentOffset.y; \
                                \
                                int screenHeight = self._view.frame.size.height; \
                                    int visibleScreenHeight = screenHeight - t.size.width; \
                                        \
                                        if(screenY > visibleScreenHeight) \
                                        { \
                                            self.moveDifference = screenY - visibleScreenHeight + self.selectedKeyboardTextField.frame.size.height; \
                                                [self setViewMovedUp:YES:notif]; \
                                                    self.movedUpField = YES; \
                                        } \
                        } \
                        else \
                        { \
                            screenY = self.selectedKeyboardTextField.frame.origin.y + self._view.frame.origin.y; \
                                \
                                int screenHeight = self._view.frame.size.height; \
                                    int visibleScreenHeight = screenHeight - t.size.width; \
                                        \
                                        if(screenY > visibleScreenHeight) \
                                        { \
                                            self.moveDifference = screenY - visibleScreenHeight + self.selectedKeyboardTextField.frame.size.height; \
                                                [self setViewMovedUp:YES:notif]; \
                                                    self.movedUpField = YES; \
                                        } \
                        } \
                } \
                else \
                { \
                    int screenY = self.selectedKeyboardTextView.frame.origin.y; \
                        \
                        if([self._view isKindOfClass:[UIScrollView class]]) \
                        { \
                            screenY = self.selectedKeyboardTextView.frame.origin.y + self._view.frame.origin.y - ((UIScrollView *)self._view).contentOffset.y; \
                                \
                                int screenHeight = self._view.frame.size.height; \
                                    int visibleScreenHeight = screenHeight - t.size.width; \
                                        \
                                        if(screenY > visibleScreenHeight) \
                                        { \
                                            self.moveDifference = screenY - visibleScreenHeight + self.selectedKeyboardTextView.frame.size.height; \
                                                [self setViewMovedUp:YES:notif]; \
                                                    self.movedUpField = YES; \
                                        } \
                        } \
                        else \
                        { \
                            screenY = self.selectedKeyboardTextView.frame.origin.y + self._view.frame.origin.y; \
                                \
                                int screenHeight = self._view.frame.size.height; \
                                    int visibleScreenHeight = screenHeight - t.size.width; \
                                        \
                                        if(screenY > visibleScreenHeight) \
                                        { \
                                            self.moveDifference = screenY - visibleScreenHeight + self.selectedKeyboardTextView.frame.size.height; \
                                                [self setViewMovedUp:YES:notif]; \
                                                    self.movedUpField = YES; \
                                        } \
                        } \
                } \
} \
\
-(void)keyboardWillHide:(NSNotification *)notif \
{ \
    if(self.movedUpField) \
    { \
        self.movedUpField = NO; \
            [self setViewMovedUp:NO:notif]; \
                self.selectedKeyboardTextField = nil; \
                    self.selectedKeyboardTextView = nil; \
    } \
} \
\
-(IBAction)editingBegin:(id)sender \
{ \
    if(self.selectedKeyboardTextView != nil) \
        [self keyboardWillHide:nil]; \
    self.selectedKeyboardTextView = nil; \
    self.selectedKeyboardTextField = (UITextField*)sender; \
} \
\
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView { \
    if(self.selectedKeyboardTextField != nil) \
        [self keyboardWillHide:nil]; \
    self.selectedKeyboardTextField = nil; \
    self.selectedKeyboardTextView = textView; \
    return textView.editable; \
} \
\
- (void)textViewDidBeginEditing:(UITextView *)textView \
{ \
    \
}

@end
