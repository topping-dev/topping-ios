import Foundation

class ArrayExtension {
    static func remove<T>(list: inout Array<T>, object: T) -> Bool {
        var indexToRemove = -1
        for (index, v) in list.enumerated() {
            if(!(v is Keyable)) {
                return false
            }
            if(!(object is Keyable)) {
                return false
            }
            if((v as! Keyable).key == (object as! Keyable).key) {
                indexToRemove = index
                break
            }
        }
        if (indexToRemove != -1) {
            list.remove(at: indexToRemove)
            return true
        }
        
        return false
    }
    
    static func remove<T>(list: inout Array<T>?, object: T) -> Bool {
        if(list == nil) {
            return false
        }
        var indexToRemove = -1
        for (index, v) in list!.enumerated() {
            if(!(v is Keyable)) {
                return false
            }
            if(!(object is Keyable)) {
                return false
            }
            if((v as! Keyable).key == (object as! Keyable).key) {
                indexToRemove = index
                break
            }
        }
        if (indexToRemove != -1) {
            list!.remove(at: indexToRemove)
            return true
        }
        
        return false
    }
}

extension Array where Element: NSObjectProtocol {
    
    @discardableResult mutating func remove(nsobject: Element) -> Bool {
        var indexToRemove = -1
        for (index, v) in enumerated() {
            if(v.isEqual(nsobject)) {
                indexToRemove = index
                break
            }
        }
        if (indexToRemove != -1) {
            remove(at: indexToRemove)
            return true
        }
        
        return false
    }
    
}

extension Array where Element: Keyable {
    
    @discardableResult mutating func remove(object: Element) -> Bool {
        var indexToRemove = -1
        for (index, v) in enumerated() {
            if(v.key == object.key) {
                indexToRemove = index
                break
            }
        }
        if (indexToRemove != -1) {
            remove(at: indexToRemove)
            return true
        }
        
        return false
    }
    
}

extension Array where Element: Equatable {

    @discardableResult mutating func remove(object: Element) -> Bool {
        if let index = firstIndex(of: object) {
            self.remove(at: index)
            return true
        }
        return false
    }

    @discardableResult mutating func remove(where predicate: (Array.Iterator.Element) -> Bool) -> Bool {
        if let index = self.firstIndex(where: { (element) -> Bool in
            return predicate(element)
        }) {
            self.remove(at: index)
            return true
        }
        return false
    }
    
    mutating func removeAll(object: Element) {
        self = self.filter { $0 != object }
    }

}
