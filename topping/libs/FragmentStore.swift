import UIKit

class FragmentStore: NSObject {
    var mAdded: Array<LuaFragment?> = []
    var mActive: Dictionary<String, FragmentStateManager?> = Dictionary()
    var mSavedState: Dictionary<String, FragmentStateStore> = Dictionary()
    
    var mNonConfig: FragmentManagerViewModel = FragmentManagerViewModel(stateAutomaticallySaved: false)
    
    override init() {
        
    }
    
    func setNonConfig(nonConfig: FragmentManagerViewModel) {
        mNonConfig = nonConfig
    }
    
    func getNonConfig() -> FragmentManagerViewModel {
        return mNonConfig
    }
    
    func resetActiveFragments() {
        mActive.removeAll()
    }
    
    func restoreAddedFragments(added: Array<String>?) {
        mAdded.removeAll()
        if(added != nil) {
            for who in added! {
                var f = findActiveFragment(who: who)
                if(f == nil) {
                    return
                }
                addFragment(fragment: f!)
            }
        }
    }
    
    func makeActive(newlyActive: FragmentStateManager) {
        var f = newlyActive.getFragment()
        if(containsActiveFragment(who: f.mWho)) {
            return
        }
        mActive[f.mWho] = newlyActive
        if(f.mRetainInstanceChangedWhileDetached) {
            if(f.mRetainInstance) {
                mNonConfig.addRetainedFragment(fragment: f)
            } else {
                mNonConfig.removeRetainedFragment(fragment: f)
            }
        }
    }
    
    func addFragment(fragment: LuaFragment) {
        if(mAdded.contains(fragment)) {
            return
        }
        synced(self) {
            mAdded.append(fragment)
        }
        fragment.mAdded = true
    }
    
    func dispatchStateChange(state: Int) {
        for fragmentStateManager in mActive.values {
            fragmentStateManager?.setFragmentManagerState(state: state)
        }
    }
    
    func moveToExpectedState() {
        for f in mAdded {
            var fragmentStateManager = mActive[f?.mWho ?? ""]
            if(fragmentStateManager != nil) {
                fragmentStateManager!!.moveToExpectedState()
            }
        }
        
        for fragmentStateManager in mActive.values {
            if(fragmentStateManager != nil) {
                fragmentStateManager!.moveToExpectedState()
                
                var f = fragmentStateManager!.getFragment()
                var beingRemoved = f.mRemoving && !f.isInBackStack()
                if(beingRemoved) {
                    if(f.mBeingSaved && mSavedState[f.mWho] != nil) {
                        fragmentStateManager!.saveState()
                    }
                    makeInactive(newlyActive: fragmentStateManager.unsafelyUnwrapped)
                }
            }
        }
    }
    
    func removeFragment(fragment: LuaFragment) {
        synced(self) {
            mAdded.remove(object: fragment)
        }
        fragment.mAdded = false
    }
    
    func makeInactive(newlyActive: FragmentStateManager) {
        var f = newlyActive.getFragment()
        
        if(f.mRetainInstance) {
            mNonConfig.removeRetainedFragment(fragment: f)
        }
        
        var removedStateManager = mActive[f.mWho]
        if(removedStateManager == nil) {
            return
        }
        mActive.removeValue(forKey: f.mWho)
    }
    
    func burpActive() {
        mActive.removeAll()
    }
    
    func getSavedState(who: String) -> FragmentStateStore? {
        return mSavedState[who]
    }
    
    func setSavedState(who: String, fragmentState: FragmentStateStore?) -> FragmentStateStore? {
        if(fragmentState != nil) {
            var ret = mSavedState[who]
            if(ret != nil) {
                return ret
            }
            else {
                mSavedState[who] = fragmentState
                return fragmentState
            }
        } else {
            var ret = mSavedState[who]
            mSavedState.removeValue(forKey: who)
            return ret
        }
    }
    
    func restoreSavedState(savedState: Array<FragmentStateStore>) {
        mSavedState.removeAll()
        for fs in savedState {
            mSavedState[fs.mWho ?? ""] = fs
        }
    }
    
    func getAllSavedState() -> Array<FragmentStateStore> {
        return Array(mSavedState.values)
    }
    
    func saveActiveFragments() -> Array<String> {
        var active = Array<String>()
        for fragmentStateManager in mActive.values {
            if(fragmentStateManager != nil) {
                var f = fragmentStateManager!.getFragment()
                
                fragmentStateManager!.saveState()
                active.append(f.mWho)
            }
        }
        
        return active
    }
    
    func saveAddedFragments() -> Array<String>? {
        let res = syncedRet(self) {
            if(mAdded.isEmpty) {
                return nil
            }
            
            var added = Array<String>()
            for f in mAdded {
                added.append(f?.mWho ?? "")
            }
            return added
        }
        if(res != nil)
        {
            return res as! Array<String>
        }
        else {
            return nil
        }
    }
    
    func getActiveFragmentStateManagers() -> Array<FragmentStateManager> {
        var activeFragmentStateManagers = Array<FragmentStateManager>()
        for fragmentStateManager in mActive.values {
            if(fragmentStateManager != nil) {
                activeFragmentStateManagers.append(fragmentStateManager!)
            }
        }
        return activeFragmentStateManagers
    }
    
    func getFragments() -> Array<LuaFragment> {
        if(mAdded.isEmpty) {
            return Array()
        }
        return syncedRet(self) {
            return Array(mAdded)
        } as! Array<LuaFragment>
    }
    
    func getActiveFragments() -> Array<LuaFragment?> {
        var activeFragments = Array<LuaFragment?>()
        for fragmentStateManager in mActive.values {
            if(fragmentStateManager != nil) {
                activeFragments.append(fragmentStateManager?.getFragment())
            } else {
                activeFragments.append(nil)
            }
        }
        return activeFragments
    }
    
    func getActiveFragmentCount() -> Int {
        return mActive.count
    }
    
    func findFragmentById(id: String) -> LuaFragment? {
        for i in (0..<mAdded.count).reversed() {
            let f = mAdded[i]
            if(f != nil && f?.mFragmentId == id) {
                return f
            }
        }
        for fragmentStateManager in mActive.values {
            if(fragmentStateManager != nil) {
                let f = fragmentStateManager?.getFragment()
                if(f?.mFragmentId == id) {
                    return f
                }
            }
        }
        return nil
    }
    
    func findFragmentByTag(tag: String) -> LuaFragment? {
        if(tag != nil) {
            for i in (0..<mAdded.count).reversed() {
                let f = mAdded[i]
                if(f != nil && f?.mTag == tag) {
                    return f
                }
            }
            for fragmentStateManager in mActive.values {
                if(fragmentStateManager != nil) {
                    let f = fragmentStateManager?.getFragment()
                    if(f?.mTag == tag) {
                        return f
                    }
                }
            }
        }
        return nil
    }
    
    func containsActiveFragment(who: String) -> Bool {
        return mActive[who] != nil
    }
    
    func getFragmentStateManager(who: String) -> FragmentStateManager? {
        return mActive[who] ?? nil
    }
    
    func findFragmentByWho(who: String) -> LuaFragment? {
        for fragmentStateManager in mActive.values {
            if(fragmentStateManager != nil) {
                var f = fragmentStateManager?.getFragment()
                var fn = f?.find(byWho: who)
                if(fn != nil) {
                    return fn
                }
            }
        }
        return nil
    }
    
    func findActiveFragment(who: String) -> LuaFragment? {
        let fragmentStateManager = mActive[who]
        if(fragmentStateManager != nil) {
            return fragmentStateManager!!.getFragment()
        }
        return nil
    }
    
    func findFragmentIndexInContainer(f: LuaFragment) -> Int {
        
        //TODO
        var container = f.mContainer
        
        if(container == nil) {
            return -1
        }
        /*var fragmentIndex = mActive.keys.firstIndex(of: f.mWho)
        for i in mActive.enu
        if(fragmentIndex == nil) {
            fragmentIndex = -1
        }
        else {
            fragmentIndex = fragmentIndex!
        }
        for i in (0..<fragmentIndex).reversed() {
            let underFragment = mAdded[i]
        }*/
        
        return 0
    }
}
