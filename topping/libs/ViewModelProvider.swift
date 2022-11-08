import UIKit

@objc(ViewModelProviderFactory)
public protocol ViewModelProviderFactory : NSObjectProtocol {
    @objc func create() -> LuaViewModel
}

@objc(ViewModelProviderOnRequeryFactory)
open class ViewModelProviderOnRequeryFactory : NSObject {
    @objc func onRequery(viewModel: LuaViewModel) { }
}

@objc(ViewModelProviderKeyedFactory)
open class ViewModelProviderKeyedFactory : ViewModelProviderOnRequeryFactory, ViewModelProviderFactory {
    @objc public func create(key: String) -> LuaViewModel {
        return LuaViewModel()
    }
    
    @objc public func create() -> LuaViewModel {
        return LuaViewModel()
    }
}

class ViewModelProviderNewInstanceFactory: NSObject, ViewModelProviderFactory {
    func create() -> LuaViewModel {
        return LuaViewModel()
    }
}

class ViewModelProviderAndroidViewModelFactory : ViewModelProviderNewInstanceFactory {
    override func create() -> LuaViewModel {
        return LuaViewModel()
    }
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
    
    init(store: ViewModelStore, factory: ViewModelProviderFactory) {
        self.store = store
        self.factory = factory
    }
    
    func get() -> LuaViewModel {
        return get(key: "$DEFAULT_KEY:LuaViewModel")
    }
    
    func get(key: String) -> LuaViewModel {
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
}
