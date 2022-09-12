import UIKit

class FragmentLifecycleCallbacksHolder {
    var mCallback: FragmentLifecycleCallbacks
    var mRecursive: Bool
    
    init(callback: FragmentLifecycleCallbacks, recursive: Bool) {
        mCallback = callback
        mRecursive = recursive
    }
}

class FragmentLifecycleCallbacksDispatcher: NSObject {
    var mLifecycleCallbacks = Array<FragmentLifecycleCallbacksHolder>()
    var mFragmentManager: FragmentManager
    
    init(fragmentManager: FragmentManager) {
        mFragmentManager = fragmentManager
    }
    
    func registerFragmentLifecycleCallbacks(cb: FragmentLifecycleCallbacks, recursive: Bool) {
        mLifecycleCallbacks.append(FragmentLifecycleCallbacksHolder(callback: cb, recursive: recursive))
    }
    
    func unregisterFragmentLifecycleCallbacks(cb: FragmentLifecycleCallbacks) {
        synced(self) {
            let count = mLifecycleCallbacks.count
            for i in 0..<count {
                if(mLifecycleCallbacks[i].mCallback == cb) {
                    mLifecycleCallbacks.remove(at: i)
                    break
                }
            }
        }
    }
    
    func dispatchOnFragmentPreAttached(f: LuaFragment, onlyRecursive: Bool) {
        let context = mFragmentManager.getHost()?.getContext()
        let parent = mFragmentManager.getParent()
        if(parent != nil) {
            let parentManager = (parent?.getParentFragmentManager())!
            parentManager.getLifecycleCallbacksDispatcher().dispatchOnFragmentPreAttached(f: f, onlyRecursive: true)
        }
        for holder in mLifecycleCallbacks {
            if(!onlyRecursive || holder.mRecursive) {
                holder.mCallback.onFragmentPreAttached(fm: mFragmentManager, f: f, context: context!)
            }
        }
    }
    
    func dispatchOnFragmentAttached(f: LuaFragment, onlyRecursive: Bool) {
        let context = mFragmentManager.getHost()?.getContext()
        let parent = mFragmentManager.getParent()
        if(parent != nil) {
            let parentManager = (parent?.getParentFragmentManager())!
            parentManager.getLifecycleCallbacksDispatcher().dispatchOnFragmentAttached(f: f, onlyRecursive: true)
        }
        for holder in mLifecycleCallbacks {
            if(!onlyRecursive || holder.mRecursive) {
                holder.mCallback.onFragmentAttached(fm: mFragmentManager, f: f, context: context!)
            }
        }
    }
    
    func dispatchOnFragmentPreCreated(f: LuaFragment, savedInstanceState: Dictionary<String, Any>, onlyRecursive: Bool) {
        _ = mFragmentManager.getHost()?.getContext()
        let parent = mFragmentManager.getParent()
        if(parent != nil) {
            let parentManager = (parent?.getParentFragmentManager())!
            parentManager.getLifecycleCallbacksDispatcher().dispatchOnFragmentPreCreated(f: f, savedInstanceState: savedInstanceState, onlyRecursive: true)
        }
        for holder in mLifecycleCallbacks {
            if(!onlyRecursive || holder.mRecursive) {
                holder.mCallback.onFragmentPreCreated(fm: mFragmentManager, f: f, savedInstanceState: savedInstanceState)
            }
        }
    }
    
    func dispatchOnFragmentCreated(f: LuaFragment, savedInstanceState: Dictionary<String, Any>, onlyRecursive: Bool) {
        var context = mFragmentManager.getHost()?.getContext()
        var parent = mFragmentManager.getParent()
        if(parent != nil) {
            var parentManager = (parent?.getParentFragmentManager())!
            parentManager.getLifecycleCallbacksDispatcher().dispatchOnFragmentCreated(f: f, savedInstanceState: savedInstanceState, onlyRecursive: true)
        }
        for holder in mLifecycleCallbacks {
            if(!onlyRecursive || holder.mRecursive) {
                holder.mCallback.onFragmentCreated(fm: mFragmentManager, f: f, savedInstanceState: savedInstanceState)
            }
        }
    }
    
    func dispatchOnFragmentViewCreated(f: LuaFragment, view: LGView, savedInstanceState: Dictionary<String, Any>, onlyRecursive: Bool) {
        var context = mFragmentManager.getHost()?.getContext()
        var parent = mFragmentManager.getParent()
        if(parent != nil) {
            var parentManager = (parent?.getParentFragmentManager())!
            parentManager.getLifecycleCallbacksDispatcher().dispatchOnFragmentViewCreated(f: f, view: view, savedInstanceState: savedInstanceState, onlyRecursive: true)
        }
        for holder in mLifecycleCallbacks {
            if(!onlyRecursive || holder.mRecursive) {
                holder.mCallback.onFragmentViewCreated(fm: mFragmentManager, f: f, v: view, savedInstanceState: savedInstanceState)
            }
        }
    }
    
    func dispatchOnFragmentStarted(f: LuaFragment, onlyRecursive: Bool) {
        var context = mFragmentManager.getHost()?.getContext()
        var parent = mFragmentManager.getParent()
        if(parent != nil) {
            var parentManager = (parent?.getParentFragmentManager())!
            parentManager.getLifecycleCallbacksDispatcher().dispatchOnFragmentStarted(f: f, onlyRecursive: true)
        }
        for holder in mLifecycleCallbacks {
            if(!onlyRecursive || holder.mRecursive) {
                holder.mCallback.onFragmentStarted(fm: mFragmentManager, f: f)
            }
        }
    }
    
    func dispatchOnFragmentResumed(f: LuaFragment, onlyRecursive: Bool) {
        var context = mFragmentManager.getHost()?.getContext()
        var parent = mFragmentManager.getParent()
        if(parent != nil) {
            var parentManager = (parent?.getParentFragmentManager())!
            parentManager.getLifecycleCallbacksDispatcher().dispatchOnFragmentResumed(f: f, onlyRecursive: true)
        }
        for holder in mLifecycleCallbacks {
            if(!onlyRecursive || holder.mRecursive) {
                holder.mCallback.onFragmentResumed(fm: mFragmentManager, f: f)
            }
        }
    }
    
    func dispatchOnFragmentPaused(f: LuaFragment, onlyRecursive: Bool) {
        var context = mFragmentManager.getHost()?.getContext()
        var parent = mFragmentManager.getParent()
        if(parent != nil) {
            var parentManager = (parent?.getParentFragmentManager())!
            parentManager.getLifecycleCallbacksDispatcher().dispatchOnFragmentPaused(f: f, onlyRecursive: true)
        }
        for holder in mLifecycleCallbacks {
            if(!onlyRecursive || holder.mRecursive) {
                holder.mCallback.onFragmentPaused(fm: mFragmentManager, f: f)
            }
        }
    }
    
    func dispatchOnFragmentStopped(f: LuaFragment, onlyRecursive: Bool) {
        var context = mFragmentManager.getHost()?.getContext()
        var parent = mFragmentManager.getParent()
        if(parent != nil) {
            var parentManager = (parent?.getParentFragmentManager())!
            parentManager.getLifecycleCallbacksDispatcher().dispatchOnFragmentStopped(f: f, onlyRecursive: true)
        }
        for holder in mLifecycleCallbacks {
            if(!onlyRecursive || holder.mRecursive) {
                holder.mCallback.onFragmentStopped(fm: mFragmentManager, f: f)
            }
        }
    }
    
    func dispatchOnFragmentSaveInstanceState(f: LuaFragment, outState: Dictionary<String, Any>, onlyRecursive: Bool) {
        var context = mFragmentManager.getHost()?.getContext()
        var parent = mFragmentManager.getParent()
        if(parent != nil) {
            var parentManager = (parent?.getParentFragmentManager())!
            parentManager.getLifecycleCallbacksDispatcher().dispatchOnFragmentSaveInstanceState(f: f, outState: outState, onlyRecursive: true)
        }
        for holder in mLifecycleCallbacks {
            if(!onlyRecursive || holder.mRecursive) {
                holder.mCallback.onFragmentSaveInstanceState(fm: mFragmentManager, f: f, outState: outState)
            }
        }
    }
    
    func dispatchOnFragmentViewDestroyed(f: LuaFragment, onlyRecursive: Bool) {
        var context = mFragmentManager.getHost()?.getContext()
        var parent = mFragmentManager.getParent()
        if(parent != nil) {
            var parentManager = (parent?.getParentFragmentManager())!
            parentManager.getLifecycleCallbacksDispatcher().dispatchOnFragmentViewDestroyed(f: f, onlyRecursive: true)
        }
        for holder in mLifecycleCallbacks {
            if(!onlyRecursive || holder.mRecursive) {
                holder.mCallback.onFragmentViewDestroyed(fm: mFragmentManager, f: f)
            }
        }
    }
    
    func dispatchOnFragmentDestroyed(f: LuaFragment, onlyRecursive: Bool) {
        var context = mFragmentManager.getHost()?.getContext()
        var parent = mFragmentManager.getParent()
        if(parent != nil) {
            var parentManager = (parent?.getParentFragmentManager())!
            parentManager.getLifecycleCallbacksDispatcher().dispatchOnFragmentDestroyed(f: f, onlyRecursive: true)
        }
        for holder in mLifecycleCallbacks {
            if(!onlyRecursive || holder.mRecursive) {
                holder.mCallback.onFragmentDestroyed(fm: mFragmentManager, f: f)
            }
        }
    }
    
    func dispatchOnFragmentDetached(f: LuaFragment, onlyRecursive: Bool) {
        var context = mFragmentManager.getHost()?.getContext()
        var parent = mFragmentManager.getParent()
        if(parent != nil) {
            var parentManager = (parent?.getParentFragmentManager())!
            parentManager.getLifecycleCallbacksDispatcher().dispatchOnFragmentDetached(f: f, onlyRecursive: true)
        }
        for holder in mLifecycleCallbacks {
            if(!onlyRecursive || holder.mRecursive) {
                holder.mCallback.onFragmentDetached(fm: mFragmentManager, f: f)
            }
        }
    }
}
