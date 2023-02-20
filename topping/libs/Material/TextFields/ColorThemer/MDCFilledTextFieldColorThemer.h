// Copyright 2018-present the Material Components for iOS authors. All Rights Reserved.
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

#import <Foundation/Foundation.h>

@class MDCTextInputControllerFilled;
@protocol MDCColorScheming;

API_DEPRECATED_BEGIN(
    "🕘 Schedule time to migrate. "
    "Use branded UITextField or UITextView instead: go/material-ios-text-fields/gm2-migration. "
    "This is go/material-ios-migrations#not-scriptable 🕘",
    ios(12, 12))

/**
 The Material Design color system's filled text field themer.

 @warning This API will eventually be deprecated. See the individual method documentation for
 details on replacement APIs.
 Learn more at docs/theming.md#migration-guide-themers-to-theming-extensions
 */
@interface MDCFilledTextFieldColorThemer : NSObject
@end

@interface MDCFilledTextFieldColorThemer (ToBeDeprecated)

/**
 Applies a color scheme's properties to a text field using the filled style.

 @param colorScheme The color scheme to apply to the component instance.
 @param textInputControllerFilled A component instance to which the color scheme should be applied.

 @warning This API will eventually be deprecated. The replacement API is:
 `MDCTextInputControllerFilled`'s `-applyThemeWithScheme:`
 Learn more at docs/theming.md#migration-guide-themers-to-theming-extensions
 */
+ (void)applySemanticColorScheme:(nonnull id<MDCColorScheming>)colorScheme
     toTextInputControllerFilled:(nonnull MDCTextInputControllerFilled *)textInputControllerFilled;

@end

API_DEPRECATED_END
