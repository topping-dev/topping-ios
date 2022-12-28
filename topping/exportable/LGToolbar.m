#import "LGToolbar.h"
#import <topping/topping-Swift.h>
#import "Topping.h"
#import "LGColorParser.h"
#import "LGDimensionParser.h"
#import "LGDrawableParser.h"
#import "UIImage+Resize.h"

@implementation LGToolbar

- (int)GetContentH
{
    return 49;
}

-(UIView *)CreateComponent
{
    self.toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(self.dX, self.dY, self.dWidth, self.dHeight)];
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    self.titleLabel.text = @"";
    self.title = [[UIBarButtonItem alloc] initWithCustomView:self.titleLabel];
    
    self.spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                            target:nil
                                                                action:nil];
    
    self.startItems = [NSMutableArray array];
    self.endItems = [NSMutableArray array];
    
    [self SetItems];
    
    return self.toolbar;
}

-(void)SetupComponent:(UIView *)view
{
    UIToolbar *toolbar = (UIToolbar*)self.toolbar;
    if(self.android_background == nil)
    {
        self.android_background = @"@color/colorPrimary";
    }
    if(self.android_title != nil)
    {
        self.titleLabel.text = [[LGStringParser GetInstance] GetString:self.android_title];
    }
    if(self.android_titleTextColor != nil)
    {
        self.titleLabel.textColor = [[LGColorParser GetInstance] ParseColor:self.android_titleTextColor];
    }
    /*toolbar.getView.detail = self.android_subtitle;
    if(self.android_subtitleTextColor != nil)
    {
        toolbar.getView.detailLabel.textColor = [[LGColorParser GetInstance] ParseColor:self.android_titleTextColor];
    }
    
    if(self.android_logo != nil)
    {
        LGDrawableReturn *ldr = [[LGDrawableParser GetInstance] ParseDrawable:self.android_logo];
        if(ldr != nil)
            toolbar.getView.image = ldr.img;
    }*/
    
    if(self.android_background != nil)
    {
        LGDrawableReturn *ldr = [[LGDrawableParser GetInstance] ParseDrawable:self.android_background];
        if(ldr != nil)
            toolbar.barTintColor = ldr.color;
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
        
        //toolbar.titleInsets = UIEdgeInsetsMake(dMarginTop, dMarginLeft, dMarginBottom, dMarginRight);
    } @catch (...) {}
    
    
    CGSize val = [self.titleLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.titleLabel.font} context:nil].size;
    self.titleLabel.frame = CGRectMake(self.titleLabel.frame.origin.x, self.titleLabel.frame.origin.y, val.width, val.height);
    
    [super SetupComponent:toolbar];
}

-(void)SetItems {
    NSMutableArray *arr = [NSMutableArray array];
    [arr addObjectsFromArray:self.startItems];
    [arr addObject:self.spacer];
    [arr addObject:self.title];
    [arr addObject:self.spacer];
    [arr addObjectsFromArray:self.endItems];
    [((UIToolbar*)self.toolbar) setItems:arr];
}

-(void)SetMenu:(LuaRef*)menu
{
    
}

-(void)SetLogo:(LuaRef*)logo
{
    //Not supported
}

-(void)SetNavigationIcon:(LuaRef*)navigationIcon
{
    UIToolbar *toolbar = (UIToolbar*)self.toolbar;
    [self.startItems removeAllObjects];
    if(navigationIcon == nil) {
        [self SetItems];
        return;
    }

    LGDrawableReturn *lgr = [[LGDrawableParser GetInstance] ParseDrawableRef:navigationIcon];
    UIImage *img = lgr.img;
    img = [img imageWithSizeAspect:toolbar.frame.size.height - 4];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(navigationTap)];
    
    [self.startItems addObject:leftItem];
    
    [self SetItems];
}

-(void)SetNavigationIconImage:(UIImage *)img {
    UIToolbar *toolbar = (UIToolbar*)self.toolbar;
    [self.startItems removeAllObjects];
    if(img == nil) {
        [self SetItems];
        return;
    }
    
    img = [img imageWithSizeAspect:toolbar.frame.size.height - 4];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(navigationTap)];
    
    [self.startItems addObject:leftItem];
    
    [self SetItems];
}

-(void)SetOverflowIcon:(LuaRef*)overflowIcon
{
    LGDrawableReturn *lgr = [[LGDrawableParser GetInstance] ParseDrawableRef:overflowIcon];
    UIImage *img = lgr.img;
    NSMutableArray *arr = [NSMutableArray arrayWithArray:self.endItems];
    UIBarButtonItem *iv = nil;
    if(arr.count > 0)
    {
        iv = [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(overflowTap)];
    }
    else
    {
        iv = [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(overflowTap)];
        [arr addObject:iv];
        /*UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(navigationTap)];
        singleTap.numberOfTapsRequired = 1;
        [iv setUserInteractionEnabled:YES];
        [iv.getView addGestureRecognizer:singleTap];*/
    }
    self.endItems = arr;
    [self SetItems];
}

-(NSString*)GetTitle
{
    return self.titleLabel.text;
}

-(void)SetTitleInternal:(NSString*)title
{
    self.titleLabel.text = title;
}

-(void)SetTitle:(LuaRef*)ref
{
    self.titleLabel.text = [[LGStringParser GetInstance] GetString:ref.idRef];
}

-(void)SetTitleTextColor:(LuaRef*)color
{
    self.titleLabel.textColor = [[LGColorParser GetInstance] ParseColor:color.idRef];
}

-(void)SetTitleTextApperance:(LuaRef*)ref
{
    /*MDCBottomAppBarView *toolbar = (MDCBottomAppBarView*)self.toolbar;
    MDCNavigationBar *navBar = [toolbar valueForKey:@"navBar"];
    lt.titleTextAppearance = [LuaTextViewAppearance Parse:ref.idRef];*/
}

-(NSString*)GetSubtitle
{
    return @"";
}

-(void)SetSubtitleInternal:(NSString*)subtitle
{
}

-(void)SetSubtitle:(LuaRef*)ref
{
}

-(void)SetSubtitleTextColor:(LuaRef*)color
{
}

-(void)SetSubtitleTextApperance:(LuaRef*)ref
{
}

-(void)navigationTap
{
    if(self.ltNavigationClick != nil)
    {
        [self.ltNavigationClick Call:self :nil];
    }
    if(self.inNavigationClick != nil)
    {
        [self.inNavigationClick onClick:self];
    }
}

-(void)SetNavigationOnClickListener:(LuaTranslator*)lt
{
    self.ltNavigationClick = lt;
}

-(void)SetNavigationOnClickListenerInternal:(id<OnClickListenerInternal>)runnable
{
    self.inNavigationClick = runnable;
}

-(void)overflowTap
{
    if(self.ltOverflowClick != nil)
    {
        [self.ltOverflowClick Call:self :nil];
    }
}

-(void)SetMenuItemClickListener:(LuaTranslator*)lt
{
    self.ltOverflowClick = lt;
}

-(NSString*)GetId
{
    if(self.lua_id != nil)
        return self.lua_id;
    if(self.android_id != nil)
        return self.android_id;
    return [LGToolbar className];
}

+ (NSString*)className
{
    return @"LGToolbar";
}

+(NSMutableDictionary*)luaMethods
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(Create:))
                                        :@selector(Create:)
                                        :[LGRecyclerView class]
                                        :[NSArray arrayWithObjects:[LuaContext class], [NSString class], nil]
                                        :[LGRecyclerView class]]
             forKey:@"Create"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetMenu:)) :@selector(SetMenu:) :nil :MakeArray([LuaRef class]C nil)] forKey:@"SetMenu"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetLogo:)) :@selector(SetLogo:) :nil :MakeArray([LuaStream class]C nil)] forKey:@"SetLogo"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetNavigationIcon:)) :@selector(SetNavigationIcon:) :nil :MakeArray([LuaRef class]C nil)] forKey:@"SetNavigationIcon"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetOverflowIcon:)) :@selector(SetOverflowIcon:) :nil :MakeArray([LuaRef class]C nil)] forKey:@"SetOverflowIcon"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(GetTitle)) :@selector(GetTitle) :[NSString class] :MakeArray(nil)] forKey:@"GetTitle"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetTitleInternal:)) :@selector(SetTitleInternal:) :nil :MakeArray([NSString class]C nil)] forKey:@"SetTitle"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetTitle:)) :@selector(SetTitle:) :nil :MakeArray([LuaRef class]C nil)] forKey:@"SetTitleRef"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetTitleTextColor:)) :@selector(SetTitleTextColor:) :nil :MakeArray([LuaRef class]C nil)] forKey:@"SetTitleTextColor"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetTitleTextApperance:)) :@selector(SetTitleTextApperance:) :nil :MakeArray([LuaRef class]C nil)] forKey:@"SetTitleTextApperance"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(GetSubtitle)) :@selector(GetSubtitle) :[NSString class] :MakeArray(nil)] forKey:@"GetSubtitle"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetSubtitleInternal:)) :@selector(SetSubtitleInternal:) :nil :MakeArray([NSString class]C nil)] forKey:@"SetSubtitle"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetSubtitle:)) :@selector(SetSubtitle:) :nil :MakeArray([LuaRef class]C nil)] forKey:@"SetSubtitleRef"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetSubtitleTextColor:)) :@selector(SetSubtitleTextColor:) :nil :MakeArray([LuaRef class]C nil)] forKey:@"SetSubtitleTextColor"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetSubtitleTextApperance:)) :@selector(SetSubtitleTextApperance:) :nil :MakeArray([LuaRef class]C nil)] forKey:@"SetSubtitleTextApperance"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetNavigationOnClickListener:)) :@selector(SetNavigationOnClickListener:) :nil :MakeArray([LuaTranslator class]C nil)] forKey:@"SetNavigationOnClickListener"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetMenuItemClickListener:)) :@selector(SetMenuItemClickListener:) :nil :MakeArray([LuaTranslator class]C nil)] forKey:@"SetMenuItemClickListener"];
    return dict;
}

@end
