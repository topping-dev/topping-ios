#import "LuaColor.h"
#import "LuaAll.h"

@implementation LuaColor

@synthesize colorValue;

+(LuaColor *)FromString:(NSString *)colorStr
{
    LuaColor *color = [[LuaColor alloc] init];
    color.colorValue = [[LGColorParser GetInstance] ParseColor:colorStr];
    return color;
}

+(LuaColor *)CreateFromARGB:(int)alpha :(int)red :(int)green :(int)blue
{
    LuaColor *color = [[LuaColor alloc] init];
    color.colorValue = [UIColor colorWithRed:red / 255.0f green:green / 255.0f blue:blue / 255.0f alpha:alpha / 255.0f];
    return color;
}

+(LuaColor *)CreateFromRGB:(int)red :(int)green :(int)blue
{
    LuaColor *color = [[LuaColor alloc] init];
    color.colorValue = [UIColor colorWithRed:red / 255.0f green:green / 255.0f blue:blue / 255.0f alpha:1.0f];
    return color;
}

/**
 * Internal
 */
+(LuaColor*)ColorFromInt:(int)color
{
    unsigned int A = [LuaColor Alpha:color];
    int R = [LuaColor Red:color];
    int G = [LuaColor Green:color];
    int B = [LuaColor Blue:color];
    
    return [LuaColor CreateFromARGB:A :R :G :B];
}

/**
 * Return the alpha component of a color int. This is the same as saying
 * color >>> 24
 */
+(unsigned int)Alpha:(unsigned int) color
{
    return color >> 24;
}

/**
 * Return the red component of a color int. This is the same as saying
 * (color >> 16) & 0xFF
 */
+(int)Red:(int) color
{
    return (color >> 16) & 0xFF;
}

/**
 * Return the green component of a color int. This is the same as saying
 * (color >> 8) & 0xFF
 */
+(int)Green:(int) color
{
    return (color >> 8) & 0xFF;
}

/**
 * Return the blue component of a color int. This is the same as saying
 * color & 0xFF
 */
+(int)Blue:(int) color
{
    return color & 0xFF;
}

-(NSString*)GetId
{
	return @"LuaColor";
}

+ (NSString*)className
{
	return @"LuaColor";
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(FromString:))
										:@selector(FromString:)
										:[NSObject class]
										:[NSArray arrayWithObjects:[NSString class], nil]
										:[LuaColor class]]
			 forKey:@"FromString"];
    [dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(CreateFromARGB::::))
										:@selector(CreateFromARGB::::)
										:[NSObject class]
										:[NSArray arrayWithObjects:[LuaInt class], [LuaInt class], [LuaInt class], [LuaInt class], nil]
										:[LuaColor class]]
			 forKey:@"CreateFromARGB"];
    [dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(CreateFromRGB:::))
										:@selector(CreateFromRGB:::)
										:[NSObject class]
										:[NSArray arrayWithObjects:[LuaInt class], [LuaInt class], [LuaInt class], nil]
										:[LuaColor class]]
			 forKey:@"CreateFromRGB"];
	return dict;
}

+(NSMutableDictionary *)luaStaticVars
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	[dict setObject:[NSNumber numberWithInt:0xff000000] forKey:@"BLACK"];
	[dict setObject:[NSNumber numberWithInt:0xff0000ff] forKey:@"BLUE"];
    [dict setObject:[NSNumber numberWithInt:0xff00ffff] forKey:@"CYAN"];
	[dict setObject:[NSNumber numberWithInt:0xff444444] forKey:@"DKGRAY"];
    [dict setObject:[NSNumber numberWithInt:0xff888888] forKey:@"GRAY"];
	[dict setObject:[NSNumber numberWithInt:0xff00ff00] forKey:@"GREEN"];
    [dict setObject:[NSNumber numberWithInt:0xffcccccc] forKey:@"LTGRAY"];
	[dict setObject:[NSNumber numberWithInt:0xffff00ff] forKey:@"MAGENTA"];
    [dict setObject:[NSNumber numberWithInt:0xffff0000] forKey:@"RED"];
	[dict setObject:[NSNumber numberWithInt:0x00000000] forKey:@"TRANSPARENT"];
    [dict setObject:[NSNumber numberWithInt:0xffffffff] forKey:@"WHITE"];
	[dict setObject:[NSNumber numberWithInt:0xffffff00] forKey:@"YELLOW"];
	return dict;
}

@end
