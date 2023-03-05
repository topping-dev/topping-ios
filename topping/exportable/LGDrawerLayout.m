#import "LGDrawerLayout.h"
#import "LuaFunction.h"
#import <Topping/Topping-Swift.h>

@implementation LGDrawerLayoutDelegate

- (instancetype)initWithDrawer:(LGDrawerLayout*)drawerLayout :(BOOL)animation
{
    self = [super init];
    if (self) {
        self.drawerLayout = drawerLayout;
        self.supportAnimation = animation;
    }
    return self;
}

-(UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source
{
    self.drawerLayout.navigationController = [[NavigationDrawerSwipeController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
    self.drawerLayout.navigationController.stateDelegate = self.drawerLayout;
    return self.drawerLayout.navigationController;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return [[NavigationDrawerPresentationAnimator alloc] initWithIsBeingPresented:true supportAnimation:self.supportAnimation];
}

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [[NavigationDrawerPresentationAnimator alloc] initWithIsBeingPresented:false supportAnimation:self.supportAnimation];
}

@end

@implementation LGDrawerLayout

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.ltOnDrawerSlide = [NSMutableArray array];
        self.ltOnDrawerOpened = [NSMutableArray array];
        self.ltOnDrawerClosed = [NSMutableArray array];
        self.ltOnDrawerStateChanged = [NSMutableArray array];
    }
    return self;
}

+(LGDrawerLayout*)create:(LuaContext*)context {
    LGDrawerLayout *dl = [[LGDrawerLayout alloc] init];
    dl.lc = context;
    return dl;
}

-(void)addOnDrawerSlide:(LuaTranslator *)lt {
    [self.ltOnDrawerSlide addObject:lt];
}

-(void)addOnDrawerOpened:(LuaTranslator *)lt {
    [self.ltOnDrawerOpened addObject:lt];
}

-(void)addOnDrawerClosed:(LuaTranslator *)lt {
    [self.ltOnDrawerClosed addObject:lt];
}

-(void)addOnDrawerStateChanged:(LuaTranslator *)lt {
    [self.ltOnDrawerStateChanged addObject:lt];
}

-(void)removeOnDrawerSlide:(LuaTranslator *)lt {
    [self.ltOnDrawerSlide removeObject:lt];
}

-(void)removeOnDrawerOpened:(LuaTranslator *)lt {
    [self.ltOnDrawerOpened removeObject:lt];
}

-(void)removeOnDrawerClosed:(LuaTranslator *)lt {
    [self.ltOnDrawerClosed removeObject:lt];
}

-(void)removeOnDrawerStateChanged:(LuaTranslator *)lt {
    [self.ltOnDrawerStateChanged removeObject:lt];
}

-(void)openDrawer:(BOOL)animate {
    if(self.isOpen)
        return;
    self.delegate = [[LGDrawerLayoutDelegate alloc] initWithDrawer:self :animate];
    self.drawerForm.transitioningDelegate = self.delegate;
    self.drawerForm.modalPresentationStyle = UIModalPresentationCustom;
    
    [self.lc.form presentViewController:self.drawerForm animated:true completion:^{
        [self.drawerLayout configChange];
    }];
}

-(void)closeDrawer {
    if(!self.isOpen)
        return;
    [self.drawerForm dismissViewControllerAnimated:true completion:^{
    }];
}

-(void)didPan:(UIGestureRecognizer *)gesture {
    for(LuaTranslator *lt in self.ltOnDrawerSlide) {
        [lt callIn:[NSNumber numberWithInt:[gesture locationInView:self].x]];
    }
    if(gesture.state == UIGestureRecognizerStateBegan) {
        [self openDrawer:false];
    } else {
        if(self.drawerForm != nil && [self.drawerForm.presentationController isKindOfClass:[NavigationDrawerSwipeController class]]) {
            [((NavigationDrawerSwipeController*)self.drawerForm.presentationController) didPanWithPanRecognizer:gesture screenGestureEnabled:true];
        }
    }
}

-(void)initComponent:(UIView *)view :(LuaContext *)lc
{
    self.drawerLayout = [self.subviews lastObject];
    [self removeSubview:self.drawerLayout];
    [self.drawerLayout._view removeFromSuperview];
    LuaContext *lcNew = [LuaContext new];
    self.drawerForm = [[LuaForm alloc] init];
    [lcNew setup:self.drawerForm :false];
    self.drawerForm.context = lcNew;
    self.drawerLayout.lc = lcNew;
    [self.drawerForm setLuaView:self.drawerLayout];
    
    [super initComponent:view :lc];
    
    UIScreenEdgePanGestureRecognizer *screenEdgeGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(didPan:)];
    if([self._view isRTL])
        screenEdgeGesture.edges = UIRectEdgeRight;
    else
        screenEdgeGesture.edges = UIRectEdgeLeft;
    [self._view addGestureRecognizer:screenEdgeGesture];
}

-(void)onPresent {
    self.isOpen = true;
    for(LuaTranslator *lt in self.ltOnDrawerOpened) {
        [lt call];
    }
}

-(void)onStateChangeWithState:(NSInteger)state {
    for(LuaTranslator *lt in self.ltOnDrawerStateChanged) {
        [lt call:[NSNumber numberWithInt:state]];
    }
}

-(void)onDismiss {
    self.isOpen = false;
    for(LuaTranslator *lt in self.ltOnDrawerClosed) {
        [lt call];
    }
}

-(NSString*)GetId
{
    if(self.lua_id != nil)
        return self.lua_id;
    if(self.android_id != nil)
        return self.android_id;
    return [LGDrawerLayout className];
}

+ (NSString*)className
{
    return @"LGDrawerLayout";
}

+(NSMutableDictionary*)luaMethods
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];

    ClassMethod(create:, LGDrawerLayout, @[[LuaContext class]], @"create", [LGDrawerLayout class])
    
    return dict;
}

@end
