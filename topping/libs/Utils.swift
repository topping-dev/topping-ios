typealias Bundle = Dictionary<String, NSObject>

import UIKit

protocol Keyable {
    var key:String { get }
}

protocol Runnable : Keyable {
    func run()
}

protocol Cancellable : Keyable {
    func cancel()
}

func synced(_ lock: Any, closure: () -> ()) {
    objc_sync_enter(lock)
    
    defer { objc_sync_exit(lock) }
    
    closure()
}

func syncedRet(_ lock: Any, closure: () -> (Any?)) -> Any? {
    objc_sync_enter(lock)
    
    defer { objc_sync_exit(lock) }
    
    return closure()
}

extension NSDictionary {
    var swiftDictionary: Dictionary<String, Any> {
        var swiftDictionary = Dictionary<String, Any>()

        for key : Any in self.allKeys {
            let stringKey = key as! String
            if let keyValue = self.value(forKey: stringKey){
                swiftDictionary[stringKey] = keyValue
            }
        }

        return swiftDictionary
    }
    
    var swiftDictionaryObj: Dictionary<String, NSObject> {
        var swiftDictionaryObj = Dictionary<String, NSObject>()

        for key : Any in self.allKeys {
            let stringKey = key as! String
            if let keyValue = self.value(forKey: stringKey){
                swiftDictionaryObj[stringKey] = keyValue as! NSObject
            }
        }

        return swiftDictionaryObj
    }
}

extension Dictionary {
    var objcDictionary: NSMutableDictionary {
        return NSMutableDictionary(dictionary: self)
    }
}

extension NSArray {
    var swiftArray: Array<Any> {
        var swiftArray = Array<Any>()

        for key : Any in self {
            swiftArray.append(key)
        }

        return swiftArray
    }
    
    var swiftArrayObj: Array<NSObject> {
        var swiftArrayObj = Array<NSObject>()

        for key : Any in self {
            let objKey = key as! NSObject
            swiftArrayObj.append(objKey)
        }

        return swiftArrayObj
    }
}

extension Array {
    var objcArray: NSMutableArray {
        return NSMutableArray(array: self)
    }
}

class Utils: NSObject {
    static func getClassForClassName<T>(className: String) -> T.Type? {
        var cls = NSClassFromString(className) as? T.Type
        if(cls == nil) {
            let lastClassName = className.components(separatedBy: ".").last
            cls = NSClassFromString(lastClassName!) as? T.Type
            if(cls == nil) {
                let lgLastClassName = "LG" + lastClassName!
                cls = NSClassFromString(lgLastClassName) as? T.Type
                if(cls == nil) {
                    let luaLastClassName = "Lua" + lastClassName!
                    cls = NSClassFromString(luaLastClassName) as? T.Type
                }
            }
        }
        return cls
    }
}

extension UIFont {
    func sizeOfString (string: String, constrainedToWidth width: Double) -> CGSize {
        return NSString(string: string).boundingRect(
            with: CGSize(width: width, height: .greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            attributes: [.font: self],
            context: nil).size
    }
}

public extension String {
    func substring(startIndex: Int, length: Int) -> String {
        let start = index(self.startIndex, offsetBy: startIndex)
        let end = index(self.startIndex, offsetBy: startIndex + length)
        return String(self[start..<end])
    }
}

private enum ThreadLocalIdentifier {
    case DateFormatter(String)

    case DefaultNumberFormatter
    case LocaleNumberFormatter(Locale)

    var objcDictKey: String {
        switch self {
        case .DateFormatter(let format):
            return "SS\(self)\(format)"
        case .LocaleNumberFormatter(let l):
            return "SS\(self)\(l.identifier)"
        default:
            return "SS\(self)"
        }
    }
}

private func threadLocalInstance<T: AnyObject>(identifier: ThreadLocalIdentifier, initialValue: @autoclosure () -> T) -> T {
    let storage = Thread.current.threadDictionary
    let k = identifier.objcDictKey

    let instance: T = storage[k] as? T ?? initialValue()
    if storage[k] == nil {
        storage[k] = instance
    }

    return instance
}

private func dateFormatter(format: String) -> DateFormatter {
    return threadLocalInstance(identifier: .DateFormatter(format), initialValue: {
        let df = DateFormatter()
        df.dateFormat = format
        return df
    }())
}

private func defaultNumberFormatter() -> NumberFormatter {
    return threadLocalInstance(identifier: .DefaultNumberFormatter, initialValue: NumberFormatter())
}

private func localeNumberFormatter(locale: Locale) -> NumberFormatter {
    return threadLocalInstance(identifier: .LocaleNumberFormatter(locale), initialValue: {
        let nf = NumberFormatter()
        nf.locale = locale
        return nf
    }())
}

struct RuntimeError: Error {
    let message: String

    init(_ message: String) {
        self.message = message
    }

    public var localizedDescription: String {
        return message
    }
}

extension StringProtocol {
    subscript(offset: Int) -> Character { self[index(startIndex, offsetBy: offset)] }
    subscript(range: Range<Int>) -> SubSequence {
        let startIndex = index(self.startIndex, offsetBy: range.lowerBound)
        return self[startIndex..<index(startIndex, offsetBy: range.count)]
    }
    subscript(range: ClosedRange<Int>) -> SubSequence {
        let startIndex = index(self.startIndex, offsetBy: range.lowerBound)
        return self[startIndex..<index(startIndex, offsetBy: range.count)]
    }
    subscript(range: PartialRangeFrom<Int>) -> SubSequence { self[index(startIndex, offsetBy: range.lowerBound)...] }
    subscript(range: PartialRangeThrough<Int>) -> SubSequence { self[...index(startIndex, offsetBy: range.upperBound)] }
    subscript(range: PartialRangeUpTo<Int>) -> SubSequence { self[..<index(startIndex, offsetBy: range.upperBound)] }
    
    func distance(of element: Element) -> Int? { firstIndex(of: element)?.distance(in: self) }
    func distance<S: StringProtocol>(of string: S) -> Int? { range(of: string)?.lowerBound.distance(in: self) }
}

extension Collection {
    func distance(to index: Index) -> Int { distance(from: startIndex, to: index) }
}

extension String.Index {
    func distance<S: StringProtocol>(in string: S) -> Int { string.distance(to: self) }
}

extension UICollectionView {
  var visibleCurrentCellIndexPath: IndexPath? {
    for cell in self.visibleCells {
      let indexPath = self.indexPath(for: cell)
      return indexPath
    }
    
    return nil
  }
}

@objc
extension UIView {

    // Using a function since `var image` might conflict with an existing variable
    // (like on `UIImageView`)
    @objc public func asImage() -> UIImage {
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(size: frame.size)
                    return renderer.image { context in
                        layer.render(in: context.cgContext)
            }
        } else {
            UIGraphicsBeginImageContext(self.frame.size)
            self.layer.render(in:UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return UIImage(cgImage: image!.cgImage!)
        }
    }
}
