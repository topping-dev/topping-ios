#import "LGConstraintLayout.h"
#import "LuaFunction.h"
#import "Defines.h"
#import "LGDimensionParser.h"

@implementation LGConstraintLayout

-(void)InitComponent:(UIView *)view :(LuaContext *)lc
{
    [super InitComponent:view :lc];
    
    [self._view.widthAnchor constraintEqualToConstant:self.dWidth].active = YES;
    [self._view.heightAnchor constraintEqualToConstant:self.dHeight].active = YES;
    
    for(LGView *w in self.subviews)
    {
        w._view.translatesAutoresizingMaskIntoConstraints = NO;
        [w._view.widthAnchor constraintEqualToConstant:w.dWidth].active = YES;
        [w._view.heightAnchor constraintEqualToConstant:w.dHeight].active = YES;
        NSLayoutConstraint *leftConstraint, *rightConstraint, *topConstraint, *bottomConstraint;
        if([w.xmlProperties objectForKey:@"layout_constraintLeft_toRightOf"]
           || [w.xmlProperties objectForKey:@"layout_constraintStart_toEndOf"])
        {
            NSString *target = [w.xmlProperties objectForKey:@"layout_constraintLeft_toRightOf"];
            if(target == nil)
                target = [w.xmlProperties objectForKey:@"layout_constraintStart_toEndOf"];
            if([target isEqualToString:@"parent"])
            {
                leftConstraint = [w._view.leftAnchor constraintEqualToAnchor:self._view.rightAnchor constant:(w.dMarginLeft)];
            }
            else
            {
                NSArray *idArr = [target componentsSeparatedByString:@"/"];
                NSString *idS = [idArr objectAtIndex:idArr.count - 1];
                for(LGView *wTarget in self.subviews)
                {
                    if([[wTarget GetId] isEqualToString:idS])
                    {
                        leftConstraint = [w._view.leftAnchor constraintEqualToAnchor:wTarget._view.rightAnchor constant:(wTarget.dMarginRight)];
                        break;
                    }
                }
            }
        }
        if([w.xmlProperties objectForKey:@"layout_constraintLeft_toLeftOf"]
           || [w.xmlProperties objectForKey:@"layout_constraintStart_toStartOf"])
        {
            NSString *target = [w.xmlProperties objectForKey:@"layout_constraintLeft_toLeftOf"];
            if(target == nil)
                target = [w.xmlProperties objectForKey:@"layout_constraintStart_toStartOf"];
            if([target isEqualToString:@"parent"])
            {
                leftConstraint = [w._view.leftAnchor constraintEqualToAnchor:self._view.leftAnchor constant:(w.dMarginLeft)];
            }
            else
            {
                NSArray *idArr = [target componentsSeparatedByString:@"/"];
                NSString *idS = [idArr objectAtIndex:idArr.count - 1];
                for(LGView *wTarget in self.subviews)
                {
                    if([[wTarget GetId] isEqualToString:idS])
                    {
                        leftConstraint = [w._view.leftAnchor constraintEqualToAnchor:wTarget._view.leftAnchor constant:(wTarget.dMarginLeft)];
                        break;
                    }
                }
            }
        }
        if([w.xmlProperties objectForKey:@"layout_constraintRight_toRightOf"]
           || [w.xmlProperties objectForKey:@"layout_constraintEnd_toEndOf"])
        {
            NSString *target = [w.xmlProperties objectForKey:@"layout_constraintRight_toRightOf"];
            if(target == nil)
                target = [w.xmlProperties objectForKey:@"layout_constraintEnd_toEndOf"];
            if([target isEqualToString:@"parent"])
            {
                rightConstraint = [w._view.rightAnchor constraintEqualToAnchor:self._view.rightAnchor constant:(w.dMarginRight)];
            }
            else
            {
                NSArray *idArr = [target componentsSeparatedByString:@"/"];
                NSString *idS = [idArr objectAtIndex:idArr.count - 1];
                for(LGView *wTarget in self.subviews)
                {
                    if([[wTarget GetId] isEqualToString:idS])
                    {
                        rightConstraint = [w._view.rightAnchor constraintEqualToAnchor:wTarget._view.rightAnchor constant:(wTarget.dMarginRight)];
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
                rightConstraint = [w._view.rightAnchor constraintEqualToAnchor:self._view.leftAnchor constant:(w.dMarginRight)];
            }
            else
            {
                NSArray *idArr = [target componentsSeparatedByString:@"/"];
                NSString *idS = [idArr objectAtIndex:idArr.count - 1];
                for(LGView *wTarget in self.subviews)
                {
                    if([[wTarget GetId] isEqualToString:idS])
                    {
                        rightConstraint = [w._view.rightAnchor constraintEqualToAnchor:wTarget._view.leftAnchor constant:(wTarget.dMarginLeft)];
                        break;
                    }
                }
            }
        }
        if([w.xmlProperties objectForKey:@"layout_constraintTop_toBottomOf"])
        {
            NSString *target = [w.xmlProperties objectForKey:@"layout_constraintTop_toBottomOf"];
            if([target isEqualToString:@"parent"])
            {
                topConstraint = [w._view.topAnchor constraintEqualToAnchor:self._view.bottomAnchor constant:(w.dMarginTop)];
            }
            else
            {
                NSArray *idArr = [target componentsSeparatedByString:@"/"];
                NSString *idS = [idArr objectAtIndex:idArr.count - 1];
                for(LGView *wTarget in self.subviews)
                {
                    if([[wTarget GetId] isEqualToString:idS])
                    {
                        topConstraint = [w._view.topAnchor constraintEqualToAnchor:wTarget._view.bottomAnchor constant:(wTarget.dMarginBottom)];
                        break;
                    }
                }
            }
        }
        if([w.xmlProperties objectForKey:@"layout_constraintTop_toTopOf"])
        {
            NSString *target = [w.xmlProperties objectForKey:@"layout_constraintTop_toTopOf"];
            if([target isEqualToString:@"parent"])
            {
                topConstraint = [w._view.topAnchor constraintEqualToAnchor:self._view.topAnchor constant:(w.dMarginTop)];
            }
            else
            {
                NSArray *idArr = [target componentsSeparatedByString:@"/"];
                NSString *idS = [idArr objectAtIndex:idArr.count - 1];
                for(LGView *wTarget in self.subviews)
                {
                    if([[wTarget GetId] isEqualToString:idS])
                    {
                        topConstraint = [w._view.topAnchor constraintEqualToAnchor:wTarget._view.topAnchor constant:(wTarget.dMarginTop)];
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
                bottomConstraint = [w._view.bottomAnchor constraintEqualToAnchor:self._view.bottomAnchor constant:(w.dMarginBottom)];
            }
            else
            {
                NSArray *idArr = [target componentsSeparatedByString:@"/"];
                NSString *idS = [idArr objectAtIndex:idArr.count - 1];
                for(LGView *wTarget in self.subviews)
                {
                    if([[wTarget GetId] isEqualToString:idS])
                    {
                        bottomConstraint = [w._view.bottomAnchor constraintEqualToAnchor:wTarget._view.bottomAnchor constant:(wTarget.dMarginBottom)];
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
                bottomConstraint = [w._view.bottomAnchor constraintEqualToAnchor:self._view.topAnchor constant:(w.dMarginBottom)];
            }
            else
            {
                NSArray *idArr = [target componentsSeparatedByString:@"/"];
                NSString *idS = [idArr objectAtIndex:idArr.count - 1];
                for(LGView *wTarget in self.subviews)
                {
                    if([[wTarget GetId] isEqualToString:idS])
                    {
                        bottomConstraint = [w._view.bottomAnchor constraintEqualToAnchor:wTarget._view.topAnchor constant:(wTarget.dMarginTop)];
                        break;
                    }
                }
            }
        }
        if([w.xmlProperties objectForKey:@"layout_constraintBaseline_toBaselineOf"])
        {
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
        
        
        if(leftConstraint != nil && rightConstraint != nil)
        {
            NSString *val = [w.xmlProperties objectForKey:@"layout_constraintHorizontal_bias"];
            //float final = 0;
            float valF = 0.5f;
            
            if(val != nil)
            {
                valF = [val floatValue];
                if(valF < 0)
                    valF = 0;
                else if(valF > 1.0f)
                    valF = 1.0f;
            }
            
            /*if(leftConstraint.secondItem == self._view && rightConstraint.secondItem == self._view)
            {
                if(val != nil)
                {
                    int mult = 1;
                    float valCalc = 0;
                    if(valF < 0.5f)
                    {
                        valCalc = valF;
                        mult = -1;
                    }
                    else if(valF == 0.5f)
                        mult = 0;
                    else
                    {
                        valCalc = valF - 0.5f;
                    }
                    float halfWidth = ((float)self.dWidth) / 2.0f;
                    final = ((valCalc * halfWidth) / 0.5f) * mult;
                }
                [w._view.centerXAnchor constraintEqualToAnchor:view.centerXAnchor constant:final].active = YES;
            }
            else
            {*/
                UILayoutGuide *leftview = [UILayoutGuide new];
                [w._view addLayoutGuide:leftview];
                [leftview.leftAnchor constraintEqualToAnchor:leftConstraint.secondAnchor].active = YES;
                [leftview.rightAnchor constraintEqualToAnchor:leftConstraint.firstAnchor].active = YES;
                
                UILayoutGuide *rightview = [UILayoutGuide new];
                [w._view addLayoutGuide:rightview];
                [rightview.leftAnchor constraintEqualToAnchor:rightConstraint.firstAnchor].active = YES;
                [rightview.rightAnchor constraintEqualToAnchor:rightConstraint.secondAnchor].active = YES;
                
                if(valF <= 0.5f)
                    [leftview.widthAnchor constraintEqualToAnchor:rightview.widthAnchor multiplier:valF/0.5f].active = YES;
                else if(valF > 0.5f)
                    [rightview.widthAnchor constraintEqualToAnchor:leftview.widthAnchor multiplier:(1.0f - valF)/0.5f].active = YES;
            //}
        }
        else
        {
            if(leftConstraint != nil)
                leftConstraint.active = YES;
            if(rightConstraint != nil)
                rightConstraint.active = YES;
        }
        if(topConstraint != nil && bottomConstraint != nil)
        {
            NSString *val = [w.xmlProperties objectForKey:@"layout_constraintVertical_bias"];
            /*float final = 0;
            if(val != nil)
            {
                float valF = [val floatValue];
                int mult = 1;
                float valCalc = 0;
                if(valF < 0.5f)
                {
                    valCalc = valF;
                    mult = -1;
                }
                else if(valF == 0.5f)
                    mult = 0;
                else
                {
                    valCalc = valF - 0.5f;
                }
                float halfWidth = ((float)self.dWidth) / 2.0f;
                final = ((valCalc * halfWidth) / 0.5f) * mult;
            }
            
            UIView *view = [UIView new];
            view.translatesAutoresizingMaskIntoConstraints = NO;
            view.hidden = YES;
            [self._view addSubview:view];
            [view.topAnchor constraintEqualToAnchor:topConstraint.secondAnchor].active = YES;
            [view.bottomAnchor constraintEqualToAnchor:bottomConstraint.secondAnchor].active = YES;
            [w._view.centerYAnchor constraintEqualToAnchor:view.centerYAnchor constant:final].active = YES;*/
            
            float valF = 0.5f;
            
            if(val != nil)
            {
                valF = [val floatValue];
                if(valF < 0)
                    valF = 0;
                else if(valF > 1.0f)
                    valF = 1.0f;
            }
            
            UILayoutGuide *topView = [UILayoutGuide new];
            [w._view addLayoutGuide:topView];
            [topView.topAnchor constraintEqualToAnchor:topConstraint.secondAnchor].active = YES;
            [topView.bottomAnchor constraintEqualToAnchor:topConstraint.firstAnchor].active = YES;
            
            UILayoutGuide *bottomView = [UILayoutGuide new];
            [w._view addLayoutGuide:bottomView];
            [bottomView.topAnchor constraintEqualToAnchor:bottomConstraint.firstAnchor].active = YES;
            [bottomView.bottomAnchor constraintEqualToAnchor:bottomConstraint.secondAnchor].active = YES;
            
            if(valF <= 0.5f)
                [topView.heightAnchor constraintEqualToAnchor:bottomView.heightAnchor multiplier:valF/0.5f].active = YES;
            else if(valF > 0.5f)
                [bottomView.heightAnchor constraintEqualToAnchor:topView.heightAnchor multiplier:(1.0f - valF)/0.5f].active = YES;
        }
        else
        {
            if(topConstraint != nil)
                topConstraint.active = YES;
            if(bottomConstraint != nil)
                bottomConstraint.active = YES;
        }
        
        if(leftConstraint == nil && rightConstraint == nil)
        {
            [w._view.leftAnchor constraintEqualToAnchor:self._view.leftAnchor constant:w.dMarginLeft].active = YES;
        }
        if(topConstraint == nil && bottomConstraint == nil)
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
