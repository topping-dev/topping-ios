import Foundation
import UIKit

@objc
public class LinearLayoutDialogController : DialogController {
    
    @objc public var context: LuaContext?
    @objc public var linearLayout: LGLinearLayout?
    @objc public var dialog: LuaComponentDialog?
    
    @objc
    public func initialize() {
        self.linearLayout = LGLinearLayout.create(self.context!)
        self.linearLayout!.android_layout_width = "wrap_content"
        self.linearLayout!.android_layout_height = "wrap_content"
        self.linearLayout!.android_layout_gravity = "center"
        self.linearLayout!.fullInit()
    }
    
    public override func loadView() {
        self.view = self.linearLayout!._view
    }
    
    @objc
    public func cancel() {
        dialog?.cancel()
    }
}
