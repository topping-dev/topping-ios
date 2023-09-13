import Foundation
import IOSKotlinHelper

@objc(ToppingClass)
public class ToppingClass : NSObject, TClass {
    var cls: AnyClass
    
    @objc
    public init(cls: AnyClass) {
        self.cls = cls
    }
    
    @objc
    public func getName() -> String {
        return NSStringFromClass(self.cls)
    }
    
    @objc
    public func getSimpleName() -> String {
        return NSStringFromClass(self.cls)
    }
}
