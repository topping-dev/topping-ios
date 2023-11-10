#import "LGConstraintLayout.h"
#import "LuaFunction.h"
#import "Defines.h"
#import "LGDimensionParser.h"

@implementation LGConstraintImageFilterButton

-(void)beforeInitSubviews {
    TIOSKHMutableDictionary *dict = [[TIOSKHMutableDictionary alloc] initWithDictionary:self.xmlProperties copyItems:true];
    self.wrapper = [[TIOSKHImageFilterButton alloc] initWithContext:[LuaForm getActiveForm].context attrs:dict self:self selfImageButton:self];
}

-(NSString*)GetId
{
    if(self.lua_id != nil)
        return self.lua_id;
    if(self.android_id != nil)
        return self.android_id;
    return [LGConstraintImageFilterButton className];
}

+ (NSString*)className
{
    return @"LGConstraintImageFilterButton";
}

+(NSMutableDictionary*)luaMethods
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    return dict;
}

@end

@implementation LGConstraintImageFilterView

-(void)beforeInitSubviews {
    TIOSKHMutableDictionary *dict = [[TIOSKHMutableDictionary alloc] initWithDictionary:self.xmlProperties copyItems:true];
    self.wrapper = [[TIOSKHImageFilterView alloc] initWithContext:[LuaForm getActiveForm].context attrs:dict self:self selfImage:self];
}

-(NSString*)GetId
{
    if(self.lua_id != nil)
        return self.lua_id;
    if(self.android_id != nil)
        return self.android_id;
    return [LGConstraintImageFilterView className];
}

+ (NSString*)className
{
    return @"LGConstraintImageFilterView";
}

+(NSMutableDictionary*)luaMethods
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    return dict;
}

@end

@implementation LGConstraintMotionButton

-(void)beforeInitSubviews {
    TIOSKHMutableDictionary *dict = [[TIOSKHMutableDictionary alloc] initWithDictionary:self.xmlProperties copyItems:true];
    self.wrapper = [[TIOSKHMotionButton alloc] initWithContext:[LuaForm getActiveForm].context attrs:dict self:self];
}

-(NSString*)GetId
{
    if(self.lua_id != nil)
        return self.lua_id;
    if(self.android_id != nil)
        return self.android_id;
    return [LGConstraintMotionButton className];
}

+ (NSString*)className
{
    return @"LGConstraintMotionButton";
}

+(NSMutableDictionary*)luaMethods
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    return dict;
}

@end

/*@implementation LGConstraintMotionLabel

-(void)beforeInitSubviews {
    TIOSKHMutableDictionary *dict = [[TIOSKHMutableDictionary alloc] initWithDictionary:self.xmlProperties copyItems:true];
    self.wrapper = [[TIOSKHMotionLabel alloc] initWithContext:[LuaForm getActiveForm].context attrs:dict self:self];
}

-(NSString*)GetId
{
    if(self.lua_id != nil)
        return self.lua_id;
    if(self.android_id != nil)
        return self.android_id;
    return [LGConstraintMotionLabel className];
}

+ (NSString*)className
{
    return @"LGConstraintMotionLabel";
}

+(NSMutableDictionary*)luaMethods
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    return dict;
}

@end*/

@implementation LGConstraintBarrier

-(UIView *)createComponent {
    return nil;
}

-(void)beforeInitSubviews {
    TIOSKHMutableDictionary *dict = [[TIOSKHMutableDictionary alloc] initWithDictionary:self.xmlProperties copyItems:true];
    self.wrapper = [[TIOSKHBarrier alloc] initWithContext:[LuaForm getActiveForm].context attrs:dict self:self];
}

-(NSString*)GetId
{
    if(self.lua_id != nil)
        return self.lua_id;
    if(self.android_id != nil)
        return self.android_id;
    return [LGConstraintBarrier className];
}

+ (NSString*)className
{
    return @"LGConstraintBarrier";
}

+(NSMutableDictionary*)luaMethods
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    return dict;
}

@end

@implementation LGConstraintGroup

-(UIView *)createComponent {
    return nil;
}

-(void)beforeInitSubviews {
    TIOSKHMutableDictionary *dict = [[TIOSKHMutableDictionary alloc] initWithDictionary:self.xmlProperties copyItems:true];
    self.wrapper = [[TIOSKHGroup alloc] initWithContext:[LuaForm getActiveForm].context attrs:dict self:self];
}

-(NSString*)GetId
{
    if(self.lua_id != nil)
        return self.lua_id;
    if(self.android_id != nil)
        return self.android_id;
    return [LGConstraintGroup className];
}

+ (NSString*)className
{
    return @"LGConstraintGroup";
}

+(NSMutableDictionary*)luaMethods
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    return dict;
}

@end

@implementation LGConstraintGuideline

-(UIView *)createComponent {
    return nil;
}

-(void)beforeInitSubviews {
    TIOSKHMutableDictionary *dict = [[TIOSKHMutableDictionary alloc] initWithDictionary:self.xmlProperties copyItems:true];
    self.wrapper = [[TIOSKHGuideline alloc] initWithContext:[LuaForm getActiveForm].context attrs:dict self:self];
}

-(NSString*)GetId
{
    if(self.lua_id != nil)
        return self.lua_id;
    if(self.android_id != nil)
        return self.android_id;
    return [LGConstraintGuideline className];
}

+ (NSString*)className
{
    return @"LGConstraintGuideline";
}

+(NSMutableDictionary*)luaMethods
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    return dict;
}

@end

@implementation LGConstraintPlaceholder

-(UIView *)createComponent {
    return nil;
}

-(void)beforeInitSubviews {
    TIOSKHMutableDictionary *dict = [[TIOSKHMutableDictionary alloc] initWithDictionary:self.xmlProperties copyItems:true];
    self.wrapper = [[TIOSKHPlaceholder alloc] initWithContext:[LuaForm getActiveForm].context attrs:dict self:self];
}

-(NSString*)GetId
{
    if(self.lua_id != nil)
        return self.lua_id;
    if(self.android_id != nil)
        return self.android_id;
    return [LGConstraintPlaceholder className];
}

+ (NSString*)className
{
    return @"LGConstraintPlaceholder";
}

+(NSMutableDictionary*)luaMethods
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    return dict;
}

@end

@implementation LGConstraintReactiveGuide

-(UIView *)createComponent {
    return nil;
}

-(void)beforeInitSubviews {
    TIOSKHMutableDictionary *dict = [[TIOSKHMutableDictionary alloc] initWithDictionary:self.xmlProperties copyItems:true];
    self.wrapper = [[TIOSKHReactiveGuide alloc] initWithContext:[LuaForm getActiveForm].context attrs:dict self:self];
}

-(NSString*)GetId
{
    if(self.lua_id != nil)
        return self.lua_id;
    if(self.android_id != nil)
        return self.android_id;
    return [LGConstraintReactiveGuide className];
}

+ (NSString*)className
{
    return @"LGConstraintReactiveGuide";
}

+(NSMutableDictionary*)luaMethods
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    return dict;
}

@end

@implementation LGConstraintCarousel

-(UIView *)createComponent {
    return nil;
}

-(void)beforeInitSubviews {
    TIOSKHMutableDictionary *dict = [[TIOSKHMutableDictionary alloc] initWithDictionary:self.xmlProperties copyItems:true];
    self.wrapper = [[TIOSKHCarousel alloc] initWithContext:[LuaForm getActiveForm].context attrs:dict self:self];
}

-(NSString*)GetId
{
    if(self.lua_id != nil)
        return self.lua_id;
    if(self.android_id != nil)
        return self.android_id;
    return [LGConstraintCarousel className];
}

+ (NSString*)className
{
    return @"LGConstraintCarousel";
}

+(NSMutableDictionary*)luaMethods
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    return dict;
}

@end

@implementation LGConstraintCircularFlow

-(UIView *)createComponent {
    return nil;
}

-(void)beforeInitSubviews {
    TIOSKHMutableDictionary *dict = [[TIOSKHMutableDictionary alloc] initWithDictionary:self.xmlProperties copyItems:true];
    self.wrapper = [[TIOSKHCircularFlow alloc] initWithContext:[LuaForm getActiveForm].context attrs:dict self:self];
}

-(NSString*)GetId
{
    if(self.lua_id != nil)
        return self.lua_id;
    if(self.android_id != nil)
        return self.android_id;
    return [LGConstraintCircularFlow className];
}

+ (NSString*)className
{
    return @"LGConstraintCircularFlow";
}

+(NSMutableDictionary*)luaMethods
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    return dict;
}

@end

@implementation LGConstraintFlow

-(UIView *)createComponent {
    return nil;
}

-(void)beforeInitSubviews {
    TIOSKHMutableDictionary *dict = [[TIOSKHMutableDictionary alloc] initWithDictionary:self.xmlProperties copyItems:true];
    self.wrapper = [[TIOSKHFlow alloc] initWithContext:[LuaForm getActiveForm].context attrs:dict self:self];
}

-(NSString*)GetId
{
    if(self.lua_id != nil)
        return self.lua_id;
    if(self.android_id != nil)
        return self.android_id;
    return [LGConstraintFlow className];
}

+ (NSString*)className
{
    return @"LGConstraintFlow";
}

+(NSMutableDictionary*)luaMethods
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    return dict;
}

@end

@implementation LGConstraintGrid

-(UIView *)createComponent {
    return nil;
}

-(void)beforeInitSubviews {
    TIOSKHMutableDictionary *dict = [[TIOSKHMutableDictionary alloc] initWithDictionary:self.xmlProperties copyItems:true];
    self.wrapper = [[TIOSKHGrid alloc] initWithContext:[LuaForm getActiveForm].context attrs:dict self:self];
}

-(NSString*)GetId
{
    if(self.lua_id != nil)
        return self.lua_id;
    if(self.android_id != nil)
        return self.android_id;
    return [LGConstraintGrid className];
}

+ (NSString*)className
{
    return @"LGConstraintGrid";
}

+(NSMutableDictionary*)luaMethods
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    return dict;
}

@end

@implementation LGConstraintLayer

-(UIView *)createComponent {
    return nil;
}

-(void)beforeInitSubviews {
    TIOSKHMutableDictionary *dict = [[TIOSKHMutableDictionary alloc] initWithDictionary:self.xmlProperties copyItems:true];
    self.wrapper = [[TIOSKHLayer alloc] initWithContext:[LuaForm getActiveForm].context attrs:dict self:self];
}

-(NSString*)GetId
{
    if(self.lua_id != nil)
        return self.lua_id;
    if(self.android_id != nil)
        return self.android_id;
    return [LGConstraintLayer className];
}

+ (NSString*)className
{
    return @"LGConstraintLayer";
}

+(NSMutableDictionary*)luaMethods
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    return dict;
}

@end

@implementation LGConstraintMotionEffect

-(UIView *)createComponent {
    return nil;
}

-(void)beforeInitSubviews {
    TIOSKHMutableDictionary *dict = [[TIOSKHMutableDictionary alloc] initWithDictionary:self.xmlProperties copyItems:true];
    self.wrapper = [[TIOSKHMotionEffect alloc] initWithContext:[LuaForm getActiveForm].context attrs:dict self:self];
}

-(NSString*)GetId
{
    if(self.lua_id != nil)
        return self.lua_id;
    if(self.android_id != nil)
        return self.android_id;
    return [LGConstraintMotionEffect className];
}

+ (NSString*)className
{
    return @"LGConstraintMotionEffect";
}

+(NSMutableDictionary*)luaMethods
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    return dict;
}

@end

@implementation LGConstraintMotionPlaceholder

-(UIView *)createComponent {
    return nil;
}

-(void)beforeInitSubviews {
    TIOSKHMutableDictionary *dict = [[TIOSKHMutableDictionary alloc] initWithDictionary:self.xmlProperties copyItems:true];
    self.wrapper = [[TIOSKHMotionPlaceholder alloc] initWithContext:[LuaForm getActiveForm].context attrs:dict self:self];
}

-(NSString*)GetId
{
    if(self.lua_id != nil)
        return self.lua_id;
    if(self.android_id != nil)
        return self.android_id;
    return [LGConstraintMotionPlaceholder className];
}

+ (NSString*)className
{
    return @"LGConstraintMotionPlaceholder";
}

+(NSMutableDictionary*)luaMethods
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    return dict;
}

@end

@implementation LGConstraintMotionLayout

-(void)beforeInitSubviews {
    TIOSKHMutableDictionary *dict = [[TIOSKHMutableDictionary alloc] initWithDictionary:self.xmlProperties copyItems:true];
    self.wrapper = [[TIOSKHMotionLayout alloc] initWithContext:[LuaForm getActiveForm].context attrs:dict self:self];
}

-(LGView *)generateLGViewForName:(NSString *)name :(NSArray *)attrs {
    if(COMPARE(name, @"androidx.constraintlayout.helper.widget.Carousel")) {
        return [[LGConstraintCarousel alloc] init];
    } else if(COMPARE(name, @"androidx.constraintlayout.helper.widget.MotionEffect")) {
        return [[LGConstraintMotionEffect alloc] init];
    } else if(COMPARE(name, @"androidx.constraintlayout.helper.widget.MotionPlaceholder")) {
        return [[LGConstraintMotionPlaceholder alloc] init];
    }
    
    return [super generateLGViewForName:name :attrs];
}

-(NSString*)GetId
{
    if(self.lua_id != nil)
        return self.lua_id;
    if(self.android_id != nil)
        return self.android_id;
    return [LGConstraintMotionLayout className];
}

+ (NSString*)className
{
    return @"LGConstraintMotionLayout";
}

+(NSMutableDictionary*)luaMethods
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    return dict;
}

@end

@implementation LGConstraintLayout

-(void)initComponent:(UIView *)view :(LuaContext *)lc {
    [super initComponent:view :lc];
    self.initComponent = true;
}

-(void)beforeInitSubviews {
    TIOSKHMutableDictionary *dict = [[TIOSKHMutableDictionary alloc] initWithDictionary:self.xmlProperties copyItems:true];
    self.wrapper = [[TIOSKHConstraintLayout alloc] initWithContext:[LuaForm getActiveForm].context attrs:dict self:self];
    self.kLayoutParams = [self.wrapper generateLayoutParamsAttrs:[[TIOSKHMutableDictionary alloc] initWithDictionary:self.xmlProperties copyItems:YES]];
}

-(void)readWidthHeight {
    [super readWidthHeight];
    for(LGView *subView in self.subviews) {
        [subView readWidthHeight];
    }
}

/*-(void)onMeasure:(int)widthMeasureSpec :(int)heightMeasureSpec {
    if([self callTMethod:@"onMeasure" :[NSNumber numberWithInt:widthMeasureSpec], [NSNumber numberWithInt:heightMeasureSpec], nil])
        return;
}*/

-(LGView *)generateLGViewForName:(NSString *)name :(NSArray *)attrs {
    if(COMPARE(name, @"androidx.constraintlayout.widget.Barrier")) {
        return [[LGConstraintBarrier alloc] init];
    } else if(COMPARE(name, @"androidx.constraintlayout.widget.Group")) {
        return [[LGConstraintGroup alloc] init];
    } else if(COMPARE(name, @"androidx.constraintlayout.widget.Guideline")) {
        return [[LGConstraintGuideline alloc] init];
    } else if(COMPARE(name, @"androidx.constraintlayout.widget.Placeholder")) {
        return [[LGConstraintPlaceholder alloc] init];
    } else if(COMPARE(name, @"androidx.constraintlayout.widget.ReactiveGuide")) {
        return [[LGConstraintReactiveGuide alloc] init];
    } else if(COMPARE(name, @"androidx.constraintlayout.widget.motion.widget.MotionLayout")) {
        return [[LGConstraintMotionLayout alloc] init];
    } else if(COMPARE(name, @"androidx.constraintlayout.widget.utils.ImageFilterButton")) {
        return [[LGConstraintImageFilterButton alloc] init];
    } else if(COMPARE(name, @"androidx.constraintlayout.widget.utils.ImageFilterView")) {
        return [[LGConstraintImageFilterView alloc] init];
    } else if(COMPARE(name, @"androidx.constraintlayout.widget.utils.MotionButton")) {
        return [[LGConstraintMotionButton alloc] init];
    } /*else if(COMPARE(name, @"androidx.constraintlayout.widget.utils.MotionLabel")) {
        return [[LGConstraintMotionLabel alloc] init];
    }*/
    else if(COMPARE(name, @"androidx.constraintlayout.helper.widget.CircularFlow")) {
        return [[LGConstraintCircularFlow alloc] init];
    } else if(COMPARE(name, @"androidx.constraintlayout.helper.widget.Flow")) {
        return [[LGConstraintFlow alloc] init];
    } else if(COMPARE(name, @"androidx.constraintlayout.helper.widget.Grid")) {
        return [[LGConstraintGrid alloc] init];
    } else if(COMPARE(name, @"androidx.constraintlayout.helper.widget.Layer")) {
        return [[LGConstraintLayer alloc] init];
    }
    return nil;
}

-(void)addSubview:(LGView *)val {
    val.kLayoutParams = [self.wrapper generateLayoutParamsAttrs:[[TIOSKHMutableDictionary alloc] initWithDictionary:val.xmlProperties copyItems:YES]];
    [super addSubview:val];
}

-(void)addSubview:(LGView *)val :(NSInteger)index {
    val.kLayoutParams = [self.wrapper generateLayoutParamsAttrs:[[TIOSKHMutableDictionary alloc] initWithDictionary:val.xmlProperties copyItems:YES]];
    [super addSubview:val :index];
}

-(void)resize
{
    if(!self.widthSpecSet) {
        self.dWidthSpec = [self getParentWidthSpec];
        self.widthSpecSet = true;
    }
    if(!self.heightSpecSet) {
        self.dHeightSpec = [self getParentHeightSpec];
        self.heightSpecSet = true;
    }
    [self resizeInternal];
}

-(void)resizeInternal
{
    [self readWidthHeight];
    if(self.initComponent) {
        int widthSpec = [self getParentWidthSpec];
        int heightSpec = [self getParentHeightSpec];
        [self.wrapper setMDirtyHierarchy:true];
        [self.wrapper onMeasureSup:nil widthMeasureSpec:widthSpec heightMeasureSpec:heightSpec];
        [self.wrapper onLayoutSup:nil changed:true left:self.getLeft top:self.getTop right:self.getRight bottom:self.getBottom];
    }
}

+(LGConstraintLayout*)create:(LuaContext *)context
{
    LGConstraintLayout *lcl = [[LGConstraintLayout alloc] init];
    lcl.lc = context;
    [lcl initProperties];
    return lcl;
}

-(NSString*)GetId
{
    if(self.lua_id != nil)
        return self.lua_id;
    if(self.android_id != nil)
        return self.android_id;
    return [LGConstraintLayout className];
}

+ (NSString*)className
{
    return @"LGConstraintLayout";
}

+(NSMutableDictionary*)luaMethods
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(create:))
                                        :@selector(create:)
                                        :[LGConstraintLayout class]
                                        :[NSArray arrayWithObjects:[LuaContext class], [NSString class], nil]
                                        :[LGConstraintLayout class]]
             forKey:@"create"];
    return dict;
}

@end
