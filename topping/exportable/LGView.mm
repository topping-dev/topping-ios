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
#import "IOSKotlinHelper/IOSKotlinHelper.h"
#import <Topping/Topping-Swift.h>
#import "GDataXMLNode.h"
#import "LGRelativeLayout.h"

static BOOL rtl = false;

@implementation LGView

+(BOOL)isRtl {
    return rtl;
}

@synthesize layout, baseLine;

-(void)initProperties
{
	//self.layout_weight = [NSNumber numberWithFloat:0.0f];
	self.layout = NO;
	self.baseLine = -1;
	self.android_layout_width = @"wrap_content";
	self.android_layout_height = @"wrap_content";
    self.methodSkip = [NSMutableArray array];
    self.methodEventMap = [NSMutableDictionary dictionary];
    
    self.dScaleX = 1;
    self.dScaleY = 1;
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
        NSString *nameValue = [name stringByReplacingOccurrencesOfString:@":" withString:@"_"];
        [self setValue:[value copy] forKey:nameValue];
    }
    @catch(NSException *ex) {
        
    }
//    @try
//    {
//        /*NSObject *val = *(viewPropertyMap[name]);
//        if([val isMemberOfClass:[NSNumber class]])
//        {*/
//            NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
//            [f setNumberStyle:NSNumberFormatterDecimalStyle];
//            NSNumber *val /**(viewPropertyMap[name])*/ = [f numberFromString:value];
//        /*}
//        else*/
//        NSString *nameValue = [name stringByReplacingOccurrencesOfString:@":" withString:@"_"];
//        if(val == nil)
//        {
//            [self setValue:[value copy] forKey:nameValue];
//        }
//        else
//        {
//            [self setValue:[val copy] forKey:nameValue];
//        }
//        return YES;
//	}
//    @catch(NSException *ex)
//    {
//    }
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
	}
	
	//Setup background
    if(self.android_background != nil)
        [self setBackground:[LuaRef withValue:self.android_background]];
    
    self.lc = lc;
}

-(void)setupComponent:(UIView *)view
{
    if(![self._view isKindOfClass:[UILabelPadding class]])
        view.layoutMargins = UIEdgeInsetsMake(self.dPaddingTop, self.dPaddingLeft, self.dPaddingBottom, self.dPaddingRight);
    if(self.android_enabled != nil) {
        NSString *enabled = (NSString*)[[LGValueParser getInstance] getValue:self.android_enabled];
        [self setEnabled:SSTOB(enabled)];
    }
    
    rtl = [self._view isRTL];
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

-(void)resizeInternal {
    
}

-(int)findMatchParentWidth:(LGView*)view {
    if(view.parent != nil) {
        if([view.parent.android_layout_width isEqualToString:@"wrap_content"]) {
            return [self findMatchParentWidth:view.parent];
        } else {
            return view.parent.dWidth;
        }
    }
    else {
        return self.lc.form.view.frame.size.width;
    }
}

-(int)findMatchParentHeight:(LGView*)view {
    if(view.parent != nil) {
        if([view.parent.android_layout_height isEqualToString:@"wrap_content"]) {
            return [self findMatchParentHeight:view.parent];
        } else {
            return view.parent.dHeight;
        }
    }
    else {
        return self.lc.form.view.frame.size.height;
    }
}

-(void)measure:(int)widthMeasureSpec :(int)heightMeasureSpec {
    if(self.layout || self.dWidthSpec != widthMeasureSpec || self.dHeightSpec != heightMeasureSpec)
    {
        self.layout = NO;
        [self onMeasure:widthMeasureSpec :heightMeasureSpec];
    }
    self.widthSpecSet = true;
    self.heightSpecSet = true;
    self.dWidthSpec = widthMeasureSpec;
    self.dHeightSpec = heightMeasureSpec;
}

-(void)onMeasure:(int)widthMeasureSpec :(int)heightMeasureSpec {
    if([self callTMethod:@"onMeasure" :[NSNumber numberWithInt:widthMeasureSpec], [NSNumber numberWithInt:heightMeasureSpec], nil])
        return;
    int newWidthSpec = widthMeasureSpec;
    int newHeightSpec = heightMeasureSpec;
    if(![self isKindOfClass:[LGLinearLayout class]]
       && ![self isKindOfClass:[LGAbsListView class]]
       && ![NSStringFromClass(self.class) isEqualToString:@"LGView"]) {
        int widthSpec = [MeasureSpec getMode:widthMeasureSpec];
        int width = [MeasureSpec getSize:widthMeasureSpec];
        if(widthSpec == AT_MOST) {
            int contentW = [self getContentW];
            contentW += self.dMarginLeft + self.dMarginRight;
            width = MIN(contentW, width);
        }
        newWidthSpec = [MeasureSpec makeMeasureSpec:width :widthSpec];
        int heightSpec = [MeasureSpec getMode:heightMeasureSpec];
        int height = [MeasureSpec getSize:heightMeasureSpec];
        if(heightSpec == AT_MOST ) {
            int contentH = [self getContentH];
            contentH += self.dMarginTop + self.dMarginBottom;
            height = MIN(contentH, height);
        }
        newHeightSpec = [MeasureSpec makeMeasureSpec:height :heightSpec];
    }
    [self setMeasuredDimension:[LGView getDefaultSize:[self getSuggestedMinimumWidth] :newWidthSpec] :[LGView getDefaultSize:[self getSuggestedMinimumHeight] :newHeightSpec]];
}

-(void)setMeasuredDimension:(int)measuredWidth :(int)measuredHeight {
    self.dWidth = measuredWidth & MEASURED_SIZE_MASK;
    self.dHeight = measuredHeight & MEASURED_SIZE_MASK;
    self._view.frame = CGRectMake(self.dX, self.dY, self.dWidth, self.dHeight);
}

-(int)getMeasuredState {
    return self.dWidthSpec | self.dHeightSpec;
}

-(int)getSuggestedMinimumHeight {
    int suggestedMinHeight = 0;
    if(self.android_minHeight != nil)
        suggestedMinHeight = STOI((NSString*)[[LGValueParser getInstance] getValue:self.android_minHeight]);
    /*if(self.android_background != nil)
    if (mBGDrawable != null) {
        final int bgMinWidth = mBGDrawable.getMinimumWidth();
        if (suggestedMinWidth < bgMinWidth) {
            suggestedMinWidth = bgMinWidth;
        }
    }*/
    return suggestedMinHeight;
}

-(int)getSuggestedMinimumWidth {
    int suggestedMinWidth = 0;
    if(self.android_minWidth != nil)
        suggestedMinWidth = STOI((NSString*)[[LGValueParser getInstance] getValue:self.android_minWidth]);
    /*if(self.android_background != nil)
    if (mBGDrawable != null) {
        final int bgMinWidth = mBGDrawable.getMinimumWidth();
        if (suggestedMinWidth < bgMinWidth) {
            suggestedMinWidth = bgMinWidth;
        }
    }*/
    return suggestedMinWidth;
}

+(int)resolveSize:(int)size :(int) measureSpec {
    return [LGView resolveSizeAndState:size :measureSpec :0] & MEASURED_SIZE_MASK;
}

+(int)resolveSizeAndState:(int)size :(int)measureSpec :(int)childMeasuredState {
    int result = size;
    int specMode = [MeasureSpec getMode:measureSpec];
    int specSize =  [MeasureSpec getSize:measureSpec];
    switch (specMode) {
    case UNSPECIFIED:
        result = size;
        break;
    case AT_MOST:
        if (specSize < size) {
            result = specSize | MEASURED_STATE_TOO_SMALL;
        } else {
            result = size;
        }
        break;
    case EXACTLY:
        result = specSize;
        break;
    }
    return result | (childMeasuredState&MEASURED_STATE_MASK);
}

+(int)getDefaultSize:(int)size :(int)measureSpec {
    int result = size;
    int specMode = [MeasureSpec getMode:measureSpec];
    int specSize = [MeasureSpec getSize:measureSpec];
    switch (specMode) {
    case UNSPECIFIED:
        result = size;
        break;
    case AT_MOST:
    case EXACTLY:
        result = specSize;
        break;
    }
    return result;
}

+(int)combineMeasuredStates:(int)curState :(int)newState {
    return curState | newState;
}

-(void)readWidthHeight
{
    if (self.android_layout_gravity == nil)
        self.android_layout_gravity = @"top|left|start";
	int w = [[LGDimensionParser getInstance] getDimension:self.android_layout_width];
	int h = [[LGDimensionParser getInstance] getDimension:self.android_layout_height];
    self.dWidthDimension = w;
    self.dHeightDimension = h;
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
            w = [self findMatchParentWidth:self];
            w = w - self.dX - self.parent.dPaddingRight - self.dMarginRight;
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
            h = [self findMatchParentHeight:self];
            h = h - self.dY - self.dMarginTop - self.parent.dPaddingTop;
            h -= (self.parent.dPaddingBottom + self.dMarginBottom);
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
    self.dLayoutGravityDimen = -1;
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
    
    if(startOrEndSet || topOrBottomSet)
        self.dLayoutGravityDimen = self.dLayoutGravity;
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
    self.dGravityDimen = -1;
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
    
    if(startOrEndSet || topOrBottomSet)
        self.dGravityDimen = self.dGravity;
    if(!startOrEndSet)
    {
        self.dGravity |= GRAVITY_START;
    }
    if(!topOrBottomSet)
    {
        self.dGravity |= GRAVITY_TOP;
    }
	
    /*if(self.dWidthSpec != INT_MIN) {
        self.dWidth = [MeasureSpec getSize:self.dWidthSpec];
    }
    else*/
       self.dWidth = w;
    /*if(self.dHeightSpec != INT_MIN) {
        self.dHeight = [MeasureSpec getSize:self.dHeightSpec];
    }
    else*/
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

-(void)layout:(int)l :(int)t :(int)r :(int)b {
    if([self callTMethod:@"onLayout" :[NSNumber numberWithBool:false],
     [NSNumber numberWithInt:l], [NSNumber numberWithInt:t],
     [NSNumber numberWithInt:r], [NSNumber numberWithInt:b], nil])
        return;
    self._view.frame = CGRectMake(l, t, r - l, b - t);
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
    self.lrBackground = background;
    NSObject *obj = [[LGValueParser getInstance] getValue:background.idRef];
    if([obj isKindOfClass:[LGDrawableReturn class]])
    {
        LGDrawableReturn *ldr = (LGDrawableReturn*)obj;
        self._view.backgroundColor = [UIColor colorWithPatternImage:ldr.img];
    }
    else if([obj isKindOfClass:[UIColor class]])
    {
        self._view.backgroundColor = (UIColor*)obj;
    }
    else
    {
        self._view.backgroundColor = [UIColor clearColor];
    }
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
    self.dVisibility = (int)visibility;
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

-(int)getLeft {
    return self.dX;
}

-(int)getRight {
    return self.dX + self.dWidth;
}

-(int)getTop {
    return self.dY;
}

-(int)getBottom {
    return self.dY + self.dHeight;
}

-(int)getMLeft {
    return [self getLeft];
}

-(int)getMRight {
    return [self getRight];
}

-(int)getMTop {
    return [self getTop];
}

-(int)getMBottom {
    return [self getBottom];
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

#pragma IOSKHView start

-(BOOL)callTMethodArr:(NSString *)methodName :(NSArray *)arr {
    if([self.methodSkip containsObject:methodName])
        return false;
    
    if([self.methodEventMap objectForKey:methodName] != nil) {
        IOSKHKotlinArray *___arr___ = [IOSKHKotlinArray arrayWithSize:(int)arr.count init:^id _Nullable(IOSKHInt * _Nonnull index) { return nil; }];
        for(int i = 0; i < arr.count; i++) {
            [___arr___ setIndex:i value:[arr objectAtIndex:i]];
        }
        
        [self.methodSkip addObject:methodName];
        ((id  _Nullable (^)(id<IOSKHTView> _Nonnull, IOSKHKotlinArray<id> * _Nonnull))[self.methodEventMap objectForKey:methodName])(self, ___arr___);
        [self.methodSkip removeObject:methodName];
        return true;
    }
    
    return false;
}

-(BOOL)callTMethod:(NSString *)methodName :(id)arg, ... {
    NSMutableArray *arr = [[NSMutableArray alloc] initWithArray:VarArgs2(arg)];
    
    return [self callTMethodArr:methodName :arr];
}

- (void)addViewView:(nonnull id<IOSKHTView>)view param:(nonnull IOSKHViewGroupLayoutParams *)param {
    
}


- (BOOL)canScrollVerticallyVert:(int32_t)vert {
    return false;
}


- (void)dispatchDrawCanvas:(nonnull id<IOSKHTCanvas>)canvas {
    
}


- (float)dpToPixelDp:(float)dp {
    return [DisplayMetrics dpToSp:dp];
}


- (void)drawCanvas:(nonnull id<IOSKHTCanvas>)canvas {
    
}


- (id<IOSKHTView> _Nullable)findViewByIdId:(nonnull NSString *)id {
    return [self getViewByIdId:id];
}


- (void)forceLayout {
    [self resizeAndInvalidate];
}


- (id<IOSKHTDrawable> _Nullable)getBackground {
    NSObject *obj = [[LGValueParser getInstance] getValue:self.lrBackground.idRef];
    
    if([obj isKindOfClass:[LGDrawableReturn class]]) {
        return (id<IOSKHTDrawable>)obj;
    }
    
    return nil;
}


- (int32_t)getBaseline {
    return self.baseLine;
}


- (nonnull id<IOSKHTView>)getChildAtIndex:(int32_t)index {
    return (id<IOSKHTView>)[UIView new];
}


- (int32_t)getChildCount {
    return 0;
}


-(int32_t)getChildMeasureSpecSpec:(int32_t)spec padding:(int32_t)padding dimension:(int32_t)dimension {
    return 0;
}


- (nonnull id<IOSKHTClass>)getClass {
    return (id<IOSKHTClass>)[[ToppingClass alloc] initWithCls:[self class]];
}


- (nonnull id<IOSKHTContext>)getContext {
    return self.lc;
}


- (nonnull id<IOSKHTDisplay>)getDisplay {
    return [ToppingDisplay new];
}


- (float)getElevation {
    return ((NSNumber*)[[LGValueParser getInstance] getValue:self.android_elevation]).floatValue;
}


- (int32_t)getHeight {
    return self.dHeight;
}


- (void)getHitRectTempRec:(nonnull IOSKHRect *)tempRec {
    CGPoint topLeft = CGPointMake(self._view.bounds.origin.x,
                                       self._view.bounds.origin.y);
    CGPoint bottomRight = CGPointMake(self._view.bounds.origin.x + self._view.bounds.size.width,
                                      self._view.bounds.origin.y + self._view.bounds.size.height);
    CGPoint cTopLeft = [self._view convertPoint:topLeft toView:self.parent._view];
    CGPoint cBottomRight = [self._view convertPoint:topLeft toView:self.parent._view];
    
    tempRec.left = cTopLeft.x;
    tempRec.top = cTopLeft.y;
    tempRec.right = cBottomRight.x;
    tempRec.bottom = cBottomRight.y;
}


- (nonnull NSString *)getId {
    NSString *idVal = REPLACE([self GetId], @"+", @"");
    return [self GetId];
}


- (int32_t)getLayoutDirection {
    return [LGView isRtl] ? 1 : 0;
}


- (IOSKHViewGroupLayoutParams * _Nullable)getLayoutParams {
    return self.kLayoutParams;
}


- (void)getLocationOnScreenTempLoc:(nonnull IOSKHKotlinIntArray *)tempLoc {
    CGPoint p = [self._view convertPoint:self._view.frame.origin toView:nil];
    [tempLoc setIndex:0 value:p.x];
    [tempLoc setIndex:1 value:p.y];
}


- (nonnull IOSKHAndroidMatrix33 *)getMatrix {
    CGAffineTransform transform = self._view.transform;
    
    IOSKHKotlinFloatArray *arr = [IOSKHKotlinFloatArray arrayWithSize:9 init:^IOSKHFloat * _Nonnull(IOSKHInt * _Nonnull index) {
        return 0;
    }];
    [arr setIndex:0 value:transform.a];
    [arr setIndex:1 value:transform.b];
    [arr setIndex:2 value:0];
    [arr setIndex:3 value:transform.c];
    [arr setIndex:4 value:transform.d];
    [arr setIndex:5 value:0];
    [arr setIndex:6 value:transform.tx];
    [arr setIndex:7 value:transform.ty];
    [arr setIndex:8 value:1];
    IOSKHAndroidMatrix33 *matrix = [[IOSKHAndroidMatrix33 alloc] initWithData:arr];
    return matrix;
}


- (int32_t)getMeasuredHeight {
    return self.dHeight;
}


- (int32_t)getMeasuredWidth {
    return self.dWidth;
}


- (id _Nullable)getObjCPropertyName:(nonnull NSString *)name {
    return [self valueForKey:name];
}


- (int32_t)getOptimizationLevel {
    return 0;
}


- (int32_t)getPaddingBottom {
    return self.dPaddingBottom;
}


- (int32_t)getPaddingEnd {
    return self.dPaddingRight;
}


- (int32_t)getPaddingLeft {
    return self.dPaddingLeft;
}


- (int32_t)getPaddingRight {
    return self.dPaddingRight;
}


- (int32_t)getPaddingStart {
    return self.dPaddingLeft;
}


- (int32_t)getPaddingTop {
    return self.dPaddingTop;
}


- (id<IOSKHTView> _Nullable)getParent {
    return self.parent;
}


- (nonnull id)getParentType {
    return self.kParentType;
}


- (float)getPivotX {
    return self.dPivotX;
}


- (float)getPivotY {
    return self.dPivotY;
}


- (nonnull id<IOSKHTResources>)getResources {
    return (id<IOSKHTResources>)[[ToppingResources alloc] init];
}


- (float)getRotationX {
    return self.dRotationX;
}


- (float)getRotationY {
    return self.dRotationY;
}


- (float)getRotation_ {
    return self.dRotation;
}


- (float)getScaleX {
    return self.dScaleX;
}


- (float)getScaleY {
    return self.dScaleY;
}


- (float)getScrollX {
    return 0;
}


- (float)getScrollY {
    return 0;
}


- (id _Nullable)getTag {
    //TODO:
    return nil;
}


- (id _Nullable)getTagKey:(nonnull id)key {
    //TODO:
    return nil;
}


- (float)getTranslationX {
    return self.dTranslationX;
}


- (float)getTranslationY {
    return self.dTranslationY;
}


- (float)getTranslationZ {
    return self.dTranslationZ;
}


- (id<IOSKHTView> _Nullable)getViewByIdId:(nonnull NSString *)id {
    return [self getViewById:[LuaRef withValue:id]];
}


- (int32_t)getWidth {
    return self.dWidth;
}


- (int32_t)getX {
    return self.dX;
}


- (int32_t)getY {
    return self.dY;
}


- (void)invalidate {
    [self resizeAndInvalidate];
}


- (void)invalidateOutline {
    
}


- (void)invokeMethodMethod:(nonnull NSString *)method value:(nonnull id)value {
    SEL selector = NSSelectorFromString(method);
    [self performSelector:selector withObject:value];
}


- (BOOL)isAttachedToWindow {
    return true;
}


- (BOOL)isInEditMode {
    return false;
}


- (BOOL)isLayoutRequested {
    //TODO:
    return true;
}


- (BOOL)isRtl {
    return [LGView isRtl];
}


- (void)layoutL:(int32_t)l t:(int32_t)t r:(int32_t)r b:(int32_t)b {
    [self layout:l :t :r :b];
}


- (int32_t)makeMeasureSpecMeasureSpec:(int32_t)measureSpec type:(int32_t)type {
    return [MeasureSpec makeMeasureSpec:measureSpec :type];
}


- (void)measureWidthMeasureSpec:(int32_t)widthMeasureSpec heightMeasureSpec:(int32_t)heightMeasureSpec {
    [self measure:widthMeasureSpec :heightMeasureSpec];
}


- (void)onAttachedToWindow {
    [self._view didMoveToWindow];
}

- (void)onDrawCanvas:(nonnull id<IOSKHTCanvas>)canvas {
    //TODO:
}


- (void)onMeasureWidthMeasureSpec:(int32_t)widthMeasureSpec heightMeasureSpec:(int32_t)heightMeasureSpec {
    [self onMeasure:widthMeasureSpec :heightMeasureSpec];
}


- (BOOL)onTouchEventEvent:(nonnull IOSKHMotionEvent *)event {
    return false;
}


- (void)onViewAddedView:(nonnull id<IOSKHTView>)view {
    
}


- (void)onViewRemovedView:(nonnull id<IOSKHTView>)view {
   
}


- (void)postRunnable:(nonnull id<IOSKHTRunnable>)runnable {
    [LuaThread runOnUIThreadInternal:^{
        [runnable run];
    }];
}


- (void)requestLayout {
    [self resizeAndInvalidate];
}


- (int32_t)resolveSizeAndStateSize:(int32_t)size measureSpec:(int32_t)measureSpec childState:(int32_t)childState {
    return [LGView resolveSizeAndState:size :measureSpec :childState];
}


- (void)setAlphaValue:(float)value {
    self._view.alpha = value / 255.0f;
}


- (void)setClipToOutlineClip:(BOOL)clip {
    
}


- (void)setElevationValue:(float)value {

}


- (void)setIdId:(nonnull NSString *)id {
    self.lua_id = id;
}


- (void)setImageDrawableDrawable:(id<IOSKHTDrawable> _Nullable)drawable {
    
}


- (void)setImageResourceResourceId:(nonnull NSString *)resourceId {
    
}


- (void)setLayoutParamsParams:(nonnull IOSKHViewGroupLayoutParams *)params {
    self.kLayoutParams = params;
}


- (void)setMeasuredDimensionWidth:(int32_t)width height:(int32_t)height {
    [self setMeasuredDimension:width :height];
}


- (void)setObjCPropertyMethodName:(nonnull NSString *)methodName value:(nonnull id)value {
    [self setValue:value forKey:methodName];
}


- (void)setOnClickListenerListener:(id<IOSKHTViewOnClickListener> _Nullable)listener {
    
}


- (void)setOutlineProviderViewOutlineProvider:(IOSKHViewOutlineProvider * _Nullable)viewOutlineProvider {
    
}


- (void)setPaddingLeft:(int32_t)left top:(int32_t)top right:(int32_t)right bottom:(int32_t)bottom {
    self.dPaddingLeft = left;
    self.dPaddingTop = top;
    self.dPaddingRight = right;
    self.dPaddingBottom = bottom;
}


- (void)setParentTypeObj:(nonnull id)obj {
    self.kParentType = obj;
}


- (void)setPivotXValue:(float)value {
    self.dPivotX = value;
}


- (void)setPivotYValue:(float)value {
    self.dPivotY = value;
}


- (void)setReflectionColorDrawableMethodName:(nonnull NSString *)methodName r:(int32_t)r g:(int32_t)g b:(int32_t)b a:(int32_t)a {
    
}

-(void)setReflectionColorMethodName:(NSString *)methodName r:(int32_t)r g:(int32_t)g b:(int32_t)b a:(int32_t)a {
    
}


- (void)setReflectionValueMethodName:(nonnull NSString *)methodName value:(nonnull id)value {
    [self setValue:value forKey:methodName];
}


- (void)setRotationValue:(float)value {
    self.dRotation = value;
    self._view.transform = CGAffineTransformMakeRotation(value * M_PI/180);
}


- (void)setRotationXValue:(float)value {
    self.dRotationX = value;
    self._view.layer.transform = CATransform3DMakeRotation(value * M_PI/180, 1.0, 0.0, 0.0);
}


- (void)setRotationYValue:(float)value {
    self.dRotationY = value;
    self._view.layer.transform = CATransform3DMakeRotation(value * M_PI/180, 0.0, 1.0, 0.0);
}


- (void)setScaleXValue:(float)value {
    self.dScaleX = value;
    self._view.transform = CGAffineTransformConcat(self._view.transform, CGAffineTransformMakeScale(self.dScaleX, self.dScaleY));
}


- (void)setScaleYValue:(float)value {
    self.dScaleY = value;
    self._view.transform = CGAffineTransformConcat(self._view.transform, CGAffineTransformMakeScale(self.dScaleX, self.dScaleY));
}


- (void)setTagKey:(nonnull id)key value:(id _Nullable)value {
    
}


- (void)setTagValue:(id _Nullable)value {
    
}


- (void)setTranslationXValue:(float)value {
    self.dTranslationX = value;
    self._view.transform = CGAffineTransformTranslate(self._view.transform, self.dTranslationX, self.dTranslationY);
}


- (void)setTranslationYValue:(float)value {
    self.dTranslationY = value;
    self._view.transform = CGAffineTransformTranslate(self._view.transform, self.dTranslationX, self.dTranslationY);
}


- (void)setTranslationZValue:(float)value {
    self.dTranslationZ = value;
}


- (void)setVisibilityValue:(int32_t)value {
    [self setVisibility:value];
}


- (void)swizzleFunctionFuncName:(nonnull NSString *)funcName block_:(nonnull id  _Nullable (^)(id<IOSKHTView> _Nonnull, id _Nullable))block {
    [self.methodEventMap setObject:block forKey:funcName];
}

@end

@implementation Gravity

+(LuaRect*)apply:(int)gravity :(int)w :(int)h :(LuaRect*)container {
    return [Gravity apply:gravity :w :h :container :0 :0];
}

+(LuaRect*)apply:(int)gravity :(int)w :(int)h :(LuaRect*)container :(int)layoutDirection {
    int absGravity = [Gravity getAbsoluteGravity:gravity];
    return [Gravity apply:absGravity :w :h :container :0 :0];
}

+(LuaRect*)apply:(int)gravity :(int)w :(int)h :(LuaRect*)container :(int)xAdj :(int)yAdj {
    LuaRect* outRect = [LuaRect new];
    switch (gravity&((AXIS_PULL_BEFORE|AXIS_PULL_AFTER)<<AXIS_X_SHIFT)) {
        case 0:
            outRect.left = container.left
                    + ((container.right - container.left - w)/2) + xAdj;
            outRect.right = outRect.left + w;
            if ((gravity&(AXIS_CLIP<<AXIS_X_SHIFT))
                    == (AXIS_CLIP<<AXIS_X_SHIFT)) {
                if (outRect.left < container.left) {
                    outRect.left = container.left;
                }
                if (outRect.right > container.right) {
                    outRect.right = container.right;
                }
            }
            break;
        case AXIS_PULL_BEFORE<<AXIS_X_SHIFT:
            outRect.left = container.left + xAdj;
            outRect.right = outRect.left + w;
            if ((gravity&(AXIS_CLIP<<AXIS_X_SHIFT))
                    == (AXIS_CLIP<<AXIS_X_SHIFT)) {
                if (outRect.right > container.right) {
                    outRect.right = container.right;
                }
            }
            break;
        case AXIS_PULL_AFTER<<AXIS_X_SHIFT:
            outRect.right = container.right - xAdj;
            outRect.left = outRect.right - w;
            if ((gravity&(AXIS_CLIP<<AXIS_X_SHIFT))
                    == (AXIS_CLIP<<AXIS_X_SHIFT)) {
                if (outRect.left < container.left) {
                    outRect.left = container.left;
                }
            }
            break;
        default:
            outRect.left = container.left + xAdj;
            outRect.right = container.right + xAdj;
            break;
    }

    switch (gravity&((AXIS_PULL_BEFORE|AXIS_PULL_AFTER)<<AXIS_Y_SHIFT)) {
        case 0:
            outRect.top = container.top
                    + ((container.bottom - container.top - h)/2) + yAdj;
            outRect.bottom = outRect.top + h;
            if ((gravity&(AXIS_CLIP<<AXIS_Y_SHIFT))
                    == (AXIS_CLIP<<AXIS_Y_SHIFT)) {
                if (outRect.top < container.top) {
                    outRect.top = container.top;
                }
                if (outRect.bottom > container.bottom) {
                    outRect.bottom = container.bottom;
                }
            }
            break;
        case AXIS_PULL_BEFORE<<AXIS_Y_SHIFT:
            outRect.top = container.top + yAdj;
            outRect.bottom = outRect.top + h;
            if ((gravity&(AXIS_CLIP<<AXIS_Y_SHIFT))
                    == (AXIS_CLIP<<AXIS_Y_SHIFT)) {
                if (outRect.bottom > container.bottom) {
                    outRect.bottom = container.bottom;
                }
            }
            break;
        case AXIS_PULL_AFTER<<AXIS_Y_SHIFT:
            outRect.bottom = container.bottom - yAdj;
            outRect.top = outRect.bottom - h;
            if ((gravity&(AXIS_CLIP<<AXIS_Y_SHIFT))
                    == (AXIS_CLIP<<AXIS_Y_SHIFT)) {
                if (outRect.top < container.top) {
                    outRect.top = container.top;
                }
            }
            break;
        default:
            outRect.top = container.top + yAdj;
            outRect.bottom = container.bottom + yAdj;
            break;
    }
    return outRect;
}

+(LuaRect*)apply:(int)gravity :(int)w :(int)h :(LuaRect*)container :(int)xAdj :(int)yAdj :(int)layoutDirection {
    int absGravity = [Gravity getAbsoluteGravity:gravity];
    return [Gravity apply:absGravity :w :h :container :xAdj :yAdj];
}

+ (BOOL)isVertical:(int)gravity {
    return gravity > 0 && (gravity & VERTICAL_GRAVITY_MASK) != 0;
}

+(BOOL)isHorizontal:(int)gravity {
    return gravity > 0 && (gravity & RELATIVE_HORIZONTAL_GRAVITY_MASK) != 0;
}

+(int)getAbsoluteGravity:(int)gravity {
    int result = gravity;
    // If layout is script specific and gravity is horizontal relative (START or END)
    if ((result & RELATIVE_LAYOUT_DIRECTION) > 0) {
        if ((result & GRAVITY_START) == GRAVITY_START) {
            // Remove the START bit
            result &= ~GRAVITY_START;
            if ([LGView isRtl]) {
                // Set the RIGHT bit
                result |= GRAVITY_RIGHT;
            } else {
                // Set the LEFT bit
                result |= GRAVITY_LEFT;
            }
        } else if ((result & GRAVITY_END) == GRAVITY_END) {
            // Remove the END bit
            result &= ~GRAVITY_END;
            if ([LGView isRtl]) {
                // Set the LEFT bit
                result |= GRAVITY_LEFT;
            } else {
                // Set the RIGHT bit
                result |= GRAVITY_RIGHT;
            }
        }
        // Don't need the script specific bit any more, so remove it as we are converting to
        // absolute values (LEFT or RIGHT)
        result &= ~RELATIVE_LAYOUT_DIRECTION;
    }
    return result;
}

@end

@implementation MeasureSpec

+(int)makeMeasureSpec:(int)size :(int)mode {
    return size + mode;
}

+(int)getMode:(int)measureSpec {
    return (measureSpec & MODE_MASK);
}

+(int)getSize:(int)measureSpec {
    return (measureSpec & ~MODE_MASK);
}

@end
