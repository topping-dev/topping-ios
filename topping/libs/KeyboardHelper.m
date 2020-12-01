#import "KeyboardHelper.h"

@implementation KeyboardHelper

+(void)KeyboardEnableEvents:(UIViewController *)slf
{
    [[NSNotificationCenter defaultCenter] addObserver:slf selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:slf.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:slf selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:slf.view.window];
}

+(void)KeyboardDisableEvents:(UIViewController *)slf :(id)selKeyTextField
{
    [[NSNotificationCenter defaultCenter] removeObserver:slf name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:slf name:UIKeyboardWillHideNotification object:nil];
    if(selKeyTextField != nil)
        [selKeyTextField resignFirstResponder];
}

+(void)KeyboardSetEventForTextField:(id)obj :(UIViewController *)slf
{
    [obj addTarget:slf action:@selector(editingBegin:) forControlEvents:UIControlEventEditingDidBegin];
    [obj addTarget:slf action:@selector(onClickReturn:) forControlEvents:UIControlEventEditingDidEndOnExit];
}

+(void)KeyboardSetEventForTextView:(UITextView*)obj :(UIViewController *)slf
{
    obj.delegate = slf;
}

+(void)KeyboardEnableEventForView:(id)view :(UIViewController *)slf
{
    UITapGestureRecognizer *I = [[UITapGestureRecognizer alloc] initWithTarget:slf action:@selector(onTouchOutside:)];
    I.numberOfTapsRequired = 1;
    I.numberOfTouchesRequired = 1;
    I.cancelsTouchesInView = NO;
    [view addGestureRecognizer:I];
}

+(void)KeyboardDisableEventForView:(UIView *)view
{
    [view removeGestureRecognizer:[view.gestureRecognizers objectAtIndex:0]];
}

@end
