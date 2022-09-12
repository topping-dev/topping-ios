import Foundation

class LifecycleEventObserverI: LuaLifecycleObserver {
    
    var onStateChangedO:(LifecycleOwner, LifecycleEvent) -> () = {_,_ in }
    
    override init() {
        
    }
    
    init(overrides: (LifecycleEventObserverI) -> LifecycleEventObserverI) {
        super.init()
        overrides(self)
    }
    
    override func onStateChanged(_ source: LifecycleOwner!, _ event: LifecycleEvent) {
        self.onStateChangedO(source, event)
    }
}
