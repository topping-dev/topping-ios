import UIKit
import Material

@objc(LuaToolbar)
open class LuaToolbar: NSObject {
    var toolbar:Toolbar? = nil;
    
    @objc
    open func `init`(frame:CGRect) -> Toolbar {
        self.toolbar = Toolbar()
        self.toolbar?.frame = frame
        return self.toolbar!
    }
        
    @objc
    open var leftViews: [UIView] = []
    {
        didSet
        {
            self.toolbar?.leftViews = self.leftViews;
        }
    }
    
    @objc
    open var rightViews: [UIView] = []
    {
        didSet
        {
            self.toolbar?.leftViews = self.leftViews;
        }
    }
    
    @objc
    open func getView() -> Toolbar {
        return self.toolbar!
    }
}
