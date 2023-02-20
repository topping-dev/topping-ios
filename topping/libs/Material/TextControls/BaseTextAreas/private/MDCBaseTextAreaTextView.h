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

API_DEPRECATED_BEGIN(
    "🕘 Schedule time to migrate. "
    "Use branded UITextField or UITextView instead: go/material-ios-text-fields/gm2-migration. "
    "This is go/material-ios-migrations#not-scriptable 🕘",
    ios(12, 12))

@class MDCBaseTextAreaTextView;

/**
 This protocol allows the MDCBaseTextAreaTextView to inform the text area of important responder
 events.
 */
@protocol MDCBaseTextAreaTextViewDelegate <NSObject>

/**
This method is called when the text view is about to become the first responder.
 */
- (void)textAreaTextView:(nonnull MDCBaseTextAreaTextView *)textView
    willBecomeFirstResponder:(BOOL)willBecome;

/**
This method is called when the text view is about to resign the first responder.
 */
- (void)textAreaTextView:(nonnull MDCBaseTextAreaTextView *)textView
    willResignFirstResponder:(BOOL)willResign;
@end

/**
This private UITextView subclass is used by the MDCBaseTextArea to handle multi-line text
 */
@interface MDCBaseTextAreaTextView : UITextView

/**
 A delegate conforming to MDCBaseTextAreaTextViewDelegate
 */
@property(nonatomic, weak, nullable) id<MDCBaseTextAreaTextViewDelegate> textAreaTextViewDelegate;
@end

API_DEPRECATED_END
