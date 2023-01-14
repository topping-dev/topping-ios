import UIKit

@objc(ViewModelProviderFactory)
public protocol ViewModelProviderFactory : NSObjectProtocol {
    @objc func create() -> LuaViewModel
    @objc func create(cls: NSObject.Type) -> NSObject
    @objc func create(ptr: UnsafeMutableRawPointer) -> UnsafeMutableRawPointer
}

@objc(ViewModelProviderOnRequeryFactory)
open class ViewModelProviderOnRequeryFactory : NSObject {
    @objc func onRequery(viewModel: LuaViewModel) { }
    @objc func onRequery(viewModelClass: NSObject.Type) { }
    @objc func onRequery(ptr: UnsafeMutableRawPointer) { }
}

@objc(ViewModelProviderKeyedFactory)
open class ViewModelProviderKeyedFactory : ViewModelProviderOnRequeryFactory, ViewModelProviderFactory {
    @objc public func create(key: String) -> LuaViewModel {
        return LuaViewModel()
    }
    
    @objc public func create() -> LuaViewModel {
        return LuaViewModel()
    }
    
    @objc public func create(ptr: UnsafeMutableRawPointer) -> UnsafeMutableRawPointer {
        return ptr
    }
    
    @objc public func create(key: String, ptr: UnsafeMutableRawPointer) -> UnsafeMutableRawPointer {
        return ptr
    }
    
    @objc public func create(cls: NSObject.Type) -> NSObject {
        return cls.init()
    }
    
    @objc public func create(key: String, cls: NSObject.Type) -> NSObject {
        return cls.init()
    }
}

class ViewModelProviderNewInstanceFactory: NSObject, ViewModelProviderFactory {
    func create() -> LuaViewModel {
        return LuaViewModel()
    }
    
    func create(ptr: UnsafeMutableRawPointer) -> UnsafeMutableRawPointer {
        return ptr
    }
    
    func create(cls: NSObject.Type) -> NSObject {
        return cls.init()
    }
}

class ViewModelProviderAndroidViewModelFactory : ViewModelProviderNewInstanceFactory {
}

@objc(ViewModelProvider)
open class ViewModelProvider: NSObject {
    let store: ViewModelStore
    let factory: ViewModelProviderFactory
    
    static func defaultFactory(owner: ViewModelStoreOwner) -> ViewModelProviderFactory {
        if(owner is HasDefaultViewModelProviderFactory) {
            return (owner as! HasDefaultViewModelProviderFactory).getDefaultViewModelProviderFactory()
        }
        else {
            return ViewModelProviderAndroidViewModelFactory()
        }
    }
    
    @objc public convenience init(owner: ViewModelStoreOwner) {
        self.init(owner: owner, factory: ViewModelProvider.defaultFactory(owner: owner))
    }
    
    @objc public init(owner: ViewModelStoreOwner, factory: ViewModelProviderFactory) {
        self.store = owner.getViewModelStore()
        self.factory = factory
    }
    
    @objc public init(store: ViewModelStore, factory: ViewModelProviderFactory) {
        self.store = store
        self.factory = factory
    }
    
    @objc public func get() -> LuaViewModel {
        return get(key: "$DEFAULT_KEY:LuaViewModel")
    }
    
    @objc public func get(key: String) -> LuaViewModel {
        var viewModel = store.get(key);
        if(viewModel != nil) {
            return viewModel!
        }
        if(factory is ViewModelProviderKeyedFactory) {
            viewModel = (factory as! ViewModelProviderKeyedFactory).create(key: key)
        }
        else {
            viewModel = factory.create()
        }
        store.put(key, viewModel)
        return viewModel!
    }
    
    @objc public func get(key: String, cls: NSObject.Type) -> NSObject {
        var viewModel = store.getObj(key);
        if(viewModel != nil) {
            return viewModel!
        }
        if(factory is ViewModelProviderKeyedFactory) {
            viewModel = (factory as! ViewModelProviderKeyedFactory).create(cls: cls)
        }
        else {
            viewModel = factory.create(cls: cls)
        }
        store.put(key, viewModel)
        return viewModel!
    }
    
    @objc public func get(key: String, ptr: UnsafeMutableRawPointer) -> UnsafeMutableRawPointer {
        var viewModel = store.getPtr(key);
        if(viewModel != nil) {
            return viewModel!
        }
        if(factory is ViewModelProviderKeyedFactory) {
            viewModel = (factory as! ViewModelProviderKeyedFactory).create(ptr: ptr)
        }
        else {
            viewModel = factory.create(ptr: ptr)
        }
        store.put(key, ptr: viewModel)
        return viewModel!
    }
}
