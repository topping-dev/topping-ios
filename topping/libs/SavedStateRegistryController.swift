import UIKit

@objc
public class SavedStateProviderI : NSObject, SavedStateProvider {
    
    var saveStateO:() -> (LuaBundle) = {
        return LuaBundle()
    }
    
    @objc
    public init(overrides: (SavedStateProviderI) -> SavedStateProviderI) {
        super.init()
        overrides(self)
    }
    
    @objc
    public func saveState() -> LuaBundle {
        return saveStateO()
    }
}

@objc
public class SavingStateLiveData : LuaMutableLiveData {
    var mKey: String
    var mHandle: SavedStateHandle?
    
    @objc
    public init(handle: SavedStateHandle, key: String, val: NSObject) {
        mKey = key
        mHandle = handle
        super.init(data: val)
    }
    
    @objc
    public init(handle: SavedStateHandle, key: String) {
        mKey = key
        mHandle = handle
        super.init()
    }
    
    @objc
    public func setValue(value: NSObject) {
        if(mHandle != nil) {
            mHandle!.mRegular[mKey] = value
        }
        super.setValue(value)
    }
    
    @objc
    public func detach() {
        mHandle = nil
    }
}

@objc
public class SavedStateHandle : NSObject {
    var mRegular: Dictionary<String, NSObject>
    var mSavedStateProviders = Dictionary<String, SavedStateProvider>()
    var mLiveDatas = Dictionary<String, SavingStateLiveData>()
    
    static let VALUES = "values"
    static let KEYS = "keys"
    
    var mSavedStateProvider: SavedStateProvider? = nil
    
    @objc
    public override init() {
        mRegular = Dictionary()
        super.init()
        mSavedStateProvider = SavedStateProviderI { ssp in
            ssp.saveStateO = {
                let map: Dictionary<String, SavedStateProvider> = self.mSavedStateProviders
                for key in map.keys {
                    let value = map[key]
                    let savedState = value!.saveState()
                    self.set(key: key, value: savedState)
                }
                let keys = self.mRegular.keys
                var value = Array<NSObject>()
                for key in keys {
                    value.append(self.mRegular[key] ?? NSObject())
                }
                
                var res = LuaBundle()
                res.putObject("keys", keys)
                res.putObject("values", value)
                return res
            }
            return ssp
        }
    }
    
    @objc
    public init(initialState: Dictionary<String, NSObject>) {
        mRegular = initialState
    }
    
    @objc
    public static func createHandle(restoredState: LuaBundle?, defaultState: Dictionary<String, NSObject>?) -> SavedStateHandle {
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
        
        let keys = restoredState!.getObject(SavedStateHandle.KEYS) as! Array<String>?
        let values = restoredState!.getObject(SavedStateHandle.VALUES) as! Array<NSObject>?
        if(keys == nil || values == nil || keys!.count != values!.count) {
            return SavedStateHandle()
        }
        for i in 0..<keys!.count {
            state[keys![i]] = values![i]
        }
        return SavedStateHandle(initialState: state)
    }
    
    @objc
    public func savedStateProvider() -> SavedStateProvider? {
        return mSavedStateProvider
    }
    
    @objc
    public func contains(key: String) -> Bool {
        return mRegular[key] != nil
    }
    
    @objc
    public func getLiveData(key: String) -> LuaMutableLiveData {
        return getLiveDataInternal(key: key, hasInitialValue: false, initialValue: nil)
    }
    
    @objc
    public func getLiveData(key: String, initialValue: NSObject?) -> LuaMutableLiveData {
        return getLiveDataInternal(key: key, hasInitialValue: true, initialValue: initialValue)
    }
    
    @objc
    public func getLiveDataInternal(key: String, hasInitialValue: Bool, initialValue: NSObject?) -> LuaMutableLiveData {
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
    
    @objc
    public func keys() -> Set<String> {
        var allKeys = Set<String>(mRegular.keys)
        for key in mSavedStateProviders.keys {
            allKeys.insert(key)
        }
        for key in mLiveDatas.keys {
            allKeys.insert(key)
        }
        return allKeys
    }
    
    @objc
    public func get(key: String) -> NSObject? {
        return mRegular[key]
    }
    
    @objc
    public func set(key: String, value: NSObject?) {
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
    
    @objc
    public func remove(key: String) -> NSObject? {
        let latestValue = mRegular.removeValue(forKey: key)
        let liveData = mLiveDatas.removeValue(forKey: key)
        liveData?.detach()
        return latestValue
    }
    
    @objc
    public func setSavedStateProvider(key: String, provider: SavedStateProvider) {
        mSavedStateProviders[key] = provider
    }
    
    @objc
    public func clearSavedStateProvider(key: String) {
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
    var mDefaultArgs: LuaBundle?
    var mLifecycle: Lifecycle?
    var mSavedStateRegistry: SavedStateRegistry?
    
    convenience init(context: LuaContext, owner: SavedStateRegistryOwner) {
        self.init(context: context, owner: owner, defaultArgs: nil)
    }
    
    @objc public init(context: LuaContext?, owner: SavedStateRegistryOwner, defaultArgs: LuaBundle?) {
        mSavedStateRegistry = owner.getSavedStateRegistry()
        mLifecycle = owner.getLifecycle()
        mContext = context
        mFactory = ViewModelProviderAndroidViewModelFactory()
        mDefaultArgs = defaultArgs
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
        let classes: Array<String>? = bundle?.getObject(Recreator.CLASSES_KEY) as! Array<String>?
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
    
    func saveState() -> LuaBundle {
        let bundle = LuaBundle()
        bundle.putObject(Recreator.CLASSES_KEY, mClasses)
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
    private var mRestoredState: LuaBundle?
    private var mRestored = false
    private var mRecreatorProvider: RecreatorSavedStateProvider?
    private var mAllowingSavingState = false
    
    @objc
    public func consumeRestoredStateForKey(key: String) -> LuaBundle? {
        if(!mRestored) {
            return nil
        }
        if(mRestoredState != nil) {
            let result: LuaBundle? = mRestoredState?.getBundle(key)
            mRestoredState?.bundle.removeObject(forKey: key)
            if(mRestoredState?.bundle.count == 0) {
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
    
    @objc
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
    
    func performRestore(lifecycle: Lifecycle, savedState: LuaBundle?) {
        if(mRestored) {
            return
        }
        if(savedState != nil) {
            mRestoredState = savedState?.getBundle(SavedStateRegistry.SAVED_COMPONENTS_KEY)
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
    
    func performSave(outBundle: inout LuaBundle) {
        let components = LuaBundle()
        if(mRestoredState != nil) {
            components.putBundle("bundle", mRestoredState)
        }
        for key in mComponents.keyEnumerator() {
            let val = mComponents.object(forKey: key) as! SavedStateProvider
            components.putBundle(key as? String, val.saveState())
        }
        outBundle.putBundle(SavedStateRegistry.SAVED_COMPONENTS_KEY, components)
    }
}

@objc(SavedStateProvider)
public protocol SavedStateProvider {
    func saveState() -> LuaBundle
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
    public func performRestore(savedStrate: LuaBundle?) {
        let lifecycle = mOwner.getLifecycle()
        if(lifecycle?.getCurrentState() != LifecycleState.LIFECYCLESTATE_INITIALIZED) {
            return
        }
        lifecycle?.add(Recreator(owner: mOwner))
        mRegistry.performRestore(lifecycle: lifecycle!, savedState: savedStrate)
    }
    
    @objc
    public func performSave(outBundle: LuaBundle) -> LuaBundle {
        var outBundleC = outBundle
        mRegistry.performSave(outBundle: &outBundleC)
        return outBundleC
    }
    
    static func create(owner: SavedStateRegistryOwner) -> SavedStateRegistryController {
        return SavedStateRegistryController(owner: owner)
    }
}
