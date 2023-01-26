#import "LGView.h"
#import "Defines.h"
#import "ToppingEngine.h"
#import "LG.h"
#import "UILabelPadding.h"
#import "LGParser.h"
#import "LuaForm.h"
#import "LGValueParser.h"
#import "LuaNavHostFragment.h"
#import "KotlinExports.h"
#import <Topping/Topping-Swift.h>
#import "GDataXMLNode.h"

@implementation LGView

@synthesize layout, baseLine, backgroundImage;

-(void)initProperties
{
	//self.layout_weight = [NSNumber numberWithFloat:0.0f];
	self.layout = NO;
	self.baseLine = 14;
	self.android_layout_width = @"wrap_content";
	self.android_layout_height = @"wrap_content";
}

-(void)copyAttributesTo:(LGView*)viewToCopy {
    for(GDataXMLNode *node in self.attrs)
    {
        [viewToCopy setAttributeValue:[node name] :[node stringValue]];
    }
}

-(BOOL)setAttributeValue:(NSString*) name :(NSString*) value
{
    if(self.xmlProperties == nil)
        self.xmlProperties = [NSMutableDictionary dictionary];
    
    NSArray *nameArr = [name componentsSeparatedByString:@":"];
    NSString *xmlPropertyName = nameArr[nameArr.count - 1];
    [self.xmlProperties setObject:value forKey:xmlPropertyName];
    
    @try
    {
        /*NSObject *val = *(viewPropertyMap[name]);
        if([val isMemberOfClass:[NSNumber class]])
        {*/
            NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
            [f setNumberStyle:NSNumberFormatterDecimalStyle];
            NSNumber *val /**(viewPropertyMap[name])*/ = [f numberFromString:value];
        /*}
        else*/
        NSString *nameValue = [name stringByReplacingOccurrencesOfString:@":" withString:@"_"];
        if(val == nil)
        {
            [self setValue:[value copy] forKey:nameValue];
        }
        else
        {
            [self setValue:[val copy] forKey:nameValue];
        }
        return YES;
	}
    @catch(NSException *ex)
    {
    }
	return NO;
}

- (NSArray *)allPropertyNames
{
    if(propertyNameCache != nil)
        return propertyNameCache;
    
    NSMutableArray *rv = [NSMutableArray array];
    Class cls = [self class];
    do {
        unsigned count;
        objc_property_t *properties = class_copyPropertyList(cls, &count);

        unsigned i;
        for (i = 0; i < count; i++)
        {
            objc_property_t property = properties[i];
            NSString *name = [NSString stringWithUTF8String:property_getName(property)];
            [rv addObject:name];
        }

        free(properties);
        cls = [cls superclass];
    } while (cls != nil && cls != [NSObject class]);

    propertyNameCache = [NSArray arrayWithArray:rv];
    return rv;
}

-(NSMutableDictionary*)onSaveInstanceState {
    return [NSMutableDictionary new];
}

-(void)viewDidLayoutSubviews {
    
}

-(void)applyStyles
{
    NSString *sty = self.style;
    if(sty == nil)
        sty = [sToppingEngine getAppStyle];
    if(sty == nil)
        return;
    
    NSDictionary *styleMap = [[LGStyleParser getInstance] getStyle:sty];
    
    NSArray *arr = [self allPropertyNames];
    for(NSString *property in arr)
    {
        if([self valueForKey:property] == nil)
        {
            NSString *propertyCorrectedName = REPLACE(property, @"_", @":");
            NSString *styleVal = [styleMap objectForKey:propertyCorrectedName];
            if(styleVal != nil)
            {
                [self setValue:styleVal forKey:property];
            }
        }
    }
    
    if(self.style != nil)
    {
        styleMap = (NSDictionary*)[[LGValueParser getInstance] getValue:self.style];
        for(NSString *property in arr)
        {
            NSString *propertyCorrectedName = REPLACE(property, @"_", @":");
            NSString *styleVal = [styleMap objectForKey:propertyCorrectedName];
            if(styleVal != nil)
            {
                [self setValue:styleVal forKey:property];
            }
        }
    }
}

-(UIView *)createComponent
{
	UIView *view = [[UIView alloc] init];
	view.frame = CGRectMake(self.dX, self.dY, self.dWidth, self.dHeight);
    view.autoresizingMask = UIViewAutoresizingNone;
    view.autoresizesSubviews = NO;
	return view;
}

//Will always called
-(void)initComponent:(UIView *)view :(LuaContext *)lc
{
	if(view == nil)
		return;
	if(self._view != nil)
	{
		self._view = nil;
	}
	self._view = view;
	if(self.android_id != nil)
	{
		NSArray *arr = SPLIT(self.android_id, @"/");
		if([arr count] > 1)
			self.android_id = [arr objectAtIndex:1];
		/*else
			self.android_id = [LGView className];*/
	}
	/*else
		self.android_id = [LGView className];*/
	
	//Setup background
    NSObject *obj = nil;
    if(ISNULLOREMPTY(self.android_background))
        obj = self._view.backgroundColor = (UIColor*)[[LGStyleParser getInstance] getStyleValue:@"colorSurface" :[sToppingEngine getAppStyle]];
    else
        obj = [[LGValueParser getInstance] getValue:self.android_background];
    if([obj isKindOfClass:[LGDrawableReturn class]])
    {
        LGDrawableReturn *ldr = (LGDrawableReturn*)obj;
        if(ldr.img != nil)
        {
            self.backgroundImage = ldr.img;
            self._view.backgroundColor = [UIColor colorWithPatternImage:ldr.img];
        }
        else if(ldr.color != nil)
        {
            self._view.backgroundColor = ldr.color;
            view.backgroundColor = ldr.color;
        }
        else
        {
            UIColor *color = [[LGColorParser getInstance] parseColor:self.android_background];
            if(color != nil)
            {
                self._view.backgroundColor = color;
                view.backgroundColor = color;
            }
            else
                [Log e:@"LGView.mm" :APPEND(@"Cannot load backgorund image ", self.android_background)];
        }
    }
    else if([obj isKindOfClass:[UIColor class]])
    {
        self._view.backgroundColor = (UIColor*)obj;
        view.backgroundColor = (UIColor*)obj;
    }
    else
    {
        self._view.backgroundColor = [UIColor clearColor];
        view.backgroundColor = [UIColor clearColor];
    }
    
    self.lc = lc;
}

-(void)setupComponent:(UIView *)view
{
    if(![self._view isKindOfClass:[UILabelPadding class]])
        view.layoutMargins = UIEdgeInsetsMake(self.dPaddingTop, self.dPaddingLeft, self.dPaddingBottom, self.dPaddingRight);
}

-(void)addSelfToParent:(UIView*)par :(LuaForm*)cont
{
    self.cont = cont;
	UIView *myView = [self createComponent];
	[self initComponent:myView :cont.context];
	[self setupComponent:par];
	if(myView == nil)
	{
		NSLog(@"No view factory defined");
		return;
	}
    if([self isKindOfClass:[LGViewGroup class]])
    {
        LGViewGroup *wGroupSelf = (LGViewGroup *)self;
        for(LGView *w in wGroupSelf.subviews)
            [w addSelfToParent:myView :cont];
    }
	
	[self componentAddMethod:par :myView];
}

-(void)addSelfToParentNoSetup:(UIView*)par :(LuaForm*)cont
{
	UIView *myView = self._view;
    if([self isKindOfClass:[LGViewGroup class]])
    {
        LGViewGroup *wGroupSelf = (LGViewGroup *)self;
        for(LGView *w in wGroupSelf.subviews)
            [w addSelfToParentNoSetup:myView :cont];
    }
	
	[self componentAddMethod:par :myView];
	
	//Cleanup
	if(self.backgroundImage != nil)
	{
		self.backgroundImage = nil;
	}
}

-(void)componentAddMethod:(UIView*)par :(UIView *)me
{
	[par addSubview:me];
}

-(void)clearDimensions
{
    self.dX = self.dY = self.dWidth = self.dHeight = 0;
}

-(void)resize
{
	[self readWidthHeight];
}

-(void)resizeAndInvalidate
{
    [self resize];
    self._view.frame = CGRectMake(self.dX, self.dY, self.dWidth, self.dHeight);
}

-(void)afterResize:(BOOL)vertical
{
    //TODO:Check this
	/*for(LGView *w in self.subviews)
	{
		if([w isKindOfClass:[LGLinearLayout class]])
		{
			//TODO acaba burda vertical vermek gerekiyormu
			BOOL v = true;
			LGLinearLayout *llw = (LGLinearLayout*)w;
			if(llw.orientation != nil)
				v = [llw.orientation compare:@"vertical"] == 0;
			[llw AfterResize:v];
		}
		else
			[w AfterResize:vertical];
	}*/
	if(vertical)
		[self readWidth];
	else
		[self readHeight];
//	[self ReadWidthHeight];
}

-(void)readWidth
{
	int w = [[LGDimensionParser getInstance] getDimension:self.android_layout_width];
	if (w < 0) {
		w = self.dWidth;
		if([self.android_layout_width compare:@"fill_parent"] == 0 ||
		   [self.android_layout_width compare:@"match_parent"] == 0 ||
		   [self.android_layout_width compare:@"0dp"] == 0)
			return;
	}	
	@try {
		self.dPaddingLeft = [[LGDimensionParser getInstance] getDimension:self.android_paddingLeft];
		self.dPaddingRight = [[LGDimensionParser getInstance] getDimension:self.android_paddingRight];
		self.dPaddingTop = [[LGDimensionParser getInstance] getDimension:self.android_paddingTop];
		self.dPaddingBottom = [[LGDimensionParser getInstance] getDimension:self.android_paddingBottom];
		if(self.android_padding != nil)
		{
			self.dPaddingLeft = [[LGDimensionParser getInstance] getDimension:self.android_padding];
			self.dPaddingTop = [[LGDimensionParser getInstance] getDimension:self.android_padding];
			self.dPaddingRight = [[LGDimensionParser getInstance] getDimension:self.android_padding];
			self.dPaddingBottom = [[LGDimensionParser getInstance] getDimension:self.android_padding];
		}
		if(self.dPaddingLeft == -1)
			self.dPaddingLeft = 0;
		if(self.dPaddingRight == -1)
			self.dPaddingRight = 0;
		if(self.dPaddingTop == -1)
			self.dPaddingTop = 0;
		if(self.dPaddingBottom == -1)
			self.dPaddingBottom = 0;
	} @catch (...) {}
	
	@try {
		self.dMarginLeft = [[LGDimensionParser getInstance] getDimension:self.android_layout_marginLeft];
		self.dMarginRight = [[LGDimensionParser getInstance] getDimension:self.android_layout_marginRight];
		self.dMarginTop = [[LGDimensionParser getInstance] getDimension:self.android_layout_marginTop];
		self.dMarginBottom = [[LGDimensionParser getInstance] getDimension:self.android_layout_marginBottom];
		if(self.android_layout_margin != nil)
		{
			self.dMarginLeft = [[LGDimensionParser getInstance] getDimension:self.android_layout_margin];
			self.dMarginTop = [[LGDimensionParser getInstance] getDimension:self.android_layout_margin];
			self.dMarginRight = [[LGDimensionParser getInstance] getDimension:self.android_layout_margin];
			self.dMarginBottom = [[LGDimensionParser getInstance] getDimension:self.android_layout_margin];
		}
		if(self.dMarginLeft == -1)
			self.dMarginLeft = 0;
		if(self.dMarginRight == -1)
			self.dMarginRight = 0;
		if(self.dMarginTop == -1)
			self.dMarginTop = 0;
		if(self.dMarginBottom == -1)
			self.dMarginBottom = 0;
	} @catch (...) {}	
	
	if ([self.android_layout_width compare:@"wrap_content"] == 0) {
		w = [self getContentW];
	}
	if ([self.android_layout_width compare:@"fill_parent"] == 0 ||
		[self.android_layout_width compare:@"match_parent"] == 0 ||
        [self.android_layout_width compare:@"0dp"] == 0)
	{
		if (self.parent != nil) {
			if ([self.parent.android_layout_width compare:@"wrap_content"] == 0)
				w = [self getContentW];
			else
				w = self.parent.dWidth;
		}
		else 
		{
			w = [DisplayMetrics getMasterView].frame.size.width;
		}
		w = w - self.dX - self.dPaddingRight - self.dMarginRight;
	}
	
	self.dWidth = w;	
}

-(void)readHeight
{
	int h = [[LGDimensionParser getInstance] getDimension:self.android_layout_height];
	if (h < 0) {
		h = self.dHeight;
		if([self.android_layout_height compare:@"fill_parent"] == 0 ||
		   [self.android_layout_height compare:@"match_parent"] == 0 ||
           [self.android_layout_height compare:@"0dp"] == 0)
			return;
	}
	
	@try {
		self.dPaddingLeft = [[LGDimensionParser getInstance] getDimension:self.android_paddingLeft];
		self.dPaddingRight = [[LGDimensionParser getInstance] getDimension:self.android_paddingRight];
		self.dPaddingTop = [[LGDimensionParser getInstance] getDimension:self.android_paddingTop];
		self.dPaddingBottom = [[LGDimensionParser getInstance] getDimension:self.android_paddingBottom];
		if(self.android_padding != nil)
		{
			self.dPaddingLeft = [[LGDimensionParser getInstance] getDimension:self.android_padding];
			self.dPaddingTop = [[LGDimensionParser getInstance] getDimension:self.android_padding];
			self.dPaddingRight = [[LGDimensionParser getInstance] getDimension:self.android_padding];
			self.dPaddingBottom = [[LGDimensionParser getInstance] getDimension:self.android_padding];
		}
		if(self.dPaddingLeft == -1)
			self.dPaddingLeft = 0;
		if(self.dPaddingRight == -1)
			self.dPaddingRight = 0;
		if(self.dPaddingTop == -1)
			self.dPaddingTop = 0;
		if(self.dPaddingBottom == -1)
			self.dPaddingBottom = 0;
	} @catch (...) {}
	
	@try {
		self.dMarginLeft = [[LGDimensionParser getInstance] getDimension:self.android_layout_marginLeft];
		self.dMarginRight = [[LGDimensionParser getInstance] getDimension:self.android_layout_marginRight];
		self.dMarginTop = [[LGDimensionParser getInstance] getDimension:self.android_layout_marginTop];
		self.dMarginBottom = [[LGDimensionParser getInstance] getDimension:self.android_layout_marginBottom];
		if(self.android_layout_margin != nil)
		{
			self.dMarginLeft = [[LGDimensionParser getInstance] getDimension:self.android_layout_margin];
			self.dMarginTop = [[LGDimensionParser getInstance] getDimension:self.android_layout_margin];
			self.dMarginRight = [[LGDimensionParser getInstance] getDimension:self.android_layout_margin];
			self.dMarginBottom = [[LGDimensionParser getInstance] getDimension:self.android_layout_margin];
		}
		if(self.dMarginLeft == -1)
			self.dMarginLeft = 0;
		if(self.dMarginRight == -1)
			self.dMarginRight = 0;
		if(self.dMarginTop == -1)
			self.dMarginTop = 0;
		if(self.dMarginBottom == -1)
			self.dMarginBottom = 0;
	} @catch (...) {}	
	
	if ([self.android_layout_height compare:@"wrap_content"] == 0) {
		h = [self getContentH];
	}
	
	if ([self.android_layout_height compare:@"fill_parent"] == 0 ||
		[self.android_layout_height compare:@"match_parent"] == 0 ||
        [self.android_layout_height compare:@"0dp"] == 0)
	{
		if (self.parent != nil) {
			if ([self.parent.android_layout_height compare:@"wrap_content"] == 0)
				h = [self getContentH];
			else
				h = self.parent.dHeight;
            h = h - self.dY - self.parent.dPaddingBottom - self.dMarginBottom;
		}
		else 
		{
			h = [DisplayMetrics getMasterView].frame.size.height;
            h = h - self.dY - self.dMarginBottom;
		}
	}
	
	self.dHeight = h;	
}

-(void)readWidthHeight
{
    if (self.android_layout_gravity == nil)
        self.android_layout_gravity = @"top|left|start";
	int w = [[LGDimensionParser getInstance] getDimension:self.android_layout_width];
	int h = [[LGDimensionParser getInstance] getDimension:self.android_layout_height];
	if (w < 0) {
		w = self.dWidth;
	}
	if (h < 0) {
		h = self.dHeight;
	}
	
	@try {
		self.dPaddingLeft = [[LGDimensionParser getInstance] getDimension:self.android_paddingLeft];
		self.dPaddingRight = [[LGDimensionParser getInstance] getDimension:self.android_paddingRight];
		self.dPaddingTop = [[LGDimensionParser getInstance] getDimension:self.android_paddingTop];
		self.dPaddingBottom = [[LGDimensionParser getInstance] getDimension:self.android_paddingBottom];
		if(self.android_padding != nil)
		{
			self.dPaddingLeft = [[LGDimensionParser getInstance] getDimension:self.android_padding];
			self.dPaddingTop = [[LGDimensionParser getInstance] getDimension:self.android_padding];
			self.dPaddingRight = [[LGDimensionParser getInstance] getDimension:self.android_padding];
			self.dPaddingBottom = [[LGDimensionParser getInstance] getDimension:self.android_padding];
		}
		if(self.dPaddingLeft == -1)
			self.dPaddingLeft = 0;
		if(self.dPaddingRight == -1)
			self.dPaddingRight = 0;
		if(self.dPaddingTop == -1)
			self.dPaddingTop = 0;
		if(self.dPaddingBottom == -1)
			self.dPaddingBottom = 0;
	} @catch (...) {}
	
	@try {
		self.dMarginLeft = [[LGDimensionParser getInstance] getDimension:self.android_layout_marginLeft];
		self.dMarginRight = [[LGDimensionParser getInstance] getDimension:self.android_layout_marginRight];
		self.dMarginTop = [[LGDimensionParser getInstance] getDimension:self.android_layout_marginTop];
		self.dMarginBottom = [[LGDimensionParser getInstance] getDimension:self.android_layout_marginBottom];
		if(self.android_layout_margin != nil)
		{
			self.dMarginLeft = [[LGDimensionParser getInstance] getDimension:self.android_layout_margin];
			self.dMarginTop = [[LGDimensionParser getInstance] getDimension:self.android_layout_margin];
			self.dMarginRight = [[LGDimensionParser getInstance] getDimension:self.android_layout_margin];
			self.dMarginBottom = [[LGDimensionParser getInstance] getDimension:self.android_layout_margin];
		}
		if(self.dMarginLeft == -1)
			self.dMarginLeft = 0;
		if(self.dMarginRight == -1)
			self.dMarginRight = 0;
		if(self.dMarginTop == -1)
			self.dMarginTop = 0;
		if(self.dMarginBottom == -1)
			self.dMarginBottom = 0;
	} @catch (...) {}	
	
	if ([self.android_layout_width compare:@"wrap_content"] == 0) {
		w = [self getContentW];
	}
	if ([self.android_layout_height compare:@"wrap_content"] == 0) {
		h = [self getContentH];
	}
	
	if ([self.android_layout_width compare:@"fill_parent"] == 0 ||
		[self.android_layout_width compare:@"match_parent"] == 0 ||
        [self.android_layout_width compare:@"0dp"] == 0)
	{
		if (self.parent != nil) {
			if ([self.parent.android_layout_width compare:@"wrap_content"] == 0)
				w = [self getContentW];
			else
				w = self.parent.dWidth;
            w = w - self.dX - self.parent.dPaddingRight - self.dMarginRight /*- self.parent.dPaddingLeft*/ - self.dMarginLeft;
		}
		else 
		{
			w = [DisplayMetrics getMasterView].frame.size.width;
            w = w - self.dMarginRight - self.dMarginLeft;
            self.dX = self.dMarginLeft;
		}

	}
	if ([self.android_layout_height compare:@"fill_parent"] == 0 ||
		[self.android_layout_height compare:@"match_parent"] == 0 ||
        [self.android_layout_height compare:@"0dp"] == 0)
	{
		if (self.parent != nil) {
			if ([self.parent.android_layout_height compare:@"wrap_content"] == 0)
				h = [self getContentH];
			else
				h = self.parent.dHeight;
            h = h - self.dY - self.dMarginBottom - self.dMarginTop /*- self.parent.dPaddingTop*/ - self.parent.dPaddingBottom;
		}
		else 
		{
			h = [DisplayMetrics getMasterView].frame.size.height;
            h = h - self.dMarginBottom - self.dMarginTop;
            self.dY = self.dMarginTop;
		}
	}
    
    NSArray *gravitySplit = SPLIT(self.android_layout_gravity, @"|");
    BOOL startOrEndSet = NO;
    BOOL topOrBottomSet = NO;
    for(NSString *gravity in gravitySplit)
    {
        if([gravity isEqualToString:@"left"]
           || [gravity isEqualToString:@"start"])
        {
            self.dLayoutGravity |= GRAVITY_START;
            startOrEndSet = YES;
        }
        else if([gravity isEqualToString:@"right"]
                || [gravity isEqualToString:@"end"])
        {
            self.dLayoutGravity |= GRAVITY_END;
            startOrEndSet = YES;
        }
        else if([gravity isEqualToString:@"top"])
        {
            self.dLayoutGravity |= GRAVITY_TOP;
            topOrBottomSet = YES;
        }
        else if([gravity isEqualToString:@"bottom"])
        {
            self.dLayoutGravity |= GRAVITY_BOTTOM;
            topOrBottomSet = YES;
        }
        else if([gravity isEqualToString:@"center_vertical"])
        {
            self.dLayoutGravity |= GRAVITY_CENTER_VERTICAL;
            topOrBottomSet = YES;
        }
        else if([gravity isEqualToString:@"center_horizontal"])
        {
            self.dLayoutGravity |= GRAVITY_CENTER_HORIZONTAL;
            startOrEndSet = YES;
        }
        else if([gravity isEqualToString:@"center"])
        {
            self.dLayoutGravity |= GRAVITY_CENTER;
            startOrEndSet = YES;
            topOrBottomSet = YES;
        }
    }
    
    if(!startOrEndSet)
    {
        self.dLayoutGravity |= GRAVITY_LEFT;
    }
    if(!topOrBottomSet)
    {
        self.dLayoutGravity |= GRAVITY_TOP;
    }
    
    gravitySplit = SPLIT(self.android_gravity, @"|");
    startOrEndSet = NO;
    topOrBottomSet = NO;
    for(NSString *gravity in gravitySplit)
    {
        if([gravity isEqualToString:@"left"]
           || [gravity isEqualToString:@"start"])
        {
            self.dGravity |= GRAVITY_START;
            startOrEndSet = YES;
        }
        else if([gravity isEqualToString:@"right"]
                || [gravity isEqualToString:@"end"])
        {
            self.dGravity |= GRAVITY_END;
            startOrEndSet = YES;
        }
        else if([gravity isEqualToString:@"top"])
        {
            self.dGravity |= GRAVITY_TOP;
            topOrBottomSet = YES;
        }
        else if([gravity isEqualToString:@"bottom"])
        {
            self.dGravity |= GRAVITY_BOTTOM;
            topOrBottomSet = YES;
        }
        else if([gravity isEqualToString:@"center_vertical"])
        {
            self.dGravity |= GRAVITY_CENTER_VERTICAL;
            topOrBottomSet = YES;
        }
        else if([gravity isEqualToString:@"center_horizontal"])
        {
            self.dGravity |= GRAVITY_CENTER_HORIZONTAL;
            startOrEndSet = YES;
        }
        else if([gravity isEqualToString:@"center"])
        {
            self.dGravity |= GRAVITY_CENTER;
            startOrEndSet = YES;
            topOrBottomSet = YES;
        }
    }
	
	self.dWidth = w;
	self.dHeight = h;
}

-(int)getContentW
{
    return self.dWidth + self.dMarginLeft + self.dMarginRight;
}

-(int)getContentH
{
    return self.dHeight + self.dMarginTop + self.dMarginBottom;
}

-(NSObject *)hasAttribute:(NSString *)key
{
    NSString *nameValue = [key stringByReplacingOccurrencesOfString:@":" withString:@"_"];
    return [self valueForKey:nameValue];
}

-(BOOL) containsAttribute:(NSString *)key :(NSObject *)val
{
	NSObject* attr = [self hasAttribute:key];
	if(attr == nil)
		return NO;
	if([attr isKindOfClass:[NSString class]])
	{
		if([((NSString*)attr) compare:(NSString *)val] == 0)
			return YES;
		return NO;
	}
	else
	{
		if([((NSNumber *)attr) compare:(NSNumber *)val] == 0)
			return YES;
		return NO;
	}
}

-(void)reduceWidth:(int)share
{
    self.dWidth += share;
}

-(void)reduceHeight:(int)share
{
    self.dHeight += share;
}

-(int)getCalculatedHeight
{
    return self.dHeight;
}

-(int)getCalculatedWidth
{
    return self.dWidth;
}

-(void)configChange {
    
}

-(NSString *) debugDescription:(NSString *)val
{
	NSString *retVal = @"";
	NSString *valValue = val;
	if(val != nil)
		SAPPEND(retVal, APPEND(val, @"--"));
	else
		valValue = @"";
	retVal = FUAPPEND(retVal, NSStringFromClass([self class]), @" X: ", ITOS(self.dX), @",Y: ", ITOS(self.dY), @",Width: ", ITOS(self.dWidth), @",Height: ", ITOS(self.dHeight), @"\n", NULL);
	
	return retVal;
}

-(UIView*)getView
{
	return self._view;
}

//Lua part
+(LGView *) create:(LuaContext *)context
{
	LGView *lst = [[LGView alloc] init];
	[lst initProperties];
	return lst; 
}

-(LGView *)getViewById:(LuaRef *)lId
{
    NSString *sId = (NSString*)[[LGValueParser getInstance] getValue: lId.idRef];
    return [self getViewByIdInternal:sId];
}

-(LGView *)getViewByIdInternal:(NSString*)sId
{
    if([[self GetId] compare:sId] == 0)
       return self;
    return nil;
}

-(void)setEnabled:(BOOL)enabled
{
    self._view.userInteractionEnabled = enabled;
}

-(void)setFocusable:(BOOL)focusable
{
    //self._view  = focusable;
}

-(void)setBackground:(LuaRef*)background
{
    NSString *sId = (NSString*)[[LGValueParser getInstance] getValue: background.idRef];
    LGDrawableReturn *ldr = (LGDrawableReturn*)[[LGValueParser getInstance] getValue:sId];
    if(ldr.img)
        [self._view setBackgroundColor:[UIColor colorWithPatternImage:ldr.img]];
    else if(ldr.color != nil)
        [self._view setBackgroundColor:ldr.color];
}

-(NSInteger)getVisibility {
    if(self._view.isHidden)
        return GONE;
    else {
        if(self._view.alpha == 0)
            return INVISIBILE;
        else
            return VISIBLE;
    }
}

-(void)setVisibility:(NSInteger)visibility {
    if(visibility == VISIBLE)
    {
        self._view.hidden = NO;
    }
    else if(visibility == INVISIBILE)
    {
        self._view.alpha = 0;
    }
    else
    {
        self._view.hidden = YES;
        self._view.alpha = 1;
    }
}

-(float)getAlpha {
    return self._view.alpha;
}

-(void)setOnClickListener:(LuaTranslator *)lt
{
    self.ltOnClickListener = lt;
    [self._view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self._view action:lt.selector]];
}

-(NSDictionary *)getBindings {
    if([self isKindOfClass:[LGViewGroup class]])
        return [((LGViewGroup*)self) getBindings];
    return @{};
}

-(LuaFragment*)findFragment {
    LuaFragment *fragment = self.fragment;
    if(fragment == nil)
    {
        LGView *current = self.parent;
        while(current != nil) {
            fragment = current.fragment;
            if(fragment != nil)
                return fragment;
            current = current.parent;
        }
    }
    
    return fragment;
}

-(NavController*)findNavController {
    if(self.navController != nil) {
        return self.navController;
    }
    
    return [LuaNavHostFragment findNavController:[self findFragment]];
}

-(LuaNavController*)findNavControllerInternal {
    NavController *controller = [self findNavController];
    
    return [[LuaNavController alloc] initWithController:controller];
}

-(NSString*)GetId
{
	if(self.lua_id != nil)
        return self.lua_id;
    if(self.android_id != nil)
        return self.android_id;
    return [LGView className];
}

+ (NSString*)className
{
	return @"LGView";
}

+(NSMutableDictionary*)luaMethods
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    
	[dict setObject:[LuaFunction CreateC:class_getClassMethod([self class], @selector(create:)) 
										:@selector(create:)
										:[LGView class]
										:[NSArray arrayWithObjects:[LuaContext class], nil]
										:[LGView class]] 
			 forKey:@"create"];
	[dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(getViewById:)) :@selector(getViewById:) :[LGView class] :MakeArray([LuaRef class]C nil)] forKey:@"getViewById"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(setEnabled:)) :@selector(setEnabled:) :nil :MakeArray([LuaBool class]C nil)] forKey:@"setEnabled"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(setFocusable:)) :@selector(setFocusable:) :nil :MakeArray([LuaBool class]C nil)] forKey:@"setFocusable"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(setBackground:)) :@selector(setBackground:) :nil :MakeArray([LuaRef class]C nil)] forKey:@"setBackground"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(setOnClickListener:)) :@selector(setOnClickListener:) :nil :MakeArray([LuaTranslator class]C nil)] forKey:@"setOnClickListener"];
    [dict setObject:[LuaFunction Create:class_getInstanceMethod([self class], @selector(findNavControllerInternal)) :@selector(findNavControllerInternal) :[LuaNavController class] :MakeArray(nil)] forKey:@"findNavController"];
    InstanceMethodNoArg(getBindings, NSMutableDictionary, @"getBindings")
	return dict;
}

@end
