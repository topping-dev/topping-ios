import UIKit

@objc(FragmentViewLifecycleOwner)
open class FragmentViewLifecycleOwner: NSObject, HasDefaultViewModelProviderFactory, SavedStateRegistryOwner, ViewModelStoreOwner {
    let mFragment: LuaFragment
    let mViewModelStore: ViewModelStore;
    
    var mDefaultFactory: ViewModelProviderFactory? = nil
    
    var mLifecycleRegistry: LifecycleRegistry? = nil
    var mSavedStateRegistryController: SavedStateRegistryController? = nil
    
    @objc public init(fragment: LuaFragment, viewModelStore: ViewModelStore) {
        self.mFragment = fragment
        self.mViewModelStore = viewModelStore
    }
    
    public func getViewModelStore() -> ViewModelStore! {
        initialize()
        return mViewModelStore
    }
    
    @objc public func initialize() {
        if(mLifecycleRegistry == nil) {
            mLifecycleRegistry = LifecycleRegistry(owner: self);
            mSavedStateRegistryController = SavedStateRegistryController.create(owner: self)
        }
    }
    
    @objc public func isInitialized() -> Bool {
        return mLifecycleRegistry != nil
    }
    
    @objc public func getLifecycle() -> Lifecycle! {
        initialize()
        return mLifecycleRegistry;
    }
    
    @objc public func setCurrentState(state: LifecycleState) {
        mLifecycleRegistry?.setCurrentState(state)
    }
    
    @objc public func handleLifecycleEvent(event: LifecycleEvent) {
        mLifecycleRegistry?.handle(event)
    }
    
    @objc
    public func getDefaultViewModelProviderFactory() -> ViewModelProviderFactory {
        let currentFactory = mFragment.getDefaultViewModelProviderFactory()
        
        if(currentFactory != nil && !currentFactory!.isEqual(mFragment.mDefaultFactory)) {
            mDefaultFactory = currentFactory
            return currentFactory!
        }
        
        if(mDefaultFactory == nil) {
            mDefaultFactory = SavedStateViewModelFactory(context: mFragment.context, owner: self, defaultArgs: mFragment.getArguments())
        }
        
        return mDefaultFactory!
    }
    
    @objc
    public func getSavedStateRegistry() -> SavedStateRegistry {
        initialize()
        return (mSavedStateRegistryController?.getSavedStateRegistry())!
    }
    
    @objc public func performRestore(savedState: LuaBundle?) {
        mSavedStateRegistryController?.performRestore(savedStrate: savedState)
    }
    
    @objc public func performSave(savedState: LuaBundle) {
        mSavedStateRegistryController?.performSave(outBundle: savedState)
    }
}
