#import "LGFrameLayout.h"
#import "LuaFunction.h"
#import "Defines.h"

@implementation LGFrameLayout

-(void)initComponent:(UIView *)view :(LuaContext *)lc
{
    [super initComponent:view :lc];
    
    self.widthConstraint = [self._view.widthAnchor constraintEqualToConstant:self.dWidth];
    self.widthConstraint.active = YES;
    self.heightConstraint = [self._view.heightAnchor constraintEqualToConstant:self.dHeight];
    self.heightConstraint.active = YES;
    
    self.lgViewConstraintToAddList = [NSMutableArray array];
    
    /*NSMutableArray *constraintArr = [NSMutableArray array];
    
    for(LGView *w in self.subviews)
    {
        if(w._view == nil)
            continue;
        
        w._view.translatesAutoresizingMaskIntoConstraints = NO;
        [constraintArr addObject:[w._view.widthAnchor constraintEqualToConstant:w.dWidth - self.dPaddingLeft]];
        [constraintArr addObject:[w._view.heightAnchor constraintEqualToConstant:w.dHeight - self.dPaddingTop]];
        
        if(self.dGravity & GRAVITY_START
            || w.dLayoutGravity & GRAVITY_START)
        {
            [constraintArr addObject:[w._view.leadingAnchor constraintEqualToAnchor:self._view.leadingAnchor constant:w.dMarginLeft + self.dPaddingLeft]];
        }
        else if (self.dGravity & GRAVITY_END
            || w.dLayoutGravity & GRAVITY_END)
        {
            [constraintArr addObject:[w._view.trailingAnchor constraintEqualToAnchor:self._view.trailingAnchor constant:-w.dMarginRight - self.dPaddingRight]];
        }
        
        if(self.dGravity & GRAVITY_TOP
           || w.dLayoutGravity & GRAVITY_TOP)
        {
            [constraintArr addObject:[w._view.topAnchor constraintEqualToAnchor:self._view.topAnchor constant:w.dMarginTop + self.dPaddingTop]];
        }
        else if (self.dGravity & GRAVITY_BOTTOM
            || w.dLayoutGravity & GRAVITY_BOTTOM)
        {
            [constraintArr addObject:[w._view.bottomAnchor constraintEqualToAnchor:self._view.bottomAnchor constant:-w.dMarginBottom - self.dPaddingBottom]];
        }        
        
        if(self.dGravity & GRAVITY_CENTER_HORIZONTAL
           || w.dLayoutGravity & GRAVITY_CENTER_HORIZONTAL)
        {
            [constraintArr addObject:[w._view.centerXAnchor constraintEqualToAnchor:self._view.centerXAnchor constant:w.dMarginRight - w.dMarginLeft]];
        }
        if(self.dGravity & GRAVITY_CENTER_VERTICAL
           || w.dLayoutGravity & GRAVITY_CENTER_VERTICAL)
        {
            [constraintArr addObject:[w._view.centerYAnchor constraintEqualToAnchor:self._view.centerYAnchor constant:w.dMarginBottom - w.dMarginTop]];
        }
        [self._view bringSubviewToFront:w._view];
    }
    
    [NSLayoutConstraint activateConstraints:constraintArr];
    
    [self._view layoutIfNeeded];*/
}

-(void)addConstraintsToView:(LGView*)w
{
    NSMutableArray *constraintArr = [NSMutableArray array];
    
    if(w._view == nil)
        return;
    
    w._view.translatesAutoresizingMaskIntoConstraints = NO;
    [constraintArr addObject:[w._view.widthAnchor constraintEqualToConstant:w.dWidth - self.dPaddingLeft]];
    [constraintArr addObject:[w._view.heightAnchor constraintEqualToConstant:w.dHeight - self.dPaddingTop]];
    
    if(self.dGravity & GRAVITY_START
        || w.dLayoutGravity & GRAVITY_START)
    {
        [constraintArr addObject:[w._view.leadingAnchor constraintEqualToAnchor:self._view.leadingAnchor constant:w.dMarginLeft + self.dPaddingLeft]];
    }
    else if (self.dGravity & GRAVITY_END
        || w.dLayoutGravity & GRAVITY_END)
    {
        [constraintArr addObject:[w._view.trailingAnchor constraintEqualToAnchor:self._view.trailingAnchor constant:-w.dMarginRight - self.dPaddingRight]];
    }
    
    if(self.dGravity & GRAVITY_TOP
       || w.dLayoutGravity & GRAVITY_TOP)
    {
        [constraintArr addObject:[w._view.topAnchor constraintEqualToAnchor:self._view.topAnchor constant:w.dMarginTop + self.dPaddingTop]];
    }
    else if (self.dGravity & GRAVITY_BOTTOM
        || w.dLayoutGravity & GRAVITY_BOTTOM)
    {
        [constraintArr addObject:[w._view.bottomAnchor constraintEqualToAnchor:self._view.bottomAnchor constant:-w.dMarginBottom - self.dPaddingBottom]];
    }
    
    if(self.dGravity & GRAVITY_CENTER_HORIZONTAL
       || w.dLayoutGravity & GRAVITY_CENTER_HORIZONTAL)
    {
        [constraintArr addObject:[w._view.centerXAnchor constraintEqualToAnchor:self._view.centerXAnchor constant:w.dMarginRight - w.dMarginLeft]];
    }
    if(self.dGravity & GRAVITY_CENTER_VERTICAL
       || w.dLayoutGravity & GRAVITY_CENTER_VERTICAL)
    {
        [constraintArr addObject:[w._view.centerYAnchor constraintEqualToAnchor:self._view.centerYAnchor constant:w.dMarginBottom - w.dMarginTop]];
    }
    [self._view bringSubviewToFront:w._view];
    
    [NSLayoutConstraint activateConstraints:constraintArr];
}

- (void)addSubview:(LGView *)val
{
    [super addSubview:val];
    
    [self.lgViewConstraintToAddList addObject:val];
}

- (void)addSubview:(LGView *)val :(NSInteger)index {
    [super addSubview:val :index];
    
    [self.lgViewConstraintToAddList addObject:val];
}

-(void)componentAddMethod:(UIView *)par :(UIView *)me {
    [super componentAddMethod:par :me];
    
    for(LGView *val in self.lgViewConstraintToAddList)
        [self addConstraintsToView:val];
    
    [self.lgViewConstraintToAddList removeAllObjects];
}

//Lua
+(LGFrameLayout*)create:(LuaContext *)context
{
    LGFrameLayout *lfl = [[LGFrameLayout alloc] init];
    [lfl initProperties];
    return lfl;
}

-(NSString*)GetId
{
    if(self.lua_id != nil)
        return self.lua_id;
    if(self.android_id != nil)
        return self.android_id;
    return [LGFrameLayout className];
}

+ (NSString*)className
{
    return @"LGFrameLayout";
}

+(NSMutableDictionary*)luaMethods
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(create:))
                                        :@selector(create:)
                                        :[LGFrameLayout class]
                                        :[NSArray arrayWithObjects:[LuaContext class], [NSString class], nil]
                                        :[LGFrameLayout class]]
             forKey:@"create"];
    return dict;
}

@end
