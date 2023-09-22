#import "LGToolbar.h"
#import <ToppingIOSKotlinHelper/ToppingIOSKotlinHelper.h>
#import <Topping/Topping-Swift.h>
#import "Topping.h"
#import "LGColorParser.h"
#import "LGDimensionParser.h"
#import "LGDrawableParser.h"
#import "UIImage+Resize.h"

@implementation LGToolbar

- (int)getContentH
{
    return 49;
}

-(UIView *)createComponent
{
    self.toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(self.dX, self.dY, self.dWidth, self.dHeight)];
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    self.titleLabel.text = @"";
    self.title_ = [[UIBarButtonItem alloc] initWithCustomView:self.titleLabel];
    
    self.spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                            target:nil
                                                                action:nil];
    
    self.startItems = [NSMutableArray array];
    self.endItems = [NSMutableArray array];
    
    [self SetItems];
    
    return self.toolbar;
}

-(void)setupComponent:(UIView *)view
{
    UIToolbar *toolbar = (UIToolbar*)self.toolbar;
    if(self.android_background == nil)
    {
        self.android_background = @"@color/transparent";
    }
    if(self.android_title != nil)
    {
        self.titleLabel.text = [[LGStringParser getInstance] getString:self.android_title];
    }
    if(self.android_titleTextColor != nil)
    {
        self.titleLabel.textColor = [[LGColorParser getInstance] parseColor:self.android_titleTextColor];
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
        if([self.android_background isEqualToString:@"@color/transparent"])
        {
            [toolbar setBackgroundImage:[UIImage new]
                          forToolbarPosition:UIToolbarPositionAny
                                  barMetrics:UIBarMetricsDefault];
            toolbar.backgroundColor = [UIColor clearColor];
        }
        else {
            NSObject *obj = [[LGValueParser getInstance] getValue:self.android_background];
            if([obj isKindOfClass:[LGDrawableReturn class]]) {
                LGDrawableReturn *ldr = (LGDrawableReturn*)obj;
                toolbar.barTintColor = [UIColor colorWithPatternImage:ldr.img];
            } else if(obj != nil) {
                toolbar.barTintColor = (UIColor*)obj;
            }
        }
    }
    
    @try {
        int dMarginLeft = [[LGDimensionParser getInstance] getDimension:self.android_titleMarginStart];
        int dMarginRight = [[LGDimensionParser getInstance] getDimension:self.android_contentInsetEnd];
        int dMarginTop = [[LGDimensionParser getInstance] getDimension:self.android_titleMarginTop];
        int dMarginBottom = [[LGDimensionParser getInstance] getDimension:self.android_titleMarginBottom];
        if(self.android_titleMargin != nil)
        {
            dMarginLeft = [[LGDimensionParser getInstance] getDimension:self.android_titleMargin];
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
    
    [super setupComponent:toolbar];
}

-(void)SetItems {
    NSMutableArray *arr = [NSMutableArray array];
    [arr addObjectsFromArray:self.startItems];
    [arr addObject:self.spacer];
    [arr addObject:self.title_];
    [arr addObject:self.spacer];
    [arr addObjectsFromArray:self.endItems];
    [((UIToolbar*)self.toolbar) setItems:arr];
}

-(void)setMenu:(LuaRef*)menu
{
    
}

-(void)setLogo:(LuaRef*)logo
{
    //Not supported
}

-(void)setNavigationIcon:(LuaRef*)navigationIcon
{
    UIToolbar *toolbar = (UIToolbar*)self.toolbar;
    [self.startItems removeAllObjects];
    if(navigationIcon == nil) {
        [self SetItems];
        return;
    }

    LGDrawableReturn *lgr = [[LGDrawableParser getInstance] parseDrawableRef:navigationIcon];
    UIImage *img = lgr.img;
    img = [img imageWithSizeAspect:toolbar.frame.size.height - 4];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(navigationTap)];
    
    [self.startItems addObject:leftItem];
    
    [self SetItems];
}

-(void)setNavigationIconImage:(UIImage *)img {
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

-(void)setOverflowIcon:(LuaRef*)overflowIcon
{
    LGDrawableReturn *lgr = [[LGDrawableParser getInstance] parseDrawableRef:overflowIcon];
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

-(NSString*)getTitle
{
    return self.titleLabel.text;
}

-(void)setTitleInternal:(NSString*)title
{
    self.titleLabel.text = title;
}

-(void)setTitle:(LuaRef*)ref
{
    self.titleLabel.text = [[LGStringParser getInstance] getString:ref.idRef];
}

-(void)setTitleTextColor:(LuaRef*)color
{
    self.titleLabel.textColor = [[LGColorParser getInstance] parseColor:color.idRef];
}

-(void)setTitleTextApperance:(LuaRef*)ref
{
    /*MDCBottomAppBarView *toolbar = (MDCBottomAppBarView*)self.toolbar;
    MDCNavigationBar *navBar = [toolbar valueForKey:@"navBar"];
    lt.titleTextAppearance = [LuaTextViewAppearance Parse:ref.idRef];*/
}

-(NSString*)getSubtitle
{
    return @"";
}

-(void)setSubtitleInternal:(NSString*)subtitle
{
}

-(void)setSubtitle:(LuaRef*)ref
{
}

-(void)setSubtitleTextColor:(LuaRef*)color
{
}

-(void)setSubtitleTextApperance:(LuaRef*)ref
{
}

-(void)navigationTap
{
    if(self.ltNavigationClick != nil)
    {
        [self.ltNavigationClick call];
    }
    if(self.inNavigationClick != nil)
    {
        [self.inNavigationClick onClick:self];
    }
}

-(void)setNavigationOnClickListener:(LuaTranslator*)lt
{
    self.ltNavigationClick = lt;
}

-(void)setNavigationOnClickListenerInternal:(id<OnClickListenerInternal>)runnable
{
    self.inNavigationClick = runnable;
}

-(void)overflowTap
{
    if(self.ltOverflowClick != nil)
    {
        [self.ltOverflowClick call:self :nil];
    }
}

-(void)setMenuItemClickListener:(LuaTranslator*)lt
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
    [dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(create:))
                                        :@selector(create:)
                                        :[LGRecyclerView class]
                                        :[NSArray arrayWithObjects:[LuaContext class], [NSString class], nil]
                                        :[LGRecyclerView class]]
             forKey:@"create"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(setMenu:)) :@selector(setMenu:) :nil :MakeArray([LuaRef class]C nil)] forKey:@"setMenu"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(setLogo:)) :@selector(setLogo:) :nil :MakeArray([LuaStream class]C nil)] forKey:@"setLogo"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(setNavigationIcon:)) :@selector(setNavigationIcon:) :nil :MakeArray([LuaRef class]C nil)] forKey:@"setNavigationIcon"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(setOverflowIcon:)) :@selector(setOverflowIcon:) :nil :MakeArray([LuaRef class]C nil)] forKey:@"setOverflowIcon"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(getTitle)) :@selector(getTitle) :[NSString class] :MakeArray(nil)] forKey:@"getTitle"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(setTitleInternal:)) :@selector(setTitleInternal:) :nil :MakeArray([NSString class]C nil)] forKey:@"setTitle"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(setTitle:)) :@selector(setTitle:) :nil :MakeArray([LuaRef class]C nil)] forKey:@"setTitleRef"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(setTitleTextColor:)) :@selector(setTitleTextColor:) :nil :MakeArray([LuaRef class]C nil)] forKey:@"setTitleTextColor"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(setTitleTextApperance:)) :@selector(setTitleTextApperance:) :nil :MakeArray([LuaRef class]C nil)] forKey:@"setTitleTextApperance"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(getSubtitle)) :@selector(getSubtitle) :[NSString class] :MakeArray(nil)] forKey:@"getSubtitle"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(setSubtitleInternal:)) :@selector(setSubtitleInternal:) :nil :MakeArray([NSString class]C nil)] forKey:@"setSubtitle"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(setSubtitle:)) :@selector(setSubtitle:) :nil :MakeArray([LuaRef class]C nil)] forKey:@"setSubtitleRef"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(setSubtitleTextColor:)) :@selector(setSubtitleTextColor:) :nil :MakeArray([LuaRef class]C nil)] forKey:@"setSubtitleTextColor"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(setSubtitleTextApperance:)) :@selector(setSubtitleTextApperance:) :nil :MakeArray([LuaRef class]C nil)] forKey:@"setSubtitleTextApperance"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(setNavigationOnClickListener:)) :@selector(setNavigationOnClickListener:) :nil :MakeArray([LuaTranslator class]C nil)] forKey:@"setNavigationOnClickListener"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(setMenuItemClickListener:)) :@selector(setMenuItemClickListener:) :nil :MakeArray([LuaTranslator class]C nil)] forKey:@"setMenuItemClickListener"];
    return dict;
}

@end
