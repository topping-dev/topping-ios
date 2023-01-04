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

#import <CoreGraphics/CoreGraphics.h>

#import "MDCBottomNavigationItemView.h"

#import "MDCBadgeAppearance.h"
#import "MDCBadgeView.h"
#import "MDCBottomNavigationBar.h"
#import "MDCRippleTouchController.h"
#import "MDCRippleView.h"

NS_ASSUME_NONNULL_BEGIN

// A number large enough to be larger than any reasonable screen dimension but small enough that
// CGFloat doesn't lose precision.
static const CGFloat kMaxSizeDimension = 1000000;
static const CGFloat MDCBottomNavigationItemViewRippleOpacity = (CGFloat)0.150;
static const CGFloat MDCBottomNavigationItemViewTitleFontSize = 12;

// Selection indicator animation details.
static const CGFloat kSelectionIndicatorTransformAnimationDuration = 0.17;

/** The default value for @c numberOfLines for the title label. */
static const NSInteger kDefaultTitleNumberOfLines = 1;

// The fonts available on iOS differ from that used on Material.io.  When trying to approximate
// the position on iOS, it seems like a horizontal inset of 10 points looks pretty close.
static const CGFloat kBadgeXOffsetFromIconEdgeWithTextLTR = -8;

// However, when the badge has no visible text, its horizontal center should be 1 point inset from
// the edge of the image.
static const CGFloat kBadgeXOffsetFromIconEdgeEmptyLTR = -1;

// Offsets used for anchored layout
static const CGFloat kAnchorVerticalOffsetWithLabel = -25.0;
static const CGFloat kAnchorVerticalOffsetWithoutLabel = -16.0;
static const CGFloat kBadgeVerticalOffset = 2.0f;
static const CGFloat kIconVerticalOffset = 1.0;
static const CGFloat kLabelVerticalOffset = 7.0;
static const CGFloat kSelectionIndicatorVerticalOffset = 1.0;

// Used in horizontal layout only. Offset between label and adjacent image.
static const CGFloat kLabelHorizontalOffset = 8.0;

// The duration of the (de)selection transition animation.
static const NSTimeInterval kMDCBottomNavigationItemViewSelectionAnimationDuration = 0.100f;

// The duration of the title label's fade-out animation on deselection. The fade-in animation of the
// label on selection will be delayed by this value, and the duration of that animation is
// @c kMDCBottomNavigationItemViewSelectionAnimationDuration minus this value.
static const NSTimeInterval kMDCBottomNavigationItemViewLabelFadeOutAnimationDuration = 0.0333f;

// The amount to inset pointerEffectHoverRect.
// These values were chosen to achieve visual parity with UITabBar's highlight effect.
const CGSize MDCButtonNavigationItemViewPointerEffectHighlightRectInset = {-24, -12};

#if TARGET_IPHONE_SIMULATOR
UIKIT_EXTERN float UIAnimationDragCoefficient(void);  // UIKit private drag coefficient.
#endif

@interface MDCBottomNavigationItemView ()

@property(nonatomic, strong) UILabel *label;
- (CGPoint)badgeCenterFromIconFrame:(CGRect)iconFrame isRTL:(BOOL)isRTL;
@end

@implementation MDCBottomNavigationItemView {
  MDCBadgeView *_Nonnull _badge;
  UIView *_Nullable _selectionIndicator;
}

@synthesize badgeAppearance = _badgeAppearance;

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    _titleBelowIcon = YES;
    _truncatesTitle = YES;
    _titleNumberOfLines = kDefaultTitleNumberOfLines;
    _selectedItemTintColor = [UIColor blackColor];
    _unselectedItemTintColor = [UIColor grayColor];
    _selectedItemTitleColor = _selectedItemTintColor;

    _iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _iconImageView.isAccessibilityElement = NO;
    _iconImageView.tintAdjustmentMode = UIViewTintAdjustmentModeNormal;
    [self addSubview:_iconImageView];

    _label = [[UILabel alloc] initWithFrame:CGRectZero];
    _label.text = _title;
    _label.font = [UIFont systemFontOfSize:MDCBottomNavigationItemViewTitleFontSize];
    _label.textAlignment = NSTextAlignmentCenter;
    _label.textColor = _selectedItemTitleColor;
    _label.isAccessibilityElement = NO;
    [self addSubview:_label];
    _label.numberOfLines = kDefaultTitleNumberOfLines;

    // We store a local copy of the badge appearance so that we can consistently override with the
    // UITabBarItem badgeColor property.
    _badgeAppearance = [[MDCBadgeAppearance alloc] init];

    _badge = [[MDCBadgeView alloc] initWithFrame:CGRectZero];
    _badge.isAccessibilityElement = NO;
    [self addSubview:_badge];
    _badge.hidden = YES;

    _rippleTouchController = [[MDCRippleTouchController alloc] initWithView:self];
    _rippleTouchController.rippleView.rippleStyle = MDCRippleStyleUnbounded;

    _button = [[UIButton alloc] initWithFrame:self.bounds];
    _button.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    _button.accessibilityLabel = [self accessibilityLabelWithTitle:_title];
    _button.accessibilityValue = self.accessibilityValue;
    // This needs to be set specifically for VoiceOver to work on iOS 14, see b/175421576
    if (@available(iOS 14, *)) {
      _button.accessibilityTraits |= UIAccessibilityTraitButton;
    }
    [self addSubview:_button];
  }
  return self;
}

- (void)traitCollectionDidChange:(nullable UITraitCollection *)previousTraitCollection {
  [super traitCollectionDidChange:previousTraitCollection];

  if (self.traitCollection.legibilityWeight != previousTraitCollection.legibilityWeight) {
    // Layout subviews when bold text setting changes so the label size is recalculated to
    // fit the text.
    [self setNeedsLayout];
  }
}

- (CGSize)sizeThatFits:(__unused CGSize)size {
  if (self.titleBelowIcon) {
    return [self sizeThatFitsForVerticalLayout];
  } else {
    return [self sizeThatFitsForHorizontalLayout];
  }
}

- (BOOL)isTitleHiddenInLegacyLayout {
  return self.titleVisibility == MDCBottomNavigationBarTitleVisibilityNever ||
         (self.titleVisibility == MDCBottomNavigationBarTitleVisibilitySelected && !self.selected);
}

- (CGSize)sizeThatFitsForVerticalLayout {
  // TODO(b/244765238): Remove branching layout logic after GM3 migrations
  if ([self showsSelectionIndicator]) {
    return [self sizeThatFitsForVerticalAnchoredLayout];
  }

  CGSize maxSize = CGSizeMake(kMaxSizeDimension, kMaxSizeDimension);
  CGSize iconSize = [self.iconImageView sizeThatFits:maxSize];
  CGRect iconFrame = CGRectMake(0, 0, iconSize.width, iconSize.height);
  CGSize badgeSize = [_badge sizeThatFits:maxSize];
  CGPoint badgeCenter = [self badgeCenterFromIconFrame:iconFrame isRTL:NO];
  CGRect badgeFrame =
      CGRectMake(floor(badgeCenter.x - badgeSize.width / 2),
                 floor(badgeCenter.y - badgeSize.height / 2), badgeSize.width, badgeSize.height);
  CGRect labelFrame = CGRectZero;
  if (![self isTitleHiddenInLegacyLayout]) {
    CGSize labelSize = [self.label sizeThatFits:maxSize];
    labelFrame = CGRectMake(floor(CGRectGetMidX(iconFrame) - labelSize.width / 2),
                            CGRectGetMaxY(iconFrame) + self.contentVerticalMargin, labelSize.width,
                            labelSize.height);
  }
  return CGRectStandardize(CGRectUnion(labelFrame, CGRectUnion(iconFrame, badgeFrame))).size;
}

- (CGSize)sizeThatFitsForHorizontalLayout {
  // TODO(b/244765238): Remove branching layout logic after GM3 migrations
  if ([self showsSelectionIndicator]) {
    return [self sizeThatFitsForHorizontalAnchoredLayout];
  }

  CGSize maxSize = CGSizeMake(kMaxSizeDimension, kMaxSizeDimension);
  CGSize iconSize = [self.iconImageView sizeThatFits:maxSize];
  CGRect iconFrame = CGRectMake(0, 0, iconSize.width, iconSize.height);
  CGSize badgeSize = [_badge sizeThatFits:maxSize];
  CGPoint badgeCenter = [self badgeCenterFromIconFrame:iconFrame isRTL:NO];
  CGRect badgeFrame =
      CGRectMake(floor(badgeCenter.x - badgeSize.width / 2),
                 floor(badgeCenter.y - badgeSize.height / 2), badgeSize.width, badgeSize.height);
  CGSize labelSize = [self.label sizeThatFits:maxSize];
  CGRect labelFrame = CGRectMake(CGRectGetMaxX(iconFrame) + self.contentHorizontalMargin,
                                 floor(CGRectGetMidY(iconFrame) - labelSize.height / 2),
                                 labelSize.width, labelSize.height);
  return CGRectStandardize(CGRectUnion(labelFrame, CGRectUnion(iconFrame, badgeFrame))).size;
}

- (void)layoutSubviews {
  [super layoutSubviews];

  [self.label sizeToFit];
  [self.iconImageView sizeToFit];
  [_badge sizeToFit];
  [self centerLayoutAnimated:NO];
  [self invalidatePointerInteractions];

  // TODO(b/244765238): Remove branching layout logic after GM3 migrations
  if ([self showsSelectionIndicator]) {
    _selectionIndicator.frame = [self selectionIndicatorFrame];
    _selectionIndicator.layer.cornerRadius = _selectionIndicator.bounds.size.height / 2;
    _selectionIndicator.hidden = !_showsSelectionIndicator;
  }
}

- (void)calculateVerticalLayoutInBounds:(CGRect)contentBounds
                          forLabelFrame:(CGRect *)outLabelFrame
                     iconImageViewFrame:(CGRect *)outIconFrame {
  if ([self showsSelectionIndicator]) {
    return [self centerAnchoredLayout];
  }

  // Determine the intrinsic size of the label, icon, and combined content
  CGRect contentBoundingRect = CGRectStandardize(contentBounds);
  CGSize iconImageViewSize = [self.iconImageView sizeThatFits:contentBoundingRect.size];
  CGSize labelSize = [self.label sizeThatFits:contentBoundingRect.size];
  CGFloat iconHeight = iconImageViewSize.height;
  CGFloat labelHeight = labelSize.height;
  CGFloat totalContentHeight = iconHeight;
  if (![self isTitleHiddenInLegacyLayout]) {
    totalContentHeight += labelHeight + self.contentVerticalMargin;
  }

  // Determine the position of the label and icon
  CGFloat centerX = CGRectGetMidX(contentBoundingRect);
  CGFloat iconImageViewCenterY =
      MAX(floor(CGRectGetMidY(contentBoundingRect) - totalContentHeight / 2 +
                   iconHeight / 2),  // Content centered
          floor(CGRectGetMinY(contentBoundingRect) +
                   iconHeight / 2)  // Pinned to top of bounding rect.
      );
  CGPoint iconImageViewCenter = CGPointMake(centerX, iconImageViewCenterY);
  // Ignore the horizontal titlePositionAdjustment in a vertical layout to match UITabBar behavior.
  CGFloat centerY;
  if ([self isTitleHiddenInLegacyLayout]) {
    centerY = iconImageViewCenter.y + iconHeight / 2 + self.titlePositionAdjustment.vertical +
              self.contentVerticalMargin / 2;
  } else {
    centerY = iconImageViewCenter.y + iconHeight / 2 + self.contentVerticalMargin +
              labelHeight / 2 + self.titlePositionAdjustment.vertical;
  }

  CGPoint labelCenter = CGPointMake(centerX, centerY);
  CGFloat availableContentWidth = CGRectGetWidth(contentBoundingRect);
  if (self.truncatesTitle && (labelSize.width > availableContentWidth)) {
    labelSize = CGSizeMake(availableContentWidth, labelSize.height);
  }

  // Assign the frames to the inout arguments
  if (outLabelFrame != NULL) {
    *outLabelFrame = CGRectMake(floor(labelCenter.x - (labelSize.width / 2)),
                                floor(labelCenter.y - (labelSize.height / 2)), labelSize.width,
                                labelSize.height);
  }
  if (outIconFrame != NULL) {
    *outIconFrame = CGRectMake(floor(iconImageViewCenter.x - (iconImageViewSize.width / 2)),
                               floor(iconImageViewCenter.y - (iconImageViewSize.height / 2)),
                               iconImageViewSize.width, iconImageViewSize.height);
  }
}

- (void)calculateHorizontalLayoutInBounds:(CGRect)contentBounds
                            forLabelFrame:(CGRect *)outLabelFrame
                       iconImageViewFrame:(CGRect *)outIconFrame {
  // TODO(b/244765238): Remove branching layout logic after GM3 migrations
  if ([self showsSelectionIndicator]) {
    return [self centerAnchoredLayout];
  }
  // Determine the intrinsic size of the label and icon
  CGRect contentBoundingRect = CGRectStandardize(contentBounds);
  CGSize iconImageViewSize = [self.iconImageView sizeThatFits:contentBoundingRect.size];
  CGSize maxLabelSize = CGSizeMake(
      contentBoundingRect.size.width - self.contentHorizontalMargin - iconImageViewSize.width,
      contentBoundingRect.size.height);
  CGSize labelSize = [self.label sizeThatFits:maxLabelSize];

  CGFloat contentsWidth = iconImageViewSize.width + self.contentHorizontalMargin + labelSize.width;
  CGFloat remainingContentWidth = CGRectGetWidth(contentBoundingRect);
  if (contentsWidth > remainingContentWidth) {
    contentsWidth = remainingContentWidth;
  }
  // If the content width and available width are different, the internal spacing required to center
  // the contents.
  CGFloat contentPadding = (remainingContentWidth - contentsWidth) / 2;
  remainingContentWidth -= iconImageViewSize.width + self.contentHorizontalMargin;
  if (self.truncatesTitle) {
    labelSize = CGSizeMake(MIN(labelSize.width, remainingContentWidth), labelSize.height);
  }

  // Account for RTL
  BOOL isRTL =
      self.effectiveUserInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft;
  NSInteger rtlCoefficient = isRTL ? -1 : 1;
  CGFloat layoutStartingPoint =
      isRTL ? CGRectGetMaxX(contentBoundingRect) : CGRectGetMinX(contentBoundingRect);

  CGFloat centerY = CGRectGetMidY(contentBoundingRect);
  // Amount icon center is offset from the leading edge.
  CGFloat iconCenterOffset = contentPadding + iconImageViewSize.width / 2;

  // Determine the position of the label and icon
  CGPoint iconImageViewCenter =
      CGPointMake(layoutStartingPoint + rtlCoefficient * iconCenterOffset, centerY);
  CGFloat labelOffsetFromIcon =
      iconImageViewSize.width / 2 + self.contentHorizontalMargin + labelSize.width / 2;
  CGPoint labelCenter = CGPointMake(iconImageViewCenter.x + rtlCoefficient * labelOffsetFromIcon +
                                        self.titlePositionAdjustment.horizontal,
                                    centerY + self.titlePositionAdjustment.vertical);

  // Assign the frames to the inout arguments
  if (outLabelFrame != NULL) {
    *outLabelFrame = CGRectMake(floor(labelCenter.x - (labelSize.width / 2)),
                                floor(labelCenter.y - (labelSize.height / 2)), labelSize.width,
                                labelSize.height);
  }
  if (outIconFrame != NULL) {
    *outIconFrame = CGRectMake(floor(iconImageViewCenter.x - (iconImageViewSize.width / 2)),
                               floor(iconImageViewCenter.y - (iconImageViewSize.height / 2)),
                               iconImageViewSize.width, iconImageViewSize.height);
  }
}

- (void)centerLayoutAnimated:(BOOL)animated {
  // TODO(b/244765238): Remove branching layout logic after GM3 migrations
  if ([self showsSelectionIndicator]) {
    return [self centerAnchoredLayout];
  }

  CGRect labelFrame = CGRectZero;
  CGRect iconImageViewFrame = CGRectZero;

  if (self.titleBelowIcon) {
    [self calculateVerticalLayoutInBounds:self.bounds
                            forLabelFrame:&labelFrame
                       iconImageViewFrame:&iconImageViewFrame];
  } else {
    [self calculateHorizontalLayoutInBounds:self.bounds
                              forLabelFrame:&labelFrame
                         iconImageViewFrame:&iconImageViewFrame];
  }

  CGPoint iconImageViewCenter =
      CGPointMake(CGRectGetMidX(iconImageViewFrame), CGRectGetMidY(iconImageViewFrame));
  self.label.center = CGPointMake(CGRectGetMidX(labelFrame), CGRectGetMidY(labelFrame));
  self.label.bounds = CGRectMake(0, 0, CGRectGetWidth(labelFrame), CGRectGetHeight(labelFrame));

  UIUserInterfaceLayoutDirection layoutDirection = self.effectiveUserInterfaceLayoutDirection;
  BOOL isRTL = layoutDirection == UIUserInterfaceLayoutDirectionRightToLeft;

  if (self.titleBelowIcon) {
    if (animated) {
      [UIView animateWithDuration:kMDCBottomNavigationItemViewSelectionAnimationDuration
                       animations:^(void) {
                         self.iconImageView.center = iconImageViewCenter;
                         _badge.center =
                             [self badgeCenterFromIconFrame:CGRectStandardize(iconImageViewFrame)
                                                      isRTL:isRTL];
                       }];
    } else {
      self.iconImageView.center = iconImageViewCenter;
      _badge.center = [self badgeCenterFromIconFrame:CGRectStandardize(iconImageViewFrame)
                                               isRTL:isRTL];
    }
    self.label.textAlignment = NSTextAlignmentCenter;
  } else {
    if (!isRTL) {
      self.label.textAlignment = NSTextAlignmentLeft;
    } else {
      self.label.textAlignment = NSTextAlignmentRight;
    }
    self.iconImageView.center = iconImageViewCenter;
    _badge.center = [self badgeCenterFromIconFrame:CGRectStandardize(iconImageViewFrame)
                                             isRTL:isRTL];
  }
}

- (void)updateLabelVisibility:(BOOL)animated {
  BOOL shouldHide;
  if (self.selected) {
    switch (self.titleVisibility) {
      case MDCBottomNavigationBarTitleVisibilitySelected:
      case MDCBottomNavigationBarTitleVisibilityAlways:
        shouldHide = NO;
        break;
      case MDCBottomNavigationBarTitleVisibilityNever:
        shouldHide = YES;
        break;
    }
  } else {
    switch (self.titleVisibility) {
      case MDCBottomNavigationBarTitleVisibilitySelected:
      case MDCBottomNavigationBarTitleVisibilityNever:
        shouldHide = YES;
        break;
      case MDCBottomNavigationBarTitleVisibilityAlways:
        shouldHide = NO;
        break;
    }
  }

  if (!animated) {
    [self setNeedsLayout];
    self.label.alpha = shouldHide ? 0.0f : 1.0f;
  } else {
    [UIView animateWithDuration:kMDCBottomNavigationItemViewSelectionAnimationDuration
                     animations:^{
                       [self setNeedsLayout];
                       self.label.alpha = shouldHide ? 0.0f : 1.0f;
                     }];
    if (shouldHide) {
      [UIView animateWithDuration:kMDCBottomNavigationItemViewLabelFadeOutAnimationDuration
                       animations:^{
                         self.label.alpha = 0.0f;
                       }];
    } else {
      [UIView animateWithDuration:(kMDCBottomNavigationItemViewSelectionAnimationDuration -
                                   kMDCBottomNavigationItemViewLabelFadeOutAnimationDuration)
                            delay:kMDCBottomNavigationItemViewLabelFadeOutAnimationDuration
                          options:UIViewAnimationOptionCurveLinear
                       animations:^{
                         self.label.alpha = 1.0f;
                       }
                       completion:nil];
    }
  }
}

- (NSString *)accessibilityLabelWithTitle:(NSString *)title {
  NSMutableArray *labelComponents = [NSMutableArray array];

  // Use untransformed title as accessibility label to ensure accurate reading.
  if (title.length > 0) {
    [labelComponents addObject:title];
  }

  // Speak components with a pause in between.
  return [labelComponents componentsJoinedByString:@", "];
}

- (CGPoint)badgeCenterFromIconFrame:(CGRect)iconFrame isRTL:(BOOL)isRTL {
  CGSize badgeSize = [_badge sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];

  // There are no specifications for badge layout, so this is based on the Material Guidelines
  // article for Bottom Navigation which includes an image showing badge positions.
  // https://storage.googleapis.com/spec-host-backup/mio-design%2Fassets%2F0B6xUSjjSulxcaVpEMk5tZ2RGZ3c%2Fbottomnav-badging-1.png
  // Attempting to match the "88" badge on the "chrome reader mode" icon results in the badge's top
  // edge equalling that of the image bounds.
  // https://material.io/tools/icons/?icon=chrome_reader_mode&style=baseline
  CGFloat badgeCenterY = CGRectGetMinY(iconFrame) + (badgeSize.height / 2);

  CGFloat badgeCenterXOffset = kBadgeXOffsetFromIconEdgeWithTextLTR + badgeSize.width / 2;
  if (self.badgeText.length == 0) {
    badgeCenterXOffset = kBadgeXOffsetFromIconEdgeEmptyLTR;
  }
  CGFloat badgeCenterX = isRTL ? CGRectGetMinX(iconFrame) - badgeCenterXOffset
                               : CGRectGetMaxX(iconFrame) + badgeCenterXOffset;

  // Account for the badge's outer border width.
  badgeCenterX -= _badge.appearance.borderWidth / 2;
  badgeCenterY -= _badge.appearance.borderWidth / 2;

  return CGPointMake(badgeCenterX, badgeCenterY);
}

- (CGRect)pointerEffectHighlightRect {
  NSMutableArray<UIView *> *visibleViews = [[NSMutableArray alloc] init];
  if (!self.iconImageView.hidden) {
    [visibleViews addObject:self.iconImageView];
  }
  if (!self.label.hidden) {
    [visibleViews addObject:self.label];
  }
  if (!_badge.hidden) {
    [visibleViews addObject:_badge];
  }

  // If we don't have any visible views, there is no content to frame
  if (visibleViews.count == 0) {
    return self.frame;
  }

  CGRect contentRect = visibleViews.firstObject.frame;
  for (UIView *visibleView in visibleViews) {
    contentRect = CGRectUnion(contentRect, visibleView.frame);
  }

  CGRect insetContentRect =
      CGRectInset(contentRect, MDCButtonNavigationItemViewPointerEffectHighlightRectInset.width,
                  MDCButtonNavigationItemViewPointerEffectHighlightRectInset.height);

  // Ensure insetContentRect is the same size or smaller than self.bounds
  CGSize boundsSize = CGRectStandardize(self.bounds).size;
  if (insetContentRect.size.width > boundsSize.width) {
    insetContentRect.origin.x = 0;
    insetContentRect.size.width = boundsSize.width;
  }

  if (insetContentRect.size.height > boundsSize.height) {
    insetContentRect.origin.y = 0;
    insetContentRect.size.height = boundsSize.height;
  }

  return insetContentRect;
}

- (void)invalidatePointerInteractions {
#ifdef __IPHONE_13_4
  if (@available(iOS 13.4, *)) {
    for (UIPointerInteraction *interaction in self.interactions) {
      [interaction invalidate];
    }
  }
#endif
}

#pragma mark - Setters

- (void)setSelected:(BOOL)selected {
  [self setSelected:selected animated:NO];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  _selected = selected;

  _selectionIndicator.hidden = !selected;

  if (selected) {
    self.label.textColor = self.selectedItemTitleColor;
    self.button.accessibilityTraits |= UIAccessibilityTraitSelected;
    [self updateLabelVisibility:animated];
  } else {
    self.label.textColor = self.unselectedItemTintColor;
    self.button.accessibilityTraits &= ~UIAccessibilityTraitSelected;
    [self updateLabelVisibility:animated];
  }

  void (^selectionIndicatorAnimations)(void) = ^{
    [self commitSelectionIndicatorState];
    [self centerLayoutAnimated:animated];
  };

  void (^imageAdjustments)(void) = ^{
    if (selected) {
      self.iconImageView.tintColor = self.selectedItemTintColor;
      self.iconImageView.image = (self.selectedImage) ? self.selectedImage : self.image;
    } else {
      self.iconImageView.tintColor = self.unselectedItemTintColor;
      self.iconImageView.image = self.image;
    }
  };

  // We only animate items that are newly selected so as to avoid creating unnecessary motion
  // noise on the unselected item.
  if (selected && animated && _showsSelectionIndicator) {
    [UIView animateWithDuration:kSelectionIndicatorTransformAnimationDuration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:selectionIndicatorAnimations
                     completion:nil];

    imageAdjustments();
  } else {
    selectionIndicatorAnimations();
    imageAdjustments();
  }
}

- (void)setSelectedItemTintColor:(nullable UIColor *)selectedItemTintColor {
  _selectedItemTintColor = selectedItemTintColor;
  _selectedItemTitleColor = selectedItemTintColor;
  if (self.selected) {
    self.iconImageView.tintColor = self.selectedItemTintColor;
    self.label.textColor = self.selectedItemTitleColor;
  }
  if (!_rippleColor) {
    UIColor *rippleColor = [self.selectedItemTintColor
        colorWithAlphaComponent:MDCBottomNavigationItemViewRippleOpacity];
    if (!rippleColor) {
      rippleColor = [UIColor clearColor];
    }
    self.rippleTouchController.rippleView.rippleColor = rippleColor;
  }
}

- (void)setUnselectedItemTintColor:(nullable UIColor *)unselectedItemTintColor {
  _unselectedItemTintColor = unselectedItemTintColor;
  if (!self.selected) {
    self.iconImageView.tintColor = self.unselectedItemTintColor;
    self.label.textColor = self.unselectedItemTintColor;
  }
}

- (void)setSelectedItemTitleColor:(nullable UIColor *)selectedItemTitleColor {
  _selectedItemTitleColor = selectedItemTitleColor;
  if (self.selected) {
    self.label.textColor = self.selectedItemTitleColor;
  }
}

- (void)setImage:(nullable UIImage *)image {
  _image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

  // _image updates unselected state
  // _image updates selected state IF there is no selectedImage
  if (!self.selected || (self.selected && !self.selectedImage)) {
    self.iconImageView.image = _image;
    self.iconImageView.tintColor =
        (self.selected) ? self.selectedItemTintColor : self.unselectedItemTintColor;
    [self setNeedsLayout];
  }
}

- (void)setSelectedImage:(nullable UIImage *)selectedImage {
  _selectedImage = [selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
  if (self.selected) {
    self.iconImageView.image = _selectedImage;
    self.iconImageView.tintColor = self.selectedItemTintColor;
    [self.iconImageView sizeToFit];
    [self setNeedsLayout];
  }
}

- (void)setTitle:(nullable NSString *)title {
  _title = [title copy];
  self.label.text = _title;
  self.button.accessibilityLabel = [self accessibilityLabelWithTitle:_title];
  [self setNeedsLayout];
}

- (void)setTitleVisibility:(MDCBottomNavigationBarTitleVisibility)titleVisibility {
  _titleVisibility = titleVisibility;
  [self updateLabelVisibility:NO];
}

- (void)setItemTitleFont:(nullable UIFont *)itemTitleFont {
  _itemTitleFont = itemTitleFont;
  self.label.font = itemTitleFont;
  [self setNeedsLayout];
}

- (void)setAccessibilityValue:(nullable NSString *)accessibilityValue {
  [super setAccessibilityValue:accessibilityValue];
  self.button.accessibilityValue = accessibilityValue;
}

- (nullable NSString *)accessibilityValue {
  return self.button.accessibilityValue;
}

- (void)setAccessibilityHint:(nullable NSString *)accessibilityHint {
  [super setAccessibilityHint:accessibilityHint];
  self.button.accessibilityHint = accessibilityHint;
}

- (nullable NSString *)accessibilityHint {
  return self.button.accessibilityHint;
}

- (void)setAccessibilityElementIdentifier:(nullable NSString *)accessibilityElementIdentifier {
  self.button.accessibilityIdentifier = accessibilityElementIdentifier;
}

- (void)setBadgeHorizontalOffset:(CGFloat)badgeHorizontalOffset {
  _badgeHorizontalOffset = badgeHorizontalOffset;
  [self setNeedsLayout];
}

- (nullable NSString *)accessibilityElementIdentifier {
  return self.button.accessibilityIdentifier;
}

- (void)setTitlePositionAdjustment:(UIOffset)titlePositionAdjustment {
  if (!UIOffsetEqualToOffset(_titlePositionAdjustment, titlePositionAdjustment)) {
    _titlePositionAdjustment = titlePositionAdjustment;
    [self setNeedsLayout];
  }
}

- (NSInteger)renderedTitleNumberOfLines {
  return self.titleBelowIcon ? _titleNumberOfLines : kDefaultTitleNumberOfLines;
}

- (void)setTitleNumberOfLines:(NSInteger)titleNumberOfLines {
  _titleNumberOfLines = titleNumberOfLines;
  self.label.numberOfLines = [self renderedTitleNumberOfLines];
}

- (void)setTitleBelowIcon:(BOOL)titleBelowIcon {
  _titleBelowIcon = titleBelowIcon;
  self.label.numberOfLines = [self renderedTitleNumberOfLines];
}

#pragma mark - Configuring the selection appearance

- (void)commitSelectionIndicatorState {
  if (_selected) {
    _selectionIndicator.transform = CGAffineTransformIdentity;
    _selectionIndicator.alpha = 1.0;
  } else {
    _selectionIndicator.transform = CGAffineTransformMakeScale(0.25, 1);
    _selectionIndicator.alpha = 0;
  }
}

- (void)setShowsSelectionIndicator:(BOOL)showsSelectionIndicator {
  if (_showsSelectionIndicator == showsSelectionIndicator) {
    return;
  }
  _showsSelectionIndicator = showsSelectionIndicator;

  if (_showsSelectionIndicator) {
    _selectionIndicator = [[UIView alloc] init];
    _selectionIndicator.backgroundColor = _selectionIndicatorColor;
    _selectionIndicator.hidden = !_selected;
    [self commitSelectionIndicatorState];
    [self insertSubview:_selectionIndicator belowSubview:_iconImageView];
  } else {
    [_selectionIndicator removeFromSuperview];
    _selectionIndicator = nil;
  }
  [self setNeedsLayout];
}

- (void)setSelectionIndicatorSize:(CGSize)selectionIndicatorSize {
  if (CGSizeEqualToSize(selectionIndicatorSize, _selectionIndicatorSize)) {
    return;
  }
  _selectionIndicatorSize = selectionIndicatorSize;
  if (_showsSelectionIndicator) {
    [self setNeedsLayout];
  }
}

- (void)setSelectionIndicatorColor:(UIColor *)selectionIndicatorColor {
  _selectionIndicatorColor = selectionIndicatorColor;

  _selectionIndicator.backgroundColor = selectionIndicatorColor;
}

#pragma mark - Configuring the ripple appearance

- (void)setRippleColor:(nullable UIColor *)rippleColor {
  _rippleColor = rippleColor;

  if (!rippleColor) {
    rippleColor = [UIColor clearColor];
  }
  self.rippleTouchController.rippleView.rippleColor = rippleColor;
}

#pragma mark - Displaying a value in the badge

- (void)setBadgeText:(nullable NSString *)badgeText {
  _badge.text = badgeText;
  if ([super accessibilityValue] == nil || [self accessibilityValue].length == 0) {
    self.button.accessibilityValue = badgeText;
  }
  if (badgeText == nil) {
    _badge.hidden = YES;
  } else {
    _badge.hidden = NO;
  }
  [self setNeedsLayout];
}

- (nullable NSString *)badgeText {
  return _badge.text;
}

#pragma mark - Configuring the badge's visual appearance

- (void)commitBadgeAppearance {
  _badge.appearance = [_badgeAppearance copy];
}

- (void)setBadgeAppearance:(MDCBadgeAppearance *)badgeAppearance {
  _badgeAppearance = [badgeAppearance copy];

  [self commitBadgeAppearance];
}

- (void)setBadgeColor:(nullable UIColor *)badgeColor {
  _badgeAppearance.backgroundColor = badgeColor;

  [self commitBadgeAppearance];
}

- (nullable UIColor *)badgeColor {
  return _badgeAppearance.backgroundColor;
}

- (void)setBadgeTextColor:(nullable UIColor *)badgeTextColor {
  _badgeAppearance.textColor = badgeTextColor;

  [self commitBadgeAppearance];
}

- (nonnull UIColor *)badgeTextColor {
  return _badgeAppearance.textColor;
}

- (void)setBadgeFont:(nullable UIFont *)badgeFont {
  _badgeAppearance.font = badgeFont;

  [self commitBadgeAppearance];
}

- (nonnull UIFont *)badgeFont {
  return _badgeAppearance.font;
}

#pragma mark - UILargeContentViewerItem

- (BOOL)showsLargeContentViewer {
  return YES;
}

- (nullable NSString *)largeContentTitle {
  if (_largeContentTitle) {
    return _largeContentTitle;
  }

  return self.title;
}

- (nullable UIImage *)largeContentImage {
  if (_largeContentImage) {
    return _largeContentImage;
  }

  return self.image;
}

- (BOOL)scalesLargeContentImage {
  return _largeContentImage == nil;
}

#pragma mark - Anchored layout

// midPoint is the main point around which the item view's content is centered.
// In a labelless layout, it is the center point of the item view (0.5x, 0.5y).
// In a labeled layout, it is also the center point of the item view.
// In a labeled, it has a slight negative-Y offset (0.5x, 0.5y - yOffset). This
// shifts it upwards, to account for the label. The selection indicator serves as the main point of
// reference for all other views. The iconView and badge are enclosed within it. When labels are
// enabled, the label is adjacent to the indicator.

// (note: these views are all siblings of each other, as well as direct subviews of the ItemView)
// selectionIndicator: Positioned based on midPoint.
// IconView: Positioned based on midPoint and selectionIndicator.
// Badge: Positioned based on selectionIndicator and iconView.
// Label: Positioned based on selectionIndicator and midPoint, depending on current layout
// label is hidden in horizontal layout
// States: (horizontal || vertical) && (LTR || RTL)

//        labelless                      labeled
//  ---------------------         ---------------------
// |                     |       |                     |
// |                     |       |                     |
// |                     |       |        -----        |
// |        -----        |       |       |  o  |       |
// |       |  o  |       |       |        -----        |
// |        -----        |       |       <label>       |
// |                     |       |                     |
// |                     |       |                     |
// |                     |       |                     |
//  ---------------------         ---------------------

//         LTR badge                    RTL badge
//  ---------------------         ---------------------
// |                     |       |                     |
// |                     |       |                     |
// |                     |       |                     |
// |        -----        |       |        -----        |
// |       |  o* |       |       |       | *o  |       |
// |        -----        |       |        -----        |
// |                     |       |                     |
// |                     |       |                     |
// |                     |       |                     |
//  ---------------------         ---------------------

- (CGPoint)midPoint {
  CGFloat x = floor(CGRectGetMidX(self.bounds));
  CGFloat y;

  // Layout is centered when title labels are not visible

  if ([self isTitleHiddenInAnchoredLayout]) {
    y = floor(CGRectGetMidY(self.bounds)) + kAnchorVerticalOffsetWithoutLabel;
  } else {
    y = floor(CGRectGetMidY(self.bounds)) + kAnchorVerticalOffsetWithLabel;
  }
  return CGPointMake(x, y);
}

#pragma mark - Anchored Selection Indicator
- (CGRect)selectionIndicatorFrame {
  CGPoint midPoint = [self midPoint];
  CGSize selectionIndicatorSize = _selectionIndicatorSize;

  return CGRectMake(midPoint.x - selectionIndicatorSize.width * 0.5,
                    midPoint.y + kSelectionIndicatorVerticalOffset, selectionIndicatorSize.width,
                    selectionIndicatorSize.height);
}

#pragma mark - Anchored Badge
- (CGPoint)badgePositionForRTLState:(BOOL)isRTL {
  CGPoint iconPosition = [self iconPosition];
  CGRect indicatorFrame = [self selectionIndicatorFrame];
  CGFloat iconX = iconPosition.x;

  CGFloat badgeX;
  if (isRTL) {
    badgeX = iconX + floor([self iconSize].width * 0.5) - floor([self badgeSize].width) -
             _badgeHorizontalOffset;
  } else {
    badgeX = iconX + floor([self iconSize].width * 0.5) + _badgeHorizontalOffset;
  }

  CGFloat badgeY = CGRectGetMinY(indicatorFrame) + kBadgeVerticalOffset;

  return CGPointMake(badgeX, badgeY);
}

- (CGSize)badgeSize {
  CGSize maxSize = CGSizeMake(kMaxSizeDimension, kMaxSizeDimension);
  return [_badge sizeThatFits:maxSize];
}

#pragma mark - Anchored Icon
- (CGPoint)iconPosition {
  CGPoint midPoint = [self midPoint];
  CGFloat indicatorMidX = CGRectGetMidX(_selectionIndicator.frame);

  CGFloat iconX = indicatorMidX - CGRectGetMidX(_iconImageView.bounds);
  CGFloat iconY = midPoint.y + (_selectionIndicatorSize.height * 0.5) -
                  CGRectGetMidY(_iconImageView.bounds) + kIconVerticalOffset;

  return CGPointMake(iconX, iconY);
}

- (CGSize)iconSize {
  CGSize maxSize = CGSizeMake(kMaxSizeDimension, kMaxSizeDimension);
  return [_iconImageView sizeThatFits:maxSize];
}

#pragma mark - Anchored Label
- (CGSize)labelSize {
  if ([self isTitleHiddenInAnchoredLayout]) {
    return CGSizeZero;
  } else {
    CGSize maxSize = CGSizeMake(kMaxSizeDimension, kMaxSizeDimension);
    return [_label sizeThatFits:maxSize];
  }
}

- (CGFloat)labelXForRTLState:(BOOL)isRTL isHorizontalLayout:(BOOL)isHorizontalLayout {
  if (isHorizontalLayout) {
    return [self labelXForHorizontalLayoutWithRTLState:isRTL];
  } else {
    return [self labelXForVerticalLayout];
  }
}

// Label is anchored based on the frame provided for the active indicator
// (Not the current frame of the active indicator itself, since there may not be an indicator
// present) This frame can be calculated and referenced even if the indicator is disabled
- (CGFloat)labelYForHorizontalLayoutState:(BOOL)isHorizontalLayout {
  if (isHorizontalLayout) {
    return [self labelYForHorizontalLayout];
  } else {
    return [self labelYForVerticalLayout];
  }
}

// Vertical Label (x,y)
- (CGFloat)labelXForVerticalLayout {
  CGPoint midPoint = [self midPoint];
  return midPoint.x - CGRectGetMidX(_label.bounds);
}

- (CGFloat)labelYForVerticalLayout {
  CGPoint midPoint = [self midPoint];

  return midPoint.y + floor(_selectionIndicatorSize.height) + kLabelVerticalOffset;
}

// Horizontal Label (x, y)
- (CGFloat)labelXForHorizontalLayoutWithRTLState:(BOOL)isRTL {
  CGPoint midPoint = [self midPoint];
  CGRect selectionIndicatorFrame = [self selectionIndicatorFrame];
  CGSize labelSize = [self labelSize];

  if (isRTL) {
    return CGRectGetMinX(selectionIndicatorFrame) - labelSize.width - kLabelHorizontalOffset;
  } else {
    return midPoint.x + floor(_selectionIndicatorSize.width * 0.5) + kLabelHorizontalOffset;
  }
}

- (CGFloat)labelYForHorizontalLayout {
  CGPoint midPoint = [self midPoint];
  return midPoint.y + CGRectGetMidY(_iconImageView.bounds);
}

#pragma mark - Branched anchored layout methods
// Note that layoutSubviews is branched in its implementation, despite not having a branching method
// here.

- (CGSize)sizeThatFitsForVerticalAnchoredLayout {
  MDCBadgeView *badge = _badge;

  CGSize iconSize = [self iconSize];
  CGRect iconFrame = CGRectIntegral(CGRectMake(0, 0, iconSize.width, iconSize.height));

  BOOL isRTL =
      self.effectiveUserInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft;
  CGPoint badgePosition = [self badgePositionForRTLState:isRTL];
  CGFloat badgeX = badgePosition.x;
  CGFloat badgeY = badgePosition.y;
  CGRect normalizedBadgeFrame =
      CGRectIntegral(CGRectMake(badgeX, badgeY, badge.bounds.size.width, badge.bounds.size.height));
  CGRect labelFrame = CGRectZero;
  if (![self isTitleHiddenInAnchoredLayout]) {
    CGSize labelSize = [self labelSize];
    labelFrame = CGRectIntegral(CGRectMake([self labelXForRTLState:isRTL isHorizontalLayout:NO],
                                           [self labelYForHorizontalLayoutState:NO],
                                           labelSize.width, labelSize.height));
  }
  return CGRectStandardize(CGRectUnion(labelFrame, CGRectUnion(iconFrame, normalizedBadgeFrame)))
      .size;
}

- (void)centerAnchoredLayout {
  if ([self isTitleHiddenInAnchoredLayout]) {
    [self centerAnchoredLayoutHorizontal];
  } else {
    [self centerAnchoredLayoutVertical];
  }
}

- (void)centerAnchoredLayoutVertical {
  BOOL isRTL =
      self.effectiveUserInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft;

  CGPoint badgePosition = [self badgePositionForRTLState:isRTL];
  CGFloat badgeX = badgePosition.x;
  CGFloat badgeY = badgePosition.y;
  CGSize badgeSize = [self badgeSize];
  CGRect badgeFrame = CGRectIntegral(CGRectMake(badgeX, badgeY, badgeSize.width, badgeSize.height));
  _badge.frame = badgeFrame;

  CGPoint iconPosition = [self iconPosition];
  CGFloat iconX = iconPosition.x;
  CGFloat iconY = iconPosition.y;
  CGSize iconSize = [self iconSize];
  CGRect iconFrame = (CGRectMake(iconX, iconY, iconSize.width, iconSize.height));
  _iconImageView.frame = iconFrame;

  CGFloat labelX = [self labelXForRTLState:isRTL isHorizontalLayout:NO];
  CGFloat labelY = [self labelYForHorizontalLayoutState:NO];
  CGSize labelSize = [self labelSize];
  CGRect labelFrame = CGRectIntegral(CGRectMake(labelX, labelY, labelSize.width, labelSize.height));
  _label.frame = labelFrame;
}

- (void)centerAnchoredLayoutHorizontal {
  BOOL isRTL =
      self.effectiveUserInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft;

  CGPoint badgePosition = [self badgePositionForRTLState:isRTL];
  CGFloat badgeX = badgePosition.x;
  CGFloat badgeY = badgePosition.y;
  CGSize badgeSize = [self badgeSize];
  CGRect badgeFrame = CGRectIntegral(CGRectMake(badgeX, badgeY, badgeSize.width, badgeSize.height));
  _badge.frame = badgeFrame;

  CGPoint iconPosition = [self iconPosition];
  CGFloat iconX = iconPosition.x;
  CGFloat iconY = iconPosition.y;
  CGSize iconSize = [self iconSize];
  CGRect iconFrame = CGRectIntegral(CGRectMake(iconX, iconY, iconSize.width, iconSize.height));
  _iconImageView.frame = iconFrame;

  CGFloat labelX = [self labelXForHorizontalLayoutWithRTLState:isRTL];
  CGFloat labelY = [self labelYForHorizontalLayout];
  CGSize labelSize = [self labelSize];
  CGRect labelFrame = CGRectIntegral(CGRectMake(labelX, labelY, labelSize.width, labelSize.height));
  _label.frame = labelFrame;
}

- (CGSize)sizeThatFitsForHorizontalAnchoredLayout {
  MDCBadgeView *badge = _badge;
  BOOL isRTL =
      self.effectiveUserInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft;

  CGSize iconSize = [self iconSize];
  CGRect iconFrame = CGRectMake(0, 0, iconSize.width, iconSize.height);

  CGPoint badgePosition = [self badgePositionForRTLState:isRTL];
  CGFloat badgeX = badgePosition.x;
  CGFloat badgeY = badgePosition.y;

  CGRect normalizedBadgeFrame =
      CGRectIntegral(CGRectMake(badgeX, badgeY, badge.bounds.size.width, badge.bounds.size.height));
  CGSize labelSize = [self labelSize];
  CGRect labelFrame = CGRectMake(CGRectGetMaxX(iconFrame) + self.contentHorizontalMargin,
                                 floor(CGRectGetMidY(iconFrame) - labelSize.height / 2),
                                 labelSize.width, labelSize.height);
  return CGRectStandardize(CGRectUnion(labelFrame, CGRectUnion(iconFrame, normalizedBadgeFrame)))
      .size;
}

#pragma mark - traitCollection

// MDCBottomNavigationBarTitleVisibilitySelected is not available in GM3.
// In any given state, all labels are visible, OR all labels are hidden.

// (self.titleVisibility == MDCBottomNavigationBarTitleVisibilitySelected && !self.selected) is not
// checked because selection state is not a condition for label visibility in GM3.
- (BOOL)isTitleHiddenInAnchoredLayout {
  UITraitCollection *traitCollection = self.traitCollection;

  return traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact ||
         _titleVisibility == MDCBottomNavigationBarTitleVisibilityNever;
}

@end

NS_ASSUME_NONNULL_END
