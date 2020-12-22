#import "LGToolbar.h"
#import <Material/Material-Swift.h>
#import <topping/topping-Swift.h>
#import "Topping.h"
#import "LGColorParser.h"
#import "LGDimensionParser.h"
#import "LGDrawableParser.h"

@implementation LGToolbar

- (int)GetContentH
{
    return 49;
}

-(UIView *)CreateComponent
{
    self.toolbar = [LuaToolbar alloc];
    return [self.toolbar initWithFrame:CGRectMake(self.dX, self.dY, self.dWidth, self.dHeight)];
}

-(void)SetupComponent:(UIView *)view
{
    LuaToolbar *toolbar = (LuaToolbar*)self.toolbar;
    toolbar.getView.title = self.android_title;
    toolbar.getView.layer.zPosition = 1000;
    /*IconButton *menuButton = IconButton(image: Icon.cm.menu, tintColor: .white)
    menuButton.pulseColor = .white
    toolbar.leftViews = @[];*/
    if(self.android_titleTextColor != nil)
    {
        toolbar.getView.titleLabel.textColor = [[LGColorParser GetInstance] ParseColor:self.android_titleTextColor];
    }
    toolbar.getView.detail = self.android_subtitle;
    if(self.android_subtitleTextColor != nil)
    {
        toolbar.getView.detailLabel.textColor = [[LGColorParser GetInstance] ParseColor:self.android_titleTextColor];
    }
    
    if(self.android_logo != nil)
    {
        LGDrawableReturn *ldr = [[LGDrawableParser GetInstance] ParseDrawable:self.android_logo];
        if(ldr != nil)
            toolbar.getView.image = ldr.img;
    }
    
    if(self.android_background != nil)
    {
        LGDrawableReturn *ldr = [[LGDrawableParser GetInstance] ParseDrawable:self.android_background];
        if(ldr != nil)
            toolbar.getView.backgroundColor = ldr.color;
    }
    
    @try {
        int dMarginLeft = [[LGDimensionParser GetInstance] GetDimension:self.android_titleMarginStart];
        int dMarginRight = [[LGDimensionParser GetInstance] GetDimension:self.android_contentInsetEnd];
        int dMarginTop = [[LGDimensionParser GetInstance] GetDimension:self.android_titleMarginTop];
        int dMarginBottom = [[LGDimensionParser GetInstance] GetDimension:self.android_titleMarginBottom];
        if(self.android_titleMargin != nil)
        {
            dMarginLeft = [[LGDimensionParser GetInstance] GetDimension:self.android_titleMargin];
            dMarginRight = dMarginLeft;
            dMarginTop = dMarginLeft;
            dMarginBottom = dMarginLeft;
        }
        if(dMarginLeft == -1)
            dMarginLeft = 0;
        if(dMarginRight == -1)
            dMarginRight = 0;
        if(dMarginTop == -1)
            dMarginTop = 0;
        if(dMarginBottom == -1)
            dMarginBottom = 0;
        
        toolbar.getView.titleLabel.layoutMargins = UIEdgeInsetsMake(dMarginTop, dMarginLeft, dMarginBottom, dMarginRight);
    } @catch (...) {}
    
    [super SetupComponent:view];
    
    //[self.cont.view addSubview:self.tbc.view];
}

@end
