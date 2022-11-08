import UIKit

class SavedStateProviderI : SavedStateProvider {
    
    var saveStateO:() -> (Dictionary<String, Any>) = {
        return Dictionary()
    }
    
    init(overrides: (SavedStateProviderI) -> SavedStateProviderI) {
        overrides(self)
    }
    
    func saveState() -> Dictionary<String, Any> {
        return saveStateO()
    }
}

class SavingStateLiveData : LuaMutableLiveData {
    var mKey: String
    var mHandle: SavedStateHandle?
    
    init(handle: SavedStateHandle, key: String, val: NSObject) {
        mKey = key
        mHandle = handle
        super.init(data: val)
    }
    
    init(handle: SavedStateHandle, key: String) {
        mKey = key
        mHandle = handle
        super.init()
    }
    
    func setValue(value: NSObject) {
        if(mHandle != nil) {
            mHandle!.mRegular[mKey] = value
        }
        super.setValue(value)
    }
    
    func detach() {
        mHandle = nil
    }
}

class SavedStateHandle {
    var mRegular: Dictionary<String, NSObject>
    var mSavedStateProviders = Dictionary<String, SavedStateProvider>()
    var mLiveDatas = Dictionary<String, SavingStateLiveData>()
    
    static let VALUES = "values"
    static let KEYS = "keys"
    
    var mSavedStateProivder: SavedStateProvider? = nil
    
    init() {
        mRegular = Dictionary()
        mSavedStateProivder = SavedStateProviderI { ssp in
            ssp.saveStateO = {
                let map: Dictionary<String, SavedStateProvider> = self.mSavedStateProviders
                for key in map.keys {
                    let value = map[key]
                    let savedState = value!.saveState()
                    self.set(key: key, value: savedState.objcDictionary)
                }
                let keys = self.mRegular.keys
                var value = Array<NSObject>()
                for key in keys {
                    value.append(self.mRegular[key] ?? NSObject())
                }
                
                var res = Dictionary<String, Any>()
                res["keys"] = keys
                res["values"] = value
                
                return res
            }
            return ssp
        }
    }
    
    init(initialState: Dictionary<String, NSObject>) {
        mRegular = initialState
    }
    
    static func createHandle(restoredState: Dictionary<String, NSObject>?, defaultState: Dictionary<String, NSObject>?) -> SavedStateHandle {
        if(restoredState == nil && defaultState == nil) {
            return SavedStateHandle()
        }
        
        var state = Dictionary<String, NSObject>()
        if(defaultState != nil) {
            for key in defaultState!.keys {
                state[key] = defaultState![key]
            }
        }
        
        if(restoredState == nil) {
            return SavedStateHandle(initialState: state)
        }
        
        let keys = restoredState![SavedStateHandle.KEYS] as! Array<String>?
        let values = restoredState![SavedStateHandle.VALUES] as! Array<NSObject>?
        if(keys == nil || values == nil || keys!.count != values!.count) {
            return SavedStateHandle()
        }
        for i in 0..<keys!.count {
            state[keys![i]] = values![i]
        }
        return SavedStateHandle(initialState: state)
    }
    
    func savedStateProvider() -> SavedStateProvider? {
        return mSavedStateProivder
    }
    
    func contains(key: String) -> Bool {
        return mRegular[key] != nil
    }
    
    func getLiveData(key: String) -> LuaMutableLiveData {
        return getLiveDataInternal(key: key, hasInitialValue: false, initialValue: nil)
    }
    
    func getLiveData(key: String, initialValue: NSObject?) -> LuaMutableLiveData {
        return getLiveDataInternal(key: key, hasInitialValue: true, initialValue: initialValue)
    }
    
    func getLiveDataInternal(key: String, hasInitialValue: Bool, initialValue: NSObject?) -> LuaMutableLiveData {
        let liveData = mLiveDatas[key]
        if(liveData != nil) {
            return liveData!
        }
        
        var mutableLd: SavingStateLiveData
        if(mRegular[key] != nil) {
            mutableLd = SavingStateLiveData(handle: self, key: key, val: mRegular[key]!)
        } else if(hasInitialValue) {
            mutableLd = SavingStateLiveData(handle: self, key: key, val: initialValue!)
        } else {
            mutableLd = SavingStateLiveData(handle: self, key: key)
        }
        
        mLiveDatas[key] = mutableLd
        return mutableLd
    }
    
    func keys() -> Set<String> {
        var allKeys = Set<String>(mRegular.keys)
        for key in mSavedStateProviders.keys {
            allKeys.insert(key)
        }
        for key in mLiveDatas.keys {
            allKeys.insert(key)
        }
        return allKeys
    }
    
    func get(key: String) -> NSObject? {
        return mRegular[key]
    }
    
    func set(key: String, value: NSObject?) {
        if(value == nil) {
            return
        }
        let mutableLiveData = mLiveDatas[key]
        if(mutableLiveData != nil) {
            mutableLiveData?.setValue(value: value!)
        } else {
            mRegular[key] = value
        }
    }
    
    func remove(key: String) -> NSObject? {
        let latestValue = mRegular.removeValue(forKey: key)
        let liveData = mLiveDatas.removeValue(forKey: key)
        liveData?.detach()
        return latestValue
    }
    
    func setSavedStateProvider(key: String, provider: SavedStateProvider) {
        mSavedStateProviders[key] = provider
    }
    
    func clearSavedStateProvider(key: String) {
        mSavedStateProviders.removeValue(forKey: key)
    }
}

class OnRecreation : AutoCreated {
    func onRecreated(owner: SavedStateRegistryOwner) {
        if(!(owner is ViewModelStoreOwner)) {
            return
        }
        
        let viewModelStore = (owner as! ViewModelStoreOwner).getViewModelStore()
        let savedStateRegistry = owner.getSavedStateRegistry()
        if(viewModelStore != nil) {
            for key in viewModelStore!.keys() {
                let viewModel = viewModelStore!.get((key as! String))
                if(viewModel != nil) {
                    SavedStateHandleController.attachHandleIfNeeded(viewModel: viewModel!, registry: savedStateRegistry, lifecycle: owner.getLifecycle())
                }
            }
            if(!viewModelStore!.keys().isEmpty) {
                savedStateRegistry.runOnNextRecreation(clazz: OnRecreation.self)
            }
        }
    }

    static func new() -> AutoCreated {
        return OnRecreation()
    }
}


@objc(SavedStateHandleController)
open class SavedStateHandleController : NSObject, LifecycleEventObserver {
    static let TAG_SAVED_STATE_HANDLE_CONTROLLER = "androidx.lifecycle.savedstate.vm.tag"
    var mKey: String
    var mIsAttached = false
    var mHandle: SavedStateHandle
    var key = UUID.init().uuidString
    
    init(key: String, handle: SavedStateHandle) {
        mKey = key
        mHandle = handle
    }
    
    func isAttached() -> Bool {
        return mIsAttached
    }
    
    func attachToLifecycle(registry: SavedStateRegistry, lifecycle: Lifecycle) {
        if(mIsAttached) {
            return
        }
        mIsAttached = true
        lifecycle.add(self)
        if(mHandle.savedStateProvider() != nil) {
            registry.registerSavedStateProvider(key: mKey, provider: mHandle.savedStateProvider()!)
        }
    }
    
    public func getKey() -> String! {
        return key
    }
    
    public func onStateChanged(_ source: LifecycleOwner!, _ event: LifecycleEvent) {
        if(event == LifecycleEvent.LIFECYCLEEVENT_ON_DESTROY) {
            mIsAttached = false
            source.getLifecycle().remove(self)
        }
    }
    
    func getHandle() -> SavedStateHandle {
        return mHandle
    }
    
    static func create(registry: SavedStateRegistry, lifecycle: Lifecycle, key: String, defaultArgs: Dictionary<String, NSObject>?) -> SavedStateHandleController {
        let restoredState = registry.consumeRestoredStateForKey(key: key)
        let handle = SavedStateHandle.createHandle(restoredState: restoredState, defaultState: defaultArgs)
        let controller = SavedStateHandleController(key: key, handle: handle)
        controller.attachToLifecycle(registry: registry, lifecycle: lifecycle)
        tryToAddRecreator(registry: registry, lifecycle: lifecycle)
        return controller
    }
    
    static func attachHandleIfNeeded(viewModel: LuaViewModel, registry: SavedStateRegistry, lifecycle: Lifecycle) {
        let controller: SavedStateHandleController? = viewModel.getTag(TAG_SAVED_STATE_HANDLE_CONTROLLER) as! SavedStateHandleController?
        if(controller != nil && !controller!.isAttached()) {
            controller!.attachToLifecycle(registry: registry, lifecycle: lifecycle)
            tryToAddRecreator(registry: registry, lifecycle: lifecycle)
        }
    }
    
    static func tryToAddRecreator(registry: SavedStateRegistry, lifecycle: Lifecycle) {
        let currentState = lifecycle.getCurrentState()
        if(currentState == LifecycleState.LIFECYCLESTATE_INITIALIZED || Lifecycle.is(atLeast: currentState, LifecycleState.LIFECYCLESTATE_STARTED)) {
            registry.runOnNextRecreation(clazz: OnRecreation.self)
        }
    }
}

@objc(SavedStateViewModelFactory)
open class SavedStateViewModelFactory : ViewModelProviderKeyedFactory {
    var mContext: LuaContext?
    var mFactory: ViewModelProviderFactory
    var mDefaultArgs: Dictionary<String, Any>?
    var mLifecycle: Lifecycle?
    var mSavedStateRegistry: SavedStateRegistry?
    
    convenience init(context: LuaContext, owner: SavedStateRegistryOwner) {
        self.init(context: context, owner: owner, defaultArgs: nil)
    }
    
    @objc public init(context: LuaContext?, owner: SavedStateRegistryOwner, defaultArgs: NSMutableDictionary?) {
        mSavedStateRegistry = owner.getSavedStateRegistry()
        mLifecycle = owner.getLifecycle()
        mContext = context
        mFactory = ViewModelProviderAndroidViewModelFactory()
        mDefaultArgs = defaultArgs?.swiftDictionary
        if(context != nil) {
            mFactory = ViewModelProviderAndroidViewModelFactory()
        }
        else {
            mFactory = ViewModelProviderNewInstanceFactory()
        }
    }
    
    override public func create(key: String) -> LuaViewModel {
        return mFactory.create()
    }
}

@objc(Recreator)
open class Recreator : NSObject, LifecycleEventObserver {
    static let CLASSES_KEY = "classes_to_restor"
    static let COMPONENT_KEY = "androidx.savedstate.Restarter"
    
    private let mOwner: SavedStateRegistryOwner
    
    private let key = UUID.init().uuidString
    
    init(owner: SavedStateRegistryOwner) {
        self.mOwner = owner
    }
    
    public func getKey() -> String! {
        return key
    }
    
    public func onStateChanged(_ source: LifecycleOwner!, _ event: LifecycleEvent) {
        if(event != LifecycleEvent.LIFECYCLEEVENT_ON_CREATE) {
            return
        }
        source.getLifecycle().remove(self)
        let bundle = mOwner.getSavedStateRegistry().consumeRestoredStateForKey(key: Recreator.COMPONENT_KEY)
        if(bundle == nil) {
            return
        }
        let classes: Array<String>? = bundle?[Recreator.CLASSES_KEY] as! Array<String>?
        if(classes == nil) {
            return
        }
        for className in classes! {
            reflectiveNew(className: className)
        }
    }
    
    func reflectiveNew(className: String) {
        let clazz: AnyClass? = NSClassFromString(className)
        if(!(clazz is AutoCreated)) {
            return
        }
        let clazzz = clazz as! AutoCreated.Type
        let obj = clazzz.new()
        obj.onRecreated(owner: mOwner)
    }
}

class RecreatorSavedStateProvider : SavedStateProvider {
    var mClasses = Set<String>()
    
    init(registry: SavedStateRegistry) {
        registry.registerSavedStateProvider(key: Recreator.COMPONENT_KEY, provider: self)
    }
    
    func saveState() -> Dictionary<String, Any> {
        var bundle = Dictionary<String, Any>()
        bundle[Recreator.CLASSES_KEY] = Array(mClasses)
        return bundle
    }
    
    func add(className: String) {
        mClasses.insert(className)
    }
}

protocol AutoCreated {
    func onRecreated(owner: SavedStateRegistryOwner)
    static func new() -> AutoCreated
}

@objc(SavedStateRegistry)
open class SavedStateRegistry : NSObject {
    private static let SAVED_COMPONENTS_KEY = "androidx.lifecycle.BundlableSavedStateRegistry.key"
    private var mComponents = MutableOrderedDictionary()
    private var mRestoredState: Dictionary<String, Any>?
    private var mRestored = false
    private var mRecreatorProvider: RecreatorSavedStateProvider?
    private var mAllowingSavingState = false
    
    func consumeRestoredStateForKey(key: String) -> Dictionary<String, NSObject>? {
        if(!mRestored) {
            return nil
        }
        if(mRestoredState != nil) {
            let result: Dictionary<String, NSObject>? = mRestoredState?[key] as! Dictionary<String, NSObject>?
            mRestoredState?.removeValue(forKey: key)
            if((mRestoredState?.isEmpty) != nil) {
                mRestoredState = nil;
            }
            return result
        }
        
        return nil
    }
    
    @objc
    public func registerSavedStateProvider(key: String, provider: SavedStateProvider) {
        let previous = mComponents.putIfAbsent(key, provider)
        if(previous != nil) {
            return
        }
    }
    
    func unregisterSavedStateProvider(key: String) {
        mComponents.removeObject(forKey: key)
    }
    
    func isRestored() -> Bool {
        return mRestored
    }
    
    func runOnNextRecreation(clazz: AutoCreated.Type) {
        if(!mAllowingSavingState) {
            return
        }
        if(mRecreatorProvider == nil) {
            mRecreatorProvider = RecreatorSavedStateProvider(registry: self)
        }
        mRecreatorProvider?.add(className: NSStringFromClass(clazz as! AnyClass))
    }
    
    func performRestore(lifecycle: Lifecycle, savedState: Dictionary<String, Any>?) {
        if(mRestored) {
            return
        }
        if(savedState != nil) {
            mRestoredState = savedState?[SavedStateRegistry.SAVED_COMPONENTS_KEY] as! Dictionary<String, Any>?
        }
        
        let observer = LifecycleEventObserverI { leo in
            leo.onStateChangedO = { source, event in
                if(event == LifecycleEvent.LIFECYCLEEVENT_ON_START) {
                    self.mAllowingSavingState = true
                } else if(event == LifecycleEvent.LIFECYCLEEVENT_ON_STOP) {
                    self.mAllowingSavingState = false
                }
            }
            return leo
        }
        
        lifecycle.add(observer)
        
        mRestored = true
    }
    
    func performSave(outBundle: inout Dictionary<String, Any>) {
        var components = Dictionary<String, Any>()
        if(mRestoredState != nil) {
            components["bundle"] = mRestoredState
        }
        for key in mComponents.keyEnumerator() {
            let val = mComponents.object(forKey: key) as! SavedStateProvider
            components[key as! String] = val.saveState()
        }
        outBundle[SavedStateRegistry.SAVED_COMPONENTS_KEY] = components
    }
}

@objc(SavedStateProvider)
public protocol SavedStateProvider {
    func saveState() -> Dictionary<String, Any>
}

@objc(SavedStateRegistryOwner)
public protocol SavedStateRegistryOwner : LifecycleOwner {
    @objc func getSavedStateRegistry() -> SavedStateRegistry
}

@objc(SavedStateRegistryController)
open class SavedStateRegistryController: NSObject {
    let mOwner: SavedStateRegistryOwner
    let mRegistry: SavedStateRegistry
    
    @objc
    public init(owner: SavedStateRegistryOwner) {
        mOwner = owner
        mRegistry = SavedStateRegistry()
    }
    
    @objc
    public func getSavedStateRegistry() -> SavedStateRegistry {
        return mRegistry
    }
    
    @objc
    public func performRestore(savedStrate: Dictionary<String, Any>?) {
        let lifecycle = mOwner.getLifecycle()
        if(lifecycle?.getCurrentState() != LifecycleState.LIFECYCLESTATE_INITIALIZED) {
            return
        }
        lifecycle?.add(Recreator(owner: mOwner))
        mRegistry.performRestore(lifecycle: lifecycle!, savedState: savedStrate)
    }
    
    @objc
    public func performSave(outBundle: Dictionary<String, Any>) -> Dictionary<String, Any> {
        var outBundleC = outBundle
        mRegistry.performSave(outBundle: &outBundleC)
        return outBundleC
    }
    
    static func create(owner: SavedStateRegistryOwner) -> SavedStateRegistryController {
        return SavedStateRegistryController(owner: owner)
    }
}
