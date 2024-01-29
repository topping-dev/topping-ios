import Foundation
import ToppingIOSKotlinHelper
import UIKit

@objc
public class ToppingPaint : SkiaPaint {
    public var fontInternal: UIFont? = nil
    
    @objc
    public init(fontInternal: UIFont?) {
        super.init(skia: SkikoPaint())
        if(fontInternal != nil) {
            self.fontInternal = fontInternal!
        }
        else {
            self.fontInternal = UIFont.systemFont(ofSize: UIFont.labelFontSize)
        }
    }

    @objc
    public override func getTextBounds(text: String, start: Int32, end: Int32, bounds: Rect) {
        if(fontInternal == nil) {
            bounds.setEmpty()
            return
        }
        let toCalculate = text.substring(startIndex: Int(start), length: Int(end))
        let size = self.fontInternal!.sizeOfString(string: toCalculate, constrainedToWidth: Double.infinity)
        bounds.set(left: 0, top: 0, right: size.width, bottom: size.height)
    }
}
