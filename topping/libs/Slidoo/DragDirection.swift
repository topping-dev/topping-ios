//
//  DragDirection.swift
//  Slidoo
//
//  Created by Mitul Manish on 14/1/19.
//

import CoreGraphics

enum DragDirection {
    case left, right

    init(viewWidth: CGFloat, translationX: CGFloat, isRTL: Bool) {
        let halfViewWidth = abs(viewWidth / 2.0)
        if isRTL {
            self = (viewWidth - translationX) <= halfViewWidth ? .right : .left
        } else {
            self = (viewWidth + translationX) >= halfViewWidth ? .right : .left
        }
    }
}
