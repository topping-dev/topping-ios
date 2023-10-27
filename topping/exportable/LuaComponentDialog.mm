#import "LuaComponentDialog.h"
#import "Defines.h"
#import "LuaFunction.h"
#import <ToppingIOSKotlinHelper/ToppingIOSKotlinHelper.h>
#import <Topping/Topping-Swift.h>

@implementation LuaComponentDialog

- (instancetype)initWithContext:(LuaContext*)context
{
    self = [super init];
    if (self) {
        self.controller = [[LinearLayoutDialogController alloc] init];
        self.controller.context = context;
        self.controller.dialog = self;
        [self.controller initialize];
        self.lifecycleRegistry = [[LifecycleRegistry alloc] initWithOwner:self];
        self.savedStateRegistryController = [[SavedStateRegistryController alloc] initWithOwner:self];
        self.onBackPressedDispatcher = [[OnBackPressedDispatcher alloc] initWithFallbackOnBackPressed:^{
        }];
    }
    return self;
}

-(void)setContentViewRef:(LuaRef *)ref {
    LGView *lgView = [[LGView alloc] init];
    UIView *viewToAdd = [[LGLayoutParser getInstance] parseRef:ref :self.controller.linearLayout._view :self.controller.linearLayout :self.controller.context.form :&lgView];
    [self.controller.linearLayout addSubview:lgView];
    [self.controller.linearLayout componentAddMethod:self.controller.linearLayout._view :viewToAdd];
}

- (void)setContentView:(LGView *)view {
    [self.controller.linearLayout removeAllSubViews];
    [self.controller.linearLayout addSubview:view];
    [self.controller.linearLayout componentAddMethod:self.controller.linearLayout._view :view._view];
}

-(void)setContentView:(LGView *)view :(TIOSKHViewGroupLayoutParams *)params {
    view.kLayoutParams = params;
    [self.controller.linearLayout removeAllSubViews];
    [self.controller.linearLayout addSubview:view];
    [self.controller.linearLayout componentAddMethod:self.controller.linearLayout._view :view._view];
}

-(void)addContentView:(LGView *)view :(TIOSKHViewGroupLayoutParams *)params {
    view.kLayoutParams = params;
    [self.controller.linearLayout addSubview:view];
    [self.controller.linearLayout componentAddMethod:self.controller.linearLayout._view :view._view];
}

-(void)show {
    [self.controller.context.form presentViewController:self.controller animated:true completion:^{
            
    }];
}

-(void)dismiss {
    [self.controller dismissViewControllerAnimated:true completion:^{
        
    }];
}

-(void)cancel {
    [self.controller dismissViewControllerAnimated:true completion:^{
        
    }];
}

-(BOOL)onTouchEvent:(TIOSKHMotionEvent *)event {
    return true;
}

-(NSString*)GetId
{
    return [LuaComponentDialog className];
}

+ (NSString*)className
{
	return @"LuaComponentDialog";
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	return dict;
}

- (Lifecycle *)getLifecycle {
    return self.lifecycleRegistry;
}

- (OnBackPressedDispatcher * _Nonnull)getOnBackPressedDispatcher {
    return self.onBackPressedDispatcher;
}

- (SavedStateRegistry * _Nonnull)getSavedStateRegistry {
    return [self.savedStateRegistryController getSavedStateRegistry];
}

@end
