import Foundation
import Toaster

@objc(LuaToaster)
open class LuaToaster: NSObject {
    var toast:Toast;
    
    @objc
    public init(text: String?, delay: TimeInterval = 0, duration: TimeInterval = Delay.short)
    {
        self.toast = Toast(text: text, delay : delay, duration: duration)
    }
    
    @objc
    public func showToast()
    {
        toast.show()
    }
}

