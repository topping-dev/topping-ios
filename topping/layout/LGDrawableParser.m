#import "LGDrawableParser.h"
#import "Defines.h"
#import "LGParser.h"
#import "DisplayMetrics.h"
#import "LuaResource.h"
#import "GDataXMLNode.h"
#import "UIColor+Lum.h"
#import <Topping/Topping-Swift.h>
#import "IOSKotlinHelper/IOSKotlinHelper.h"

@implementation LGDrawableReturn

-(UIImage *)getImage {
    if(self.img != nil)
        return self.img;
    else if(self.vector) {
        VectorDrawable *drawable = (VectorDrawable*)self.vector;
        VectorTheme *vt = [[VectorTheme alloc] initWithColor:[UIColor blackColor]];
        VectorView *vv = [[VectorView alloc] initWithTheme:vt resources:vt];
        CGFloat width = drawable.baseWidth, height = drawable.baseHeight;
        if(width == 0)
            width = height;
        else if(height == 0)
            height = width;
        vv.drawable = drawable;
        vv.frame = CGRectMake(0, 0, width, height);
        return [vv asImage];
    }
    return nil;
}

-(UIImage *)getImage:(CGSize)size {
    if(self.img != nil)
        return self.img;
    else if(self.vector) {
        VectorTheme *vt = [[VectorTheme alloc] initWithColor:[UIColor blackColor]];
        VectorView *vv = [[VectorView alloc] initWithTheme:vt resources:vt];
        CGFloat width = size.width, height = size.height;
        if(width == 0)
            width = height;
        else if(height == 0)
            height = width;
        VectorDrawable *drawable = (VectorDrawable*)self.vector;
        vv.drawable = drawable;
        vv.frame = CGRectMake(0, 0, width, height);
        return [vv asImage];
    }
    return nil;
}

-(UIImage*)getImageForState:(CGSize)size :(int)state :(UIImage*)def {
    if(!self.hasState || state == UIControlStateNormal) {
        return [self getImage:size];
    }
    else if(state == UIControlStateSelected && (self.state_selected || self.state_pressed || self.state_checked)) {
        return [self getImage:size];
    } else if(state == UIControlStateDisabled && !self.state_enabled) {
        return [self getImage:size];
    }
    return def;
}

@end

@implementation VectorTheme

- (instancetype)initWithColor:(UIColor*)color
{
    self = [super init];
    if (self) {
        self.color = color;
    }
    return self;
}

- (UIColor *)colorFromThemeWithNamed:(NSString *)name {
    return self.color;
}

- (UIColor *)colorFromResourcesWithNamed:(NSString *)name {
    return self.color;
}

@end

@implementation LGDrawableParser

- (id) init
{
	self = [super init];
	if (self != nil) {
	}
	return self;
}

-(void)initialize
{
    NSArray *drawableDirectories = [LuaResource getResourceDirectories:LUA_DRAWABLE_FOLDER];
    self.clearedDirectoryList = [[LGParser getInstance] tester:drawableDirectories :LUA_DRAWABLE_FOLDER];
    [self.clearedDirectoryList sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2)
     {
         NSString *aData = (NSString*)((DynamicResource*)obj1).data;
         NSString *bData = (NSString*)((DynamicResource*)obj2).data;
         if(COMPARE(aData, bData))
             return NSOrderedSame;
         else if(aData.length > bData.length)
             return NSOrderedAscending;
         else
             return NSOrderedDescending;
     }];
    self.drawableMap = [NSMutableDictionary dictionary];
    for(DynamicResource *dr in self.clearedDirectoryList)
    {
        NSArray *files = [LuaResource getResourceFiles:(NSString*)dr.data];
        [files enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *filename = (NSString *)obj;
            NSString *fNameNoExt = [filename stringByDeletingPathExtension];
            [self.drawableMap setObject:fNameNoExt forKey:fNameNoExt];
        }];
    }
}

+(LGDrawableParser *) getInstance
{
	return [LGParser getInstance].pDrawable;
}

-(LGDrawableReturn *) parseDrawableRef:(LuaRef *)drawable
{
    return [self parseDrawableRef:drawable :0];
}

-(LGDrawableReturn *) parseDrawableRef:(LuaRef *)drawable :(int)tileMode
{
    NSString *val = (NSString*)[[LGValueParser getInstance] getValue:drawable.idRef];
    return [self parseDrawable:val :tileMode];
}

-(LGDrawableReturn *) parseDrawable:(NSString *)drawable
{
	return [self parseDrawable:drawable :0];
}

-(LGDrawableReturn *) parseDrawable:(NSString *)drawable :(int)tileMode
{
    if(drawable == nil)
        return nil;
    UIColor *color = [[LGColorParser getInstance] parseColor:drawable];
    if(color != nil)
    {
        LGDrawableReturn *ldr = [[LGDrawableReturn alloc] init];
        ldr.img = [UIColor imageFromColor:color];
        return ldr;
    }
    NSArray *arr = SPLIT(drawable, @"/");
    UIImage *retVal = nil;
    if(CONTAINS([arr objectAtIndex:0], @"drawable")
       || CONTAINS([arr objectAtIndex:0], @"mipmap"))
    {
        if([arr count] > 1)
        {
            NSString *name = [arr objectAtIndex:1];
            for(DynamicResource *dr in self.clearedDirectoryList)
            {
                LuaStream *stream = nil;
                NSString *path = [[sToppingEngine getUIRoot] stringByAppendingPathComponent:(NSString*)dr.data];
                stream = [LuaResource getResource:path :APPEND(name, @".png")];
                if(stream == nil)
                {
                    stream = [LuaResource getResource:path :APPEND(name, @".jpg")];
                    if(stream == nil)
                    {
                        stream = [LuaResource getResource:path :APPEND(name, @".gif")];
                        if(stream == nil)
                        {
                            return [self parseXML:APPEND(name, @".xml") :tileMode];
                        }
                    }
                }
                if(stream != nil)
                {
                    retVal = [UIImage imageWithData:[stream getData]];
                }
                if(retVal != nil)
                {
                    break;
                }
            }
        }
        LGDrawableReturn *ldr = [[LGDrawableReturn alloc] init];
        if(tileMode > 0)
        {
            ldr.img = [UIColor imageFromColor:[UIColor colorWithPatternImage:ldr.img]];
        }
        else
            ldr.img = retVal;
        return ldr;
    }
    
    return nil;
}

-(LGDrawableReturn *) parseXML:(NSString *)filename :(int)tileMode
{
    for(DynamicResource *dr in self.clearedDirectoryList)
    {
        NSString *path = [[sToppingEngine getUIRoot] stringByAppendingPathComponent:(NSString*)dr.data];
        LuaStream *ls = [LuaResource getResource:path :filename];
        if(ls == NULL)
            continue;
        
        NSData *dat = [ls getData];
        
        GDataXMLDocument *xml = [[GDataXMLDocument alloc] initWithData:dat error:nil];
        if(xml == nil)
        {
            NSLog(@"Cannot read xml file %@", filename);
            return nil;
        }
        
        GDataXMLElement *root = [xml rootElement];
        
        if([root kind] != GDataXMLElementKind)
            return nil;
        
        if(COMPARE([root name], @"bitmap")
           || COMPARE([root name], @"nine-patch"))
        {
            return [self parseBitmap:root];
        }
        else if(COMPARE([root name], @"layer-list"))
        {
            return [self parseLayer:root];
        }
        else if(COMPARE([root name], @"selector"))
        {
            return [self parseStateList:root];
        }
        else if(COMPARE([root name], @"shape"))
        {
            return [self parseShape:root];
        }
        else if(COMPARE([root name], @"vector"))
        {
            return [self parseVector: dat];
        }
    }
    
    return nil;
}

-(LGDrawableReturn*)parseVector:(NSData*)data
{
    VectorDrawable *drawable = [VectorDrawable createDataObjcFrom:data];
    
    LGDrawableReturn *ldr = [[LGDrawableReturn alloc] init];
    ldr.vector = drawable;
    return ldr;
}

-(LGDrawableReturn*)parseBitmap:(GDataXMLElement*)root
{
    NSArray *attrs = [root attributes];
    /*CGRect rect = CGRectMake(0, 0, 1, 1);
     UIGraphicsBeginImageContext(rect.size);
     CGContextRef context = UIGraphicsGetCurrentContext();
     CGContextSetFillColorWithColor(context,
     [[UIColor redColor] CGColor]);
     //  [[UIColor colorWithRed:222./255 green:227./255 blue: 229./255 alpha:1] CGColor]) ;
     CGContextFillRect(context, rect);
     UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
     UIGraphicsEndImageContext();*/
    
    NSString *imgPath = nil;
    NSString *tileMode = nil;
    
    //[UIColor colorWithPatternImage: [UIImage imageNamed:@"gingham.png"]];
    for(GDataXMLNode *node in attrs)
    {
        if(COMPARE([node name], @"android:src"))
        {
            imgPath = [node stringValue];
        }
        if(COMPARE([node name], @"android:tileMode"))
        {
            tileMode = [node stringValue];
        }
    }

    int tileModeInt = 0;
    if(COMPARE(tileMode, @"repeat"))
        tileModeInt = 1;
    LGDrawableReturn *ret = [self parseDrawable:imgPath :tileModeInt];
    return ret;
}

-(LGDrawableReturn*)parseLayer:(GDataXMLElement *)root
{    
    NSMutableArray *imgArr = [NSMutableArray array];
    int maxWidth = 0, maxHeight = 0;
    //Fetch all the child images for maxwidth and maxheight
    for(GDataXMLElement *child in [root children])
	{
        if([child kind] != GDataXMLElementKind)
            continue;
        int left = 0,top = 0,right = 0,bottom = 0;
        LGDrawableReturn *ldr;
        NSString *name = [child name];
        if(COMPARE(name, @"item"))
        {
            if([child childCount] > 0)
            {
                GDataXMLElement *childItem = [[child children] objectAtIndex:0];
                ldr = [self parseBitmap:childItem];
            }
            for(GDataXMLNode *node in [child attributes])
            {
                NSString *attr = [node name];
                if(COMPARE(attr, @"android:drawable"))
                {
                    ldr = [self parseDrawable:[node stringValue]];
                }
                else if(COMPARE(attr, @"android:id"))
                {
                }
                else if(COMPARE(attr, @"android:top"))
                {
                    top = [[LGDimensionParser getInstance] getDimension:[node stringValue]];
                }
                else if(COMPARE(attr, @"android:right"))
                {
                    right = [[LGDimensionParser getInstance] getDimension:[node stringValue]];
                }
                else if(COMPARE(attr, @"android:bottom"))
                {
                    bottom = [[LGDimensionParser getInstance] getDimension:[node stringValue]];
                }
                else if(COMPARE(attr, @"android:left"))
                {
                    left = [[LGDimensionParser getInstance] getDimension:[node stringValue]];
                }

            }
        }
        if(ldr != nil && ldr.img != nil)
        {
            [imgArr addObject:ldr];
            if(ldr.img != nil)
            {
                //Check that our image width,height is bigger than stored
                if(ldr.img.size.width + (left - right) > maxWidth)
                    maxWidth = ldr.img.size.width + (left - right);
                if(ldr.img.size.height + (top - bottom) > maxHeight)
                    maxHeight = ldr.img.size.height + (top - bottom);
            }
        }
    }
    
    if(imgArr.count != [root children].count)
        return nil;
    
    CGRect rect = CGRectMake(0, 0, maxWidth, maxHeight);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
    CGContextFillRect(context, rect);
    
    /*CGContextTranslateCTM(context, 0, maxHeight);
    CGContextScaleCTM(context, 1.0, -1.0);*/
    
    int count = 0;
    for(GDataXMLElement *child in [root children])
	{
        if([child kind] != GDataXMLElementKind)
            continue;
        int left = 0,top = 0,right = 0,bottom = 0;
        NSString *name = [child name];
        if(COMPARE(name, @"item"))
        {
            for(GDataXMLNode *node in [child attributes])
            {
                NSString *attr = [node name];
                if(COMPARE(attr, @"android:id"))
                {
                }
                else if(COMPARE(attr, @"android:top"))
                {
                    top = [[LGDimensionParser getInstance] getDimension:[node stringValue]];
                }
                else if(COMPARE(attr, @"android:right"))
                {
                    right = [[LGDimensionParser getInstance] getDimension:[node stringValue]];
                }
                else if(COMPARE(attr, @"android:bottom"))
                {
                    bottom = [[LGDimensionParser getInstance] getDimension:[node stringValue]];
                }
                else if(COMPARE(attr, @"android:left"))
                {
                    left = [[LGDimensionParser getInstance] getDimension:[node stringValue]];
                }
            }
            
            LGDrawableReturn *ldr = [imgArr objectAtIndex:count++];
            CGRect imageRect = CGRectMake(left - right, (top - bottom), ldr.img.size.width, ldr.img.size.height);
            [ldr.img drawInRect:imageRect];
        }
	}
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    LGDrawableReturn *ret = [[LGDrawableReturn alloc] init];
    ret.img = img;
    return ret;
}

-(LGDrawableReturn*)parseStateList:(GDataXMLElement *)root
{
    LGDrawableReturn *ldr;
    for(GDataXMLElement *child in [root children])
	{
        if([child kind] != GDataXMLElementKind)
            continue;
        
        NSString *name = [child name];
        if(COMPARE(name, @"item"))
        {
            if([child childCount] > 0)
            {
                GDataXMLElement *childItem = [[child children] objectAtIndex:0];
                ldr = [self parseBitmap:childItem];
            }
            for(GDataXMLNode *node in [child attributes])
            {
                NSString *attr = [node name];
                if(COMPARE(attr, @"android:drawable"))
                {
                    ldr = [self parseDrawable:[node stringValue]];
                    break;
                }
            }
            for(GDataXMLNode *node in [child attributes])
            {
                NSString *attr = [node name];
                if(COMPARE(attr, @"android:state_pressed"))
                {
                    ldr.hasState = true;
                    ldr.state_pressed = SSTOB([node stringValue]);
                }
                else if(COMPARE(attr, @"android:state_focused"))
                {
                    ldr.hasState = true;
                    ldr.state_focused = SSTOB([node stringValue]);
                }
                else if(COMPARE(attr, @"android:state_hovered"))
                {
                    ldr.hasState = true;
                    ldr.state_hovered = SSTOB([node stringValue]);
                }
                else if(COMPARE(attr, @"android:state_selected"))
                {
                    ldr.hasState = true;
                    ldr.state_selected = SSTOB([node stringValue]);
                }
                else if(COMPARE(attr, @"android:state_checkable"))
                {
                    ldr.hasState = true;
                    ldr.state_checkable = SSTOB([node stringValue]);
                }
                else if(COMPARE(attr, @"android:state_checked"))
                {
                    ldr.hasState = true;
                    ldr.state_checked = SSTOB([node stringValue]);
                }
                else if(COMPARE(attr, @"android:state_enabled"))
                {
                    ldr.hasState = true;
                    ldr.state_enabled = SSTOB([node stringValue]);
                }
                else if(COMPARE(attr, @"android:state_activated"))
                {
                    ldr.hasState = true;
                    ldr.state_activated = SSTOB([node stringValue]);
                }
                else if(COMPARE(attr, @"android:state_window_focused"))
                {
                    ldr.hasState = true;
                    ldr.state_window_focused = SSTOB([node stringValue]);
                }
            }
        }
	}
    
    return ldr;
}

-(LGDrawableReturn*)parseShape:(GDataXMLElement *)root
{
    if([root kind] != GDataXMLElementKind)
        return nil;
    
    NSString *type = @"rectangle";
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGSize size = CGSizeMake(screenRect.size.width, screenRect.size.height);
    int height = size.height, width = size.width;
    int radius = 0;
    int thickness = 0;
    BOOL hasCorner = NO;
    int cornerTopLeftRadius = 0;
    int cornerTopRightRadius = 0;
    int cornerBottomLeftRadius = 0;
    int cornerBottomRightRadius = 0;
    int gradientAngle = 0;
    int gradientCenterX = 0;
    int gradientCenterY = 0;
    UIColor* gradientCenterColor = nil;
    UIColor* gradientEndColor = nil;
    int gradientRadius;
    UIColor* gradientStartColor = nil;
    NSString* gradientType = nil;
    int paddingLeft = 0;
    int paddingTop = 0;
    int paddingRight = 0;
    int paddingBottom = 0;
    UIColor* fillColor = nil;
    int strokeWidth = 1;
    UIColor* strokeColor = nil;
    int dashGap = 0;
    int dashWidth = 0;
    
    for(GDataXMLNode *attr in [root attributes])
    {
        NSString *attrName = [attr name];
        if(COMPARE(attrName, @"android:shape"))
        {
            NSString *attrVal = [attr stringValue];
            type = attrVal;
        }
        else if(COMPARE(attrName, @"android:innerRadius"))
        {
            radius = [[LGDimensionParser getInstance] getDimension:[attr stringValue]];
        }
        else if(COMPARE(attrName, @"android:innerRadiusRatio"))
        {
            
        }
        else if(COMPARE(attrName, @"android:thickness"))
        {
            thickness = [[LGDimensionParser getInstance] getDimension:[attr stringValue]];
        }
        else if(COMPARE(attrName, @"android:thicknessRatio"))
        {
            
        }
    }

    for(GDataXMLElement *child in [root children])
	{
        if([child kind] != GDataXMLElementKind)
            continue;
        NSString *name = [child name];
        if(COMPARE(name, @"corners"))
        {
            for(GDataXMLNode *childAttr in [child attributes])
            {
                hasCorner = YES;
                NSString *childAttrName = [childAttr name];
                if(COMPARE(childAttrName, @"android:radius"))
                {
                    int cornerRadius = [[LGDimensionParser getInstance] getDimension:[childAttr stringValue]];
                    cornerTopLeftRadius = cornerRadius;
                    cornerTopRightRadius = cornerRadius;
                    cornerBottomLeftRadius = cornerRadius;
                    cornerBottomRightRadius = cornerRadius;
                }
                else if(COMPARE(childAttrName, @"android:topLeftRadius"))
                {
                    cornerTopLeftRadius = [[LGDimensionParser getInstance] getDimension:[childAttr stringValue]];
                }
                else if(COMPARE(childAttrName, @"android:topRightRadius"))
                {
                    cornerTopRightRadius = [[LGDimensionParser getInstance] getDimension:[childAttr stringValue]];
                }
                else if(COMPARE(childAttrName, @"android:bottomLeftRadius"))
                {
                    cornerBottomLeftRadius = [[LGDimensionParser getInstance] getDimension:[childAttr stringValue]];
                }
                else if(COMPARE(childAttrName, @"android:bottomRightRadius"))
                {
                    cornerBottomRightRadius = [[LGDimensionParser getInstance] getDimension:[childAttr stringValue]];
                }
            }
        }
        else if(COMPARE(name, @"gradient"))
        {
            gradientType = @"linear";
            for(GDataXMLNode *childAttr in [child attributes])
            {
                NSString *childAttrName = [childAttr name];
                if(COMPARE(childAttrName, @"android:angle"))
                {
                    gradientAngle = [[LGDimensionParser getInstance] getDimension:[childAttr stringValue]];
                }
                else if(COMPARE(childAttrName, @"android:centerX"))
                {
                    gradientCenterX = [[LGDimensionParser getInstance] getDimension:[childAttr stringValue]];
                }
                else if(COMPARE(childAttrName, @"android:centerY"))
                {
                    gradientCenterY = [[LGDimensionParser getInstance] getDimension:[childAttr stringValue]];
                }
                else if(COMPARE(childAttrName, @"android:centerColor"))
                {
                    gradientCenterColor = [[LGColorParser getInstance] parseColor:[childAttr stringValue]];
                }
                else if(COMPARE(childAttrName, @"android:endColor"))
                {
                    gradientEndColor = [[LGColorParser getInstance] parseColor:[childAttr stringValue]];
                }
                else if(COMPARE(childAttrName, @"android:gradientRadius"))
                {
                    gradientRadius = [[LGDimensionParser getInstance] getDimension:[childAttr stringValue]];
                }
                else if(COMPARE(childAttrName, @"android:startColor"))
                {
                    gradientStartColor = [[LGColorParser getInstance] parseColor:[childAttr stringValue]];
                }
                else if(COMPARE(childAttrName, @"android:type"))
                {
                    gradientType = [childAttr stringValue];
                }
            }
        }
        else if(COMPARE(name, @"padding"))
        {
            for(GDataXMLNode *childAttr in [child attributes])
            {
                NSString *childAttrName = [childAttr name];
                if(COMPARE(childAttrName, @"android:left"))
                {
                    paddingLeft = [[LGDimensionParser getInstance] getDimension:[childAttr stringValue]];
                }
                else if(COMPARE(childAttrName, @"android:top"))
                {
                    paddingTop = [[LGDimensionParser getInstance] getDimension:[childAttr stringValue]];
                }
                else if(COMPARE(childAttrName, @"android:right"))
                {
                    paddingRight = [[LGDimensionParser getInstance] getDimension:[childAttr stringValue]];
                }
                else if(COMPARE(childAttrName, @"android:bottom"))
                {
                    paddingBottom = [[LGDimensionParser getInstance] getDimension:[childAttr stringValue]];
                }
            }
        }
        else if(COMPARE(name, @"size"))
        {
            for(GDataXMLNode *childAttr in [child attributes])
            {
                NSString *childAttrName = [childAttr name];
                if(COMPARE(childAttrName, @"android:height"))
                {
                    height = [[LGDimensionParser getInstance] getDimension:[childAttr stringValue]];
                }
                else if(COMPARE(childAttrName, @"android:width"))
                {
                    width = [[LGDimensionParser getInstance] getDimension:[childAttr stringValue]];
                }
            }
        }
        else if(COMPARE(name, @"solid"))
        {
            for(GDataXMLNode *childAttr in [child attributes])
            {
                NSString *childAttrName = [childAttr name];
                if(COMPARE(childAttrName, @"android:color"))
                {
                    fillColor = [[LGColorParser getInstance] parseColor:[childAttr stringValue]];
                }
            }
        }
        else if(COMPARE(name, @"stroke"))
        {
            for(GDataXMLNode *childAttr in [child attributes])
            {
                NSString *childAttrName = [childAttr name];
                if(COMPARE(childAttrName, @"android:width"))
                {
                    strokeWidth = [[LGDimensionParser getInstance] getDimension:[childAttr stringValue]];
                }
                else if(COMPARE(childAttrName, @"android:color"))
                {
                    strokeColor = [[LGColorParser getInstance] parseColor:[childAttr stringValue]];
                }
                else if(COMPARE(childAttrName, @"android:dashGap"))
                {
                    dashGap = [[LGDimensionParser getInstance] getDimension:[childAttr stringValue]];
                }
                else if(COMPARE(childAttrName, @"android:dashWidth"))
                {
                    dashWidth = [[LGDimensionParser getInstance] getDimension:[childAttr stringValue]];
                }
            }
        }
    }

    CGRect rect;
    if(COMPARE(type, @"ring"))
        rect = CGRectMake(paddingLeft - paddingRight, paddingTop - paddingBottom, radius, radius);
    else
        rect = CGRectMake(paddingLeft - paddingRight, paddingTop - paddingBottom, width, height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    if(fillColor != nil)
    {
        CGContextSetFillColorWithColor(context, [fillColor CGColor]);
    }
    if(strokeColor != nil)
    {
        CGContextSetStrokeColorWithColor(context, [strokeColor CGColor]);
        CGContextSetLineWidth(context, strokeWidth);
        if(dashGap != 0)
        {
            CGFloat dash[2]={dashWidth, dashGap}; // pattern 6 times “solid”, 5 times “empty”
            CGContextSetLineDash(context, 0, dash, 2);
        }
    }
    if(COMPARE(type, @"rectangle"))
    {
        if(hasCorner)
        {
            CGContextBeginPath (context); // Creates a path and on the next three lines you create the circle, clipping the context so the linear gradient
            CGRect rect = CGRectMake(0, 0, width, height);
            CGContextAddArc(context, CGRectGetMaxX(rect) - cornerTopRightRadius, CGRectGetMinY(rect) + cornerTopRightRadius, cornerTopRightRadius, 3 * M_PI / 2, 0, 0);
            CGContextAddArc(context, CGRectGetMaxX(rect) - cornerBottomRightRadius, CGRectGetMaxY(rect) - cornerBottomRightRadius, cornerBottomRightRadius, 0, M_PI / 2, 0);
            CGContextAddArc(context, CGRectGetMinX(rect) + cornerBottomLeftRadius, CGRectGetMaxY(rect) - cornerBottomLeftRadius, cornerBottomLeftRadius, M_PI / 2, M_PI, 0);
            CGContextAddArc(context, CGRectGetMinX(rect) + cornerTopLeftRadius, CGRectGetMinY(rect) + cornerTopLeftRadius, cornerTopLeftRadius, M_PI, 3 * M_PI / 2, 0);
            
            //CGContextAddEllipseInRect(context, CGRectMake(0, 0, width, height));
            /*CGContextAddArc (context, width/2, height/2, width/2, 0,
             2*M_PI, 0);*/
            CGContextClosePath (context);  //6.28318531 corresponds to 2*pi which is a whole circle
            CGContextClip(context);
        }
        if(gradientType != nil)
        {
            NSMutableArray *colorList = [NSMutableArray array];
            if(gradientStartColor != nil)
                [colorList addObject:gradientStartColor];
            if(gradientCenterColor != nil)
                [colorList addObject:gradientCenterColor];
            if(gradientEndColor != nil)
                [colorList addObject:gradientEndColor];
            CGFloat *array = malloc(sizeof(CGFloat) * 4 * colorList.count);
            int count = 0;
            for(UIColor *color in colorList)
            {
                const CGFloat *val = CGColorGetComponents([color CGColor]);
                array[count++] = val[0];
                array[count++] = val[1];
                array[count++] = val[2];
                array[count++] = 1.0f;
            }
            CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
            CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, array, NULL, colorList.count);
            if(COMPARE(gradientType, @"linear"))
            {
                if(gradientAngle == 0)
                    CGContextDrawLinearGradient(context, gradient, CGPointMake(0, height/2), CGPointMake(width, height/2), 0);
                else if(gradientAngle == 45)
                    CGContextDrawLinearGradient(context, gradient, CGPointMake(0, 0), CGPointMake(width, height), 0);
                else if(gradientAngle == 90)
                    CGContextDrawLinearGradient(context, gradient, CGPointMake(width/2, 0), CGPointMake(width/2, height), 0);
                else if(gradientAngle == 135)
                    CGContextDrawLinearGradient(context, gradient, CGPointMake(width, 0), CGPointMake(0, height), 0);
                else if(gradientAngle == 180)
                    CGContextDrawLinearGradient(context, gradient, CGPointMake(width, height/2), CGPointMake(0, height/2), 0);
                else if(gradientAngle == 225)
                    CGContextDrawLinearGradient(context, gradient, CGPointMake(width, height), CGPointMake(0, 0), 0);
                else if(gradientAngle == 270)
                    CGContextDrawLinearGradient(context, gradient, CGPointMake(width/2, height), CGPointMake(width/2, 0), 0);
                else if(gradientAngle == 315)
                    CGContextDrawLinearGradient(context, gradient, CGPointMake(0, height), CGPointMake(width, 0), 0);
                else
                    
                {
                    CGRect frameRect = CGRectMake(0, 0, width, height);
                    CGPoint pointS = [self radialIntersectionWithDegrees:gradientAngle :frameRect];
                    int backAngle = gradientAngle + 180;
                    while(backAngle > 360)
                        backAngle -= 360;
                    CGPoint pointE = [self radialIntersectionWithDegrees:backAngle :frameRect];
                    CGContextDrawLinearGradient(context, gradient, pointS, pointE, 0);
                }
            }
            else
                CGContextDrawRadialGradient(context, gradient, CGPointMake(gradientCenterX, gradientCenterY), gradientRadius, CGPointMake(gradientCenterX, gradientCenterY), gradientRadius, 0);
            CGColorSpaceRelease(baseSpace), baseSpace = NULL;
            CGGradientRelease(gradient);
        }
        else
            CGContextFillRect(context, rect);
        if(strokeColor != nil)
            CGContextStrokeRect(context, rect);
    }
    else if(COMPARE(type, @"ring") || COMPARE(type, @"oval"))
    {
        if(gradientType != nil)
        {
            CGContextBeginPath (context); // Creates a path and on the next three lines you create the circle, clipping the context so the linear gradient
            // gets drawn only inside the circle.
            CGContextAddEllipseInRect(context, CGRectMake(0, 0, width, height));
            /*CGContextAddArc (context, width/2, height/2, width/2, 0,
                             2*M_PI, 0);*/
            CGContextClosePath (context);  //6.28318531 corresponds to 2*pi which is a whole circle
            CGContextClip(context);
            NSMutableArray *colorList = [NSMutableArray array];
            if(gradientStartColor != nil)
                [colorList addObject:gradientStartColor];
            if(gradientCenterColor != nil)
                [colorList addObject:gradientCenterColor];
            if(gradientEndColor != nil)
                [colorList addObject:gradientEndColor];
            CGFloat *array = malloc(sizeof(CGFloat) * 4 * colorList.count);
            int count = 0;
            for(UIColor *color in colorList)
            {
                const CGFloat *val = CGColorGetComponents([color CGColor]);
                array[count++] = val[0];
                array[count++] = val[1];
                array[count++] = val[2];
                array[count++] = 1.0f;
            }
            CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
            CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, array, NULL, colorList.count);
            if(COMPARE(gradientType, @"linear"))
            {
                if(gradientAngle == 0)
                    CGContextDrawLinearGradient(context, gradient, CGPointMake(0, height/2), CGPointMake(width, height/2), 0);
                else if(gradientAngle == 45)
                    CGContextDrawLinearGradient(context, gradient, CGPointMake(0, 0), CGPointMake(width, height), 0);
                else if(gradientAngle == 90)
                    CGContextDrawLinearGradient(context, gradient, CGPointMake(width/2, 0), CGPointMake(width/2, height), 0);
                else if(gradientAngle == 135)
                    CGContextDrawLinearGradient(context, gradient, CGPointMake(width, 0), CGPointMake(0, height), 0);
                else if(gradientAngle == 180)
                    CGContextDrawLinearGradient(context, gradient, CGPointMake(width, height/2), CGPointMake(0, height/2), 0);
                else if(gradientAngle == 225)
                    CGContextDrawLinearGradient(context, gradient, CGPointMake(width, height), CGPointMake(0, 0), 0);
                else if(gradientAngle == 270)
                    CGContextDrawLinearGradient(context, gradient, CGPointMake(width/2, height), CGPointMake(width/2, 0), 0);
                else if(gradientAngle == 315)
                    CGContextDrawLinearGradient(context, gradient, CGPointMake(0, height), CGPointMake(width, 0), 0);
                else
                    
                {
                    CGRect frameRect = CGRectMake(0, 0, width, height);
                    CGPoint pointS = [self radialIntersectionWithDegrees:gradientAngle :frameRect];
                    int backAngle = gradientAngle + 180;
                    while(backAngle > 360)
                        backAngle -= 360;
                    CGPoint pointE = [self radialIntersectionWithDegrees:backAngle :frameRect];
                    CGContextDrawLinearGradient(context, gradient, pointS, pointE, 0);
                }
            }
            else
                CGContextDrawRadialGradient(context, gradient, CGPointMake(gradientCenterX, gradientCenterY), gradientRadius, CGPointMake(gradientCenterX, gradientCenterY), gradientRadius, 0);
            CGColorSpaceRelease(baseSpace);
            baseSpace = NULL;
            CGGradientRelease(gradient);
        }
        else
            CGContextFillEllipseInRect(context, rect);
        if(strokeColor != nil)
            CGContextStrokeEllipseInRect(context, rect);
    }
    else if(COMPARE(type, @"line"))
    {
        CGContextMoveToPoint(context, 0, 0);
        CGContextAddLineToPoint(context, width, height);
        CGContextStrokePath(context);
    }
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    LGDrawableReturn *ret = [[LGDrawableReturn alloc] init];
    ret.img = img;
    return ret;
}

-(CGPoint) radialIntersectionWithDegrees:(CGFloat)degrees :(CGRect)frame
{
    return [self radialIntersectionWithRadians:degrees * M_PI / 180 :frame];
}

-(CGPoint) radialIntersectionWithRadians:(CGFloat)radians :(CGRect)frame
{
    radians = fmodf(radians, 2 * M_PI);
    if (radians < 0)
        radians += (CGFloat)(2 * M_PI);
    return [self radialIntersectionWithConstrainedRadians:radians :frame];
}

-(CGPoint) radialIntersectionWithConstrainedRadians:(CGFloat)radians :(CGRect)frame
{
    // This method requires 0 <= radians < 2 * π.
    
    CGFloat xRadius = frame.size.width / 2;
    CGFloat yRadius = frame.size.height / 2;
    
    CGPoint pointRelativeToCenter;
    CGFloat tangent = tanf(radians);
    CGFloat y = xRadius * tangent;
    // An infinite line passing through the center at angle `radians`
    // intersects the right edge at Y coordinate `y` and the left edge
    // at Y coordinate `-y`.
    if (fabs(y) <= yRadius) {
        // The line intersects the left and right edges before it intersects
        // the top and bottom edges.
        if (radians < (CGFloat)M_PI_2 || radians > (CGFloat)(M_PI + M_PI_2)) {
            // The ray at angle `radians` intersects the right edge.
            pointRelativeToCenter = CGPointMake(xRadius, y);
        } else {
            // The ray intersects the left edge.
            pointRelativeToCenter = CGPointMake(-xRadius, -y);
        }
    } else {
        // The line intersects the top and bottom edges before it intersects
        // the left and right edges.
        CGFloat x = yRadius / tangent;
        if (radians < (CGFloat)M_PI) {
            // The ray at angle `radians` intersects the bottom edge.
            pointRelativeToCenter = CGPointMake(x, yRadius);
        } else {
            // The ray intersects the top edge.
            pointRelativeToCenter = CGPointMake(-x, -yRadius);
        }
    }
    
    return CGPointMake(pointRelativeToCenter.x + CGRectGetMidX(frame),
                       pointRelativeToCenter.y + CGRectGetMidY(frame));
}

-(NSDictionary *)getKeys
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for(NSString *key in self.drawableMap)
    {
        [dict setObject:key forKey:key];
    }

    return dict;
}

@end
