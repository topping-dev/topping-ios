#import "LGConstraintLayout.h"
#import "LuaFunction.h"
#import "Defines.h"
#import "LGDimensionParser.h"
#import "IOSKotlinHelper/IOSKotlinHelper.h"

@implementation LGConstraintLayout

-(void)applyStyles {
    [super applyStyles];
    
    IOSKHMutableDictionary *dict = [[IOSKHMutableDictionary alloc] initWithDictionary:self.xmlProperties copyItems:true];
    self.wrapper = [[IOSKHConstraintLayout alloc] initWithContext:[LuaForm getActiveForm].context attrs:dict self:self];
}

-(void)addSubview:(LGView *)val {
    val.kLayoutParams = [self.wrapper generateLayoutParamsAttrs:[[IOSKHMutableDictionary alloc] initWithDictionary:val.xmlProperties copyItems:YES]];
    [super addSubview:val];
}

-(void)addSubview:(LGView *)val :(NSInteger)index {
    val.kLayoutParams = [self.wrapper generateLayoutParamsAttrs:[[IOSKHMutableDictionary alloc] initWithDictionary:val.xmlProperties copyItems:YES]];
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
    int widthSpec = [self getParentWidthSpec];
    int heightSpec = [self getParentHeightSpec];
    [self.wrapper onMeasureSup:nil widthMeasureSpec:widthSpec heightMeasureSpec:heightSpec];
    [self.wrapper onLayoutSup:nil changed:true left:self.getLeft top:self.getTop right:self.getRight bottom:self.getBottom];
}

+(LGConstraintLayout*)create:(LuaContext *)context
{
    LGConstraintLayout *lcl = [[LGConstraintLayout alloc] init];
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
