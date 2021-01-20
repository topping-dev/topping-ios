#import "LGConstraintLayout.h"
#import "LuaFunction.h"
#import "Defines.h"
#import "LGDimensionParser.h"

@implementation LGConstraintLayout

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
        bool hasHorizontalCons = NO;
        bool hasVerticalCons = NO;
        if([w.xmlProperties objectForKey:@"layout_constraintLeft_toRightOf"]
           || [w.xmlProperties objectForKey:@"layout_constraintStart_toEndOf"])
        {
            hasHorizontalCons = YES;
            NSString *target = [w.xmlProperties objectForKey:@"layout_constraintLeft_toRightOf"];
            if(target == nil)
                target = [w.xmlProperties objectForKey:@"layout_constraintStart_toEndOf"];
            if([target isEqualToString:@"parent"])
            {
                [w._view.leftAnchor constraintEqualToAnchor:self._view.rightAnchor constant:(w.dMarginLeft)].active = YES;
            }
            else
            {
                NSArray *idArr = [target componentsSeparatedByString:@"/"];
                NSString *idS = [idArr objectAtIndex:idArr.count - 1];
                for(LGView *wTarget in self.subviews)
                {
                    if([[wTarget GetId] isEqualToString:idS])
                    {
                        [w._view.leftAnchor constraintEqualToAnchor:wTarget._view.rightAnchor constant:(wTarget.dMarginRight)].active = YES;
                        break;
                    }
                }
            }
        }
        if([w.xmlProperties objectForKey:@"layout_constraintLeft_toLeftOf"]
           || [w.xmlProperties objectForKey:@"layout_constraintStart_toStartOf"])
        {
            hasHorizontalCons = YES;
            NSString *target = [w.xmlProperties objectForKey:@"layout_constraintLeft_toLeftOf"];
            if(target == nil)
                target = [w.xmlProperties objectForKey:@"layout_constraintStart_toStartOf"];
            if([target isEqualToString:@"parent"])
            {
                [w._view.leftAnchor constraintEqualToAnchor:self._view.leftAnchor constant:(w.dMarginLeft)].active = YES;
            }
            else
            {
                NSArray *idArr = [target componentsSeparatedByString:@"/"];
                NSString *idS = [idArr objectAtIndex:idArr.count - 1];
                for(LGView *wTarget in self.subviews)
                {
                    if([[wTarget GetId] isEqualToString:idS])
                    {
                        [w._view.leftAnchor constraintEqualToAnchor:wTarget._view.leftAnchor constant:(wTarget.dMarginLeft)].active = YES;
                        break;
                    }
                }
            }
        }
        if([w.xmlProperties objectForKey:@"layout_constraintRight_toLeftOf"]
           || [w.xmlProperties objectForKey:@"layout_constraintEnd_toStartOf"])
        {
            NSString *target = [w.xmlProperties objectForKey:@"layout_constraintRight_toLeftOf"];
            if(target == nil)
                target = [w.xmlProperties objectForKey:@"layout_constraintEnd_toStartOf"];
            if([target isEqualToString:@"parent"])
            {
                [w._view.rightAnchor constraintEqualToAnchor:self._view.leftAnchor constant:(w.dMarginRight)].active = YES;
            }
            else
            {
                NSArray *idArr = [target componentsSeparatedByString:@"/"];
                NSString *idS = [idArr objectAtIndex:idArr.count - 1];
                for(LGView *wTarget in self.subviews)
                {
                    if([[wTarget GetId] isEqualToString:idS])
                    {
                        [w._view.rightAnchor constraintEqualToAnchor:wTarget._view.leftAnchor constant:(wTarget.dMarginLeft)].active = YES;
                        break;
                    }
                }
            }
        }
        if([w.xmlProperties objectForKey:@"layout_constraintRight_toRightOf"]
           || [w.xmlProperties objectForKey:@"layout_constraintEnd_toEndOf"])
        {
            hasHorizontalCons = YES;
            NSString *target = [w.xmlProperties objectForKey:@"layout_constraintRight_toRightOf"];
            if(target == nil)
                target = [w.xmlProperties objectForKey:@"layout_constraintEnd_toEndOf"];
            if([target isEqualToString:@"parent"])
            {
                [w._view.rightAnchor constraintEqualToAnchor:self._view.rightAnchor constant:(w.dMarginRight)].active = YES;
            }
            else
            {
                NSArray *idArr = [target componentsSeparatedByString:@"/"];
                NSString *idS = [idArr objectAtIndex:idArr.count - 1];
                for(LGView *wTarget in self.subviews)
                {
                    if([[wTarget GetId] isEqualToString:idS])
                    {
                        [w._view.rightAnchor constraintEqualToAnchor:wTarget._view.rightAnchor constant:(wTarget.dMarginRight)].active = YES;
                        break;
                    }
                }
            }
        }
        if([w.xmlProperties objectForKey:@"layout_constraintTop_toTopOf"])
        {
            hasVerticalCons = YES;
            NSString *target = [w.xmlProperties objectForKey:@"layout_constraintTop_toTopOf"];
            if([target isEqualToString:@"parent"])
            {
                [w._view.topAnchor constraintEqualToAnchor:self._view.topAnchor constant:(w.dMarginTop)].active = YES;
            }
            else
            {
                NSArray *idArr = [target componentsSeparatedByString:@"/"];
                NSString *idS = [idArr objectAtIndex:idArr.count - 1];
                for(LGView *wTarget in self.subviews)
                {
                    if([[wTarget GetId] isEqualToString:idS])
                    {
                        [w._view.topAnchor constraintEqualToAnchor:wTarget._view.topAnchor constant:(wTarget.dMarginTop)].active = YES;
                        break;
                    }
                }
            }
        }
        if([w.xmlProperties objectForKey:@"layout_constraintTop_toBottomOf"])
        {
            hasVerticalCons = YES;
            NSString *target = [w.xmlProperties objectForKey:@"layout_constraintTop_toBottomOf"];
            if([target isEqualToString:@"parent"])
            {
                [w._view.topAnchor constraintEqualToAnchor:self._view.bottomAnchor constant:(w.dMarginTop)].active = YES;
            }
            else
            {
                NSArray *idArr = [target componentsSeparatedByString:@"/"];
                NSString *idS = [idArr objectAtIndex:idArr.count - 1];
                for(LGView *wTarget in self.subviews)
                {
                    if([[wTarget GetId] isEqualToString:idS])
                    {
                        [w._view.topAnchor constraintEqualToAnchor:wTarget._view.bottomAnchor constant:(wTarget.dMarginBottom)].active = YES;
                        break;
                    }
                }
            }
        }
        if([w.xmlProperties objectForKey:@"layout_constraintBottom_toTopOf"])
        {
            NSString *target = [w.xmlProperties objectForKey:@"layout_constraintBottom_toTopOf"];
            if([target isEqualToString:@"parent"])
            {
                [w._view.bottomAnchor constraintEqualToAnchor:self._view.topAnchor constant:(w.dMarginBottom)].active = YES;
            }
            else
            {
                NSArray *idArr = [target componentsSeparatedByString:@"/"];
                NSString *idS = [idArr objectAtIndex:idArr.count - 1];
                for(LGView *wTarget in self.subviews)
                {
                    if([[wTarget GetId] isEqualToString:idS])
                    {
                        [w._view.bottomAnchor constraintEqualToAnchor:wTarget._view.topAnchor constant:(wTarget.dMarginTop)].active = YES;
                        break;
                    }
                }
            }
        }
        if([w.xmlProperties objectForKey:@"layout_constraintBottom_toBottomOf"])
        {
            NSString *target = [w.xmlProperties objectForKey:@"layout_constraintBottom_toBottomOf"];
            if([target isEqualToString:@"parent"])
            {
                [w._view.bottomAnchor constraintEqualToAnchor:self._view.bottomAnchor constant:(w.dMarginBottom)].active = YES;
            }
            else
            {
                NSArray *idArr = [target componentsSeparatedByString:@"/"];
                NSString *idS = [idArr objectAtIndex:idArr.count - 1];
                for(LGView *wTarget in self.subviews)
                {
                    if([[wTarget GetId] isEqualToString:idS])
                    {
                        [w._view.bottomAnchor constraintEqualToAnchor:wTarget._view.bottomAnchor constant:(wTarget.dMarginBottom)].active = YES;
                        break;
                    }
                }
            }
        }
        if([w.xmlProperties objectForKey:@"layout_constraintBaseline_toBaselineOf"])
        {
            hasVerticalCons = YES;
            NSString *target = [w.xmlProperties objectForKey:@"layout_constraintBaseline_toBaselineOf"];
            //TODO:
            /*if([target isEqualToString:@"parent"])
            {
                [w._view.bottomAnchor constraintEqualToAnchor:self._view.bottomAnchor constant:(w.dMarginBottom + self.dMarginBottom)].active = YES;
            }
            else
            {
                NSArray *idArr = [target componentsSeparatedByString:@"/"];
                NSString *idS = [idArr objectAtIndex:idArr.count - 1];
                for(LGView *wTarget in self.subviews)
                {
                    if([[wTarget GetId] isEqualToString:idS])
                    {
                        [w._view.bottomAnchor constraintEqualToAnchor:wTarget._view.bottomAnchor constant:(w.dMarginBottom + wTarget.dMarginBottom)].active = YES;
                        break;
                    }
                }
            }*/
        }
        
        if(!hasHorizontalCons)
        {
            [w._view.leftAnchor constraintEqualToAnchor:self._view.leftAnchor constant:w.dMarginLeft].active = YES;
        }
        if(!hasVerticalCons)
        {
            [w._view.topAnchor constraintEqualToAnchor:self._view.topAnchor constant:w.dMarginTop].active = YES;
        }
    }
    
    [self._view layoutIfNeeded];
}

+(LGConstraintLayout*)Create:(LuaContext *)context
{
    LGConstraintLayout *lcl = [[LGConstraintLayout alloc] init];
    [lcl InitProperties];
    return lcl;
}

-(NSString*)GetId
{
    GETID
    return [LGConstraintLayout className];
}

+ (NSString*)className
{
    return @"LGConstraintLayout";
}

+(NSMutableDictionary*)luaMethods
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(Create:))
                                        :@selector(Create:)
                                        :[LGConstraintLayout class]
                                        :[NSArray arrayWithObjects:[LuaContext class], [NSString class], nil]
                                        :[LGConstraintLayout class]]
             forKey:@"Create"];
    return dict;
}

@end
