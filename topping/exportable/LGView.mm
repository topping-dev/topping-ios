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
#import "LGRelativeLayout.h"

static BOOL rtl = false;
static BOOL swizzled = false;

@implementation DragEvent

+(DragEvent *)obtain:(int)action :(float)x :(float)y :(NSString *)data {
    DragEvent *event = [DragEvent new];
    event.action = action;
    event.x = x;
    event.y = y;
    event.clipData = data;
    
    return event;
}

@end

@implementation Transformation

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.alpha = 1;
        self.matrix = CATransform3DIdentity;
    }
    return self;
}

-(void)clear {
    self.matrix = CATransform3DIdentity;
    self.alpha = 1;
    self.transformationType = TRANSFORMATION_TYPE_BOTH;
}

@end

@implementation UIView(Extension)

static char UIB_PROPERTY_KEY;
static char UIB_PROPERTY_KEY_FORM;

@dynamic wrapper, form;

-(void)setWrapper:(LGView *)wrapper
{
    objc_setAssociatedObject(self, &UIB_PROPERTY_KEY, wrapper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(LGView *)wrapper
{
    return (LGView*)objc_getAssociatedObject(self, &UIB_PROPERTY_KEY);
}

-(void)setForm:(LuaForm *)form
{
    objc_setAssociatedObject(self, &UIB_PROPERTY_KEY_FORM, form, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(LuaForm *)form
{
    return (LuaForm*)objc_getAssociatedObject(self, &UIB_PROPERTY_KEY_FORM);
}

-(BOOL)overload_pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if(self.wrapper != nil) {
        return CGRectContainsPoint(CGRectMake(self.wrapper.dX, self.wrapper.dY, self.wrapper.dWidth, self.wrapper.dHeight), point);
    }
    return true;
}

-(void)overload_touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if(self.form != nil || self.wrapper.lc.form)
    {
        LuaForm *formResolved = self.wrapper.lc.form;
        if(self.form != nil)
            formResolved = self.form;
        if(touches.count > 0) {
            CGPoint point = [[[touches allObjects] objectAtIndex:0] locationInView:formResolved.view];
            [formResolved dispatchTouchEvent:[LGView convertToMotionEvent:formResolved.lgview :point :UIGestureRecognizerStateBegan]];
            //[LGView onIOSTouchEvent:self.wrapper :point :UIGestureRecognizerStateChanged];
        }
    }
    /*if([self respondsToSelector:@selector(overload_touchesBegan:withEvent:)])
        [self overload_touchesBegan:touches withEvent:event];*/
}

-(void)overload_touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if(self.form != nil || self.wrapper.lc.form)
    {
        LuaForm *formResolved = self.wrapper.lc.form;
        if(self.form != nil)
            formResolved = self.form;
        if(touches.count > 0) {
            CGPoint point = [[[touches allObjects] objectAtIndex:0] locationInView:formResolved.view];
            [formResolved dispatchTouchEvent:[LGView convertToMotionEvent:formResolved.lgview :point :UIGestureRecognizerStateChanged]];
            //[LGView onIOSTouchEvent:self.wrapper :point :UIGestureRecognizerStateChanged];
        }
    }
    /*if([self respondsToSelector:@selector(overload_touchesMoved:withEvent:)])
        [self overload_touchesMoved:touches withEvent:event];*/
}

-(void)overload_touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if(self.form != nil || self.wrapper.lc.form)
    {
        LuaForm *formResolved = self.wrapper.lc.form;
        if(self.form != nil)
            formResolved = self.form;
        if(touches.count > 0) {
            CGPoint point = [[[touches allObjects] objectAtIndex:0] locationInView:formResolved.view];
            [formResolved dispatchTouchEvent:[LGView convertToMotionEvent:formResolved.lgview :point :UIGestureRecognizerStateEnded]];
            //[LGView onIOSTouchEvent:self.wrapper :point :UIGestureRecognizerStateEnded];
        }
    }
    /*if([self respondsToSelector:@selector(overload_touchesEnded:withEvent:)])
        [self overload_touchesEnded:touches withEvent:event];*/
}

-(void)overload_didMoveToWindow {
    [self overload_didMoveToWindow];
    
    if(self.wrapper == nil)
        return;
    
    if(self.window != nil)
    {
        [self.wrapper onAttachedToWindow];
        
        for(id<OnAttachStateChangeListener> listener in self.wrapper.mOnAttachStateChangeListeners) {
            [listener onViewAttachedToWindow:self.wrapper];
        }
    }
    else {
        [self.wrapper onDetachedFromWindow];
        
        for(id<OnAttachStateChangeListener> listener in self.wrapper.mOnAttachStateChangeListeners) {
            [listener onViewDetachedFromWindow:self.wrapper];
        }
    }
}

/*-(void)overload_layoutSublayersOfLayer:(CALayer *)layer {
    [self overload_layoutSublayersOfLayer:layer];
}*/

-(void)overload_layoutSubviews {
    [self overload_layoutSubviews];
    
    [self.wrapper.viewTreeObserver dispatchGlobalLayout];
}

-(BOOL)overload_canBecomeFocused {
    return self.wrapper.isFocusable;
}

-(void)overload_didUpdateFocusInContext:(UIFocusUpdateContext *)context withAnimationCoordinator:(UIFocusAnimationCoordinator *)coordinator {
    TIOSKHRect *rect = [[TIOSKHRect alloc] init];
    if (@available(iOS 12.0, *)) {
        if(context.previouslyFocusedItem != nil) {
            rect.left = context.previouslyFocusedItem.frame.origin.x;
            rect.top = context.previouslyFocusedItem.frame.origin.y;
            rect.right = rect.left + context.previouslyFocusedItem.frame.size.width;
            rect.bottom = rect.top + context.previouslyFocusedItem.frame.size.height;
        }
    }
    [self.wrapper onFocusChanged:(context.nextFocusedView == self) :0 : rect];
    
    [self overload_didUpdateFocusInContext:context withAnimationCoordinator:coordinator];
}

/*
 https://stackoverflow.com/questions/506622/cgcontextdrawimage-draws-image-upside-down-when-passed-uiimage-cgimage
 */

-(void)overload_drawRect:(CGRect)rect {
    //TODO: Find a way for this in kotlin
    if(self.wrapper.forceOverrideDrawRect || [self.wrapper respondsToSelector:@selector(onDrawCanvas:)])
    {
        if(self.wrapper.forceOverrideDrawRectBlock(rect)) {
            return;
        }
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        if(self.wrapper.canvas == nil || (rect.size.width != self.wrapper.lastCanvasSize.size.width && rect.size.height != self.wrapper.lastCanvasSize.size.height))
        {
            self.wrapper.lastCanvasSize = rect;
            UIGraphicsBeginImageContext(rect.size);
            UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            if(img == nil)
            {
                return;
            }

            TIOSKHSkikoImage *skImage = [TIOSKHSkiaCanvasKt toSkiaImage:img];
            TIOSKHSkikoBitmap *skBitmap = [skImage toBitmap];
            self.wrapper.canvas = [[TIOSKHSkiaCanvas alloc] initWithBitmap:skBitmap];
        }
        TIOSKHSkiaCanvas *canvas = self.wrapper.canvas;
        [self.wrapper onDrawCanvas:canvas];
        [self.wrapper dispatchDrawCanvas:canvas];

        TIOSKHKotlinByteArray *byteArr = [canvas.bitmap readPixelsDstInfo:canvas.bitmap.imageInfo dstRowBytes:canvas.bitmap.rowBytes srcX:0 srcY:0];
        UIImage *img = [UIImage new];
        if(byteArr != nil)
        {
            NSMutableData *data = [[NSMutableData alloc] initWithLength:byteArr.size];
            //NSString *str = @"";
            for(int i = 0; i < byteArr.size; i++) {
                char c = [byteArr getIndex:i];
                //str = [str stringByAppendingFormat:@"%x,", c];
                ((char*)[data mutableBytes])[i] = c;
            }
            //NSLog(@"%@,", str);
            CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
            CGDataProviderRef dataProviderRef = CGDataProviderCreateWithCFData((CFDataRef)data);
            CGImageRef imageRef = CGImageCreate(canvas.bitmap.imageInfo.width, canvas.bitmap.imageInfo.height, 8, canvas.bitmap.imageInfo.bytesPerPixel * 8, canvas.bitmap.imageInfo.minRowBytes, colorSpaceRef, kCGImageAlphaFirst | kCGBitmapByteOrder32Little, dataProviderRef, nil, false, kCGRenderingIntentDefault);
            CGColorSpaceRelease(colorSpaceRef);
            CGDataProviderRelease(dataProviderRef);
            
            img = [[UIImage alloc] initWithCGImage:imageRef];
        }

        UIGraphicsPushContext(ctx);
        [img drawAtPoint:CGPointZero]; // UIImage will handle all especial cases!
        UIGraphicsPopContext();
        [self overload_drawRect:rect];
    }
    else
        [self overload_drawRect:rect];
}

-(void)overload_drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
    [self overload_drawLayer:layer inContext:ctx];
}

@end

@implementation LGView

+(BOOL)isRtl {
    return rtl;
}

@synthesize layout, baseLine, onDragListener = _onDragListener;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.layout = NO;
        self.layoutRequested = true;
        self.baseLine = -1;
        self.isFocusable = true;
        self.android_layout_width = @"wrap_content";
        self.android_layout_height = @"wrap_content";
        self.methodSkip = [NSMutableArray array];
        self.methodEventMap = [NSMutableDictionary dictionary];
        self.viewTreeObserver = [ViewTreeObserver new];
    }
    return self;
}

-(void)initProperties
{
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
    if(self.postOnAnimationBlock != nil)
    {
        self.postOnAnimationBlock();
        self.postOnAnimationBlock = nil;
    }
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

-(void)beforeInitSubviews {
    
}

-(void)beforeInitComponent {
    rtl = [self._view isRTL];
    [self resolveLayoutDirection];
}

//Will always calle
-(void)initComponent:(UIView *)view :(LuaContext *)lc
{
	if(view == nil)
		return;
	if(self._view != nil)
	{
		self._view = nil;
	}
	self._view = view;
    self._view.wrapper = self;
	if(self.android_id != nil)
	{
        self.android_id = [[LGIdParser getInstance] getId:self.android_id];
	}
	
	//Setup background
    if(self.android_background != nil)
        [self setBackground:[LuaRef withValue:self.android_background]];
    
    if(self.android_alpha != nil) {
        self.dAlpha = ((NSNumber*)[[LGValueParser getInstance] getValue:self.android_alpha]).floatValue / 255.0f;
        self._view.alpha = self.dAlpha;
    }
    else
        self.dAlpha = 1;
    
    if(self.android_transitionAlpha != nil)
        self.dTransitionAlpha = ((NSNumber*)[[LGValueParser getInstance] getValue:self.android_transitionAlpha]).floatValue / 255.0f;
    else
        self.dTransitionAlpha = 1;
    
    self.lc = lc;
    
    if(!swizzled) {
        swizzled = true;
        [self swizzleMethods:[UIView class] :NSSelectorFromString(@"pointInside:withEvent:") :NSSelectorFromString(@"overload_pointInside:withEvent:")];
        [self swizzleMethods:[UIView class] :NSSelectorFromString(@"touchesBegan:withEvent:") :NSSelectorFromString(@"overload_touchesBegan:withEvent:")];
        [self swizzleMethods:[UIView class] :NSSelectorFromString(@"touchesMoved:withEvent:") :NSSelectorFromString(@"overload_touchesMoved:withEvent:")];
        [self swizzleMethods:[UIView class] :NSSelectorFromString(@"touchesEnded:withEvent:") :NSSelectorFromString(@"overload_touchesEnded:withEvent:")];
        [self swizzleMethods:[UIView class] :NSSelectorFromString(@"didMoveToWindow") :NSSelectorFromString(@"overload_didMoveToWindow")];
        [self swizzleMethods:[UIView class] :NSSelectorFromString(@"layoutSubviews") :NSSelectorFromString(@"overload_layoutSubviews")]; 
        [self swizzleMethods:[UIView class] :NSSelectorFromString(@"canBecomeFocused") :NSSelectorFromString(@"overload_canBecomeFocused")];
        [self swizzleMethods:[UIView class] :NSSelectorFromString(@"didUpdateFocusInContext:withAnimationCoordinator:") :NSSelectorFromString(@"overload_didUpdateFocusInContext:withAnimationCoordinator:")];
        [self swizzleMethods:[UIView class] :NSSelectorFromString(@"drawLayer:inContext:") :NSSelectorFromString(@"overload_drawLayer:inContext:")];
        [self swizzleMethods:[UIView class] :NSSelectorFromString(@"drawRect:") :NSSelectorFromString(@"overload_drawRect:")];
    }
}

-(void)setupComponent:(UIView *)view
{
    if(![self._view isKindOfClass:[UILabelPadding class]])
        view.layoutMargins = UIEdgeInsetsMake(self.dPaddingTop, self.dPaddingLeft, self.dPaddingBottom, self.dPaddingRight);
    if(self.android_enabled != nil) {
        NSString *enabled = (NSString*)[[LGValueParser getInstance] getValue:self.android_enabled];
        [self setEnabled:SSTOB(enabled)];
    }
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

-(LGView *)generateLGViewForName:(NSString *)name :(NSArray *)attrs {
    return nil;
}

-(void)fullInit
{
    [self applyStyles];
    [self beforeInitComponent];
    [self readWidthHeight];
    UIView *_view = [self createComponent];
    [self initComponent:_view :self.lc];
    [self setupComponent:_view];
}

-(void)clearDimensions
{
    self.dX = self.dY = self.dWidth = self.dHeight = 0;
}

-(void)resize
{
	[self readWidthHeight];
}

-(void)resolveLayoutDirection {
    int layoutDirection = 0;
    if([LGView isRtl])
        layoutDirection = 1;
    if(self.kLayoutParams != nil) {
        [self.kLayoutParams resolveLayoutDirectionLayoutDirection:layoutDirection];
    }
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
    if(self.layoutRequested || self.layout || self.dWidthSpec != widthMeasureSpec || self.dHeightSpec != heightMeasureSpec)
    {
        self.layout = NO;
        [self onMeasure:widthMeasureSpec :heightMeasureSpec];
        self.layoutRequested = false;
    }
    self.widthSpecSet = true;
    self.heightSpecSet = true;
    self.dWidthSpec = widthMeasureSpec;
    self.dHeightSpec = heightMeasureSpec;
}

-(void)onMeasure:(int)widthMeasureSpec :(int)heightMeasureSpec {
    if([self callTMethod:@"onMeasure" :nil :[NSNumber numberWithInt:widthMeasureSpec], [NSNumber numberWithInt:heightMeasureSpec], nil])
        return;
    int newWidthSpec = widthMeasureSpec;
    int newHeightSpec = heightMeasureSpec;
    
    //TODO: Check this if later
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
    [self._view setNeedsLayout];
}

-(int)getMeasuredState {
    return self.dWidthSpec | self.dHeightSpec;
}

-(int)getSuggestedMinimumHeight {
    int suggestedMinHeight = 0;
    if(self.android_minHeight != nil)
        suggestedMinHeight = self.dHeightMin;
    /*if(self.android_background != nil)
    if (mBGDrawable != null) {
        int bgMinWidth = mBGDrawable.getMinimumWidth();
        if (suggestedMinWidth < bgMinWidth) {
            suggestedMinWidth = bgMinWidth;
        }
    }*/
    return suggestedMinHeight;
}

-(int)getSuggestedMinimumWidth {
    int suggestedMinWidth = 0;
    if(self.android_minWidth != nil)
        suggestedMinWidth = self.dWidthMin;
    /*if(self.android_background != nil)
    if (mBGDrawable != null) {
        int bgMinWidth = mBGDrawable.getMinimumWidth();
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
    self.dWidthMin = [[LGDimensionParser getInstance] getDimension:self.android_minWidth];
    self.dHeightMin = [[LGDimensionParser getInstance] getDimension:self.android_minHeight];
    
	@try {
		self.dPaddingLeft = [[LGDimensionParser getInstance] getDimension:self.android_paddingLeft];
		self.dPaddingRight = [[LGDimensionParser getInstance] getDimension:self.android_paddingRight];
		self.dPaddingTop = [[LGDimensionParser getInstance] getDimension:self.android_paddingTop];
		self.dPaddingBottom = [[LGDimensionParser getInstance] getDimension:self.android_paddingBottom];
        if(self.android_paddingStart != nil) {
            if(![LGView isRtl]) {
                self.dPaddingLeft = [[LGDimensionParser getInstance] getDimension:self.android_paddingStart];
            } else {
                self.dPaddingRight = [[LGDimensionParser getInstance] getDimension:self.android_paddingStart];
            }
        }
        if(self.android_paddingEnd != nil) {
            if(![LGView isRtl]) {
                self.dPaddingRight = [[LGDimensionParser getInstance] getDimension:self.android_paddingEnd];
            } else {
                self.dPaddingLeft = [[LGDimensionParser getInstance] getDimension:self.android_paddingEnd];
            }
        }
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
        if(self.android_layout_marginStart != nil) {
            if(![LGView isRtl]) {
                self.dMarginLeft = [[LGDimensionParser getInstance] getDimension:self.android_layout_marginStart];
            } else {
                self.dMarginRight = [[LGDimensionParser getInstance] getDimension:self.android_layout_marginStart];
            }
        }
        if(self.android_layout_marginEnd != nil) {
            if(![LGView isRtl]) {
                self.dMarginRight = [[LGDimensionParser getInstance] getDimension:self.android_layout_marginEnd];
            } else {
                self.dMarginLeft = [[LGDimensionParser getInstance] getDimension:self.android_layout_marginEnd];
            }
        }
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
    if([self callTMethod:@"onLayout" :nil :[NSNumber numberWithBool:false],
     [NSNumber numberWithInt:l], [NSNumber numberWithInt:t],
     [NSNumber numberWithInt:r], [NSNumber numberWithInt:b], nil])
        return;
    self._view.frame = CGRectMake(l, t, r - l, b - t);
}

+(BOOL)onIOSTouchEvent:(LGView*)view :(CGPoint)point :(UIGestureRecognizerState)state {
    BOOL result = false;
    TIOSKHMotionEvent *event;
    if(state == UIGestureRecognizerStateBegan
       || state == UIGestureRecognizerStateChanged
       || state == UIGestureRecognizerStateEnded) {
        event = [LGView convertToMotionEvent:view :point :state];
    }
    
    if(event != nil) {
        result = [view dispatchTouchEvent:event];
    }
    
    return result;
}

+(TIOSKHMotionEvent *)convertToMotionEvent:(LGView*)view :(CGPoint)point :(UIGestureRecognizerState)state {
    long time = [[NSDate new] timeIntervalSince1970] * 1000;

    if((view.tapDownTime == 0 || (time - view.tapDownTime) > 1000) && state == UIGestureRecognizerStateBegan) {
        view.tapDownTime = time;
        TIOSKHMotionEvent *event = [[TIOSKHMotionEvent companion]
                                   obtainDownTime:view.tapDownTime
                                   eventTime:view.tapDownTime
                                   action:[TIOSKHMotionEvent companion].ACTION_DOWN x:point.x y:point.y metaState:0];
        return event;
    } else if(state == UIGestureRecognizerStateChanged) {
        TIOSKHMotionEvent *event = [[TIOSKHMotionEvent companion]
                                   obtainDownTime:view.tapDownTime
                                   eventTime:time
                                   action:[TIOSKHMotionEvent companion].ACTION_MOVE x:point.x y:point.y metaState:0];
        return event;
    } else if(state == UIGestureRecognizerStateEnded) {
        TIOSKHMotionEvent *event = [[TIOSKHMotionEvent companion]
                                   obtainDownTime:view.tapDownTime
                                   eventTime:time
                                   action:[TIOSKHMotionEvent companion].ACTION_UP x:point.x y:point.y metaState:0];
        view.tapDownTime = 0;
        return event;
    }
    
    return nil;
}

-(BOOL)dispatchTouchEvent:(TIOSKHMotionEvent*)event {
    BOOL handled = false;
    
    int actionMasked = event.actionMasked;
    if(actionMasked == TIOSKHMotionEvent.companion.ACTION_DOWN) {
        self.tapDownTime = event.downTime;
        //stop scroll?
    }
    
    //TODO:Add touch listeners?
    //if(self.onTouchListener)
    
    if(!handled && [self onTouchEvent:event]) {
        handled = true;
    }
    
    if(actionMasked == TIOSKHMotionEvent.companion.ACTION_UP
       || actionMasked == TIOSKHMotionEvent.companion.ACTION_CANCEL
       || (actionMasked == TIOSKHMotionEvent.companion.ACTION_DOWN && !handled)) {
        //stop scroll?
    }
    
    return handled;
}

- (BOOL)onTouchEvent:(TIOSKHMotionEvent *)event {
    BOOL result = false;
    
    result = [self onTouchEventEvent:event];
    
    if(!result) {
        NSNumber *num = [NSNumber numberWithBool:false];
        [self callTMethod:@"onTouchEvent" :&num :event, nil];
        result = [num boolValue];
    }
    
    return result;
}

-(BOOL)dispatchGenericMotionEvent:(TIOSKHMotionEvent*)event {
    int source = event.source;
    /*if((source & TIOSKHAINPUT_SOURCE.ainputSourceClassPointer.value) != 0) {
        int action = event.action;
        if(action == TIOSKHMotionEvent.companion.ACTION_HOVER_ENTER
           || action == TIOSKHMotionEvent.companion.ACTION_HOVER_MOVE
           || action == TIOSKHMotionEvent.companion.ACTION_HOVER_EXIT) {
            //dispatchHover
        }
    }*/
    
    if([self dispatchGenericMotionEventInternal:event]) {
        return true;
    }
    return false;
}

-(BOOL)dispatchGenericMotionEventInternal:(TIOSKHMotionEvent*)event {
    //TODO:
    return false;
}

-(void)postOnAnimation:(void (^)())block {
    self.postOnAnimationBlock = block;
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
+(LGView *)create:(LuaContext *)context
{
	LGView *lst = [[LGView alloc] init];
    lst.lc = context;
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
    self.isFocusable = focusable;
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
    if(self._view == nil)
        return self.dVisibility;
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
    if([self callTMethod:@"setVisibility" :nil :[NSNumber numberWithInt:(int)visibility], nil])
        return;
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
    if(lt == nil) {
        if(self.tapGesture != nil)
            [self._view removeGestureRecognizer:self.tapGesture];
        self.tapGesture = nil;
        return;
    }
    if(self.tapGesture != nil) {
        [self._view removeGestureRecognizer:self.tapGesture];
    }
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self._view action:lt.selector];
    [self._view addGestureRecognizer:self.tapGesture];
}

-(NSDictionary *)getBindings {
    if([self isKindOfClass:[LGViewGroup class]])
        return [((LGViewGroup*)self) getBindings];
    return @{};
}

-(void)SetId:(NSString *)idVal {
    self.lua_id = [[LGIdParser getInstance] getId:idVal];
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

-(void)setTag:(NSString*)key :(NSObject*)value {
    if(self.tagMap == nil)
        self.tagMap = [NSMutableDictionary dictionary];
    
    [self.tagMap setObject:value forKey:key];
}

-(NSObject*)getTag:(NSString*)key {
    return self.tagMap[key];
}

-(void)setViewTreeLifecycleOwner:(id<LifecycleOwner>)lifecycleOwner {
    [self setTag:@"view_tree_lifecycle_owner" :lifecycleOwner];
}

-(id<LifecycleOwner>)findViewTreeLifecycleOwner {
    id<LifecycleOwner> found = (id<LifecycleOwner>)[self getTag:@"view_tree_lifecycle_owner"];
    if (found != nil) return found;
    LGView *parent = self.parent;
    while (found == nil && parent != nil) {
        found = (id<LifecycleOwner>)[parent getTag:@"view_tree_lifecycle_owner"];
        parent = parent.parent;
    }
    
    return found;
}

-(void)onFocusChanged:(BOOL)gainFocus :(int)direction :(TIOSKHRect *)previouslyFocusedRect {}

-(void)onConfigurationChanged:(Configuration *)configuration {}

-(void)startDragAndDrop:(NSString *)data {
    self.dragData = data;
}

//Drag
-(void)dragInteraction:(UIDragInteraction *)interaction sessionWillBegin:(id<UIDragSession>)session {
    CGPoint point = [session locationInView:self._view];
    [self.onDragListener onDrag:self :[DragEvent obtain:ACTION_DRAG_LOCATION :point.x :point.y :nil]];
}

-(NSArray<UIDragItem *> *)dragInteraction:(UIDragInteraction *)interaction itemsForBeginningSession:(id<UIDragSession>)session {
    NSItemProvider *provider = [[NSItemProvider alloc] initWithObject:self.dragData];
    UIDragItem *item = [[UIDragItem alloc] initWithItemProvider:provider];

    return @[item];
}

//Drop
-(BOOL)dropInteraction:(UIDropInteraction *)interaction canHandleSession:(id<UIDropSession>)session {
    CGPoint point = [session locationInView:self._view];
    return [self.onDragListener onDrag:self :[DragEvent obtain:ACTION_DRAG_STARTED :point.x :point.y :nil]];
}

-(void)dropInteraction:(UIDropInteraction *)interaction sessionDidEnter:(id<UIDropSession>)session {
    CGPoint point = [session locationInView:self._view];
    [self.onDragListener onDrag:self :[DragEvent obtain:ACTION_DRAG_ENTERED :point.x :point.y :nil]];
}

-(UIDropProposal *)dropInteraction:(UIDropInteraction *)interaction sessionDidUpdate:(id<UIDropSession>)session {
    CGPoint point = [session locationInView:self._view];
    [self.onDragListener onDrag:self :[DragEvent obtain:ACTION_DRAG_LOCATION :point.x :point.y :nil]];
    return [[UIDropProposal alloc] initWithDropOperation:UIDropOperationCopy];
}

- (void)dropInteraction:(UIDropInteraction *)interaction performDrop:(id<UIDropSession>)session {
    __block CGPoint point = [session locationInView:self._view];
    [session loadObjectsOfClass:[NSObject class] completion:^(NSArray<__kindof id<NSItemProviderReading>> * _Nonnull objects) {
        NSString *data = [objects firstObject];
        [self.onDragListener onDrag:self :[DragEvent obtain:ACTION_DROP :point.x :point.y :data]];
    }];
}

-(void)dropInteraction:(UIDropInteraction *)interaction sessionDidExit:(id<UIDropSession>)session {
    CGPoint point = [session locationInView:self._view];
    [self.onDragListener onDrag:self :[DragEvent obtain:ACTION_DRAG_EXITED :point.x :point.y :nil]];
}

- (void)dropInteraction:(UIDropInteraction *)interaction sessionDidEnd:(id<UIDropSession>)session {
    CGPoint point = [session locationInView:self._view];
    [self.onDragListener onDrag:self :[DragEvent obtain:ACTION_DRAG_ENDED :point.x :point.y :nil]];
}

-(void)setOnDragListener:(id<OnDragListener>)onDragListener {
    _onDragListener = onDragListener;
    if(_onDragListener != nil) {
        self.dragInteraction = [[UIDragInteraction alloc] initWithDelegate:self];
        [self._view addInteraction:self.dragInteraction];
        
        self.dropInteraction = [[UIDropInteraction alloc] initWithDelegate:self];
        [self._view addInteraction:self.dropInteraction];
    } else {
        [self._view removeInteraction:self.dragInteraction];
        [self._view removeInteraction:self.dropInteraction];
    }
}

-(BOOL)hasIdentityMatrix {
    return CATransform3DIsIdentity(self._view.layer.transform);
}

-(BOOL)onSetAlpha:(float)value {
    return false;
}

-(void)addOnAttachStateChangeListener:(id<OnAttachStateChangeListener>)listener {
    if(self.mOnAttachStateChangeListeners == nil) {
        self.mOnAttachStateChangeListeners = [NSMutableArray new];
    }
    
    [self.mOnAttachStateChangeListeners addObject:listener];
}

-(void)removeOnAttachStateChangeListener:(id<OnAttachStateChangeListener>)listener {
    if(self.mOnAttachStateChangeListeners == nil) {
        return;
    }
    
    [self.mOnAttachStateChangeListeners removeObject:listener];
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

#pragma TIOSKHView start

-(BOOL)callTMethodArr:(NSString *)methodName :(NSObject**)result :(NSArray *)arr {
    if([self.methodSkip containsObject:methodName])
        return false;
    
    if([self.methodEventMap objectForKey:methodName] != nil) {
        TIOSKHKotlinArray *___arr___ = [TIOSKHKotlinArray arrayWithSize:(int)arr.count init:^id _Nullable(TIOSKHInt * _Nonnull index) { return nil; }];
        for(int i = 0; i < arr.count; i++) {
            [___arr___ setIndex:i value:[arr objectAtIndex:i]];
        }
        
        [self.methodSkip addObject:methodName];
        if(result != nil) {
            *result = ((id  _Nullable (^)(id<TIOSKHTView> _Nonnull, TIOSKHKotlinArray<id> * _Nonnull))[self.methodEventMap objectForKey:methodName])(self, ___arr___);
        } else {
            ((id  _Nullable (^)(id<TIOSKHTView> _Nonnull, TIOSKHKotlinArray<id> * _Nonnull))[self.methodEventMap objectForKey:methodName])(self, ___arr___);
        }
        [self.methodSkip removeObject:methodName];
        return true;
    }
    
    return false;
}

-(BOOL)callTMethod:(NSString *)methodName :(NSObject**)result :(id)arg, ... {
    NSMutableArray *arr = [[NSMutableArray alloc] initWithArray:VarArgs2(arg)];
    
    return [self callTMethodArr:methodName :result :arr];
}

-(void)swizzleMethods:(Class)cls :(SEL)original :(SEL)swizzled {
    SEL originalSelector = original;
    SEL swizzledSelector = swizzled;

    Method originalMethod = class_getInstanceMethod(cls, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(cls, swizzledSelector);

    // When swizzling a class method, use the following:
    // Method originalMethod = class_getClassMethod(class, originalSelector);
    // Method swizzledMethod = class_getClassMethod(class, swizzledSelector);

    IMP originalImp = method_getImplementation(originalMethod);
    IMP swizzledImp = method_getImplementation(swizzledMethod);

    class_replaceMethod(cls,
            swizzledSelector,
            originalImp,
            method_getTypeEncoding(originalMethod));
    class_replaceMethod(cls,
            originalSelector,
            swizzledImp,
            method_getTypeEncoding(swizzledMethod));
}

-(void)swizzleMethods:(SEL)original :(SEL)swizzled {
    [self swizzleMethods:[LGView class] :original :swizzled];
}

- (void)addViewView:(nonnull id<TIOSKHTView>)view param:(nonnull TIOSKHViewGroupLayoutParams *)param {
    
}

- (BOOL)canScrollVerticallyVert:(int32_t)vert {
    return false;
}

- (void)dispatchDrawCanvas:(nonnull id<TIOSKHTCanvas>)canvas {
    
}

- (float)dpToPixelDp:(float)dp {
    return [DisplayMetrics dpToSp:dp];
}

- (id<TIOSKHTView> _Nullable)findViewByIdId:(nonnull NSString *)id {
    return [self getViewByIdId:id];
}

- (void)forceLayout {
    self.layoutRequested = true;
    [self._view setNeedsDisplay];
}

- (id<TIOSKHTDrawable> _Nullable)getBackground {
    NSObject *obj = [[LGValueParser getInstance] getValue:self.lrBackground.idRef];
    
    if([obj isKindOfClass:[LGDrawableReturn class]]) {
        return (id<TIOSKHTDrawable>)obj;
    }
    
    return nil;
}

- (int32_t)getBaseline {
    return self.baseLine;
}

- (nonnull id<TIOSKHTView>)getChildAtIndex:(int32_t)index {
    return (id<TIOSKHTView>)[UIView new];
}

- (int32_t)getChildCount {
    return 0;
}

-(int32_t)getChildMeasureSpecSpec:(int32_t)spec padding:(int32_t)padding dimension:(int32_t)dimension {
    return 0;
}

- (nonnull id<TIOSKHTClass>)getClass {
    return (id<TIOSKHTClass>)[[ToppingClass alloc] initWithCls:[self class]];
}

- (nonnull id<TIOSKHTContext>)getContext {
    return self.lc;
}

- (nonnull id<TIOSKHTDisplay>)getDisplay {
    return [ToppingDisplay new];
}

- (float)getElevation {
    return ((NSNumber*)[[LGValueParser getInstance] getValue:self.android_elevation]).floatValue;
}

- (int32_t)getHeight {
    return self.dHeight;
}

- (void)getHitRectTempRec:(nonnull TIOSKHRect *)tempRec {
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
    if([[LGIdParser getInstance] hasId:[self GetId]])
        return [[LGIdParser getInstance] getId:[self GetId]];

    return @"";
}

- (int32_t)getLayoutDirection {
    return [LGView isRtl] ? 1 : 0;
}

- (TIOSKHViewGroupLayoutParams * _Nullable)getLayoutParams {
    return self.kLayoutParams;
}

- (void)getLocationOnScreenTempLoc:(nonnull TIOSKHKotlinIntArray *)tempLoc {
    CGPoint p = [self._view convertPoint:self._view.frame.origin toView:nil];
    [tempLoc setIndex:0 value:p.x];
    [tempLoc setIndex:1 value:p.y];
}

- (nonnull TIOSKHSkikoMatrix33 *)getMatrix {
    return [KotlinMatrixConvertor skikoMatrixFromCATransform3D:self._view.layer.transform];
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

- (id<TIOSKHTView> _Nullable)getParent {
    return self.parent;
}

- (nonnull id)getParentType {
    return self.kParentType;
}

- (float)getPivotX {
    return self._view.layer.anchorPoint.x;
}

- (float)getPivotY {
    return self._view.layer.anchorPoint.y;
}

- (nonnull id<TIOSKHTResources>)getResources {
    return self.lc._resources;
}

- (float)getRotationX {
    return [[self._view.layer valueForKeyPath:@"transform.rotation.x"] floatValue];
}

- (float)getRotationY {
    return [[self._view.layer valueForKeyPath:@"transform.rotation.y"] floatValue];
}

- (float)getRotation_ {
    return [[self._view.layer valueForKeyPath:@"transform.rotation.z"] floatValue];
}

- (float)getScaleX {
    return [[self._view.layer valueForKeyPath:@"transform.scale.x"] floatValue];
}

- (float)getScaleY {
    return [[self._view.layer valueForKeyPath:@"transform.scale.y"] floatValue];
}

- (float)getScrollX {
    return 0;
}

- (float)getScrollY {
    return 0;
}

- (id _Nullable)getTag {
    return [self.tagMap objectForKey:@""];
}

- (id _Nullable)getTagKey:(nonnull id)key {
    return [self.tagMap objectForKey:key];
}

- (float)getTranslationX {
    return [[self._view.layer valueForKeyPath:@"transform.translation.x"] floatValue];
}

- (float)getTranslationY {
    return [[self._view.layer valueForKeyPath:@"transform.translation.y"] floatValue];
}

- (float)getTranslationZ {
    return [[self._view.layer valueForKeyPath:@"transform.translation.z"] floatValue];
}

- (id<TIOSKHTView> _Nullable)getViewByIdId:(nonnull NSString *)id {
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
    self.layoutRequested = true;
    [self._view setNeedsDisplay];
    self.layoutRequested = false;
}

- (void)invalidateOutline {
    
}

- (void)invokeMethodMethod:(nonnull NSString *)method value:(nonnull id)value {
    SEL selector = NSSelectorFromString(method);
    [self performSelector:selector withObject:value];
}

- (BOOL)isAttachedToWindow {
    BOOL result = self._view.window != nil;
    if(!result) {
        LGView *parent = self.parent;
        while(parent != nil) {
            result = parent._view.window != nil;
            parent = parent.parent;
        }
    }
    
    return result;
}

- (BOOL)isInEditMode {
    return false;
}

- (BOOL)isLayoutRequested {
    return self.layoutRequested;
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
    self.onAttachToWindowCalled = true;
    [self callTMethod:@"onAttachedToWindow" :nil :nil];
    [self.viewTreeObserver dispatchWindowAttach:true];
}

-(void)onDetachedFromWindow {
    self.onAttachToWindowCalled = false;
    [self callTMethod:@"onDetachedFromWindow" :nil :nil];
    [self.viewTreeObserver dispatchWindowAttach:false];
}

- (BOOL)draw:(nonnull id<TIOSKHTCanvas>)canvas :(LGViewGroup*)parent :(int)drawingTime {
    BOOL more = false;
    BOOL childHasIdentityMatrix = [self hasIdentityMatrix];
    int parentFlags = parent.mGroupFlags;
    if ((parentFlags & GROUP_FLAG_CLEAR_TRANSFORMATION) != 0) {
        [parent.childTransformation clear];
        parent.mGroupFlags &= ~GROUP_FLAG_CLEAR_TRANSFORMATION;
    }
    Transformation *transformToApply = nil;
    BOOL concatMatrix = false;
    /*Animation a = getAnimation();
    if (a != null) {
        more = applyLegacyAnimation(parent, drawingTime, a, scalingRequired);
        concatMatrix = a.willChangeTransformationMatrix();
        if (concatMatrix) {
            mPrivateFlags3 |= PFLAG3_VIEW_IS_ANIMATING_TRANSFORM;
        }
        transformToApply = parent.getChildTransformation();
    } else {
        if ((mPrivateFlags3 & PFLAG3_VIEW_IS_ANIMATING_TRANSFORM) != 0) {
            // No longer animating: clear out old animation matrix
            mRenderNode.setAnimationMatrix(null);
            mPrivateFlags3 &= ~PFLAG3_VIEW_IS_ANIMATING_TRANSFORM;
        }*/
        if ((parentFlags & GROUP_FLAG_SUPPORT_STATIC_TRANSFORMATIONS) != 0) {
            Transformation *t = parent.childTransformation;
            BOOL hasTransform = [parent getChildStaticTransformation:self :t];
            if (hasTransform) {
                int transformType = t.transformationType;
                transformToApply = transformType != TRANSFORMATION_TYPE_IDENTITY ? t : nil;
                concatMatrix = (transformType & TRANSFORMATION_TYPE_MATRIX) != 0;
            }
        }
    /*}*/
    concatMatrix |= !childHasIdentityMatrix;
    // Sets the flag as early as possible to allow draw() implementations
    // to call invalidate() successfully when doing animations
    //TODO:Enable this over invalidate
    self.dPrivateFlags |= PFLAG_DRAWN;
    /*if (!concatMatrix &&
            (parentFlags & (GROUP_FLAG_SUPPORT_STATIC_TRANSFORMATIONS |
                    GROUP_FLAG_CLIP_CHILDREN)) == GROUP_FLAG_CLIP_CHILDREN &&
            canvas.quickReject(mLeft, mTop, mRight, mBottom) &&
            (mPrivateFlags & PFLAG_DRAW_ANIMATION) == 0) {
        mPrivateFlags2 |= PFLAG2_VIEW_QUICK_REJECTED;
        return more;
    }
    mPrivateFlags2 &= ~PFLAG2_VIEW_QUICK_REJECTED;
    if (hardwareAcceleratedCanvas) {
        // Clear INVALIDATED flag to allow invalidation to occur during rendering, but
        // retain the flag's value temporarily in the mRecreateDisplayList flag
        mRecreateDisplayList = (mPrivateFlags & PFLAG_INVALIDATED) != 0;
        mPrivateFlags &= ~PFLAG_INVALIDATED;
    }
    RenderNode renderNode = null;
    Bitmap cache = null;
    int layerType = getLayerType(); // TODO: signify cache state with just 'cache' local
    if (layerType == LAYER_TYPE_SOFTWARE || !drawingWithRenderNode) {
         if (layerType != LAYER_TYPE_NONE) {
             // If not drawing with RenderNode, treat HW layers as SW
             layerType = LAYER_TYPE_SOFTWARE;
             buildDrawingCache(true);
        }
        cache = getDrawingCache(true);
    }
    if (drawingWithRenderNode) {
        // Delay getting the display list until animation-driven alpha values are
        // set up and possibly passed on to the view
        renderNode = updateDisplayListIfDirty();
        if (!renderNode.hasDisplayList()) {
            // Uncommon, but possible. If a view is removed from the hierarchy during the call
            // to getDisplayList(), the display list will be marked invalid and we should not
            // try to use it again.
            renderNode = null;
            drawingWithRenderNode = false;
        }
    }*/
    int sx = self.mScrollX;
    int sy = self.mScrollY;
    if (transformToApply != nil) {
        [canvas save];
    }
    [canvas translateDx:(self.getMLeft - sx) dy:(self.getMTop - sy)];
    float alpha = self.dAlpha * self.dTransitionAlpha;
    if (transformToApply != nil
            || alpha < 1
            || ![self hasIdentityMatrix]
            || (self.dPrivateFlags3 & PFLAG3_VIEW_IS_ANIMATING_ALPHA) != 0) {
        if (transformToApply != nil || !childHasIdentityMatrix) {
            int transX = -sx;
            int transY = -sy;
            if (transformToApply != nil) {
                if (concatMatrix) {
                    // Undo the scroll translation, apply the transformation matrix,
                    // then redo the scroll translate to get the correct result.
                    [canvas translateDx:-transX dy:-transY];
                    [canvas concatMatrix:[KotlinMatrixConvertor skikoMatrixFromCATransform3D:transformToApply.matrix]];
                    [canvas translateDx:transX dy:transY];
                    parent.mGroupFlags |= GROUP_FLAG_CLEAR_TRANSFORMATION;
                }
                float transformAlpha = transformToApply.alpha;
                if (transformAlpha < 1) {
                    alpha *= transformAlpha;
                    parent.mGroupFlags |= GROUP_FLAG_CLEAR_TRANSFORMATION;
                }
            }
            if (!childHasIdentityMatrix) {
                [canvas translateDx:-transX dy:-transY];
                [canvas concatMatrix:[KotlinMatrixConvertor skikoMatrixFromCATransform3D:self._view.layer.transform]];
                [canvas translateDx:transX dy:transY];
            }
        }
        // Deal with alpha if it is or used to be <1
        if (alpha < 1 || (self.dPrivateFlags3 & PFLAG3_VIEW_IS_ANIMATING_ALPHA) != 0) {
            if (alpha < 1) {
                self.dPrivateFlags3 |= PFLAG3_VIEW_IS_ANIMATING_ALPHA;
            } else {
                self.dPrivateFlags3 &= ~PFLAG3_VIEW_IS_ANIMATING_ALPHA;
            }
            parent.mGroupFlags |= GROUP_FLAG_CLEAR_TRANSFORMATION;
        
            int multipliedAlpha = (int) (255 * alpha);
            if (![self onSetAlpha:multipliedAlpha]) {
                TIOSKHSkikoRect *rect = [[TIOSKHSkikoRect alloc] initWithLeft:sx top:sy right:sx + self.dWidth bottom:sy + self.dHeight];
                ToppingPaint *tp = (ToppingPaint*)[self.lc createPaint];
                [canvas saveLayerBounds:rect paint:tp];
            } else {
                // Alpha is handled by the child directly, clobber the layer's alpha
                self.dPrivateFlags |= PFLAG_ALPHA_SET;
            }
        }
    } else if ((self.dPrivateFlags & PFLAG_ALPHA_SET) == PFLAG_ALPHA_SET) {
        [self onSetAlpha:255];
        self.dPrivateFlags &= ~PFLAG_ALPHA_SET;
    }
    
    // apply clips directly, since RenderNode won't do it for this draw
    if ((parentFlags & GROUP_FLAG_CLIP_CHILDREN) != 0) {
        [canvas clipRectLeft:sx top:sy right:sx + self.dWidth bottom:sy + self.dHeight clipOp:TIOSKHSkikoClipMode.difference];
    }
    if (self.clipBounds != nil) {
        [canvas clipRectLeft:self.clipBounds.left top:self.clipBounds.top right:self.clipBounds.right bottom:self.clipBounds.bottom clipOp:TIOSKHSkikoClipMode.difference];
        // clip bounds ignore scroll
    }
    
    
    // Fast path for layouts with no backgrounds
    if ((self.dPrivateFlags & PFLAG_SKIP_DRAW) == PFLAG_SKIP_DRAW) {
        self.dPrivateFlags &= ~PFLAG_DIRTY_MASK;
        [self dispatchDrawCanvas:canvas];
    } else {
        [self draw:canvas];
    }

    [canvas restore];
    
    /*if (a != null && !more) {
        if (!hardwareAcceleratedCanvas && !a.getFillAfter()) {
            onSetAlpha(255);
        }
        parent.finishAnimatingView(this, a);
    }
    if (more && hardwareAcceleratedCanvas) {
        if (a.hasAlpha() && (mPrivateFlags & PFLAG_ALPHA_SET) == PFLAG_ALPHA_SET) {
            // alpha animations should cause the child to recreate its display list
            invalidate(true);
        }
    }
    mRecreateDisplayList = false;*/
    return more;
}

- (void)draw:(nonnull id<TIOSKHTCanvas>)canvas {
    UIGraphicsBeginImageContextWithOptions(self._view.bounds.size, self._view.opaque, 0.0f);
    [self._view drawViewHierarchyInRect:self._view.bounds afterScreenUpdates:NO];
    UIImage *snapshotImageFromMyView = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    TIOSKHSkikoImage *skImage = [TIOSKHSkiaCanvasKt toSkiaImage:snapshotImageFromMyView];
    TIOSKHSkikoBitmap *skBitmap = [skImage toBitmap];
    TIOSKHSkikoPoint *point = [[TIOSKHSkikoPoint alloc] initWithX:0 y:0];
    [canvas drawImageImage:skBitmap topLeftOffset:point paint:[self.lc createPaint]];
}

- (void)onMeasureWidthMeasureSpec:(int32_t)widthMeasureSpec heightMeasureSpec:(int32_t)heightMeasureSpec {
    [self onMeasure:widthMeasureSpec :heightMeasureSpec];
}

- (BOOL)onTouchEventEvent:(nonnull TIOSKHMotionEvent *)event {
    return false;
}

- (void)onViewAddedView:(nonnull id<TIOSKHTView>)view {
    //NOT needed by lgview
}

- (void)onViewRemovedView:(nonnull id<TIOSKHTView>)view {
    //NOT needed by lgview
}

- (void)postRunnable:(nonnull id<TIOSKHTRunnable>)runnable {
    [LuaThread runOnUIThreadInternal:^{
        [runnable run];
    }];
}

- (void)requestLayout {
    self.layoutRequested = true;
    //[self resizeAndInvalidate];
    [self._view setNeedsDisplay];
}

- (int32_t)resolveSizeAndStateSize:(int32_t)size measureSpec:(int32_t)measureSpec childState:(int32_t)childState {
    return [LGView resolveSizeAndState:size :measureSpec :childState];
}

- (void)setAlphaValue:(float)value {
    //TODO:Add onsetalpha
    self.dAlpha = value;
    self.dPrivateFlags |= PFLAG_ALPHA_SET;
    if([self onSetAlpha:self.dAlpha * 255.0f]) {
        [self._view layoutIfNeeded];
    } else {
        self._view.alpha = value;
    }
}

- (void)setClipToOutlineClip:(BOOL)clip {
    
}

//Can we move this to CATransform3D
- (void)setElevationValue:(float)value {
    self.android_elevation = FTOS(value);
}

- (void)setIdId:(nonnull NSString *)id {
    [self SetId:id];
}

- (void)setImageDrawableDrawable:(id<TIOSKHTDrawable> _Nullable)drawable {
    //NOT needed by lgview
}

- (void)setImageResourceResourceId:(nonnull NSString *)resourceId {
    //NOT needed by lgview
}

- (void)setLayoutParamsParams:(nonnull TIOSKHViewGroupLayoutParams *)params {
    self.kLayoutParams = params;
}

- (void)setMeasuredDimensionWidth:(int32_t)width height:(int32_t)height {
    [self setMeasuredDimension:width :height];
}

- (void)setObjCPropertyMethodName:(nonnull NSString *)methodName value:(nonnull id)value {
    [self setValue:value forKey:methodName];
}

- (void)onClickInternal {
    [self.internalClickListener onClickView:self];
}

- (void)setOnClickListenerListener:(id<TIOSKHTViewOnClickListener> _Nullable)listener {
    if(self.tapGesture != nil)
        [self._view removeGestureRecognizer:self.tapGesture];
    self.tapGesture = nil;
    if(listener == nil) {
        self.internalClickListener = nil;
        return;
    }
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickInternal)];
    [self._view addGestureRecognizer:self.tapGesture];
}

- (void)setOutlineProviderViewOutlineProvider:(TIOSKHViewOutlineProvider * _Nullable)viewOutlineProvider {
    
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
    self._view.layer.anchorPoint = CGPointMake(value, self._view.layer.anchorPoint.y);
}

- (void)setPivotYValue:(float)value {
    self._view.layer.anchorPoint = CGPointMake(self._view.layer.anchorPoint.x, value);
}

- (void)setReflectionColorDrawableMethodName:(nonnull NSString *)methodName r:(int32_t)r g:(int32_t)g b:(int32_t)b a:(int32_t)a {
    
}

-(void)setReflectionColorMethodName:(NSString *)methodName r:(int32_t)r g:(int32_t)g b:(int32_t)b a:(int32_t)a {
    
}

- (void)setReflectionValueMethodName:(nonnull NSString *)methodName value:(nonnull id)value {
    [self setValue:value forKey:methodName];
}

- (void)setRotationValue:(float)value {
    self._view.layer.affineTransform = CGAffineTransformMakeRotation(value * M_PI/180);
}

- (void)setRotationXValue:(float)value {
    self._view.layer.transform = CATransform3DMakeRotation(value * M_PI/180, 1.0, 0.0, 0.0);
}

- (void)setRotationYValue:(float)value {
    self._view.layer.transform = CATransform3DMakeRotation(value * M_PI/180, 0.0, 1.0, 0.0);
}

- (void)setScaleXValue:(float)value {
    self._view.layer.transform = CATransform3DScale(self._view.layer.transform, value, [self getScaleY], 1);
}

- (void)setScaleYValue:(float)value {
    self._view.layer.transform = CATransform3DScale(self._view.layer.transform, [self getScaleX], value, 1);
}

- (void)setTranslationXValue:(float)value {
    self._view.layer.transform = CATransform3DTranslate(self._view.layer.transform, value, [self getTranslationY], [self getTranslationZ]);
}

- (void)setTranslationYValue:(float)value {
    self._view.layer.transform = CATransform3DTranslate(self._view.layer.transform, [self getTranslationX], value, [self getTranslationZ]);
}

- (void)setTranslationZValue:(float)value {
    self._view.layer.transform = CATransform3DTranslate(self._view.layer.transform, [self getTranslationX], [self getTranslationY], value);
}

- (void)setTagKey:(nonnull id)key value:(id _Nullable)value {
    [self setTag:key :value];
}

- (void)setTagValue:(id _Nullable)value {
    [self setTag:@"" :value];
}

- (void)setVisibilityValue:(int32_t)value {
    [self setVisibility:value];
}

-(void)swizzleFunctionFuncName:(NSString *)funcName block:(id  _Nullable (^)(id<TIOSKHTView> _Nonnull, TIOSKHKotlinArray<id> * _Nonnull))block {
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
