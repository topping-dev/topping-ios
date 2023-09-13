import Foundation
import IOSKotlinHelper
import UIKit

@objc
public class ToppingDisplay : NSObject, TDisplay {
    @objc
    public func getRotation() -> Int32 {
        let ori = UIDevice.current.orientation;
        
        switch(ori) {
        case UIDeviceOrientation.landscapeLeft:
            return 1
        case UIDeviceOrientation.portraitUpsideDown:
            return 2
        case UIDeviceOrientation.faceDown:
            return 2
        case UIDeviceOrientation.landscapeRight:
            return 3
        default:
            return 0
        }
    }
}
