#import "Configuration.h"
#import "LGView.h"

@implementation Configuration

+(Configuration *)configurationFromTraitCollection:(UITraitCollection *)traitCollection {
    return [Configuration new];
}

+(int)reduceScreenLayout:(int)curLayout :(int)longSizeDp :(int)shortSizeDp {
    int screenLayoutSize;
    BOOL screenLayoutLong;
    BOOL screenLayoutCompatNeeded;
    // These semi-magic numbers define our compatibility modes for
    // applications with different screens.  These are guarantees to
    // app developers about the space they can expect for a particular
    // configuration.  DO NOT CHANGE!
    if (longSizeDp < 470) {
        // This is shorter than an HVGA normal density screen (which
        // is 480 pixels on its long side).
        screenLayoutSize = CONFIGURATION_SCREENLAYOUT_SIZE_SMALL;
        screenLayoutLong = false;
        screenLayoutCompatNeeded = false;
    } else {
        // What size is this screen screen?
        if (longSizeDp >= 960 && shortSizeDp >= 720) {
            // 1.5xVGA or larger screens at medium density are the point
            // at which we consider it to be an extra large screen.
            screenLayoutSize = CONFIGURATION_SCREENLAYOUT_SIZE_XLARGE;
        } else if (longSizeDp >= 640 && shortSizeDp >= 480) {
            // VGA or larger screens at medium density are the point
            // at which we consider it to be a large screen.
            screenLayoutSize = CONFIGURATION_SCREENLAYOUT_SIZE_LARGE;
        } else {
            screenLayoutSize = CONFIGURATION_SCREENLAYOUT_SIZE_NORMAL;
        }
        // If this screen is wider than normal HVGA, or taller
        // than FWVGA, then for old apps we want to run in size
        // compatibility mode.
        if (shortSizeDp > 321 || longSizeDp > 570) {
            screenLayoutCompatNeeded = true;
        } else {
            screenLayoutCompatNeeded = false;
        }
        // Is this a long screen?
        if (((longSizeDp*3)/5) >= (shortSizeDp-1)) {
            // Anything wider than WVGA (5:3) is considering to be long.
            screenLayoutLong = true;
        } else {
            screenLayoutLong = false;
        }
    }
    // Now reduce the last screenLayout to not be better than what we
    // have found.
    if (!screenLayoutLong) {
        curLayout = (curLayout&~CONFIGURATION_SCREENLAYOUT_LONG_MASK) | CONFIGURATION_SCREENLAYOUT_LONG_NO;
    }
    if (screenLayoutCompatNeeded) {
        curLayout |= CONFIGURATION_SCREENLAYOUT_COMPAT_NEEDED;
    }
    int curSize = curLayout&CONFIGURATION_SCREENLAYOUT_SIZE_MASK;
    if (screenLayoutSize < curSize) {
        curLayout = (curLayout&~CONFIGURATION_SCREENLAYOUT_SIZE_MASK) | screenLayoutSize;
    }
    return curLayout;
}

-(BOOL)isLayoutSizeAtLeast:(int)size {
    int cur = self.screenLayout&CONFIGURATION_SCREENLAYOUT_SIZE_MASK;
    if (cur == CONFIGURATION_SCREENLAYOUT_SIZE_UNDEFINED) return false;
    return cur >= size;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        [self unset];
    }
    return self;
}

-(instancetype)initWithConfiguration:(Configuration*)o
{
    self = [super init];
    if (self) {
        [self setTo:o];
    }
    return self;
}

-(void)fixUpLocaleList {
    if ((self.locale == nil && self.mLocaleList.count != 0) ||
            (self.locale != nil && ![self.locale isEqual:[self.mLocaleList objectAtIndex:0]])) {
        self.mLocaleList = self.locale == nil ? [NSLocale preferredLanguages] : [NSArray array];
    }
}

-(void)setTo:(Configuration*) o {
    self.fontScale = o.fontScale;
    if (o.locale == nil) {
        self.locale = nil;
    } else if (![o.locale isEqual:self.locale]) {
        // Only clone a new Locale instance if we need to:  the clone() is
        // both CPU and GC intensive.
        self.locale = o.locale.copy;
    }
    [o fixUpLocaleList];
    self.mLocaleList = o.mLocaleList;
    self.userSetLocale = o.userSetLocale;
    self.touchscreen = o.touchscreen;
    self.keyboard = o.keyboard;
    self.keyboardHidden = o.keyboardHidden;
    self.hardKeyboardHidden = o.hardKeyboardHidden;
    self.navigation = o.navigation;
    self.navigationHidden = o.navigationHidden;
    self.orientation = o.orientation;
    self.screenLayout = o.screenLayout;
    //colorMode = o.colorMode;
    self.uiMode = o.uiMode;
    self.screenWidthDp = o.screenWidthDp;
    self.screenHeightDp = o.screenHeightDp;
    self.smallestScreenWidthDp = o.smallestScreenWidthDp;
    self.densityDpi = o.densityDpi;
    self.fontWeightAdjustment = o.fontWeightAdjustment;
}

-(void)setToDefaults {
    self.fontScale = 1;
    self.mLocaleList = [NSLocale preferredLanguages];
    self.locale = nil;
    self.userSetLocale = false;
    self.touchscreen = CONFIGURATION_TOUCHSCREEN_UNDEFINED;
    self.keyboard = CONFIGURATION_KEYBOARD_UNDEFINED;
    self.keyboardHidden = CONFIGURATION_KEYBOARDHIDDEN_UNDEFINED;
    self.hardKeyboardHidden = CONFIGURATION_HARDKEYBOARDHIDDEN_UNDEFINED;
    self.navigation = CONFIGURATION_NAVIGATION_UNDEFINED;
    self.navigationHidden = CONFIGURATION_NAVIGATIONHIDDEN_UNDEFINED;
    self.orientation = CONFIGURATION_ORIENTATION_UNDEFINED;
    self.screenLayout = CONFIGURATION_SCREENLAYOUT_UNDEFINED;
    self.uiMode = CONFIGURATION_UI_MODE_TYPE_UNDEFINED;
    self.screenWidthDp = CONFIGURATION_SCREEN_WIDTH_DP_UNDEFINED;
    self.screenHeightDp = CONFIGURATION_SCREEN_HEIGHT_DP_UNDEFINED;
    self.smallestScreenWidthDp = CONFIGURATION_SMALLEST_SCREEN_WIDTH_DP_UNDEFINED;
    self.densityDpi = CONFIGURATION_DENSITY_DPI_UNDEFINED;
    self.fontWeightAdjustment = CONFIGURATION_FONT_WEIGHT_ADJUSTMENT_UNDEFINED;
}

-(void)unset {
    [self setToDefaults];
    self.fontScale = 0;
}

-(int)updateFrom:(Configuration *)delta {
    int changed = 0;
    if (delta.fontScale > 0 && self.fontScale != delta.fontScale) {
        changed |= ACTIVITY_INFO_CONFIG_FONT_SCALE;
        self.fontScale = delta.fontScale;
    }
    [self fixUpLocaleList];
    [delta fixUpLocaleList];
    if (delta.mLocaleList.count != 0 && ![self.mLocaleList isEqualToArray:delta.mLocaleList]) {
        changed |= ACTIVITY_INFO_CONFIG_LOCALE;
        self.mLocaleList = delta.mLocaleList;
        // delta.locale can't be null, since delta.mLocaleList is not empty.
        if (![delta.locale isEqual:self.locale]) {
            self.locale = delta.locale.copy;
            // If locale has changed, then layout direction is also changed ...
            changed |= ACTIVITY_INFO_CONFIG_LAYOUT_DIRECTION;
            // ... and we need to update the layout direction (represented by the first
            // 2 most significant bits in screenLayout).
            [self setLayoutDirection:self.locale];
        }
    }
    __block int deltaScreenLayoutDir = delta.screenLayout & CONFIGURATION_SCREENLAYOUT_LAYOUTDIR_MASK;
    if (deltaScreenLayoutDir != CONFIGURATION_SCREENLAYOUT_LAYOUTDIR_UNDEFINED &&
            deltaScreenLayoutDir != (self.screenLayout & CONFIGURATION_SCREENLAYOUT_LAYOUTDIR_MASK)) {
        self.screenLayout = (self.screenLayout & ~CONFIGURATION_SCREENLAYOUT_LAYOUTDIR_MASK) | deltaScreenLayoutDir;
        changed |= ACTIVITY_INFO_CONFIG_LAYOUT_DIRECTION;
    }
    if (delta.userSetLocale && (!self.userSetLocale || ((changed & ACTIVITY_INFO_CONFIG_LOCALE) != 0)))
    {
        changed |= ACTIVITY_INFO_CONFIG_LOCALE;
        self.userSetLocale = true;
    }
    if (delta.touchscreen != CONFIGURATION_TOUCHSCREEN_UNDEFINED
            && self.touchscreen != delta.touchscreen) {
        changed |= ACTIVITY_INFO_CONFIG_TOUCHSCREEN;
        self.touchscreen = delta.touchscreen;
    }
    if (delta.keyboard != CONFIGURATION_KEYBOARD_UNDEFINED
            && self.keyboard != delta.keyboard) {
        changed |= ACTIVITY_INFO_CONFIG_KEYBOARD;
        self.keyboard = delta.keyboard;
    }
    if (delta.keyboardHidden != CONFIGURATION_KEYBOARDHIDDEN_UNDEFINED
            && self.keyboardHidden != delta.keyboardHidden) {
        changed |= ACTIVITY_INFO_CONFIG_KEYBOARD_HIDDEN;
        self.keyboardHidden = delta.keyboardHidden;
    }
    if (delta.hardKeyboardHidden != CONFIGURATION_HARDKEYBOARDHIDDEN_UNDEFINED
            && self.hardKeyboardHidden != delta.hardKeyboardHidden) {
        changed |= ACTIVITY_INFO_CONFIG_KEYBOARD_HIDDEN;
        self.hardKeyboardHidden = delta.hardKeyboardHidden;
    }
    if (delta.navigation != CONFIGURATION_NAVIGATION_UNDEFINED
            && self.navigation != delta.navigation) {
        changed |= ACTIVITY_INFO_CONFIG_NAVIGATION;
        self.navigation = delta.navigation;
    }
    if (delta.navigationHidden != CONFIGURATION_NAVIGATIONHIDDEN_UNDEFINED
            && self.navigationHidden != delta.navigationHidden) {
        changed |= ACTIVITY_INFO_CONFIG_KEYBOARD_HIDDEN;
        self.navigationHidden = delta.navigationHidden;
    }
    if (delta.orientation != CONFIGURATION_ORIENTATION_UNDEFINED
            && self.orientation != delta.orientation) {
        changed |= ACTIVITY_INFO_CONFIG_ORIENTATION;
        self.orientation = delta.orientation;
    }
    if (((delta.screenLayout & CONFIGURATION_SCREENLAYOUT_SIZE_MASK) != CONFIGURATION_SCREENLAYOUT_SIZE_UNDEFINED)
            && (delta.screenLayout & CONFIGURATION_SCREENLAYOUT_SIZE_MASK)
            != (self.screenLayout & CONFIGURATION_SCREENLAYOUT_SIZE_MASK)) {
        changed |= ACTIVITY_INFO_CONFIG_SCREEN_LAYOUT;
        self.screenLayout = (self.screenLayout & ~CONFIGURATION_SCREENLAYOUT_SIZE_MASK)
                | (delta.screenLayout & CONFIGURATION_SCREENLAYOUT_SIZE_MASK);
    }
    if (((delta.screenLayout & CONFIGURATION_SCREENLAYOUT_LONG_MASK) != CONFIGURATION_SCREENLAYOUT_LONG_UNDEFINED)
            && (delta.screenLayout & CONFIGURATION_SCREENLAYOUT_LONG_MASK)
            != (self.screenLayout & CONFIGURATION_SCREENLAYOUT_LONG_MASK)) {
        changed |= ACTIVITY_INFO_CONFIG_SCREEN_LAYOUT;
        self.screenLayout = (self.screenLayout & ~CONFIGURATION_SCREENLAYOUT_LONG_MASK)
                | (delta.screenLayout & CONFIGURATION_SCREENLAYOUT_LONG_MASK);
    }
    if (((delta.screenLayout & CONFIGURATION_SCREENLAYOUT_ROUND_MASK) != CONFIGURATION_SCREENLAYOUT_ROUND_UNDEFINED)
            && (delta.screenLayout & CONFIGURATION_SCREENLAYOUT_ROUND_MASK)
            != (self.screenLayout & CONFIGURATION_SCREENLAYOUT_ROUND_MASK)) {
        changed |= ACTIVITY_INFO_CONFIG_SCREEN_LAYOUT;
        self.screenLayout = (self.screenLayout & ~CONFIGURATION_SCREENLAYOUT_ROUND_MASK)
                | (delta.screenLayout & CONFIGURATION_SCREENLAYOUT_ROUND_MASK);
    }
    if ((delta.screenLayout & CONFIGURATION_SCREENLAYOUT_COMPAT_NEEDED)
            != (self.screenLayout & CONFIGURATION_SCREENLAYOUT_COMPAT_NEEDED)
            && delta.screenLayout != 0) {
        changed |= ACTIVITY_INFO_CONFIG_SCREEN_LAYOUT;
        self.screenLayout = (self.screenLayout & ~CONFIGURATION_SCREENLAYOUT_COMPAT_NEEDED)
            | (delta.screenLayout & CONFIGURATION_SCREENLAYOUT_COMPAT_NEEDED);
    }
    if (delta.uiMode != (CONFIGURATION_UI_MODE_TYPE_UNDEFINED|CONFIGURATION_UI_MODE_NIGHT_UNDEFINED)
            && self.uiMode != delta.uiMode) {
        changed |= ACTIVITY_INFO_CONFIG_UI_MODE;
        if ((delta.uiMode&CONFIGURATION_UI_MODE_TYPE_MASK) != CONFIGURATION_UI_MODE_TYPE_UNDEFINED) {
            self.uiMode = (self.uiMode&~CONFIGURATION_UI_MODE_TYPE_MASK)
                    | (delta.uiMode&CONFIGURATION_UI_MODE_TYPE_MASK);
        }
        if ((delta.uiMode&CONFIGURATION_UI_MODE_NIGHT_MASK) != CONFIGURATION_UI_MODE_NIGHT_UNDEFINED) {
            self.uiMode = (self.uiMode&~CONFIGURATION_UI_MODE_NIGHT_MASK)
                    | (delta.uiMode&CONFIGURATION_UI_MODE_NIGHT_MASK);
        }
    }
    if (delta.screenWidthDp != CONFIGURATION_SCREEN_WIDTH_DP_UNDEFINED
            && self.screenWidthDp != delta.screenWidthDp) {
        changed |= ACTIVITY_INFO_CONFIG_SCREEN_SIZE;
        self.screenWidthDp = delta.screenWidthDp;
    }
    if (delta.screenHeightDp != CONFIGURATION_SCREEN_HEIGHT_DP_UNDEFINED
            && self.screenHeightDp != delta.screenHeightDp) {
        changed |= ACTIVITY_INFO_CONFIG_SCREEN_SIZE;
        self.screenHeightDp = delta.screenHeightDp;
    }
    if (delta.smallestScreenWidthDp != CONFIGURATION_SMALLEST_SCREEN_WIDTH_DP_UNDEFINED
            && self.smallestScreenWidthDp != delta.smallestScreenWidthDp) {
        changed |= ACTIVITY_INFO_CONFIG_SMALLEST_SCREEN_SIZE;
        self.smallestScreenWidthDp = delta.smallestScreenWidthDp;
    }
    if (delta.densityDpi != CONFIGURATION_DENSITY_DPI_UNDEFINED &&
        self.densityDpi != delta.densityDpi) {
        changed |= ACTIVITY_INFO_CONFIG_DENSITY;
        self.densityDpi = delta.densityDpi;
    }
    if (delta.fontWeightAdjustment != CONFIGURATION_FONT_WEIGHT_ADJUSTMENT_UNDEFINED
            && delta.fontWeightAdjustment != self.fontWeightAdjustment) {
        changed |= ACTIVITY_INFO_CONFIG_FONT_WEIGHT_ADJUSTMENT;
        self.fontWeightAdjustment = delta.fontWeightAdjustment;
    }
    return changed;
}

-(void)setTo:(Configuration*)delta :(int) mask :(int)windowMask {
    if ((mask & ACTIVITY_INFO_CONFIG_FONT_SCALE) != 0) {
        self.fontScale = delta.fontScale;
    }
    if ((mask & ACTIVITY_INFO_CONFIG_LOCALE) != 0) {
        self.mLocaleList = delta.mLocaleList;
        if (self.mLocaleList.count != 0) {
            if (![delta.locale isEqual:self.locale]) {
                // Don't churn a new Locale clone unless we're actually changing it
                self.locale = delta.locale.copy;
            }
        }
    }
    if ((mask & ACTIVITY_INFO_CONFIG_LAYOUT_DIRECTION) != 0) {
        int deltaScreenLayoutDir = delta.screenLayout & CONFIGURATION_SCREENLAYOUT_LAYOUTDIR_MASK;
        self.screenLayout = (self.screenLayout & ~CONFIGURATION_SCREENLAYOUT_LAYOUTDIR_MASK) | deltaScreenLayoutDir;
    }
    if ((mask & ACTIVITY_INFO_CONFIG_LOCALE) != 0) {
        self.userSetLocale = delta.userSetLocale;
    }
    if ((mask & ACTIVITY_INFO_CONFIG_TOUCHSCREEN) != 0) {
        self.touchscreen = delta.touchscreen;
    }
    if ((mask & ACTIVITY_INFO_CONFIG_KEYBOARD) != 0) {
        self.keyboard = delta.keyboard;
    }
    if ((mask & ACTIVITY_INFO_CONFIG_KEYBOARD_HIDDEN) != 0) {
        self.keyboardHidden = delta.keyboardHidden;
        self.hardKeyboardHidden = delta.hardKeyboardHidden;
        self.navigationHidden = delta.navigationHidden;
    }
    if ((mask & ACTIVITY_INFO_CONFIG_NAVIGATION) != 0) {
        self.navigation = delta.navigation;
    }
    if ((mask & ACTIVITY_INFO_CONFIG_ORIENTATION) != 0) {
        self.orientation = delta.orientation;
    }
    if ((mask & ACTIVITY_INFO_CONFIG_SCREEN_LAYOUT) != 0) {
        // Not enough granularity for each component unfortunately.
        self.screenLayout = self.screenLayout | (delta.screenLayout & ~CONFIGURATION_SCREENLAYOUT_LAYOUTDIR_MASK);
    }
    if ((mask & ACTIVITY_INFO_CONFIG_UI_MODE) != 0) {
        self.uiMode = delta.uiMode;
    }
    if ((mask & ACTIVITY_INFO_CONFIG_SCREEN_SIZE) != 0) {
        self.screenWidthDp = delta.screenWidthDp;
        self.screenHeightDp = delta.screenHeightDp;
    }
    if ((mask & ACTIVITY_INFO_CONFIG_SMALLEST_SCREEN_SIZE) != 0) {
        self.smallestScreenWidthDp = delta.smallestScreenWidthDp;
    }
    if ((mask & ACTIVITY_INFO_CONFIG_DENSITY) != 0) {
        self.densityDpi = delta.densityDpi;
    }
    if ((mask & ACTIVITY_INFO_CONFIG_FONT_WEIGHT_ADJUSTMENT) != 0) {
        self.fontWeightAdjustment = delta.fontWeightAdjustment;
    }
}

-(int)diff:(Configuration*) delta {
    return [self diff:delta :false /* compareUndefined */ :false /* publicOnly */];
}

-(int)diffPublicOnly:(Configuration*) delta {
    return [self diff:delta :false /* compareUndefined */ :true /* publicOnly */];
}

-(int)diff:(Configuration*)delta :(BOOL)compareUndefined :(BOOL)publicOnly {
    int changed = 0;
    if ((compareUndefined || delta.fontScale > 0) && self.fontScale != delta.fontScale) {
        changed |= ACTIVITY_INFO_CONFIG_FONT_SCALE;
    }
    [self fixUpLocaleList];
    [delta fixUpLocaleList];
    if ((compareUndefined || delta.mLocaleList.count != 0)
            && ![self.mLocaleList isEqualToArray:delta.mLocaleList]) {
        changed |= ACTIVITY_INFO_CONFIG_LOCALE;
        changed |= ACTIVITY_INFO_CONFIG_LAYOUT_DIRECTION;
    }
    int deltaScreenLayoutDir = delta.screenLayout & CONFIGURATION_SCREENLAYOUT_LAYOUTDIR_MASK;
    if ((compareUndefined || deltaScreenLayoutDir != CONFIGURATION_SCREENLAYOUT_LAYOUTDIR_UNDEFINED)
            && deltaScreenLayoutDir != (self.screenLayout & CONFIGURATION_SCREENLAYOUT_LAYOUTDIR_MASK)) {
        changed |= ACTIVITY_INFO_CONFIG_LAYOUT_DIRECTION;
    }
    if ((compareUndefined || delta.touchscreen != CONFIGURATION_TOUCHSCREEN_UNDEFINED)
            && self.touchscreen != delta.touchscreen) {
        changed |= ACTIVITY_INFO_CONFIG_TOUCHSCREEN;
    }
    if ((compareUndefined || delta.keyboard != CONFIGURATION_KEYBOARD_UNDEFINED)
            && self.keyboard != delta.keyboard) {
        changed |= ACTIVITY_INFO_CONFIG_KEYBOARD;
    }
    if ((compareUndefined || delta.keyboardHidden != CONFIGURATION_KEYBOARDHIDDEN_UNDEFINED)
            && self.keyboardHidden != delta.keyboardHidden) {
        changed |= ACTIVITY_INFO_CONFIG_KEYBOARD_HIDDEN;
    }
    if ((compareUndefined || delta.hardKeyboardHidden != CONFIGURATION_HARDKEYBOARDHIDDEN_UNDEFINED)
            && self.hardKeyboardHidden != delta.hardKeyboardHidden) {
        changed |= ACTIVITY_INFO_CONFIG_KEYBOARD_HIDDEN;
    }
    if ((compareUndefined || delta.navigation != CONFIGURATION_NAVIGATION_UNDEFINED)
            && self.navigation != delta.navigation) {
        changed |= ACTIVITY_INFO_CONFIG_NAVIGATION;
    }
    if ((compareUndefined || delta.navigationHidden != CONFIGURATION_NAVIGATIONHIDDEN_UNDEFINED)
            && self.navigationHidden != delta.navigationHidden) {
        changed |= ACTIVITY_INFO_CONFIG_KEYBOARD_HIDDEN;
    }
    if ((compareUndefined || delta.orientation != CONFIGURATION_ORIENTATION_UNDEFINED)
            && self.orientation != delta.orientation) {
        changed |= ACTIVITY_INFO_CONFIG_ORIENTATION;
    }
    if ((compareUndefined || [Configuration getScreenLayoutNoDirection:delta.screenLayout] !=
            (CONFIGURATION_SCREENLAYOUT_SIZE_UNDEFINED | CONFIGURATION_SCREENLAYOUT_LONG_UNDEFINED))
        && [Configuration getScreenLayoutNoDirection:self.screenLayout] !=
        [Configuration getScreenLayoutNoDirection:delta.screenLayout]) {
        changed |= ACTIVITY_INFO_CONFIG_SCREEN_LAYOUT;
    }
    if ((compareUndefined || delta.uiMode != (CONFIGURATION_UI_MODE_TYPE_UNDEFINED|CONFIGURATION_UI_MODE_NIGHT_UNDEFINED))
            && self.uiMode != delta.uiMode) {
        changed |= ACTIVITY_INFO_CONFIG_UI_MODE;
    }
    if ((compareUndefined || delta.screenWidthDp != CONFIGURATION_SCREEN_WIDTH_DP_UNDEFINED)
            && self.screenWidthDp != delta.screenWidthDp) {
        changed |= ACTIVITY_INFO_CONFIG_SCREEN_SIZE;
    }
    if ((compareUndefined || delta.screenHeightDp != CONFIGURATION_SCREEN_HEIGHT_DP_UNDEFINED)
            && self.screenHeightDp != delta.screenHeightDp) {
        changed |= ACTIVITY_INFO_CONFIG_SCREEN_SIZE;
    }
    if ((compareUndefined || delta.smallestScreenWidthDp != CONFIGURATION_SMALLEST_SCREEN_WIDTH_DP_UNDEFINED)
            && self.smallestScreenWidthDp != delta.smallestScreenWidthDp) {
        changed |= ACTIVITY_INFO_CONFIG_SMALLEST_SCREEN_SIZE;
    }
    if ((compareUndefined || delta.densityDpi != CONFIGURATION_DENSITY_DPI_UNDEFINED)
            && self.densityDpi != delta.densityDpi) {
        changed |= ACTIVITY_INFO_CONFIG_DENSITY;
    }
    if ((compareUndefined || delta.fontWeightAdjustment != CONFIGURATION_FONT_WEIGHT_ADJUSTMENT_UNDEFINED)
            && self.fontWeightAdjustment != delta.fontWeightAdjustment) {
        changed |= ACTIVITY_INFO_CONFIG_FONT_WEIGHT_ADJUSTMENT;
    }
    return changed;
}

+(BOOL)needNewResources:(int)configChanges :(int)interestingChanges {
    // CONFIG_ASSETS_PATHS and CONFIG_FONT_SCALE are higher level configuration changes that
    // all resources are subject to change with.
    interestingChanges = interestingChanges | ACTIVITY_INFO_CONFIG_ASSETS_PATHS
            | ACTIVITY_INFO_CONFIG_FONT_SCALE;
    return (configChanges & interestingChanges) != 0;
}

-(BOOL)isNightModeActive {
    return (self.uiMode & CONFIGURATION_UI_MODE_NIGHT_MASK) == CONFIGURATION_UI_MODE_NIGHT_YES;
}

-(NSArray*)getLocales {
    [self fixUpLocaleList];
    return self.mLocaleList;
}

-(void)setLocales:(NSArray *)locales {
    self.mLocaleList = locales == nil ? [NSLocale preferredLanguages] : locales;
    self.locale = [self.mLocaleList objectAtIndex:0];
    [self setLayoutDirection:self.locale];
}

-(void)setLocale:(NSLocale*)loc {
    [self setLocales:loc == nil ? [NSLocale preferredLanguages] : [NSArray arrayWithObject:loc]];
}

-(void)clearLocales {
    self.mLocaleList = [NSLocale preferredLanguages];
    self.locale = nil;
}

-(int)getLayoutDirection {
    return (self.screenLayout&CONFIGURATION_SCREENLAYOUT_LAYOUTDIR_MASK) == CONFIGURATION_SCREENLAYOUT_LAYOUTDIR_RTL
            ? LAYOUT_DIRECTION_RTL : LAYOUT_DIRECTION_LTR;
}

-(void)setLayoutDirection:(NSLocale*)loc {
    // There is a "1" difference between the configuration values for
    // layout direction and View constants for layout direction, just add "1".
    int layoutDirection = 1 + ([LGView isRtl] ? LAYOUT_DIRECTION_RTL : LAYOUT_DIRECTION_LTR);
    self.screenLayout = (self.screenLayout&~CONFIGURATION_SCREENLAYOUT_LAYOUTDIR_MASK)|
            (layoutDirection << CONFIGURATION_SCREENLAYOUT_LAYOUTDIR_SHIFT);
}

+(int)getScreenLayoutNoDirection:(int)screenLayout {
    return screenLayout&~CONFIGURATION_SCREENLAYOUT_LAYOUTDIR_MASK;
}

-(BOOL)isScreenRound {
    return (self.screenLayout & CONFIGURATION_SCREENLAYOUT_ROUND_MASK) == CONFIGURATION_SCREENLAYOUT_ROUND_YES;
}

+(Configuration*) generateDelta:(Configuration*)base :(Configuration*)change {
    Configuration *delta = [Configuration new];
    if (base.fontScale != change.fontScale) {
        delta.fontScale = change.fontScale;
    }
    [base fixUpLocaleList];
    [change fixUpLocaleList];
    if (![base.mLocaleList isEqualToArray:change.mLocaleList])  {
        delta.mLocaleList = change.mLocaleList;
        delta.locale = change.locale;
    }
    if (base.touchscreen != change.touchscreen) {
        delta.touchscreen = change.touchscreen;
    }
    if (base.keyboard != change.keyboard) {
        delta.keyboard = change.keyboard;
    }
    if (base.keyboardHidden != change.keyboardHidden) {
        delta.keyboardHidden = change.keyboardHidden;
    }
    if (base.navigation != change.navigation) {
        delta.navigation = change.navigation;
    }
    if (base.navigationHidden != change.navigationHidden) {
        delta.navigationHidden = change.navigationHidden;
    }
    if (base.orientation != change.orientation) {
        delta.orientation = change.orientation;
    }
    if ((base.screenLayout & CONFIGURATION_SCREENLAYOUT_SIZE_MASK) !=
            (change.screenLayout & CONFIGURATION_SCREENLAYOUT_SIZE_MASK)) {
        delta.screenLayout |= change.screenLayout & CONFIGURATION_SCREENLAYOUT_SIZE_MASK;
    }
    if ((base.screenLayout & CONFIGURATION_SCREENLAYOUT_LAYOUTDIR_MASK) !=
            (change.screenLayout & CONFIGURATION_SCREENLAYOUT_LAYOUTDIR_MASK)) {
        delta.screenLayout |= change.screenLayout & CONFIGURATION_SCREENLAYOUT_LAYOUTDIR_MASK;
    }
    if ((base.screenLayout & CONFIGURATION_SCREENLAYOUT_LONG_MASK) !=
            (change.screenLayout & CONFIGURATION_SCREENLAYOUT_LONG_MASK)) {
        delta.screenLayout |= change.screenLayout & CONFIGURATION_SCREENLAYOUT_LONG_MASK;
    }
    if ((base.screenLayout & CONFIGURATION_SCREENLAYOUT_ROUND_MASK) !=
            (change.screenLayout & CONFIGURATION_SCREENLAYOUT_ROUND_MASK)) {
        delta.screenLayout |= change.screenLayout & CONFIGURATION_SCREENLAYOUT_ROUND_MASK;
    }
    if ((base.uiMode & CONFIGURATION_UI_MODE_TYPE_MASK) != (change.uiMode & CONFIGURATION_UI_MODE_TYPE_MASK)) {
        delta.uiMode |= change.uiMode & CONFIGURATION_UI_MODE_TYPE_MASK;
    }
    if ((base.uiMode & CONFIGURATION_UI_MODE_NIGHT_MASK) != (change.uiMode & CONFIGURATION_UI_MODE_NIGHT_MASK)) {
        delta.uiMode |= change.uiMode & CONFIGURATION_UI_MODE_NIGHT_MASK;
    }
    if (base.screenWidthDp != change.screenWidthDp) {
        delta.screenWidthDp = change.screenWidthDp;
    }
    if (base.screenHeightDp != change.screenHeightDp) {
        delta.screenHeightDp = change.screenHeightDp;
    }
    if (base.smallestScreenWidthDp != change.smallestScreenWidthDp) {
        delta.smallestScreenWidthDp = change.smallestScreenWidthDp;
    }
    if (base.densityDpi != change.densityDpi) {
        delta.densityDpi = change.densityDpi;
    }
    if (base.fontWeightAdjustment != change.fontWeightAdjustment) {
        delta.fontWeightAdjustment = change.fontWeightAdjustment;
    }
    return delta;
}

@end
