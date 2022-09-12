import Foundation

class FragmentManagerViewModel : LuaViewModel {
    var mRetainedFragments = Dictionary<String, LuaFragment>()
    var mChildNonConfigs = Dictionary<String, FragmentManagerViewModel>()
    var mViewModelStores = Dictionary<String, ViewModelStore>()
    
    var mStateAutomaticallySaved :Bool
    var mHasBeenCleared = false
    var mHasSavedSnapshot = false
    var mIsStateSaved = false
    
    static func getInstance(viewModelStore: ViewModelStore) -> FragmentManagerViewModel {
        var viewModel = FragmentManagerViewModel(stateAutomaticallySaved: true)
        return viewModel
    }
    
    init(stateAutomaticallySaved: Bool) {
        mStateAutomaticallySaved = stateAutomaticallySaved
    }
    
    func setIsStateSaved(isStateSaved: Bool) {
        mIsStateSaved = isStateSaved
    }
    
    override func onCleared() {
        mHasBeenCleared = true
    }
    
    func isCleared() -> Bool {
        return mHasBeenCleared
    }
    
    func addRetainedFragment(fragment: LuaFragment) {
        if(mIsStateSaved)
        {
            return
        }
        if(mRetainedFragments[fragment.mWho] != nil) {
            return
        }
        mRetainedFragments[fragment.mWho] = fragment
    }
    
    func findRetainedFragment(who: String) -> LuaFragment? {
        return mRetainedFragments[who]
    }
    
    func getRetainedFragments() -> Dictionary<String, LuaFragment>.Values {
        return mRetainedFragments.values
    }
    
    func shouldDestroy(fragment: LuaFragment) -> Bool {
        if(mRetainedFragments[fragment.mWho] == nil)
        {
            return true
        }
        if(mStateAutomaticallySaved) {
            return mHasBeenCleared
        } else {
            return !mHasSavedSnapshot
        }
    }
    
    func removeRetainedFragment(fragment: LuaFragment) {
        if(mIsStateSaved) {
            return
        }
        mRetainedFragments.removeValue(forKey: fragment.mWho)
    }
    
    func getChildNonConfig(f: LuaFragment) -> FragmentManagerViewModel? {
        var childNonConfig = mChildNonConfigs[f.mWho]
        if(childNonConfig == nil) {
            childNonConfig = FragmentManagerViewModel(stateAutomaticallySaved: mStateAutomaticallySaved)
            mChildNonConfigs[f.mWho] = childNonConfig
        }
        return childNonConfig
    }
    
    func getViewModelStore(f: LuaFragment) -> ViewModelStore {
        var viewModelStore = mViewModelStores[f.mWho]
        if(viewModelStore == nil) {
            viewModelStore = ViewModelStore()
            mViewModelStores[f.mWho] = viewModelStore
        }
        return viewModelStore!
    }
    
    func clearNonConfigState(f: LuaFragment) {
        clearNonConfigState(who: f.mWho)
    }
    
    func clearNonConfigState(who: String) {
        clearNonConfigStateInternal(who: who)
    }
    
    private func clearNonConfigStateInternal(who: String) {
        var childNonConfig = mChildNonConfigs[who]
        if(childNonConfig != nil) {
            childNonConfig?.onCleared()
            mChildNonConfigs.removeValue(forKey: who)
        }
        var viewModelStore = mViewModelStores[who]
        if(viewModelStore != nil) {
            viewModelStore!.clear()
            mViewModelStores.removeValue(forKey: who)
        }
    }
}
