#import "LGFrameLayout.h"
#import "LuaFunction.h"
#import "Defines.h"

@implementation LGFrameLayout

-(void)InitComponent:(UIView *)view :(LuaContext *)lc
{
    [super InitComponent:view :lc];
    
    self._view.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self._view.widthAnchor constraintEqualToConstant:self.dWidth].active = YES;
    [self._view.heightAnchor constraintEqualToConstant:self.dHeight].active = YES;
    
    for(LGView *w in self.subviews)
    {
        w._view.translatesAutoresizingMaskIntoConstraints = NO;
        [w._view.widthAnchor constraintEqualToConstant:w.dWidth].active = YES;
        [w._view.heightAnchor constraintEqualToConstant:w.dHeight].active = YES;
        
        if(self.dGravity & GRAVITY_START
            || w.dLayoutGravity & GRAVITY_START)
        {
            [w._view.leadingAnchor constraintEqualToAnchor:self._view.leadingAnchor constant:w.dMarginLeft].active = YES;
        }
        else if (self.dGravity & GRAVITY_END
            || w.dLayoutGravity & GRAVITY_END)
        {
            [w._view.trailingAnchor constraintEqualToAnchor:self._view.trailingAnchor constant:-w.dMarginRight].active = YES;
        }
        
        if(self.dGravity & GRAVITY_TOP
           || w.dLayoutGravity & GRAVITY_TOP)
        {
            [w._view.topAnchor constraintEqualToAnchor:self._view.topAnchor constant:w.dMarginTop].active = YES;
        }
        else if (self.dGravity & GRAVITY_BOTTOM
            || w.dLayoutGravity & GRAVITY_BOTTOM)
        {
            [w._view.bottomAnchor constraintEqualToAnchor:self._view.bottomAnchor constant:-w.dMarginBottom].active = YES;
        }        
        
        if(self.dGravity & GRAVITY_CENTER_HORIZONTAL
           || w.dLayoutGravity & GRAVITY_CENTER_HORIZONTAL)
        {
            [w._view.centerXAnchor constraintEqualToAnchor:self._view.centerXAnchor constant:w.dMarginRight - w.dMarginLeft].active = YES;
        }
        if(self.dGravity & GRAVITY_CENTER_VERTICAL
           || w.dLayoutGravity & GRAVITY_CENTER_VERTICAL)
        {
            [w._view.centerYAnchor constraintEqualToAnchor:self._view.centerYAnchor constant:w.dMarginBottom - w.dMarginTop].active = YES;
        }
    }
    
    [self._view layoutIfNeeded];
}

//Lua
+(LGFrameLayout*)Create:(LuaContext *)context
{
    LGFrameLayout *lfl = [[LGFrameLayout alloc] init];
    [lfl InitProperties];
    return lfl;
}

-(NSString*)GetId
{
    GETID
    return [LGFrameLayout className];
}

+ (NSString*)className
{
    return @"LGFrameLayout";
}

+(NSMutableDictionary*)luaMethods
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(Create:))
                                        :@selector(Create:)
                                        :[LGFrameLayout class]
                                        :[NSArray arrayWithObjects:[LuaContext class], [NSString class], nil]
                                        :[LGFrameLayout class]]
             forKey:@"Create"];
    return dict;
}

@end
