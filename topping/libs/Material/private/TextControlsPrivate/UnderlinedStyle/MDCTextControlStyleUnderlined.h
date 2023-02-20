// Copyright 2020-present the Material Components for iOS authors. All Rights Reserved.
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

#import "MDCTextControl.h"

API_DEPRECATED_BEGIN(
    "🕘 Schedule time to migrate. "
    "Use branded UITextField or UITextView instead: go/material-ios-text-fields/gm2-migration. "
    "This is go/material-ios-migrations#not-scriptable 🕘",
    ios(12, 12))

/**
This style object is used by MDCTextControls adopting the Material Underlined style.
*/
@interface MDCTextControlStyleUnderlined : NSObject <MDCTextControlStyle>

/**
The thickness of the underline that shows in the normal and disabled states.
*/
@property(nonatomic, assign) CGFloat normalUnderlineThickness;

/**
The thickness of the underline that shows in the editing state.
*/
@property(nonatomic, assign) CGFloat editingUnderlineThickness;

/**
Sets the normal underline thickness.
@param thickness The thickness of the underline.
@param animated Determines whether or not the change is animated.
*/
- (void)setNormalUnderlineThickness:(CGFloat)thickness animated:(BOOL)animated;

/**
Sets the editing underline thickness.
@param thickness The thickness of the underline.
@param animated Determines whether or not the change is animated.
*/
- (void)setEditingUnderlineThickness:(CGFloat)thickness animated:(BOOL)animated;

/**
Sets the underline color color for a given state.
@param underlineColor The UIColor for the given state.
@param state The MDCTextControlState.
*/
- (void)setUnderlineColor:(nonnull UIColor *)underlineColor forState:(MDCTextControlState)state;

/**
Returns the underline color color for a given state.
@param state The MDCTextControlState.
*/
- (nonnull UIColor *)underlineColorForState:(MDCTextControlState)state;

@end

API_DEPRECATED_END
