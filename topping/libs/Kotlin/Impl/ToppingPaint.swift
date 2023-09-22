import Foundation
import ToppingIOSKotlinHelper
import UIKit

@objc
public class ToppingPaint : NSObject, TPaint {
    var font: UIFont
    var antiAlias = false
    var color = TColor.init(a: 255.0, r: 255.0, g: 255.0, b: 255.0)
    var strokeWidth = 1
    
    @objc
    public init(font: UIFont?) {
        if(font != nil) {
            self.font = font!
        }
        else {
            self.font = UIFont.systemFont(ofSize: UIFont.labelFontSize)
        }
    }

    @objc
    public func getTextBounds(text: String, start: Int32, end: Int32, bounds: Rect) {
        let toCalculate = text.substring(startIndex: Int(start), length: Int(end))
        let size = self.font.sizeOfString(string: toCalculate, constrainedToWidth: Double.infinity)
        bounds.set(left: 0, top: 0, right: size.width, bottom: size.height)
    }
    
    @objc
    public func setAntiAlias(value: Bool) {
        antiAlias = value
    }
    
    @objc
    public func setColor(color: TColor) {
        self.color = color
    }
    
    @objc
    public func setStrokeWidth(value: Int32) {
        self.strokeWidth = Int(value)
    }
}
