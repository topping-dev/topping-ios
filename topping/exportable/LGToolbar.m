#import "LGToolbar.h"
#import <topping/topping-Swift.h>
#import <MaterialComponents/MaterialNavigationBar.h>
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
    self.toolbar = [[MDCNavigationBar alloc] initWithFrame:CGRectMake(self.dX, self.dY, self.dWidth, self.dHeight)];
    return self.toolbar;
}

-(void)SetupComponent:(UIView *)view
{
    MDCNavigationBar *toolbar = (MDCNavigationBar*)self.toolbar;
    if(self.android_background == nil)
    {
        self.android_background = @"@color/colorPrimary";
    }
    if(self.android_title != nil)
    {
        toolbar.title = [[LGStringParser GetInstance] GetString:self.android_title];
    }
    if(self.android_titleTextColor != nil)
    {
        toolbar.titleTextColor = [[LGColorParser GetInstance] ParseColor:self.android_titleTextColor];
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
            toolbar.backgroundColor = ldr.color;
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
        
        toolbar.titleInsets = UIEdgeInsetsMake(dMarginTop, dMarginLeft, dMarginBottom, dMarginRight);
    } @catch (...) {}
    
    [super SetupComponent:toolbar];
}

-(void)SetMenu:(LuaRef*)menuRef
{
    
}

-(void)SetLogo:(LuaStream*)logoStream
{
    //Not supported
}

-(void)SetNavigationIcon:(LuaStream*)navigationIconStream
{
    MDCNavigationBar *toolbar = (MDCNavigationBar*)self.toolbar;
    UIImage *img = (UIImage*)navigationIconStream.nonStreamData;
    NSMutableArray *arr = [NSMutableArray arrayWithArray:toolbar.leadingBarButtonItems];
    UIBarButtonItem *iv = nil;
    if(arr.count > 0)
    {
        iv = [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(navigationTap)];
    }
    else
    {
        iv = [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(navigationTap)];
        [arr addObject:iv];
        /*UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(navigationTap)];
        singleTap.numberOfTapsRequired = 1;
        [iv setUserInteractionEnabled:YES];
        [iv.getView addGestureRecognizer:singleTap];*/
    }
    toolbar.leadingBarButtonItems = arr;
}

-(void)SetOverflowIcon:(LuaStream*)overflowIconStream
{
    MDCNavigationBar *toolbar = (MDCNavigationBar*)self.toolbar;
    UIImage *img = (UIImage*)overflowIconStream.nonStreamData;
    NSMutableArray *arr = [NSMutableArray arrayWithArray:toolbar.leadingBarButtonItems];
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
    toolbar.trailingBarButtonItems = arr;
}

-(NSString*)GetTitle
{
    MDCNavigationBar *toolbar = (MDCNavigationBar*)self.toolbar;
    return toolbar.title;
}

-(void)SetTitle:(NSString*)title
{
    MDCNavigationBar *toolbar = (MDCNavigationBar*)self.toolbar;
    toolbar.title = title;
}

-(void)SetTitleRef:(LuaRef*)ref
{
    MDCNavigationBar *toolbar = (MDCNavigationBar*)self.toolbar;
    toolbar.title = [[LGStringParser GetInstance] GetString:ref.idRef];
}

-(void)SetTitleTextColor:(NSString*)color
{
    MDCNavigationBar *toolbar = (MDCNavigationBar*)self.toolbar;
    toolbar.titleTextColor = [[LGColorParser GetInstance] ParseColor:color];
}

-(void)SetTitleTextColorRef:(LuaRef*)color
{
    MDCNavigationBar *toolbar = (MDCNavigationBar*)self.toolbar;
    toolbar.titleTextColor = [[LGColorParser GetInstance] ParseColor:color.idRef];
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

-(void)SetSubtitle:(NSString*)subtitle
{
}

-(void)SetSubtitleRef:(LuaRef*)ref
{
}

-(void)SetSubtitleTextColor:(NSString*)color
{
}

-(void)SetSubtitleTextColorRef:(LuaRef*)color
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
}

-(void)SetNavigationOnClickListener:(LuaTranslator*)lt
{
    self.ltNavigationClick = lt;
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
    if(self.android_tag != nil)
        return self.android_tag;
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
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetNavigationIcon:)) :@selector(SetNavigationIcon:) :nil :MakeArray([LuaStream class]C nil)] forKey:@"SetNavigationIcon"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetOverflowIcon:)) :@selector(SetOverflowIcon:) :nil :MakeArray([LuaStream class]C nil)] forKey:@"SetOverflowIcon"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(GetTitle)) :@selector(GetTitle) :[NSString class] :MakeArray(nil)] forKey:@"GetTitle"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetTitle:)) :@selector(SetTitle:) :nil :MakeArray([NSString class]C nil)] forKey:@"SetTitle"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetTitleRef:)) :@selector(SetTitleRef:) :nil :MakeArray([LuaRef class]C nil)] forKey:@"SetTitleRef"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetTitleTextColor:)) :@selector(SetTitleTextColor:) :nil :MakeArray([NSString class]C nil)] forKey:@"SetTitleTextColor"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetTitleTextColorRef:)) :@selector(SetTitleTextColorRef:) :nil :MakeArray([LuaRef class]C nil)] forKey:@"SetTitleTextColorRef"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetTitleTextApperance:)) :@selector(SetTitleTextApperance:) :nil :MakeArray([LuaRef class]C nil)] forKey:@"SetTitleTextApperance"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(GetSubtitle)) :@selector(GetSubtitle) :[NSString class] :MakeArray(nil)] forKey:@"GetSubtitle"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetSubtitle:)) :@selector(SetSubtitle:) :nil :MakeArray([NSString class]C nil)] forKey:@"SetSubtitle"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetSubtitleRef:)) :@selector(SetSubtitleRef:) :nil :MakeArray([LuaRef class]C nil)] forKey:@"SetSubtitleRef"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetSubtitleTextColor:)) :@selector(SetSubtitleTextColor:) :nil :MakeArray([NSString class]C nil)] forKey:@"SetSubtitleTextColor"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetSubtitleTextColorRef::)) :@selector(SetSubtitleTextColorRef::) :nil :MakeArray([LuaRef class]C nil)] forKey:@"SetSubtitleTextColorRef:"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetSubtitleTextApperance:)) :@selector(SetSubtitleTextApperance:) :nil :MakeArray([LuaRef class]C nil)] forKey:@"SetSubtitleTextApperance"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetNavigationOnClickListener:)) :@selector(SetNavigationOnClickListener:) :nil :MakeArray([LuaTranslator class]C nil)] forKey:@"SetNavigationOnClickListener"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(SetMenuItemClickListener:)) :@selector(SetMenuItemClickListener:) :nil :MakeArray([LuaTranslator class]C nil)] forKey:@"SetMenuItemClickListener"];
    return dict;
}

@end
