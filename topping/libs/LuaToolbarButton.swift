import UIKit
import Material

@objc(LuaToolbarButton)
open class LuaToolbarButton: NSObject {
    var toolbarButton:IconButton? = nil;
    
    @objc
    open func `init`(image:UIImage?) -> LuaToolbarButton {
        self.toolbarButton = IconButton(image: image)
        return self
    }
    
    @objc
    open func `init`(ic:IconButton?) -> LuaToolbarButton {
        self.toolbarButton = ic
        return self
    }
    
    @objc
    open var image: UIImage? = nil
    {
        didSet
        {
            self.toolbarButton!.image = self.image
        }
    }
        
    @objc
    open var tintColor: UIColor? = nil
    {
        didSet
        {
            self.toolbarButton!.tintColor = self.tintColor
        }
    }
    
    @objc
    open func getView() -> IconButton {
        return self.toolbarButton!
    }
}
