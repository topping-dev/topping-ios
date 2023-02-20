// Copyright 2019-present the Material Components for iOS authors. All Rights Reserved.
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

#import "MDCBaseTextField.h"

#import <Foundation/Foundation.h>

#import "MDCTextControlLabelBehavior.h"
#import "MDCTextControlState.h"
#import "MDCTextControlStyleBase.h"
#import "MDCTextControl.h"
#import "MDCTextControlAssistiveLabelDrawPriority.h"

#import "MDCBaseTextFieldDelegate.h"
#import "MDCTextControlAssistiveLabelView.h"
#import "MDCTextControlColorViewModel.h"
#import "MDCTextControlHorizontalPositioning.h"
#import "MDCTextControlHorizontalPositioningReference.h"
#import "MDCTextControlLabelAnimation.h"
#import "MDCTextControlLabelSupport.h"
#import "MDCTextControlPlaceholderSupport.h"
#import "MDCBaseTextFieldLayout.h"
#import "MDCTextControlTextField.h"
#import "MDCTextControlTextFieldSideViewAlignment.h"

static char *const kKVOContextMDCBaseTextField = "kKVOContextMDCBaseTextField";

@interface MDCBaseTextField () <MDCTextControlTextField>

@property(strong, nonatomic) UILabel *label;
@property(nonatomic, strong) MDCTextControlAssistiveLabelView *assistiveLabelView;
@property(strong, nonatomic) MDCBaseTextFieldLayout *layout;
@property(nonatomic, assign) MDCTextControlState textControlState;
@property(nonatomic, assign) MDCTextControlLabelPosition labelPosition;
@property(nonatomic, assign) CGRect floatingLabelFrame;
@property(nonatomic, assign) CGRect normalLabelFrame;
@property(nonatomic, assign) CGFloat lastRecordedWidth;
@property(nonatomic, assign) CGFloat lastCalculatedHeight;
/**
 * This property is set in every layout cycle, in preLayoutSubviews, right after the current
 * labelPosition is determined . It's set to YES if the labelPosition changed and NO if it didn't.
 * It's referred to in animateLabel (called from postLayoutSubviews) when deciding on a label
 * animation duration. If it's NO, the label gets an animation duration of 0, to avoid buggy looking
 * frame/text animations. Otherwise, it uses the value in the animationDuration property.
 */
@property(nonatomic, assign) BOOL labelPositionChanged;

/**
 This property maps MDCTextControlStates as NSNumbers to
 MDCTextControlColorViewModels.
 */
@property(nonatomic, strong)
    NSMutableDictionary<NSNumber *, MDCTextControlColorViewModel *> *colorViewModels;

@end

@implementation MDCBaseTextField
@synthesize containerStyle = _containerStyle;
@synthesize assistiveLabelDrawPriority = _assistiveLabelDrawPriority;
@synthesize customAssistiveLabelDrawPriority = _customAssistiveLabelDrawPriority;

#pragma mark Object Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self commonMDCBaseTextFieldInit];
  }
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self) {
    [self commonMDCBaseTextFieldInit];
  }
  return self;
}

- (void)commonMDCBaseTextFieldInit {
  [self initializeProperties];
  [self setUpColorViewModels];
  [self setUpLabel];
  [self setUpAssistiveLabels];
  [self observeContentSizeCategoryNotifications];
  [self observeLabelKeyPaths];
}

- (void)dealloc {
  [self removeObservers];
}

#pragma mark View Setup

- (void)initializeProperties {
  self.animationDuration = kMDCTextControlDefaultAnimationDuration;
  self.labelBehavior = MDCTextControlLabelBehaviorFloats;
  self.labelPosition = [self determineCurrentLabelPosition];
  self.textControlState = [self determineCurrentTextControlState];
  self.containerStyle = [[MDCTextControlStyleBase alloc] init];
  self.colorViewModels = [[NSMutableDictionary alloc] init];
}

- (void)setUpColorViewModels {
  self.colorViewModels[@(MDCTextControlStateNormal)] =
      [[MDCTextControlColorViewModel alloc] initWithState:MDCTextControlStateNormal];
  self.colorViewModels[@(MDCTextControlStateEditing)] =
      [[MDCTextControlColorViewModel alloc] initWithState:MDCTextControlStateEditing];
  self.colorViewModels[@(MDCTextControlStateDisabled)] =
      [[MDCTextControlColorViewModel alloc] initWithState:MDCTextControlStateDisabled];
}

- (void)setUpAssistiveLabels {
  self.assistiveLabelDrawPriority = MDCTextControlAssistiveLabelDrawPriorityTrailing;
  self.assistiveLabelView = [[MDCTextControlAssistiveLabelView alloc] init];
  CGFloat assistiveFontSize = round([UIFont systemFontSize] * (CGFloat)0.75);
  UIFont *assistiveFont = [UIFont systemFontOfSize:assistiveFontSize];
  self.assistiveLabelView.leadingAssistiveLabel.font = assistiveFont;
  self.assistiveLabelView.trailingAssistiveLabel.font = assistiveFont;
  UIGestureRecognizer *tapGestureRecognizer =
      [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(becomeFirstResponder)];
  [self.assistiveLabelView addGestureRecognizer:tapGestureRecognizer];
  [self addSubview:self.assistiveLabelView];
}

- (void)setUpLabel {
  self.label = [[UILabel alloc] init];
  [self addSubview:self.label];
}

#pragma mark UIResponder Overrides

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
  BOOL canPerformAction = [super canPerformAction:action withSender:sender];
  if ([self.baseTextFieldDelegate
          respondsToSelector:@selector(baseTextField:
                                 shouldPerformAction:withSender:canPerformAction:)]) {
    return [self.baseTextFieldDelegate baseTextField:self
                                 shouldPerformAction:action
                                          withSender:sender
                                    canPerformAction:canPerformAction];
  }
  return canPerformAction;
}

#pragma mark UIView Overrides

- (void)layoutSubviews {
  [self preLayoutSubviews];
  [super layoutSubviews];
  [self postLayoutSubviews];
}

// UITextField's sizeToFit calls this method and then also calls setNeedsLayout.
// When the system calls this method the size parameter is the view's current size.
- (CGSize)sizeThatFits:(CGSize)size {
  return [self preferredSizeWithWidth:size.width];
}

- (CGSize)intrinsicContentSize {
  return [self preferredSizeWithWidth:CGRectGetWidth(self.bounds)];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
  [super traitCollectionDidChange:previousTraitCollection];
  [self setNeedsLayout];
}

- (void)setSemanticContentAttribute:(UISemanticContentAttribute)semanticContentAttribute {
  [super setSemanticContentAttribute:semanticContentAttribute];
  [self setNeedsLayout];
}

- (void)setBounds:(CGRect)bounds {
  [super setBounds:bounds];

  // I wouldn't think something like the following is necessary, but in light of b/173646979 I think
  // it is.
  CGFloat newWidth = CGRectGetWidth(bounds);
  BOOL widthHasChanged = newWidth != self.lastRecordedWidth;
  if (widthHasChanged) {
    [self setNeedsLayout];
  }
  self.lastRecordedWidth = CGRectGetWidth(bounds);
}

#pragma mark Layout

/**
 UITextField layout methods such as @c -textRectForBounds: and @c -editingRectForBounds: are called
 within @c -layoutSubviews. The exact values of the CGRects MDCBaseTextField returns from these
 methods depend on many factors, and are calculated alongside all the other frames of
 MDCBaseTextField's subviews. To ensure that these values are known before UITextField's layout
 methods expect them, they are determined by this method, which is called before the superclass's @c
 -layoutSubviews in the layout cycle.
 */
- (void)preLayoutSubviews {
  self.textControlState = [self determineCurrentTextControlState];
  MDCTextControlLabelPosition previousLabelPosition = self.labelPosition;
  self.labelPosition = [self determineCurrentLabelPosition];
  self.labelPositionChanged = previousLabelPosition != self.labelPosition;
  MDCTextControlColorViewModel *colorViewModel =
      [self textControlColorViewModelForState:self.textControlState];
  [self applyColorViewModel:colorViewModel withLabelPosition:self.labelPosition];
  CGSize fittingSize = CGSizeMake(CGRectGetWidth(self.bounds), CGFLOAT_MAX);
  self.layout = [self calculateLayoutWithTextFieldSize:fittingSize];
  self.normalLabelFrame = self.layout.labelFrameNormal;
  self.floatingLabelFrame = self.layout.labelFrameFloating;
}

- (void)postLayoutSubviews {
  self.label.hidden = self.labelPosition == MDCTextControlLabelPositionNone;
  self.assistiveLabelView.frame = self.layout.assistiveLabelViewFrame;
  self.assistiveLabelView.layout = self.layout.assistiveLabelViewLayout;
  [self.assistiveLabelView setNeedsLayout];
  [self animateLabel];
  [self updateSideViews];
  [self.containerStyle applyStyleToTextControl:self animationDuration:self.animationDuration];
  [self updateCalculatedHeight];
}

- (void)updateCalculatedHeight {
  if (self.layout.calculatedHeight != self.lastCalculatedHeight) {
    [self invalidateIntrinsicContentSize];
    if ([self.baseTextFieldDelegate respondsToSelector:@selector(baseTextField:
                                                           didUpdateIntrinsicHeight:)]) {
      [self.baseTextFieldDelegate baseTextField:self
                       didUpdateIntrinsicHeight:self.layout.calculatedHeight];
    }
  }
  self.lastCalculatedHeight = self.layout.calculatedHeight;
}

- (void)updateSideViews {
  if (self.layout.displaysLeadingView) {
    if (self.leadingView) {
      if (self.leadingView.superview != self) {
        [self addSubview:self.leadingView];
      }
      self.leadingView.frame = self.layout.leadingViewFrame;
    }
  } else {
    [self.leadingView removeFromSuperview];
  }

  if (self.layout.displaysTrailingView) {
    if (self.trailingView) {
      if (self.trailingView.superview != self) {
        [self addSubview:self.trailingView];
      }
      self.trailingView.frame = self.layout.trailingViewFrame;
    }
  } else {
    [self.trailingView removeFromSuperview];
  }
}

- (CGRect)textRectFromLayout:(MDCBaseTextFieldLayout *)layout
               labelPosition:(MDCTextControlLabelPosition)labelPosition {
  CGRect textRect = layout.textRectNormal;
  if (labelPosition == MDCTextControlLabelPositionFloating) {
    textRect = layout.textRectFloating;
  }
  return textRect;
}

/**
 To understand this method one must understand that the CGRect UITextField returns from @c
 -textRectForBounds: does not actually represent the CGRect of visible text in UITextField. It
 represents the CGRect of an internal "field editing" class, which has a height that is
 significantly taller than the text (@c font.lineHeight) itself. Providing a height in @c
 -textRectForBounds: that differs from the height determined by the superclass results in a text
 field with poor text rendering, sometimes to the point of the text not being visible. By taking the
 desired CGRect of the visible text from the layout object, giving it the height preferred by the
 superclass's implementation of @c -textRectForBounds:, and then ensuring that this new CGRect has
 the same midY as the original CGRect, we are able to take control of the text's positioning.
 */
- (CGRect)adjustTextAreaFrame:(CGRect)textRect
    withParentClassTextAreaFrame:(CGRect)parentClassTextAreaFrame {
  CGFloat systemDefinedHeight = CGRectGetHeight(parentClassTextAreaFrame);
  CGFloat minY = CGRectGetMidY(textRect) - (systemDefinedHeight * (CGFloat)0.5);
  return CGRectMake(CGRectGetMinX(textRect), minY, CGRectGetWidth(textRect), systemDefinedHeight);
}

- (MDCBaseTextFieldLayout *)calculateLayoutWithTextFieldSize:(CGSize)textFieldSize {
  CGFloat clampedCustomAssistiveLabelDrawPriority =
      [self clampedCustomAssistiveLabelDrawPriority:self.customAssistiveLabelDrawPriority];
  CGFloat clearButtonSideLength = [self clearButtonSideLengthWithTextFieldSize:textFieldSize];
  id<MDCTextControlVerticalPositioningReference> verticalPositioningReference =
      [self createVerticalPositioningReference];
  id<MDCTextControlHorizontalPositioning> horizontalPositioningReference =
      [self createHorizontalPositioningReference];
  return [[MDCBaseTextFieldLayout alloc]
                 initWithTextFieldSize:textFieldSize
                  positioningReference:verticalPositioningReference
        horizontalPositioningReference:horizontalPositioningReference
                                  text:self.text
                                  font:self.normalFont
                          floatingFont:self.floatingFont
                                 label:self.label
                         labelPosition:self.labelPosition
                         labelBehavior:self.labelBehavior
                     sideViewAlignment:self.sideViewAlignment
                           leadingView:self.leadingView
                       leadingViewMode:self.leadingViewMode
                          trailingView:self.trailingView
                      trailingViewMode:self.trailingViewMode
                 clearButtonSideLength:clearButtonSideLength
                       clearButtonMode:self.clearButtonMode
                 leadingAssistiveLabel:self.assistiveLabelView.leadingAssistiveLabel
                trailingAssistiveLabel:self.assistiveLabelView.trailingAssistiveLabel
            assistiveLabelDrawPriority:self.assistiveLabelDrawPriority
      customAssistiveLabelDrawPriority:clampedCustomAssistiveLabelDrawPriority
                                 isRTL:self.shouldLayoutForRTL
                             isEditing:self.isEditing];
}

- (id<MDCTextControlHorizontalPositioning>)createHorizontalPositioningReference {
  id<MDCTextControlHorizontalPositioning> horizontalPositioningReference =
      self.containerStyle.horizontalPositioningReference;
  if (self.leadingEdgePaddingOverride) {
    horizontalPositioningReference.leadingEdgePadding =
        (CGFloat)[self.leadingEdgePaddingOverride doubleValue];
  }
  if (self.trailingEdgePaddingOverride) {
    horizontalPositioningReference.trailingEdgePadding =
        (CGFloat)[self.trailingEdgePaddingOverride doubleValue];
  }
  if (self.horizontalInterItemSpacingOverride) {
    horizontalPositioningReference.horizontalInterItemSpacing =
        (CGFloat)[self.horizontalInterItemSpacingOverride doubleValue];
  }
  return horizontalPositioningReference;
}

- (id<MDCTextControlVerticalPositioningReference>)createVerticalPositioningReference {
  return [self.containerStyle
      positioningReferenceWithFloatingFontLineHeight:self.floatingFont.lineHeight
                                normalFontLineHeight:self.normalFont.lineHeight
                                       textRowHeight:self.normalFont.lineHeight
                                    numberOfTextRows:self.numberOfLinesOfVisibleText
                                             density:self.verticalDensity
                            preferredContainerHeight:self.preferredContainerHeight
                              isMultilineTextControl:NO];
}

- (CGFloat)clampedCustomAssistiveLabelDrawPriority:(CGFloat)customPriority {
  CGFloat value = customPriority;
  if (value < 0) {
    value = 0;
  } else if (value > 1) {
    value = 1;
  }
  return value;
}

- (CGFloat)clearButtonSideLengthWithTextFieldSize:(CGSize)textFieldSize {
  CGRect bounds = CGRectMake(0, 0, textFieldSize.width, textFieldSize.height);
  CGRect systemPlaceholderRect = [super clearButtonRectForBounds:bounds];
  return systemPlaceholderRect.size.height;
}

- (CGSize)preferredSizeWithWidth:(CGFloat)width {
  CGSize fittingSize = CGSizeMake(width, CGFLOAT_MAX);
  MDCBaseTextFieldLayout *layout = [self calculateLayoutWithTextFieldSize:fittingSize];
  return CGSizeMake(width, layout.calculatedHeight);
}

- (BOOL)shouldLayoutForRTL {
  if (self.semanticContentAttribute == UISemanticContentAttributeForceRightToLeft) {
    return YES;
  } else if (self.semanticContentAttribute == UISemanticContentAttributeForceLeftToRight) {
    return NO;
  } else {
    return self.effectiveUserInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft;
  }
}

#pragma mark UITextField Accessor Overrides

- (void)setEnabled:(BOOL)enabled {
  [super setEnabled:enabled];

  [self setNeedsLayout];
}

- (void)setLeftViewMode:(UITextFieldViewMode)leftViewMode {
  self.leadingViewMode = leftViewMode;
}

- (UITextFieldViewMode)leftViewMode {
  return self.leadingViewMode;
}

- (void)setRightViewMode:(UITextFieldViewMode)rightViewMode {
  self.trailingViewMode = rightViewMode;
}

- (UITextFieldViewMode)rightViewMode {
  return self.trailingViewMode;
}

/**
 RTL behavior appears to have been added to UITextField some time after the leftView and rightView
 properties. As a result, things don't always behave how one might expect. The values returned from
 -leftViewRectForBounds: and -rightViewRectForBounds: can sometimes be ignored in RTL locales, or
 when semanticContentAttribute is set. To get around this strange behavior from the superclass we
 manage our own leading and trailing views. The setters for the original UITextField leftView and
 rightView properties get forwarded to the setters for leadingView and trailingView, respectively.
 In RTL, -setRightView: will call -setTrailingView:, which will result in a view that gets rendered
 on the left edge of the view, which is consistent with how UITextField behaves.
*/
- (void)setRightView:(UIView *)rightView {
  self.trailingView = rightView;
}

- (UIView *)rightView {
  return self.trailingView;
}

- (void)setLeftView:(UIView *)leftView {
  self.leadingView = leftView;
}

- (UIView *)leftView {
  return self.leadingView;
}

#pragma mark Custom Accessors

- (void)setLeadingEdgePaddingOverride:(NSNumber *)leadingEdgePaddingOverride {
  _leadingEdgePaddingOverride = leadingEdgePaddingOverride;
  [self setNeedsLayout];
}

- (void)setTrailingEdgePaddingOverride:(NSNumber *)trailingEdgePaddingOverride {
  _trailingEdgePaddingOverride = trailingEdgePaddingOverride;
  [self setNeedsLayout];
}

- (UILabel *)leadingAssistiveLabel {
  return self.assistiveLabelView.leadingAssistiveLabel;
}

- (UILabel *)trailingAssistiveLabel {
  return self.assistiveLabelView.trailingAssistiveLabel;
}

- (void)setTrailingView:(UIView *)trailingView {
  [_trailingView removeFromSuperview];
  _trailingView = trailingView;
  [self setNeedsLayout];
}

- (void)setLeadingView:(UIView *)leadingView {
  [_leadingView removeFromSuperview];
  _leadingView = leadingView;
  [self setNeedsLayout];
}

- (void)setTrailingViewMode:(UITextFieldViewMode)trailingViewMode {
  _trailingViewMode = trailingViewMode;
  [self setNeedsLayout];
}

- (void)setLeadingViewMode:(UITextFieldViewMode)leadingViewMode {
  _leadingViewMode = leadingViewMode;
  [self setNeedsLayout];
}

- (void)setVerticalDensity:(CGFloat)verticalDensity {
  _verticalDensity = verticalDensity;
  [self setNeedsLayout];
}

#pragma mark MDCTextControl accessors

- (void)setLabelBehavior:(MDCTextControlLabelBehavior)labelBehavior {
  if (_labelBehavior == labelBehavior) {
    return;
  }
  _labelBehavior = labelBehavior;
  [self setNeedsLayout];
}

- (void)setContainerStyle:(id<MDCTextControlStyle>)containerStyle {
  id<MDCTextControlStyle> oldStyle = _containerStyle;
  if (oldStyle) {
    [oldStyle removeStyleFrom:self];
  }
  _containerStyle = containerStyle;
  [_containerStyle applyStyleToTextControl:self animationDuration:0];
}

- (CGRect)containerFrame {
  return CGRectMake(0, 0, CGRectGetWidth(self.bounds), self.layout.containerHeight);
}

- (CGFloat)numberOfLinesOfVisibleText {
  return 1;
}

#pragma mark UITextField Layout Overrides

- (CGRect)textRectForBounds:(CGRect)bounds {
  CGRect textRect = [self textRectFromLayout:self.layout labelPosition:self.labelPosition];
  return [self adjustTextAreaFrame:textRect
      withParentClassTextAreaFrame:[super textRectForBounds:bounds]];
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
  CGRect textRect = [self textRectFromLayout:self.layout labelPosition:self.labelPosition];
  return [self adjustTextAreaFrame:textRect
      withParentClassTextAreaFrame:[super editingRectForBounds:bounds]];
}

- (CGRect)borderRectForBounds:(CGRect)bounds {
  if (!self.containerStyle) {
    return [super borderRectForBounds:bounds];
  }
  return CGRectZero;
}

- (CGRect)clearButtonRectForBounds:(CGRect)bounds {
  return self.layout.clearButtonFrame;
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds {
  if (self.shouldPlaceholderBeVisible) {
    return [super placeholderRectForBounds:bounds];
  }
  return CGRectZero;
}

#pragma mark UITextField Drawing Overrides

- (void)drawPlaceholderInRect:(CGRect)rect {
  if (self.shouldPlaceholderBeVisible) {
    [super drawPlaceholderInRect:rect];
  }
}

#pragma mark Fonts

- (UIFont *)normalFont {
  return self.font ?: MDCTextControlDefaultUITextFieldFont();
}

- (UIFont *)floatingFont {
  return [self.containerStyle floatingFontWithNormalFont:self.normalFont];
}

#pragma mark Dynamic Type

- (void)setAdjustsFontForContentSizeCategory:(BOOL)adjustsFontForContentSizeCategory {
  [super setAdjustsFontForContentSizeCategory:adjustsFontForContentSizeCategory];
  self.leadingAssistiveLabel.adjustsFontForContentSizeCategory = adjustsFontForContentSizeCategory;
  self.trailingAssistiveLabel.adjustsFontForContentSizeCategory = adjustsFontForContentSizeCategory;
}

- (void)observeContentSizeCategoryNotifications {
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(contentSizeCategoryDidChange:)
                                               name:UIContentSizeCategoryDidChangeNotification
                                             object:nil];
}

- (void)contentSizeCategoryDidChange:(NSNotification *)notification {
  [self setNeedsLayout];
}

#pragma mark MDCTextControlState

- (MDCTextControlState)determineCurrentTextControlState {
  return MDCTextControlStateWith(self.isEnabled, self.isEditing);
}

#pragma mark Placeholder

- (BOOL)shouldPlaceholderBeVisible {
  return MDCTextControlShouldPlaceholderBeVisibleWithPlaceholder(self.placeholder, self.text,
                                                                 self.labelPosition);
}

#pragma mark Label

- (void)animateLabel {
  NSTimeInterval animationDuration = self.labelPositionChanged ? self.animationDuration : 0.0f;
  __weak MDCBaseTextField *weakSelf = self;
  [MDCTextControlLabelAnimation animateLabel:self.label
                                       state:self.labelPosition
                            normalLabelFrame:self.layout.labelFrameNormal
                          floatingLabelFrame:self.layout.labelFrameFloating
                                  normalFont:self.normalFont
                                floatingFont:self.floatingFont
                    labelTruncationIsPresent:self.layout.labelTruncationIsPresent
                           animationDuration:animationDuration
                                  completion:^(BOOL finished) {
                                    if (finished) {
                                      // Ensure that the label position is correct in case of
                                      // competing animations.
                                      weakSelf.label.frame = [weakSelf.layout
                                          labelFrameWithLabelPosition:self.labelPosition];
                                    }
                                  }];
}

- (BOOL)canLabelFloat {
  return self.labelBehavior == MDCTextControlLabelBehaviorFloats;
}

- (MDCTextControlLabelPosition)determineCurrentLabelPosition {
  return MDCTextControlLabelPositionWith(self.label.text.length > 0, self.text.length > 0,
                                         self.canLabelFloat, self.isEditing);
}

#pragma mark Coloring

- (void)applyColorViewModel:(MDCTextControlColorViewModel *)colorViewModel
          withLabelPosition:(MDCTextControlLabelPosition)labelPosition {
  UIColor *labelColor = [UIColor clearColor];
  if (labelPosition == MDCTextControlLabelPositionNormal) {
    labelColor = colorViewModel.normalLabelColor;
  } else if (labelPosition == MDCTextControlLabelPositionFloating) {
    labelColor = colorViewModel.floatingLabelColor;
  }
  if (![self.textColor isEqual:colorViewModel.textColor]) {
    self.textColor = colorViewModel.textColor;
  }
  if (![self.leadingAssistiveLabel.textColor isEqual:colorViewModel.leadingAssistiveLabelColor]) {
    self.leadingAssistiveLabel.textColor = colorViewModel.leadingAssistiveLabelColor;
  }
  if (![self.trailingAssistiveLabel.textColor isEqual:colorViewModel.trailingAssistiveLabelColor]) {
    self.trailingAssistiveLabel.textColor = colorViewModel.trailingAssistiveLabelColor;
  }
  if (![self.label.textColor isEqual:labelColor]) {
    self.label.textColor = labelColor;
  }
}

- (void)setTextControlColorViewModel:(MDCTextControlColorViewModel *)colorViewModel
                            forState:(MDCTextControlState)textControlState {
  if (colorViewModel) {
    self.colorViewModels[@(textControlState)] = colorViewModel;
  }
}

- (MDCTextControlColorViewModel *)textControlColorViewModelForState:
    (MDCTextControlState)textControlState {
  MDCTextControlColorViewModel *colorViewModel = self.colorViewModels[@(textControlState)];
  if (!colorViewModel) {
    colorViewModel = [[MDCTextControlColorViewModel alloc] initWithState:textControlState];
  }
  return colorViewModel;
}

#pragma mark MDCTextControlTextField

- (MDCTextControlTextFieldSideViewAlignment)sideViewAlignment {
  return MDCTextControlTextFieldSideViewAlignmentCenteredInContainer;
}

#pragma mark Accessibility Overrides

- (NSInteger)accessibilityElementCount {
  if (self.isAccessibilityElement) {
    return [super accessibilityElementCount];
  } else {
    return [self accessibilityElements].count;
  }
}

- (NSString *)accessibilityLabel {
  if (self.isAccessibilityElement) {
    NSString *superAccessibilityLabel = [super accessibilityLabel];
    if (superAccessibilityLabel.length > 0) {
      return superAccessibilityLabel;
    }

    NSMutableArray *accessibilityLabelComponents = [[NSMutableArray alloc] init];
    if (self.label.text.length > 0) {
      [accessibilityLabelComponents addObject:self.label.text];
    }
    if (self.leadingAssistiveLabel.text.length > 0) {
      [accessibilityLabelComponents addObject:self.leadingAssistiveLabel.text];
    }
    if (self.trailingAssistiveLabel.text.length > 0) {
      [accessibilityLabelComponents addObject:self.trailingAssistiveLabel.text];
    }

    if (accessibilityLabelComponents.count > 0) {
      return [accessibilityLabelComponents componentsJoinedByString:@", "];
    }

    return nil;
  } else {
    return [super accessibilityLabel];
  }
}

- (NSString *)accessibilityValue {
  NSString *accessibilityValue = [super accessibilityValue];
  NSString *accessibilityLabel = [self accessibilityLabel];
  // Voice Over reads both the accessibility label and the accessibility value in succession.
  // If no value is set on the text field, the accessibility value will be the placeholder.
  // This means that if a placeholder is set and it is equal to the label text
  // Voice Over will read the same string twice. Ex, "Label, Label, Text Field". This is
  // confusing to the user, so if we determine this to be case, we manually return an empty
  // accessibility value.
  if (accessibilityLabel && [accessibilityValue isEqualToString:accessibilityLabel] &&
      self.text.length == 0) {
    // We need to return empty string rather than nil,
    // otherwise Voice Over seems to still read a value.
    accessibilityValue = @"";
  }
  return accessibilityValue;
}

- (NSArray *)accessibilityElements {
  if (self.isAccessibilityElement) {
    return [super accessibilityElements];
  } else {
    NSMutableArray *mutableElements = [[super accessibilityElements] mutableCopy];
    if (self.label.isAccessibilityElement &&
        self.labelPosition != MDCTextControlLabelPositionNone) {
      // The label should be before the system text field element
      [mutableElements insertObject:self.label atIndex:0];
    }
    if (self.leadingView.isAccessibilityElement && self.leadingView.superview == self) {
      // The leading view should be first if it's there
      [mutableElements insertObject:self.leadingView atIndex:0];
    }
    if (self.trailingView.isAccessibilityElement && self.trailingView.superview == self) {
      // The trailing view should be after the system text field element or clear button if it's
      // there
      [mutableElements addObject:self.trailingView];
    }
    if (self.leadingAssistiveLabel.isAccessibilityElement) {
      [mutableElements addObject:self.leadingAssistiveLabel];
    }
    if (self.trailingAssistiveLabel.isAccessibilityElement) {
      [mutableElements addObject:self.trailingAssistiveLabel];
    }
    return [mutableElements copy];
  }
}

- (UIBezierPath *)accessibilityPath {
  return [UIBezierPath bezierPathWithRect:self.accessibilityFrame];
}

- (CGRect)accessibilityFrame {
  if (self.window) {
    CGRect bounds = self.bounds;
    CGFloat boundsMinY = CGRectGetMinY(bounds);
    CGFloat floatingLabelMinY = CGRectGetMinY(self.layout.labelFrameFloating);
    if (floatingLabelMinY < boundsMinY) {
      CGFloat difference = boundsMinY - floatingLabelMinY;
      bounds.origin.y = boundsMinY - difference;
      bounds.size.height = bounds.size.height + difference;
    }
    return [self convertRect:bounds toCoordinateSpace:self.window.screen.coordinateSpace];
  } else {
    return [super accessibilityFrame];
  }
}

#pragma mark Color Accessors

- (void)setNormalLabelColor:(nonnull UIColor *)labelColor forState:(MDCTextControlState)state {
  MDCTextControlColorViewModel *colorViewModel = [self textControlColorViewModelForState:state];
  colorViewModel.normalLabelColor = labelColor;
  [self setNeedsLayout];
}

- (UIColor *)normalLabelColorForState:(MDCTextControlState)state {
  MDCTextControlColorViewModel *colorViewModel = [self textControlColorViewModelForState:state];
  return colorViewModel.normalLabelColor;
}

- (void)setFloatingLabelColor:(nonnull UIColor *)labelColor forState:(MDCTextControlState)state {
  MDCTextControlColorViewModel *colorViewModel = [self textControlColorViewModelForState:state];
  colorViewModel.floatingLabelColor = labelColor;
  [self setNeedsLayout];
}

- (UIColor *)floatingLabelColorForState:(MDCTextControlState)state {
  MDCTextControlColorViewModel *colorViewModel = [self textControlColorViewModelForState:state];
  return colorViewModel.floatingLabelColor;
}

- (void)setTextColor:(nonnull UIColor *)labelColor forState:(MDCTextControlState)state {
  MDCTextControlColorViewModel *colorViewModel = [self textControlColorViewModelForState:state];
  colorViewModel.textColor = labelColor;
  [self setNeedsLayout];
}

- (UIColor *)textColorForState:(MDCTextControlState)state {
  MDCTextControlColorViewModel *colorViewModel = [self textControlColorViewModelForState:state];
  return colorViewModel.textColor;
}

- (void)setLeadingAssistiveLabelColor:(nonnull UIColor *)leadingAssistiveLabelColor
                             forState:(MDCTextControlState)state {
  MDCTextControlColorViewModel *colorViewModel = [self textControlColorViewModelForState:state];
  colorViewModel.leadingAssistiveLabelColor = leadingAssistiveLabelColor;
  [self setNeedsLayout];
}

- (nonnull UIColor *)leadingAssistiveLabelColorForState:(MDCTextControlState)state {
  MDCTextControlColorViewModel *colorViewModel = [self textControlColorViewModelForState:state];
  return colorViewModel.leadingAssistiveLabelColor;
}

- (void)setTrailingAssistiveLabelColor:(nonnull UIColor *)trailingAssistiveLabelColor
                              forState:(MDCTextControlState)state {
  MDCTextControlColorViewModel *colorViewModel = [self textControlColorViewModelForState:state];
  colorViewModel.trailingAssistiveLabelColor = trailingAssistiveLabelColor;
  [self setNeedsLayout];
}

- (nonnull UIColor *)trailingAssistiveLabelColorForState:(MDCTextControlState)state {
  MDCTextControlColorViewModel *colorViewModel = [self textControlColorViewModelForState:state];
  return colorViewModel.trailingAssistiveLabelColor;
}

#pragma mark UIKeyInput

- (void)deleteBackward {
  BOOL shouldDeleteBackward = YES;
  if ([self.baseTextFieldDelegate
          respondsToSelector:@selector(baseTextFieldShouldDeleteBackward:)]) {
    shouldDeleteBackward = [self.baseTextFieldDelegate baseTextFieldShouldDeleteBackward:self];
  }

  if (shouldDeleteBackward) {
    [super deleteBackward];
    if ([self.baseTextFieldDelegate
            respondsToSelector:@selector(baseTextFieldDidDeleteBackward:)]) {
      [self.baseTextFieldDelegate baseTextFieldDidDeleteBackward:self];
    }
  }
}

#pragma mark - Key-value observing

- (void)observeLabelKeyPaths {
  for (NSString *keyPath in [MDCBaseTextField assistiveLabelKeyPaths]) {
    [self.leadingAssistiveLabel addObserver:self
                                 forKeyPath:keyPath
                                    options:NSKeyValueObservingOptionNew
                                    context:kKVOContextMDCBaseTextField];
    [self.trailingAssistiveLabel addObserver:self
                                  forKeyPath:keyPath
                                     options:NSKeyValueObservingOptionNew
                                     context:kKVOContextMDCBaseTextField];
  }
  for (NSString *keyPath in [MDCBaseTextField labelKeyPaths]) {
    [self.label addObserver:self
                 forKeyPath:keyPath
                    options:NSKeyValueObservingOptionNew
                    context:kKVOContextMDCBaseTextField];
  }
}

- (void)removeObservers {
  for (NSString *keyPath in [MDCBaseTextField assistiveLabelKeyPaths]) {
    [self.leadingAssistiveLabel removeObserver:self
                                    forKeyPath:keyPath
                                       context:kKVOContextMDCBaseTextField];
    [self.trailingAssistiveLabel removeObserver:self
                                     forKeyPath:keyPath
                                        context:kKVOContextMDCBaseTextField];
  }
  for (NSString *keyPath in [MDCBaseTextField labelKeyPaths]) {
    [self.label removeObserver:self forKeyPath:keyPath context:kKVOContextMDCBaseTextField];
  }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey, id> *)change
                       context:(void *)context {
  if (context == kKVOContextMDCBaseTextField) {
    if (object == self.leadingAssistiveLabel || object == self.trailingAssistiveLabel) {
      for (NSString *labelKeyPath in [MDCBaseTextField assistiveLabelKeyPaths]) {
        if ([labelKeyPath isEqualToString:keyPath]) {
          [self setNeedsLayout];
          break;
        }
      }
    } else if (object == self.label)
      for (NSString *labelKeyPath in [MDCBaseTextField labelKeyPaths]) {
        if ([labelKeyPath isEqualToString:keyPath]) {
          [self setNeedsLayout];
          break;
        }
      }
  }
}

+ (NSArray<NSString *> *)assistiveLabelKeyPaths {
  static NSArray<NSString *> *keyPaths = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    keyPaths = @[
      NSStringFromSelector(@selector(text)),
      NSStringFromSelector(@selector(font)),
    ];
  });
  return keyPaths;
}

+ (NSArray<NSString *> *)labelKeyPaths {
  static NSArray<NSString *> *keyPaths = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    keyPaths = @[
      NSStringFromSelector(@selector(text)),
    ];
  });
  return keyPaths;
}

@end
