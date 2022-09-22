import Foundation

@objc public protocol OnBackPressedDispatcherOwner : LifecycleOwner {
    func getOnBackPressedDispatcher() -> OnBackPressedDispatcher
}

class OnBackPressedCallback : NSObject, Keyable {
    var key: String = UUID.init().uuidString
    
    private var mEnabled: Bool
    private var mCancellables = Array<Cancellable>()
    
    init(enabled: Bool) {
        mEnabled = enabled
    }
    
    func setEnabled(enabled: Bool) { mEnabled = enabled }
    
    func isEnabled() -> Bool { return mEnabled }
    
    func remove() {
        for cancellable in mCancellables {
            cancellable.cancel()
        }
    }
    
    func handleOnBackPressed() {
        
    }
    
    func addCancellable(cancellable: Cancellable) {
        mCancellables.append(cancellable)
    }
    
    func removeCancellable(cancellable: Cancellable) {
        var indexToRemove = -1
        for (index, v) in mCancellables.enumerated() {
            if(v.key == cancellable.key) {
                indexToRemove = index
                break
            }
        }
        if (indexToRemove != -1) {
            mCancellables.remove(at: indexToRemove)
        }
    }
}

@objc(OnBackPressedDispatcher)
open class OnBackPressedDispatcher : NSObject {
    var mFallbackOnBackPressed: (() -> ())?
    
    var mOnBackPressedCallbacks = Array<OnBackPressedCallback>()
    
    override init() {
        mFallbackOnBackPressed = nil
    }
    
    init(fallbackOnBackPressed:(() -> ())?) {
        mFallbackOnBackPressed = fallbackOnBackPressed
    }
    
    func addCallback(onBackPressedCallback: OnBackPressedCallback) {
        
    }
    
    func addCancellableCallback(onBackPressedCallback: OnBackPressedCallback) -> Cancellable {
        mOnBackPressedCallbacks.append(onBackPressedCallback)
        var cancellable = OnBackPressedCancellable(onBackPressedCallbacks: mOnBackPressedCallbacks, onBackPressedCallback: onBackPressedCallback)
        onBackPressedCallback.addCancellable(cancellable: cancellable)
        return cancellable
    }
    
    func addCallback(owner: LifecycleOwner, onBackPressedCallback: OnBackPressedCallback) {
/*        var lifecycle = owner.getLifecycle()
        if(lifecycle.)*/
    }
    
    func hasEnabledCallbacks() -> Bool {
        var iterator = mOnBackPressedCallbacks.reversed().makeIterator()
        var obj = iterator.next()
        while(obj != nil) {
            if (obj!.isEnabled()) {
                return true
            }
            obj = iterator.next()
        }
        return false
    }
    
    func onBackPressed() {
        var iterator = mOnBackPressedCallbacks.reversed().makeIterator()
        var obj = iterator.next()
        while(obj != nil) {
            if(obj!.isEnabled()) {
                obj!.handleOnBackPressed()
                return
            }
            obj = iterator.next()
        }
        if(mFallbackOnBackPressed != nil) {
            mFallbackOnBackPressed!()
        }
    }
    
    class OnBackPressedCancellable : Cancellable {
        var key: String = UUID.init().uuidString
        
        private var mOnBackPressedCallbacks: Array<OnBackPressedCallback>
        private var mOnBackPressedCallback: OnBackPressedCallback
        
        init(onBackPressedCallbacks: Array<OnBackPressedCallback>, onBackPressedCallback: OnBackPressedCallback) {
            mOnBackPressedCallbacks = onBackPressedCallbacks
            mOnBackPressedCallback = onBackPressedCallback
        }
        
        func cancel() {
            var indexToRemove = -1
            for (index, v) in mOnBackPressedCallbacks.enumerated() {
                if(v.key == mOnBackPressedCallback.key) {
                    indexToRemove = index
                    break
                }
            }
            if (indexToRemove != -1) {
                mOnBackPressedCallbacks.remove(at: indexToRemove)
            }
        }
    }
    
    @objc(LifecycleOnBackPressedCancellable)
    open class LifecycleOnBackPressedCancellable : NSObject, LifecycleEventObserver, Cancellable {
        var key: String = UUID.init().uuidString
        
        private var mLifecycle: LuaLifecycle
        private var mOnBackPressedCallback: OnBackPressedCallback
        private var mCurrentCancellable: Cancellable?
        
        private var mOnBackPressedDispatcher: OnBackPressedDispatcher
        
        init(lifecycle: LuaLifecycle, onBackPressedCallback: OnBackPressedCallback, onBackPressedDispatcher: OnBackPressedDispatcher) {
            mLifecycle = lifecycle
            mOnBackPressedCallback = onBackPressedCallback
            mOnBackPressedDispatcher = onBackPressedDispatcher
            super.init()
            lifecycle.add(self)
        }
        
        public func getKey() -> String! {
            return key
        }
        
        public func onStateChanged(_ source: LifecycleOwner!, _ event: LifecycleEvent) {
            if(event == LifecycleEvent.LIFECYCLEEVENT_ON_START) {
                mCurrentCancellable = mOnBackPressedDispatcher.addCancellableCallback(onBackPressedCallback: mOnBackPressedCallback)
            } else if(event == LifecycleEvent.LIFECYCLEEVENT_ON_STOP) {
                mCurrentCancellable?.cancel()
            } else if(event == LifecycleEvent.LIFECYCLEEVENT_ON_DESTROY) {
                cancel()
            }
        }
                
        func cancel() {
            mLifecycle.remove(self)
            mOnBackPressedCallback.removeCancellable(cancellable: self)
            mCurrentCancellable?.cancel()
            mCurrentCancellable = nil
        }
    }
}
