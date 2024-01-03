import Foundation
import ToppingIOSKotlinHelper
import SwiftUI

@objc
public class ToppingResources : NSObject, TResources {
    var _configuration: Configuration
    
    @objc
    public override init() {
        _configuration = Configuration()
        super.init()
        initConfig()
    }
    
    @objc
    public func getConfiguration() -> Configuration {
        return _configuration
    }
    
    @objc
    public func initConfig() {
        _configuration = Configuration()
        _configuration.fontScale = 1
        _configuration.mLocale = NSLocale.init(localeIdentifier: NSLocale.preferredLanguages[0]) as Locale
        _configuration.touchscreen = Int32(CONFIGURATION_TOUCHSCREEN_FINGER.rawValue)
        let interfaceOrientation = UIApplication.shared.statusBarOrientation
        _configuration.orientation = Int32(CONFIGURATION_ORIENTATION_LANDSCAPE.rawValue)
        if(interfaceOrientation.isPortrait) {
            _configuration.orientation = Int32(CONFIGURATION_ORIENTATION_PORTRAIT.rawValue)
        }
        let screenRect = UIScreen.main.bounds
        let screenWidth = screenRect.size.width
        let screenHeight = screenRect.size.height
        var long = Int32(screenWidth >= screenHeight ? screenWidth : screenHeight);
        var short = Int32(screenWidth >= screenHeight ? screenHeight : screenWidth);
        long = Int32(DisplayMetrics.sp(toDp: Float(long)))
        short = Int32(DisplayMetrics.sp(toDp: Float(short)))
        _configuration.screenLayout = Configuration.reduceScreenLayout(_configuration.screenLayout, long, short)
        _configuration.setLayoutDirection(_configuration.mLocale)
        let nightMode: UInt32
        if #available(iOS 12.0, *) {
            switch UIScreen.main.traitCollection.userInterfaceStyle {
            case .light:
                nightMode = CONFIGURATION_UI_MODE_NIGHT_NO.rawValue
                break
            case .dark:
                nightMode = CONFIGURATION_UI_MODE_NIGHT_YES.rawValue
                break
            case .unspecified:
                nightMode = CONFIGURATION_UI_MODE_NIGHT_UNDEFINED.rawValue
                break
            @unknown default:
                nightMode = CONFIGURATION_UI_MODE_NIGHT_UNDEFINED.rawValue
                break
            }
        } else {
            nightMode = CONFIGURATION_UI_MODE_NIGHT_UNDEFINED.rawValue
        }
        _configuration.uiMode = Int32(CONFIGURATION_UI_MODE_TYPE_NORMAL.rawValue | nightMode)
        _configuration.screenWidthDp = Int32(DisplayMetrics.sp(toDp: Float(screenWidth)))
        _configuration.screenHeightDp = Int32(DisplayMetrics.sp(toDp: Float(screenHeight)))
    }
    
    @objc
    public func getAnimation(id: String) -> CoreXmlBufferedReader? {
        return nil
        //return Xml.Companion.shared.getBufferedReader(value: id)
    }
    
    @objc
    public func getBoolean(value: String, def: Bool) -> Bool {
        return LGValueParser.getInstance().getBoolValueDirect(value, def)
    }
    
    @objc
    public func getColor(value: String, def: TColor) -> TColor {
        let c = LGColorParser.getInstance().parseColor(value)
        if(c == nil) {
            return def
        }
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        if c!.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            let iRed = Int(fRed * 255.0)
            let iGreen = Int(fGreen * 255.0)
            let iBlue = Int(fBlue * 255.0)
            let iAlpha = Int(fAlpha * 255.0)
            return TColor.init(a: iAlpha, r: iRed, g: iGreen, b: iBlue)
        } else {
            return def
        }
    }
    
    @objc
    public func getDimension(value: String, def: Float) -> Float {
        let d = LGDimensionParser.getInstance().getDimension(value)
        if(d == -1) {
            return def
        }
        return Float(d)
    }
    
    @objc
    public func getDimensionPixelOffset(value: String, def: Int32) -> Int32 {
        return Int32(getDimension(value: value, def: Float(def)))
    }
    
    @objc
    public func getDimensionPixelSize(value: String, def: Int32) -> Int32 {
        return Int32(getDimension(value: value, def: Float(def)))
    }
    
    @objc
    public func getDisplayMetrics() -> TDisplayMetrics {
        return TDisplayMetrics(deviceDensity: Int32(DisplayMetrics.getDensity()))
    }
    
    @objc
    public func getDrawable(resId: String) -> TDrawable? {
        return LGDrawableParser.getInstance().parseDrawableRef(LuaRef.withValue(resId))
    }
    
    @objc
    func isNumber(val: String) -> Bool {
        let digitsCharacters = CharacterSet(charactersIn: "0123456789.,")
        return CharacterSet(charactersIn: val).isSubset(of: digitsCharacters)
    }
    
    @objc
    public func getFloat(key: String?, value: String, def: Float) -> Float {
        let vObj = LGValueParser.getInstance().getValue(value, key)
        if(vObj != nil) {
            if(vObj is NSString) {
                if(isNumber(val: vObj as! String)) {
                    return Float(vObj as! String)!
                }
            }
            return Float(vObj as! Float)
        }
        return def
    }
    
    @objc
    public func getIdentifier(id: String, type: String, packageName: String) -> String {
        return LGIdParser.getInstance().getId(id);
    }
    
    @objc
    public func getInt(key: String?, value: String, def: Int32) -> Int32 {
        return Int32(getFloat(key: key, value: value, def: Float(def)))
    }
    
    @objc
    public func getIntArray(key: String?, value: String) -> NSMutableArray {
        let vObj = LGValueParser.getInstance().getValue(value, key)
        if(vObj != nil) {
            if(vObj is NSMutableArray) {
                return vObj as! NSMutableArray
            }
        }
        return NSMutableArray()
    }
    
    @objc
    public func getLayoutDimension(attr: String, def: Int32) -> Int32 {
        //TODO: Check?
        let s = DisplayMetrics.readSize(attr)
        if(s == -1) {
            return def
        }
        return s
    }
    
    @objc
    public func getResourceEntryName(id: String) -> String {
        return id
    }
    
    @objc
    public func getResourceId(id: String, def: String) -> String {
        if(LGIdParser.getInstance().hasId(id)) {
            return LGIdParser.getInstance().getId(id)
        }
        return def
    }
    
    @objc
    public func getResourceName(key: String) -> String {
        return key
    }
    
    @objc
    public func getResourceType(id: String) -> Int32 {
        let type = getType(value: id)
        switch(type) {
        case "id":
            return TypedValue.Companion.shared.TYPE_REFERENCE
        case "color":
            return TypedValue.Companion.shared.TYPE_FIRST_COLOR_INT
        case "string":
            return TypedValue.Companion.shared.TYPE_STRING
        case "float":
            return TypedValue.Companion.shared.TYPE_FLOAT
        case "int":
            return TypedValue.Companion.shared.TYPE_FIRST_INT
        case "boolean":
            return TypedValue.Companion.shared.TYPE_INT_BOOLEAN
        case "layout":
            return TypedValue.Companion.shared.TYPE_LAYOUT
        case "xml":
            return TypedValue.Companion.shared.TYPE_XML
        default:
            return TypedValue.Companion.shared.TYPE_NULL
        }
    }
    
    @objc
    public func getString(key: String?, value: String) -> String {
        return String(LGValueParser.getInstance().getValue(value, key) as! NSString)
    }
    
    @objc
    public func getType(value: String) -> String {
        return LGValueParser.getInstance().getValueType(value)
    }
    
    @objc
    public func getXml(resourceId: String) -> CoreXmlBufferedReader {
        return Xml.Companion.shared.getBufferedReader(value: LGXmlParser.getInstance().getXml(resourceId))
    }
}
