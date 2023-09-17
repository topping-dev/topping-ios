import Foundation
import IOSKotlinHelper

@objc
public class ToppingResources : NSObject, TResources {
    public func getAnimation(id: String) -> CoreXmlBufferedReader? {
        return nil
        //return Xml.Companion.shared.getBufferedReader(value: id)
    }
    
    public func getBoolean(value: String, def: Bool) -> Bool {
        return LGValueParser.getInstance().getBoolValueDirect(value, def)
    }
    
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
    
    public func getDimension(value: String, def: Float) -> Float {
        let d = LGDimensionParser.getInstance().getDimension(value)
        if(d == -1) {
            return def
        }
        return Float(d)
    }
    
    public func getDimensionPixelOffset(value: String, def: Int32) -> Int32 {
        return Int32(self.getDimension(value: value, def: Float(def)))
    }
    
    public func getDimensionPixelSize(value: String, def: Int32) -> Int32 {
        return Int32(self.getDimension(value: value, def: Float(def)))
    }
    
    public func getDisplayMetrics() -> TDisplayMetrics {
        return TDisplayMetrics(deviceDensity: Int32(DisplayMetrics.getDensity()))
    }
    
    public func getDrawable(resId: String) -> TDrawable? {
        return LGDrawableParser.getInstance().parseDrawableRef(LuaRef.withValue(resId))
    }
    
    func isNumber(val: String) -> Bool {
        let digitsCharacters = CharacterSet(charactersIn: "0123456789.")
        return CharacterSet(charactersIn: val).isSubset(of: digitsCharacters)
    }
    
    public func getFloat(value: String, def: Float) -> Float {
        let vObj = LGValueParser.getInstance().getValue(value)
        if(vObj != nil && vObj is NSString) {
            if(isNumber(val: vObj as! String)) {
                return Float(vObj as! String)!
            }
        }
        return def
    }
    
    public func getIdentifier(id: String, type: String, packageName: String) -> String {
        return LGIdParser.getInstance().getId(id);
    }
    
    public func getInt(value: String, def: Int32) -> Int32 {
        return Int32(self.getFloat(value: value, def: Float(def)))
    }
    
    public func getLayoutDimension(attr: String, def: Int32) -> Int32 {
        //TODO: Check?
        let s = DisplayMetrics.readSize(attr)
        if(s == -1) {
            return def
        }
        return s
    }
    
    public func getResourceEntryName(id: String) -> String {
        return id
    }
    
    public func getResourceId(id: String, def: String) -> String {
        if(LGIdParser.getInstance().hasId(id)) {
            return LGIdParser.getInstance().getId(id)
        }
        return def
    }
    
    public func getResourceName(key: String) -> String {
        return key
    }
    
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
    
    public func getString(key: String?, value: String) -> String {
        return String(LGValueParser.getInstance().getValue(value, key) as! NSString)
    }
    
    public func getType(value: String) -> String {
        return LGValueParser.getInstance().getValueType(value)
    }
    
    public func getXml(resourceId: String) -> CoreXmlBufferedReader {
        return Xml.Companion.shared.getBufferedReader(value: LGXmlParser.getInstance().getXml(resourceId))
    }
    
    
}
