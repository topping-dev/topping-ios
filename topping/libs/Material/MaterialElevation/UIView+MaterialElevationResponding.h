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

#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

API_DEPRECATED_BEGIN("🤖👀 Use colors with dynamic providers that handle elevation instead. "
                     "See go/material-ios-color/gm2-migration and "
                     "go/material-ios-elevation/gm2-migration for more info. "
                     "This has go/material-ios-migrations#scriptable-potential 🤖👀.",
                     ios(12, 12))

/**
 Allows elevation changes to propagate down the view hierarchy and allows objects conforming to
 @c MDCElevatable to react to those changes accordingly.
 */
@interface UIView (MaterialElevationResponding)

/**
 Returns the sum of all @c mdc_currentElevation of the superviews going up the view hierarchy
 recursively.

 If a view in the hierarchy conforms to @c MDCElevationOveriding and  @c mdc_overrideBaseElevation
 is non-negative, then  the sum of the current total plus the value of @c mdc_overrideBaseElevation
 is returned.

 If a @c UIViewController conforms to @c MDCElevatable or @c MDCElevationOveriding then its @c view
 will report the view controllers base elevation.
 */
@property(nonatomic, assign, readonly) CGFloat mdc_baseElevation;

/**
 Returns the sum of the view's @c mdc_currentElevation with the @c mdc_currentElevation of its
 superviews going up the view hierarchy recursively.

 This value is effectively the sum of @c mdc_baseElevation and @c mdc_currentElevation.
 */
@property(nonatomic, assign, readonly) CGFloat mdc_absoluteElevation;

/**
 Should be called when the view's @c mdc_currentElevation has changed. Will be called on the
 receiver's @c subviews.

 If a @c UIView views conform to @c MDCElevation then @c mdc_elevationDidChangeBlock: is called.
 */
- (void)mdc_elevationDidChange;

@end

API_DEPRECATED_END
