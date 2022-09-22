import UIKit

@objc(FragmentController)
open class FragmentController: NSObject {
    
    private var mHost: FragmentHostCallback
    
    private init(callback: FragmentHostCallback) {
        mHost = callback
    }
    
    @objc
    public static func createController(fragmentHostCallback: FragmentHostCallback) -> FragmentController {
        return FragmentController(callback: fragmentHostCallback)
    }
    
    @objc
    public func getSupportFragmentManager() -> FragmentManager { return mHost.fragmentManager }
    
    @objc
    public func findFragmentByWho(who: String) -> LuaFragment? {
        return mHost.fragmentManager.findFragmentByWho(who: who)
    }
    
    @objc
    public func getActiveFragmentsCount() -> Int {
        return mHost.fragmentManager.getActiveFragmentCount()
    }
    
    @objc
    public func getActiveFragments() -> NSArray {
        return mHost.fragmentManager.getActiveFragments().objcArray
    }

    @objc
    public func attachHost(parent: LuaFragment?) {
        mHost.fragmentManager.attachController(host: mHost, container: mHost, parent: parent)
    }
    
    @objc
    public func onCreateView(parent: LGView?, name: String, context: LuaContext, attrs: NSArray) -> LGView {
        return mHost.fragmentManager.getLayoutInflaterFactory().parseUI(name, parent?._view, parent, mHost.form, attrs.swiftArray)
    }
    
    @objc
    public func noteStateNotSaved() {
        mHost.fragmentManager.noteStateNotSaved()
    }
    
    @objc
    public func saveAllState() -> FragmentManagerState? {
        return mHost.fragmentManager.saveAllState()
    }
    
    @objc
    public func restoreAllState(state: FragmentManagerState?) {
        mHost.fragmentManager.restoreSaveState(state: state)
    }
    
    @objc
    public func dispatchCreate() {
        mHost.fragmentManager.dispatchCreate()
    }
    
    @objc
    public func dispatchActivityCreated() {
        mHost.fragmentManager.dispatchActivityCreated()
    }
    
    @objc
    public func dispatchStart() {
        mHost.fragmentManager.dispatchStart()
    }

    @objc
    public func dispatchResume() {
        mHost.fragmentManager.dispatchResume()
    }
    
    @objc
    public func dispatchPause() {
        mHost.fragmentManager.dispatchPause()
    }
    
    @objc
    public func dispatchStop() {
        mHost.fragmentManager.dispatchStop()
    }
    
    @objc
    public func dispatchDestroyView() {
        mHost.fragmentManager.dispatchDestroyView()
    }
    
    @objc
    public func dispatchDestroy() {
        mHost.fragmentManager.dispatchDestroy()
    }
    
    @objc
    public func execPendingActions() {
        mHost.fragmentManager.execPendingActions(allowStateLoss: true)
    }
}
