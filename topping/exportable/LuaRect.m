#import "LuaRect.h"
#import "LuaAll.h"

@implementation LuaRect

- (instancetype)init
{
    self = [super init];
    if (self) {
        rect = CGRectMake(0, 0, 0, 0);
    }
    return self;
}

+(LuaRect *)create
{
    return [[LuaRect alloc] init];
}

+(LuaRect *)createPar:(float)left :(float)top :(float)right :(float)bottom
{
    LuaRect *rect = [[LuaRect alloc] init];
    [rect set:left :top :right :bottom];
    return rect;    
}

-(void)set:(float)left :(float)top :(float)right :(float)bottom
{
    rect = CGRectMake(left, top, right - left, bottom - top);
}

-(void)setLeft:(float)left {
    rect.origin.x = left;
}

-(void)setRight:(float)right {
    rect.size.width = right - self.left;
}

-(void)setTop:(float)top {
    rect.origin.y = top;
}

- (void)setBottom:(float)bottom {
    rect.size.height = bottom - self.top;
}

-(float)getLeft
{
    return rect.origin.x;
}

-(float)getRight
{
    return rect.origin.x + rect.size.width;
}

-(float)getTop
{
    return rect.origin.y;
}

-(float)getBottom
{
    return rect.origin.y + rect.size.height;
}

-(void)setCGRect:(CGRect)rectP {
    rect = rectP;
}

-(CGRect)getCGRect {
    return rect;
}

-(NSString*)GetId
{
	return @"LuaRect";
}

+ (NSString*)className
{
	return @"LuaRect";
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(create))
										:@selector(create)
										:[NSObject class]
										:[NSArray arrayWithObjects:nil]
										:[LuaRect class]]
			 forKey:@"create"];
    [dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(createPar::::))
										:@selector(createPar::::)
										:[NSObject class]
										:[NSArray arrayWithObjects:[LuaFloat class], [LuaFloat class], [LuaFloat class], [LuaFloat class], nil]
										:[LuaRect class]]
			 forKey:@"createPar"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(set::::))
									   :@selector(set::::)
									   :nil
									   :[NSArray arrayWithObjects:[LuaFloat class], [LuaFloat class], [LuaFloat class], [LuaFloat class], nil]]
			 forKey:@"set"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(getLeft))
									   :@selector(getLeft)
									   :[LuaFloat class]
									   :MakeArray(nil)]
			 forKey:@"getLeft"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(getRight))
									   :@selector(getRight)
									   :[LuaFloat class]
									   :MakeArray(nil)]
			 forKey:@"getRight"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(getTop))
									   :@selector(getTop)
									   :[LuaFloat class]
									   :MakeArray(nil)]
			 forKey:@"getTop"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(getBottom))
									   :@selector(getBottom)
									   :[LuaFloat class]
									   :MakeArray(nil)]
			 forKey:@"getBottom"];
	return dict;
}

@end
