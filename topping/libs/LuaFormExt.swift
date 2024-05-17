import Foundation

@objc(LuaFormOnBackPressedDispatcher)
open class LuaFormOnBackPressedDispatcher: OnBackPressedDispatcher {
    @objc
    public init(form: LuaForm) {
        super.init {
            form.onBackPressed()
        }
    }
}

@objc(LuaFormSavedStateProvider)
open class LuaFormSavedStateProvider: NSObject, SavedStateProvider {
    
    let form: LuaForm
    
    @objc
    public init(form: LuaForm) {
        self.form = form
    }
    
    public func saveState() -> LuaBundle {
        var outState = LuaBundle()
        form.markFragmentsCreated()
        form.lifecycleRegistry.handle(LifecycleEvent.LIFECYCLEEVENT_ON_STOP)
        var p = form.mFragments.saveAllState()
        if(p != nil) {
            outState.putObject("android:support:fragments", p)
        }
        return outState
    }
}
