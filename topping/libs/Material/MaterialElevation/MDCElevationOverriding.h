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
#import <Foundation/Foundation.h>

API_DEPRECATED_BEGIN("🤖👀 Use colors with dynamic providers that handle elevation instead. "
                     "See go/material-ios-color/gm2-migration and "
                     "go/material-ios-shadow/gm2-migration for more info. "
                     "This has go/material-ios-migrations#scriptable-potential 🤖👀.",
                     ios(12, 12))

/**
 Provides APIs for @c UIViews to communicate their elevation throughout the view hierarchy.
 */
@protocol MDCElevationOverriding

/**
 Used by @c MaterialElevationResponding instead of @c mdc_baseElevation.

 This can be used in cases where there is elevation behind an object that is not part of the
 view hierarchy, like a @c UIPresentationController.

 Note: If set to a negative value, this property is ignored as part of the @c mdc_baseElevation
 calculation.
 */
@property(nonatomic, assign, readwrite) CGFloat mdc_overrideBaseElevation;

@end

API_DEPRECATED_END
