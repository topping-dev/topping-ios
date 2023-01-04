// Copyright 2017-present the Material Components for iOS authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import <UIKit/UIKit.h>

#import "MDCBottomNavigationBarDelegate.h"
#import "MaterialElevation.h"
#import "MaterialShadow.h"
#import "MaterialShadowElevations.h"

@protocol MDCBottomNavigationBarDelegate;

/** States used to configure bottom navigation on when to show item titles. */
typedef NS_ENUM(NSInteger, MDCBottomNavigationBarTitleVisibility) {

  // Default behavior is to show title when item is selected, hide otherwise.
  MDCBottomNavigationBarTitleVisibilitySelected = 0,

  // Item titles are always visible.
  MDCBottomNavigationBarTitleVisibilityAlways = 1,

  // Item titles are never visible.
  MDCBottomNavigationBarTitleVisibilityNever = 2
};

/**
 States used to configure bottom navigation in landscape mode with respect to how items are spaced
 and item title orientation. Titles will be shown or hidden depending on title hide state.
 */
typedef NS_ENUM(NSInteger, MDCBottomNavigationBarAlignment) {

  // Items are distributed using the entire width of the device, justified. Titles are centered
  // below icons.
  MDCBottomNavigationBarAlignmentJustified = 0,

  // Items are distributed using the entire width of the device, justified. Titles are positioned
  // adjacent to icons.
  MDCBottomNavigationBarAlignmentJustifiedAdjacentTitles = 1,

  // Items are tightly clustered together and centered on the navigation bar. Titles are positioned
  // below icons.
  MDCBottomNavigationBarAlignmentCentered = 2
};

@class MDCBadgeAppearance;

/**
 A bottom navigation bar.

 The bottom navigation bar is docked at the bottom of the screen with tappable items. Only one item
 can be selected at at time. The selected item's title text is displayed. Title text for unselected
 items are hidden.
 */
@interface MDCBottomNavigationBar : UIView <MDCElevatable, MDCElevationOverriding>

/** The bottom navigation bar delegate. */
@property(nonatomic, weak, nullable) id<MDCBottomNavigationBarDelegate> delegate;

/**
 Configures when item titles should be displayed.
 Default is MDCBottomNavigationBarTitleVisibilitySelected.
 */
@property(nonatomic, assign)
    MDCBottomNavigationBarTitleVisibility titleVisibility UI_APPEARANCE_SELECTOR;

/**
 Configures item space distribution and title orientation in landscape mode.
 Default is MDCBottomNavigationBarAlignmentJustified.
 */
@property(nonatomic, assign) MDCBottomNavigationBarAlignment alignment UI_APPEARANCE_SELECTOR;

/**
 An array of UITabBarItems that is used to populate bottom navigation bar content. It is strongly
 recommended the array contain at least three items and no more than five items -- appearance may
 degrade outside of this range.
 */
@property(nonatomic, copy, nonnull) NSArray<UITabBarItem *> *items;

/**
 Selected item in the bottom navigation bar.
 Default is no item selected.
 */
@property(nonatomic, weak, nullable) UITabBarItem *selectedItem;

/**
 Display font used for item titles.
 Default is system font.
 */
@property(nonatomic, strong, nonnull) UIFont *itemTitleFont UI_APPEARANCE_SELECTOR;

/**
 Color of selected item. Applies color to items' icons and text. If set also sets
 selectedItemTitleColor. Default color is black.

 By default, setting this property will also configure the ripple color of all item views.
 If @c rippleColor has been set to a non-nil value, however, then this property will no longer
 affect the color of ripple behavior.

 Use @c rippleColor to configure ripple color instead instead of relying on the side effect behavior
 of this property. The side effect behavior of this property may be removed in the future.
*/
@property(nonatomic, strong, readwrite, nonnull)
    UIColor *selectedItemTintColor UI_APPEARANCE_SELECTOR;

/**
 Color of the selected item's title text. Default color is black.
 */
@property(nonatomic, strong, readwrite, nonnull) UIColor *selectedItemTitleColor;

/**
 Color of unselected items. Applies color to items' icons. Text is not displayed in unselected mode.
 Default color is dark gray.
 */
@property(nonatomic, strong, readwrite, nonnull)
    UIColor *unselectedItemTintColor UI_APPEARANCE_SELECTOR;

/**
 Color of the background of bottom navigation bar and the bar items.
 */
@property(nonatomic, strong, nullable) UIColor *barTintColor UI_APPEARANCE_SELECTOR;

/**
 To color the background of the view use -barTintColor instead.
 */
@property(nullable, nonatomic, copy) UIColor *backgroundColor UI_APPEARANCE_SELECTOR;

/**
 The blur effect style to use behind the Bottom Navigation bar.

 Has no effect unless @backgroundBlurEnabled is @c YES and @c barTintColor has an @c alpha value
 less than 1.
 */
@property(nonatomic, assign) UIBlurEffectStyle backgroundBlurEffectStyle;

/**
 If @c YES, the background of the bar is masked by a UIBlurEffectView. Configure the blur effect
 style using the @c backgroundBlurEffectStyle property.

 Defaults to @c NO.
 */
@property(nonatomic, assign, getter=isBackgroundBlurEnabled) BOOL backgroundBlurEnabled;

/**
 The margin between the item's icon and title when alignment is either Justified or Centered.
 Defaults to 0.
 */
@property(nonatomic, assign) CGFloat itemsContentVerticalMargin;

/**
 The margin between the item's icon and title when alignment is JustifiedAdjacentTitles. Defaults to
 12.
 */
@property(nonatomic, assign) CGFloat itemsContentHorizontalMargin;

/**
 The amount of horizontal padding on the leading/trailing edges of each bar item. Defaults to 0.

 @note: The amount of horizontal space between the bar items will be double this value.
 */
@property(nonatomic, assign) CGFloat itemsHorizontalPadding;

/**
 NSLayoutAnchor for the bottom of the bar items.

 @note It is recommended that this anchor be constrained to the bottom of the safe area layout guide
 of the superview. This will allow the Bottom Navigation bar to extend to the bottom of the screen
 and provide sufficient height for its content above the safe area.
*/
@property(nonatomic, readonly, nonnull)
    NSLayoutYAxisAnchor *barItemsBottomAnchor NS_AVAILABLE_IOS(9_0);

/**
 If @c YES, it will truncate titles that don't fit within the bounds available to the item.

 Default is @c YES.
 */
@property(nonatomic, assign) BOOL truncatesLongTitles;

/**
 The elevation of the bottom navigation bar. Defaults to @c MDCShadowElevationBottomNavigationBar .
 */
@property(nonatomic, assign) MDCShadowElevation elevation;

/** The color of the shadow of the bottom navigation bar. Defaults to black. */
@property(nonatomic, copy, nonnull) UIColor *shadowColor;

/**
 The number of lines used for item titles. It is possible that long titles may cause the text to
 extend beyond the safe area of the Bottom Navigation bar. It is recommended that short titles are
 used before this value is changed.

 Defaults to 1.

 @note This property has no effect if the bar items are laid-out with the image and title
       side-by-side. This may be the case if the bar's @c alignment is
       @c MDCBottomNavigationBarAlignmentJustifiedAdjacentTitles.
 */
@property(nonatomic, assign) NSInteger titlesNumberOfLines;

/**
A block that is invoked when the @c MDCBottomNavigationBar receives a call to @c
traitCollectionDidChange:. The block is called after the call to the superclass.
*/
@property(nonatomic, copy, nullable) void (^traitCollectionDidChangeBlock)
    (MDCBottomNavigationBar *_Nonnull bottomNavigationBar,
     UITraitCollection *_Nullable previousTraitCollection);

/**
 Sets the height of the navigation bar.

 Note: If set to a value smaller or equal to zero (<= 0), the bar will default to a height of 56 in
 the normal case, and to 40 if alignment is set to
 MDCBottomNavigationBarAlignmentJustifiedAdjacentTitles and horizontalSizeClass is set to
 UIUserInterfaceSizeClassRegular.

 If value is bigger than 0 ( > 0), then the intrinsic height will match the provided barHeight.

 Defaults to 0.
 */
@property(nonatomic, assign) CGFloat barHeight;

/**
 Sets the height of the navigation bar when titles are not present.

 Defaults to barHeight's value.
 */
@property(nonatomic, assign) CGFloat barHeightWithoutTitles;

/**
 Returns the navigation bar subview associated with the specific item.

 @param item A UITabBarItem
 */
- (nullable UIView *)viewForItem:(nonnull UITabBarItem *)item;

#pragma mark - Configuring the ripple appearance

@property(nonatomic, getter=isRippleEnabled) BOOL rippleEnabled;

/**
 The color of the ripple effect shown when the user taps on an item.

 When this property is nil, the ripple's color will be inferred from @c selectedItemTintColor. If
 you want a clear ripple, you must set @c rippleColor to UIColor.clearColor.
*/
@property(nonatomic, strong, nullable) UIColor *rippleColor API_DEPRECATED(
    "Follow go/material-ios-touch-response for guidance instead.", ios(12, 12));

#pragma mark - Configuring the default visual appearance for all badges

/**
 The default appearance to be used for all item badges.

 If a given UITabBarItem has set a non-nil badgeColor, then that value will be used for that item
 view's badge instead of the backgroundColor associated with this appearance object.

 Note that the individual itemBadge* properties will be deprecated and already act as proxies for
 modifying the itemBadgeAppearance of each badge directly.
 */
@property(nonatomic, copy, nonnull) MDCBadgeAppearance *itemBadgeAppearance;

/**
 Default background color for badges.

 If a given UITabBarItem's `badgeColor` is non-nil, then the item's `badgeColor` is used instead of
 this value.

 This property is a proxy for itemBadgeAppearance.backgroundColor, with the exception that assigning
 nil will be treated as [UIColor clearColor].

 Default is a red color.
 */
@property(nonatomic, copy, nullable)
    UIColor *itemBadgeBackgroundColor API_DEPRECATED_WITH_REPLACEMENT(
        "itemBadgeAppearance.backgroundColor", ios(12, 12));

/**
 X-offset for Badge position.

 Set this property to adjust horizontal spacing between badges and icons, within item views.

 The additive inverse of this value is applied for RTL layouts. Set this value based on LTR.

 Increasing values shift towards the right, and decreasing values shift towards the left.

 Default is 0.
 */
@property(nonatomic, assign) CGFloat itemBadgeHorizontalOffset;

/**
 Text color for badges.

 This property is a proxy for itemBadgeAppearance.textColor.

 Default is white.
 */
@property(nonatomic, copy, nullable) UIColor *itemBadgeTextColor API_DEPRECATED_WITH_REPLACEMENT(
    "itemBadgeAppearance.textColor", ios(12, 12));

/**
 Text font for badges.

 This property is a proxy for itemBadgeAppearance.font.

 Default is a small system font.
 */
@property(nonatomic, copy, nullable) UIFont *itemBadgeTextFont API_DEPRECATED_WITH_REPLACEMENT(
    "itemBadgeAppearance.font", ios(12, 12));

@end

#if !TARGET_OS_TV
/**
 This component supports UIKit's Large Content Viewer. It is recommended that images associated with
 each tab bar item be backed with a PDF image with "preserve vector data" enabled within the assets
 entry in the catalog. This ensures that the image is scaled appropriately in the content viewer.

 Alternatively specify an image to use for the large content viewer using UITabBarItem's property
 @c largeContentSizeImage . If an image is specified, the given image is used as-is for the large
 content viewer and will not be scaled.

 If the image is not backed by PDF and a @c largeContentSizeImage is not specified, the given
 @c image will be scaled and may be blurry.

 For more details on the Large Content Viewer see:
 https://developer.apple.com/videos/play/wwdc2019/261/
 */
API_UNAVAILABLE(tvos, watchos)
@interface MDCBottomNavigationBar (UILargeContentViewerInteractionDelegate) <
    UILargeContentViewerInteractionDelegate>
@end
#endif  // MDC_AVAILABLE_SDK_IOS(13_0)
