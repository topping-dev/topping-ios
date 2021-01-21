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
    open var logo: IconButton? = nil
    {
        didSet
        {
            if(self.toolbar?.centerViews.count == 0)
            {
                self.toolbar?.centerViews.append(self.logo!)
            }
        }
    }
    
    @objc
    open var title: String? = nil
    {
        didSet
        {
            self.toolbar?.titleLabel.text = self.title
        }
    }
    
    @objc
    open var titleTextColor: UIColor? = nil
    {
        didSet
        {
            self.toolbar?.titleLabel.textColor = self.titleTextColor
        }
    }
    
    @objc
    open var titleTextAppearance: LuaTextViewAppearance? = nil
    {
        didSet
        {
            self.toolbar?.titleLabel.font = self.titleTextAppearance!.font
            self.toolbar?.titleLabel.fontSize = self.titleTextAppearance!.textSize
            self.toolbar?.titleLabel.textColor = self.titleTextAppearance!.color
        }
    }
    
    @objc
    open var subtitle: String? = nil
    {
        didSet
        {
            self.toolbar?.detailLabel.text = self.subtitle
        }
    }
    
    @objc
    open var subtitleTextColor: UIColor? = nil
    {
        didSet
        {
            self.toolbar?.detailLabel.textColor = self.subtitleTextColor
        }
    }
    
    @objc
    open var subtitleTextAppearance: LuaTextViewAppearance? = nil
    {
        didSet
        {
            self.toolbar?.detailLabel.font = self.subtitleTextAppearance!.font
            self.toolbar?.detailLabel.fontSize = self.subtitleTextAppearance!.textSize
            self.toolbar?.detailLabel.textColor = self.subtitleTextAppearance!.color
        }
    }
    
    @objc
    open func getView() -> Toolbar {
        return self.toolbar!
    }
}
