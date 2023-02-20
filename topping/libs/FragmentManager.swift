import UIKit
import CoreMIDI

protocol BackStackEntry {
    
    func getId() -> Int
    func getName() -> String?
}

@objc(OnBackStackChangedListener)
open class OnBackStackChangedListener : NSObject {
    func onBackStackChanged() {
        
    }
}

protocol FragmentOnAttachListener : Keyable {
    func onAttachFragment(fragmentManager: FragmentManager, fragment: LuaFragment)
}

protocol FragmentResultListener {
    func onFragmentResult(key: String, result: Dictionary<String, Any>)
}

@objc(LifecycleAwareResultListener)
open class LifecycleAwareResultListener : NSObject, FragmentResultListener {
    var mLifecycle: Lifecycle
    var mListener: FragmentResultListener
    var mObserver: LifecycleObserver
    
    init(lifecycle: Lifecycle, listener: FragmentResultListener, observer: LifecycleObserver) {
        mLifecycle = lifecycle
        mListener = listener
        mObserver = observer
    }
    
    @objc func isAtLeast(state: LifecycleState) -> Bool {
        return Lifecycle.is(atLeast: mLifecycle.getCurrentState(), state)
    }
    
    @objc func onFragmentResult(key: String, result: Dictionary<String, Any>) {
        mListener.onFragmentResult(key: key, result: result)
    }
    
    @objc func removeObserver() {
        mLifecycle.remove(mObserver)
    }
}

@objc(FragmentLifecycleCallbacks)
public protocol FragmentLifecycleCallbacks: NSObjectProtocol {
    
    @objc func onFragmentPreAttached(fm: FragmentManager, f:LuaFragment, context:LuaContext)
    
    @objc func onFragmentAttached(fm: FragmentManager, f:LuaFragment, context:LuaContext)

    @objc func onFragmentPreCreated(fm: FragmentManager, f:LuaFragment, savedInstanceState:Dictionary<String, Any>?)

    @objc func onFragmentCreated(fm: FragmentManager, f:LuaFragment, savedInstanceState:Dictionary<String, Any>?)

    @objc func onFragmentActivityCreated(fm: FragmentManager, f:LuaFragment, savedInstanceState:Dictionary<String, Any>?)

    @objc func onFragmentViewCreated(fm: FragmentManager, f:LuaFragment, v:LGView, savedInstanceState:Dictionary<String, Any>?)

    @objc func onFragmentStarted(fm: FragmentManager, f:LuaFragment)

    @objc func onFragmentResumed(fm: FragmentManager, f:LuaFragment)

    @objc func onFragmentPaused(fm: FragmentManager, f:LuaFragment)

    @objc func onFragmentStopped(fm: FragmentManager, f:LuaFragment)

    @objc func onFragmentSaveInstanceState(fm: FragmentManager, f:LuaFragment, outState:Dictionary<String, Any>)

    @objc func onFragmentViewDestroyed(fm: FragmentManager, f:LuaFragment)

    @objc func onFragmentDestroyed(fm: FragmentManager, f:LuaFragment)

    @objc func onFragmentDetached(fm: FragmentManager, f:LuaFragment)
}

@objc(Op)
open class Op: NSObject {
    var mCmd: Int = 0
    var mFragment: LuaFragment? = nil
    var mFromExpandedOp: Bool = false
    var mEnterAnim: String = ""
    var mExitAnim: String = ""
    var mPopEnterAnim: String = ""
    var mPopExitAnim: String = ""
    var mOldMaxState: LifecycleState? = nil
    var mCurrentMaxState: LifecycleState? = nil
    
    @objc override init() {
    }
    
    @objc init(cmd: Int, fragment: LuaFragment?) {
        mCmd = cmd
        mFragment = fragment
        mFromExpandedOp = false
        mOldMaxState = LifecycleState.LIFECYCLESTATE_RESUMED
        mCurrentMaxState = LifecycleState.LIFECYCLESTATE_RESUMED
    }
    
    @objc init(cmd: Int, fragment: LuaFragment?, fromExpandedOp: Bool) {
        mCmd = cmd
        mFragment = fragment
        mFromExpandedOp = fromExpandedOp
        mOldMaxState = LifecycleState.LIFECYCLESTATE_RESUMED
        mCurrentMaxState = LifecycleState.LIFECYCLESTATE_RESUMED
    }
    
    @objc init(cmd: Int, fragment: LuaFragment?, state: LifecycleState) {
        mCmd = cmd
        mFragment = fragment
        mFromExpandedOp = false
        mOldMaxState = fragment?.mMaxState
        mCurrentMaxState = state
    }
    
    @objc init(op: Op) {
        mCmd = op.mCmd
        mFragment = op.mFragment
        mFromExpandedOp = op.mFromExpandedOp
        mEnterAnim = op.mEnterAnim
        mExitAnim = op.mExitAnim
        mPopEnterAnim = op.mPopEnterAnim
        mPopExitAnim = op.mPopExitAnim
        mOldMaxState = op.mOldMaxState
        mCurrentMaxState = op.mCurrentMaxState
    }

}

@objc(FragmentFactory)
open class FragmentFactory : NSObject {
    @objc public override init() {
        
    }
    
    @objc
    public func instantiate() -> LuaFragment? {
        //TODO find context here
        LuaFragment.create(LuaContext.init(), LuaRef.withValue(""))
    }
    
    @objc
    public func instantiate(className: String) -> LuaFragment? {
        let cls: LuaFragment.Type = Utils.getClassForClassName(className: className)!
        return cls.create(LuaContext.init(), LuaRef.withValue(""))
    }
}

protocol OpGenerator {
    func generateOps(records: inout Array<BackStackRecord>, isRecordPop: inout Array<Bool>) -> Bool
}

class BackStackState {
    var mFragments: Array<String>
    private var mTransactions: Array<BackStackRecordState?>
    
    init(fragments: Array<String>, transactions: Array<BackStackRecordState?>) {
        mFragments = fragments
        mTransactions = transactions
    }
    
    func instantiate(fm: FragmentManager, pendingSavedFragments: Dictionary<String, LuaFragment>) -> Array<BackStackRecord> {
        var fragments = Dictionary<String, LuaFragment>()
        for fWho in mFragments {
            let existingFragment = pendingSavedFragments[fWho]
            if(existingFragment != nil) {
                fragments[(existingFragment?.mWho)!] = existingFragment
                continue;
            }
            /*
             //TODO
             var fragmentState = fm.getFragmenntStore().setSavedState(fWho, nil)
             */
        }
        
        var transactions: Array<BackStackRecord> = []
        for backStackRecordState in mTransactions {
            //TODO check this
            if(backStackRecordState != nil) {
                transactions.append(backStackRecordState!.instantiate(fm: fm, fragments: fragments))
            }
            else {
                transactions.append(BackStackRecord(manager: fm))
            }
        }
        return transactions
    }
}

struct LaunchedFragmentInfo {
    var mWho: String
    var mRequestCode: Int
}

class PopBackStackState : OpGenerator {
    private var fm: FragmentManager
    private var mName: String?
    private var mId: Int
    private var mFlags: Int
    
    init(fm: FragmentManager, name: String?, id: Int, flags: Int) {
        self.fm = fm
        mName = name
        mId = id
        mFlags = flags
    }
    
    func generateOps(records: inout Array<BackStackRecord>, isRecordPop: inout Array<Bool>) -> Bool {
        if(fm.mPrimaryNav != nil && mId < 0 && mName == nil) {
            let childManager = fm.mPrimaryNav!.getChildFragmentManager()
            if(childManager!.popBackStackImmediate()) {
                return false
            }
        }
        return fm.popBackStackState(records: &records, isRecordPop: &isRecordPop, name: mName, id: mId, flags: mFlags)
    }
}

class RestoreBackStackState : OpGenerator {
    private var fm: FragmentManager
    private var mName: String?
    
    init(fm: FragmentManager, name: String?) {
        self.fm = fm
        mName = name
    }
    
    func generateOps(records: inout Array<BackStackRecord>, isRecordPop: inout Array<Bool>) -> Bool {
        return fm.restoreBackStackState(records: &records, isRecordPop: &isRecordPop, name: mName ?? "")
    }
}

class SaveBackStackState : OpGenerator {
    private var fm: FragmentManager
    private var mName: String?
    
    init(fm: FragmentManager, name: String?) {
        self.fm = fm
        mName = name
    }
    
    func generateOps(records: inout Array<BackStackRecord>, isRecordPop: inout Array<Bool>) -> Bool {
        return fm.saveBackStackState(records: &records, isRecordPop: &isRecordPop, name: mName ?? "")
    }
}

class ClearBackStackState : OpGenerator {
    private var fm: FragmentManager
    private var mName: String?
    
    init(fm: FragmentManager, name: String?) {
        self.fm = fm
        mName = name
    }
    
    func generateOps(records: inout Array<BackStackRecord>, isRecordPop: inout Array<Bool>) -> Bool {
        return fm.clearBackStackState(records: &records, isRecordPop: &isRecordPop, name: mName ?? "")
    }
}

class HostFragmentFactory: FragmentFactory {
    var fm: FragmentManager
    
    init(fm: FragmentManager) {
        self.fm = fm
    }
    
    override func instantiate() -> LuaFragment? {
        return fm.getHost()?.instantiate(context: fm.getHost()!.context, arguments: nil)
    }
    
    override func instantiate(className: String) -> LuaFragment? {
        return fm.getHost()?.instantiate(context: fm.getHost()!.context, className: className, arguments: nil)
    }
}

class OnBackPressedCallbackI: OnBackPressedCallback {
    var fm: FragmentManager
    var handleOnBackPressedO:() -> () = { }
    
    init(fm: FragmentManager, enabled: Bool, overrides: (OnBackPressedCallbackI) -> OnBackPressedCallbackI) {
        self.fm = fm
        super.init(enabled: enabled)
        overrides(self)
    }
    
    override func handleOnBackPressed() {
        self.handleOnBackPressedO()
    }
}

class ExecCommitRunnable : Runnable {
    var key: String = UUID.init().uuidString
    
    let fm: FragmentManager
    
    init(fm: FragmentManager) {
        self.fm = fm
    }
    
    func run() {
        fm.execPendingActions(allowStateLoss: true)
    }
}

@objc(LGFragmentLayoutParser)
public class LGFragmentLayoutParser: LGLayoutParser {
    var mFragmentManager: FragmentManager
    
    @objc
    public init(fragmentManager: FragmentManager) {
        mFragmentManager = fragmentManager
        super.init()
        super.initialize()
    }

    override public func getViewFromName(_ name: String!, _ attrs: [Any]!, _ parent: LGView!) -> LGView! {
        if(name == "androidx.fragment.app.FragmentContainerView"
           || name == "LGFragmentContainerView") {
            let result = LGFragmentContainerView(fragmentManager: mFragmentManager)
            result?.initProperties()
            return result
        }
        return super.getViewFromName(name, attrs, parent)
    }
    
    public override func applyOverrides(_ parent: LGView!, _ lgview: LGView!) {
        super.applyOverrides(parent, lgview)
        
        /*if(!(lgview is LGFragmentContainerView)) {
            return;
        }
        let idVal = lgview.getId()
        let tag = lgview.android_tag
        let containerId = parent != nil ? parent.getId() : nil
        let fname = lgview.android_name
        if(containerId == nil && idVal == nil && tag == nil) {
            return
        }
        
        var fragment = idVal != nil ? mFragmentManager.findFragmentById(id: idVal!) : nil
        if(fragment == nil && tag != nil) {
            fragment = mFragmentManager.findFragmentByTag(tag: tag!)
        }
        if(fragment == nil && containerId != nil) {
            fragment = mFragmentManager.findFragmentById(id: containerId!)
        }
        
        var fragmentStateManager: FragmentStateManager?
        if(fragment == nil) {
            fragment = mFragmentManager.getFragmentFactory()?.instantiate(className: fname!)
            fragment?.mFromLayout = true
            fragment?.mFragmentId = idVal != nil ? idVal : containerId
            fragment?.mContainerId = containerId
            fragment?.mTag = tag
            fragment?.mInLayout = true
            fragment?.mFragmentManager = mFragmentManager
            fragment?.mHost = mFragmentManager.getHost()
            fragment?.onInflate(mFragmentManager.getHost()?.context, [:], fragment!.mSavedFragmentState)
            fragmentStateManager = mFragmentManager.addFragment(fragment: fragment!)
        } else if(fragment!.mInLayout) {
            return
        } else {
            fragment?.mInLayout = true
            fragment?.mFragmentManager = mFragmentManager
            fragment?.mHost = mFragmentManager.getHost()
            fragment?.onInflate(mFragmentManager.getHost()?.context, [:], fragment?.mSavedFragmentState)
        }
        
        fragment?.mContainer = parent as? LGViewGroup
        fragmentStateManager?.moveToExpectedState()
        fragmentStateManager?.ensureInflatedView()
        
        if(fragment?.lgview == nil) {
            return
        }
        if(idVal != "") {
            fragment?.lgview.android_id = idVal
        }
        if(fragment?.lgview.android_tag == nil) {
            fragment?.lgview.android_tag = tag
        }*/
        //TODO:Add on attach state
        //fragment?.view.addon
    }
}


@objc(FragmentManager)
open class FragmentManager: NSObject, LuaClass, LuaInterface {
    
    public func getId() -> String! {
        return "FragmentManager"
    }
    
    #if targetEnvironment(macCatalyst)
    open override class func className() -> String {
        return "FragmentManager"
    }
    #else
    public static func className() -> String {
        return "FragmentManager"
    }
    #endif
    
    public static func luaMethods() -> NSMutableDictionary! {
        let dict = NSMutableDictionary()
        
        dict["findFragmentById"] = LuaFunction.create(true, class_getInstanceMethod(self, #selector(findFragmentById(id:))), #selector(findFragmentById(id:)), LuaFragment.self, [NSString.self])
        dict["findFragmentByTag"] = LuaFunction.create(true, class_getInstanceMethod(self, #selector(findFragmentByTag(tag:))), #selector(findFragmentByTag(tag:)), nil, [NSString.self])
        dict["findFragment"] = LuaFunction.create(true, class_getInstanceMethod(self, #selector(findFragment(view:))), #selector(findFragment(view:)), nil, [LGView.self])
        /*dict["navigate"] = LuaFunction.create(true, class_getInstanceMethod(self, #selector()), #selector(), nil, [LuaRef.self])
        dict["navigate"] = LuaFunction.create(true, class_getInstanceMethod(self, #selector()), #selector(), nil, [LuaRef.self])
        dict["navigate"] = LuaFunction.create(true, class_getInstanceMethod(self, #selector()), #selector(), nil, [LuaRef.self])
        dict["navigate"] = LuaFunction.create(true, class_getInstanceMethod(self, #selector()), #selector(), nil, [LuaRef.self])*/
        
        return dict
    }
    
    @objc let SAVED_STATE_TAG = "android:support:fragments"
    @objc private var mFragmentFactory: FragmentFactory? = nil
    @objc private var mHostFragmentFactory: HostFragmentFactory?
    private var mPendingActions: Array<OpGenerator> = []
    @objc private var mExecutingActions: Bool = false
    @objc private var mFragmentStore = FragmentStore()
    @objc private var mBackStack: Array<BackStackRecord>?
    private var mLayoutInflaterFactory: LGFragmentLayoutParser?
    @objc private var mCreatedMenus: Array<LuaFragment> = Array()
    
    @objc private var mOnBackPressedDispatcher: OnBackPressedDispatcher? = nil
    
    @objc private var mOnBackPressedCallback: OnBackPressedCallback?
    
    private var mBackStackIndex = AtomicInteger<Int>(0)
    
    private var mBackStackStates = Dictionary<String, BackStackState>()
    @objc private var mResults = Dictionary<String, Dictionary<String, Any>>()
    @objc private var mResultListeners = Dictionary<String, LifecycleAwareResultListener>()
    
    @objc private var mBackStackChangeListeners: Array<OnBackStackChangedListener>?
    @objc private var mLifeycleCallbackDispatcher: FragmentLifecycleCallbacksDispatcher?
    private var mOnAttachListeners = Array<FragmentOnAttachListener>()
    
    @objc private var mCurState = FragmentState.FS_INITIALIZING.rawValue
    @objc private var mHost: FragmentHostCallback?
    @objc private var mContainer: FragmentContainer?
    @objc private var mParent: LuaFragment?
    @objc internal var mPrimaryNav: LuaFragment?
    
    private var mLaunchedFragments: Deque<LaunchedFragmentInfo> = Deque()
    
    @objc private var mNeedMenuInvalidate: Bool = false
    @objc private var mStateSaved: Bool = false
    @objc private var mStopped: Bool = false
    @objc private var mDestroyed: Bool = false
    @objc private var mHavePendingDeferredStart: Bool = false
    
    @objc private var mTmpRecords: Array<BackStackRecord> = Array()
    @objc private var mTmpIsPop: Array<Bool> = Array()
    private var mTmpAddedFragments: Array<LuaFragment?> = Array()
    
    @objc private var mNonConfig: FragmentManagerViewModel = FragmentManagerViewModel(stateAutomaticallySaved: false)
    
    @objc public static let POP_BACK_STACK_INCLUSIVE: NSInteger = 1
    
    private var mExecCommit: ExecCommitRunnable?
    
    @objc
    public init(dummy: String) {
        super.init()
    }

    @objc
    public override init() {
        super.init()
        mLifeycleCallbackDispatcher = FragmentLifecycleCallbacksDispatcher(fragmentManager: self)
        mExecCommit = ExecCommitRunnable(fm: self)
        mOnBackPressedCallback = OnBackPressedCallbackI(fm: self, enabled: false) { obpc in
           obpc.handleOnBackPressedO = {
               obpc.fm.handleOnBackPressed()
           }
           return obpc
        }
        mHostFragmentFactory = HostFragmentFactory(fm: self)
        mLayoutInflaterFactory = LGFragmentLayoutParser(fragmentManager: self)
    }
    
    public func setHost(host: FragmentHostCallback) {
        mHost = host
    }
    
    @objc public func beginTransaction() -> FragmentTransaction {
        return BackStackRecord(manager: self)
    }
    
    func executePendingTransactions() -> Bool {
        let updates = execPendingActions(allowStateLoss: true)
        forcePostponedTransactions()
        return updates
    }
    
    private func updateOnBackPressedCallbackEnabled() {
        //TODO
    }
    
    @objc public func isPrimaryNavigation(parent: LuaFragment?) -> Bool {
        if(parent == nil)
        {
            return true
        }
        
        let parentFragmentManager = parent?.mFragmentManager
        let primaryNavigationFragment = parentFragmentManager?.getPrimaryNavigationFragment()
        return parent == primaryNavigationFragment && isPrimaryNavigation(parent: parentFragmentManager?.mParent)
    }
    
    func isParentHidden(parent: LuaFragment?) -> Bool {
        if(parent == nil) {
            return false
        }
        
        return parent!.isHidden()
    }
    
    func handleOnBackPressed() {
        //TODO
    }
    
    func restoreBackStack(name: String) {
        enqueueAction(action: RestoreBackStackState(fm: self, name: name), allowStateLoss: false)
    }
    
    func saveBackStack(name: String) {
        enqueueAction(action: SaveBackStackState(fm: self, name: name), allowStateLoss: false)
    }
    
    func clearBackStack(name: String) {
        enqueueAction(action: ClearBackStackState(fm: self, name: name), allowStateLoss: false)
    }
    
    func popBackStack(name: String) {
        enqueueAction(action: SaveBackStackState(fm: self, name: name), allowStateLoss: false)
    }
    
    func popBackStackImmediate() -> Bool {
        return popBackStackImmediate(name: nil, id: -1, flags: 0)
    }
    
    func popBackStack(name: String?, flags: Int) {
        enqueueAction(action: PopBackStackState(fm: self, name: name, id: -1, flags: flags), allowStateLoss: false)
    }
    
    func popBackStackImmediate(name: String?, flags: Int) -> Bool {
        return popBackStackImmediate(name: name, id: -1, flags: flags)
    }
    
    func popBackStack(id: Int, flags: Int) {
        popBackStack(id: id, flags: flags, allowStateLoss: false)
    }
    
    func popBackStack(id: Int, flags: Int, allowStateLoss: Bool) {
        if(id < 0) {
            return
        }
        enqueueAction(action: PopBackStackState(fm: self, name: nil, id: id, flags: flags), allowStateLoss: false)
    }
    
    func popBackStackImmediate(id: Int, flags: Int) -> Bool {
        if(id < 0) {
            return false
        }
        return popBackStackImmediate(name: nil, id: id, flags: flags)
    }
    
    func popBackStackImmediate(name: String?, id: Int, flags: Int) -> Bool {
        execPendingActions(allowStateLoss: false)
        ensureExecReady(allowStateLoss: true)
        
        if(mPrimaryNav != nil && id < 0 && name == nil) {
            let childManager = (mPrimaryNav!.getChildFragmentManager())!
            if(childManager.popBackStackImmediate()) {
                return true
            }
        }
        
        let executePop = popBackStackState(records: &mTmpRecords, isRecordPop: &mTmpIsPop, name: name, id: id, flags: flags)
        if(executePop) {
            mExecutingActions = true
            removeRedundantOperationsAndExecute(records: mTmpRecords, isRecordPop: mTmpIsPop)
            cleanupExec()
        }
        
        updateOnBackPressedCallbackEnabled()
        doPendingDeferredStart()
        mFragmentStore.burpActive()
        return executePop
    }
    
    func getBackStackEntryCount() -> Int {
        return mBackStack != nil ? mBackStack!.count : 0
    }
    
    func getBackStackEntryAt(index: Int) -> BackStackEntry {
        return mBackStack![index]
    }
    
    func addOnBackStackChangedListener(listener: OnBackStackChangedListener) {
        if(mBackStackChangeListeners == nil)
        {
            mBackStackChangeListeners = Array()
        }
        mBackStackChangeListeners?.append(listener)
    }
    
    func removeOnBackStackChangedListener(listener: OnBackStackChangedListener) {
        mBackStackChangeListeners?.remove(object: listener)
    }
    
    func setFragmentResult(requestKey: String, result: Dictionary<String, Any>) {
        let resultListener = mResultListeners[requestKey]
        if(resultListener != nil && resultListener!.isAtLeast(state: LifecycleState.LIFECYCLESTATE_STARTED)) {
            resultListener?.onFragmentResult(key: requestKey, result: result)
        } else {
            mResults[requestKey] = result
        }
    }
    
    func clearFragmentResult(requestKey: String) {
        mResults.removeValue(forKey: requestKey)
    }
    
    func setFragmentResultListener(requestKey: String, lifecycleOwner: LifecycleOwner, listener: FragmentResultListener) {
        let lifecycle: Lifecycle = lifecycleOwner.getLifecycle()
        if(lifecycle.getCurrentState() == LifecycleState.LIFECYCLESTATE_DESTROYED) {
            return
        }
        let observer = LifecycleEventObserverI { leo in
            leo.onStateChangedO = { source, event in
                if(event == LifecycleEvent.LIFECYCLEEVENT_ON_START) {
                    let storedResult = self.mResults[requestKey]
                    if(storedResult != nil) {
                        listener.onFragmentResult(key: requestKey, result: storedResult!)
                    }
                }
                
                if(event == LifecycleEvent.LIFECYCLEEVENT_ON_DESTROY) {
                    lifecycle.remove(leo)
                    self.mResults.removeValue(forKey: requestKey)
                }
            }
            return leo
        }
        lifecycle.add(observer)
        let storedListener = mResultListeners[requestKey]
        if(storedListener != nil) {
            storedListener?.removeObserver()
        }
        else {
            mResultListeners[requestKey] = LifecycleAwareResultListener(lifecycle: lifecycle, listener: listener, observer: observer)
        }
    }
    
    func clearFragmentResultListener(requestKey: String) {
        let listener = mResultListeners[requestKey]
        if(listener != nil)
        {
            listener?.removeObserver()
            mResultListeners.removeValue(forKey: requestKey)
        }
    }
    
    func putFragment(bundle: inout Dictionary<String, Any>, key: String, fragment: LuaFragment)
    {
        if(fragment.mFragmentManager != self)
        {
            return
        }
        
        bundle[key] = fragment.mWho
    }
    
    func getFragment(bundle: inout Dictionary<String, Any>, key: String) -> LuaFragment?
    {
        let who = bundle[key]
            
        let f = findActiveFragment(who: who as! String)
        return f
    }
    
    @objc public static func findFragment(view: LGView) -> LuaFragment? {
        return findViewFragment(view: view)
    }
    
    static func findViewFragment(view: LGView) -> LuaFragment? {
        var viewLoop: LGView? = view
        while(viewLoop != nil) {
            let fragment = getViewFragment(view: viewLoop)
            if(fragment != nil) {
                return fragment
            }
            
            viewLoop = viewLoop?.parent
        }
        
        return nil
    }
    
    static func getViewFragment(view: LGView?) -> LuaFragment? {
        return view?.fragment
    }
    
    @objc
    public func onContainerAvailable(view: LGView) {
        for fragmentStateManager in mFragmentStore.getActiveFragmentStateManagers() {
            let fragment = fragmentStateManager.getFragment()
            if(fragment.mContainerId == view.getId() && fragment.lgview != nil) {
                fragment.mContainer = view as? LGViewGroup
                fragmentStateManager.addViewToContainer()
            }
        }
    }
    
    static func findFragmentManager(view: LGView) -> FragmentManager? {
        let fragment = findViewFragment(view: view)
        var fm: FragmentManager? = nil
        if(fragment != nil) {
            if(!fragment!.mAdded) {
                return nil
            }
            fm = fragment!.getChildFragmentManager()
        }
        else {
            let fragmentActivity = view.lc.form
            if(fragmentActivity != nil) {
                fm = fragmentActivity!.getSupportFragmentManager()
            }
        }
        
        return fm
    }
    
    @objc
    public func getFragments() -> NSMutableArray {
        return mFragmentStore.getFragments().objcArray
    }
    
    @objc public func getViewModelStore(f: LuaFragment) -> ViewModelStore {
        return mNonConfig.getViewModelStore(f: f)
    }
    
    func getChildNonConfig(f: LuaFragment) -> FragmentManagerViewModel? {
        return mNonConfig.getChildNonConfig(f: f)
    }
    
    func addRetainedFragment(f: LuaFragment) {
        mNonConfig.addRetainedFragment(fragment: f)
    }
    
    func removeRetainedFragment(f: LuaFragment) {
        mNonConfig.removeRetainedFragment(fragment: f)
    }
    
    func getActiveFragments() -> Array<LuaFragment?> {
        return mFragmentStore.getActiveFragments()
    }
    
    func getActiveFragmentCount() -> Int {
        return mFragmentStore.getActiveFragmentCount()
    }
    
    @objc
    public func saveFragmentInstanceState(fragment: LuaFragment) -> SavedState? {
        let fragmentStateManager = mFragmentStore.getFragmentStateManager(who: fragment.mWho)
        if(fragmentStateManager == nil || fragmentStateManager?.getFragment() != fragment) {
            return nil
        }
        return fragmentStateManager?.saveInstanceState()
    }
    
    func clearbackStackStateViewModels() {
        var shouldClear: Bool
        if(mHost is ViewModelStoreOwner) {
            shouldClear = mFragmentStore.getNonConfig().isCleared()
        } else if(mHost?.getContext().form != nil) {
            shouldClear = false //TODO
        } else {
            shouldClear = true
        }
        if(shouldClear) {
            for backStackState in mBackStackStates.values {
                for who in backStackState.mFragments {
                    mFragmentStore.getNonConfig().clearNonConfigState(who: who)
                }
            }
        }
    }
    
    @objc public func isDestroyed() -> Bool {
        return mDestroyed
    }
    
    func performPendingDeferredStart(fragmentStateManager: FragmentStateManager) {
        let f = fragmentStateManager.getFragment()
        if(f.mDeferStart) {
            if(mExecutingActions) {
                mHavePendingDeferredStart = true
                return
            }
            f.mDeferStart = false
            fragmentStateManager.moveToExpectedState()
        }
    }
    
    func isStateAtLeast(state: Int) -> Bool {
        return mCurState >= state
    }
    
    func setExitAnimationOrder(f: LuaFragment, isPop: Bool) {
        //TODO
        /*var container = getFragmentContainer(f)
        if(container != nil) {
            if(container is FragmentContainerView)
        }*/
    }
    
    func moveToState(newState: Int, always: Bool) {
        if(mHost == nil && newState != FragmentState.FS_INITIALIZING.rawValue) {
            return
        }
        
        if(!always && newState == mCurState) {
            return
        }
        
        mCurState = newState
        mFragmentStore.moveToExpectedState()
        startPendingDeferredFragments()
        
        if(mNeedMenuInvalidate && mHost != nil && mCurState == FragmentState.FS_RESUMED.rawValue) {
            mHost?.onSupportInvalidateOptionsMenu()
            mNeedMenuInvalidate = false
        }
    }
    
    private func startPendingDeferredFragments() {
        for fragmentStateManager in mFragmentStore.getActiveFragmentStateManagers() {
            performPendingDeferredStart(fragmentStateManager: fragmentStateManager)
        }
    }
    
    private func createOrGetFragmentStateManager(f: LuaFragment) -> FragmentStateManager {
        let existing = mFragmentStore.getFragmentStateManager(who: f.mWho)
        if(existing != nil) {
            return existing!
        }
        let fragmentStateManager = FragmentStateManager(dispatcher: mLifeycleCallbackDispatcher!, fragmentStore: mFragmentStore, fragment: f)
        fragmentStateManager.restoreState()
        fragmentStateManager.setFragmentManagerState(state: mCurState)
        return fragmentStateManager
    }
    
    func addFragment(fragment: LuaFragment) -> FragmentStateManager {
        if(fragment.mPreviousWho != nil) {
            
        }
        let fragmentStateManager = createOrGetFragmentStateManager(f: fragment)
        fragment.mFragmentManager = self
        mFragmentStore.makeActive(newlyActive: fragmentStateManager)
        if(!fragment.mDetached) {
            mFragmentStore.addFragment(fragment: fragment)
            fragment.mRemoving = false
            if(fragment.lgview == nil) {
                fragment.mHiddenChanged = false
            }
            //TODO
            /*if(isMenuAvailable(fragment)) {
                mNeedMenuInvalidate = true
            }*/
        }
        return fragmentStateManager
    }
    
    func removeFragment(fragment: LuaFragment) {
        let inactive = !fragment.isInBackStack()
        if(!fragment.mDetached || inactive) {
            mFragmentStore.removeFragment(fragment: fragment)
            //TODO
            /*if(isMenuAvailable(fragment)) {
                mNeedMenuInvalidate = true
            }*/
            fragment.mRemoving = true
            setVisibleRemovingFragment(f: fragment)
        }
    }
    
    func hideFragment(fragment: LuaFragment) {
        if(fragment.mHidden) {
            fragment.mHidden = false
            fragment.mHiddenChanged = !fragment.mHiddenChanged
        }
    }
    
    func showFragment(fragment: LuaFragment) {
        if(fragment.mHidden) {
            fragment.mHidden = false
            fragment.mHiddenChanged = !fragment.mHiddenChanged
        }
    }
    
    func detachFragment(fragment: LuaFragment) {
        if(!fragment.mDetached) {
            fragment.mDetached = true
            if(fragment.mAdded) {
                mFragmentStore.removeFragment(fragment: fragment)
                //TODO
                /*if(isMenuAvailable(fragment)) {
                    mNeedMenuInvalidate = true
                }*/
                setVisibleRemovingFragment(f: fragment)
            }
        }
    }
    
    func attachFragment(fragment: LuaFragment) {
        if(fragment.mDetached) {
            fragment.mDetached = false
            if(!fragment.mAdded) {
                mFragmentStore.addFragment(fragment: fragment)
                //TODO
                /*if(isMenuAvailable(fragment)) {
                    mNeedMenuInvalidate = true
                }*/
            }
        }
    }
    
    @objc
    public func findFragmentById(id: String) -> LuaFragment? {
        return mFragmentStore.findFragmentById(id: id)
    }
    
    @objc
    public func findFragmentByTag(tag: String) -> LuaFragment? {
        return mFragmentStore.findFragmentByTag(tag: tag)
    }
    
    @objc
    public func findFragmentByWho(who: String) -> LuaFragment? {
        return mFragmentStore.findFragmentByWho(who: who)
    }
    
    @objc
    public func findActiveFragment(who: String) -> LuaFragment? {
        return mFragmentStore.findActiveFragment(who: who)
    }
    
    func checkStateLoss() {
        if(isStateSaved()) {
            //TODO?
        }
    }
    
    @objc public func isStateSaved() -> Bool {
        return mStateSaved || mStopped
    }
    
    func enqueueAction(action: OpGenerator, allowStateLoss: Bool) {
        if(!allowStateLoss) {
            if(mHost == nil) {
                if(mDestroyed) {
                    //TODO err
                } else {
                    //TODO  err
                }
            }
            checkStateLoss()
        }
        synced(self) {
            if(mHost == nil) {
                if(allowStateLoss) {
                    return
                }
                //TODO err
            }
            mPendingActions.append(action)
            scheduleCommit()
        }
    }
    
    func scheduleCommit() {
        synced(self) {
            let pendingReady = mPendingActions.count == 1
            if(pendingReady) {
                if(mHost?.runnableArray != nil) {
                    ArrayExtension.remove(list: &mHost!.runnableArray, object: mExecCommit as! Runnable)
                }
                DispatchQueue.main.async {
                    self.mExecCommit!.run()
                }
                updateOnBackPressedCallbackEnabled()
            }
        }
    }
    
    func allocBackStackIndex() -> AtomicInteger<Int> {
        return mBackStackIndex.getAndIncrement()
    }
    
    private func ensureExecReady(allowStateLoss: Bool) {
        if(mExecutingActions) {
            
        }
        
        if(mHost == nil) {
            if(mDestroyed) {
                
            } else {
                
            }
        }
        
        if(!allowStateLoss) {
            checkStateLoss()
        }
        
        if(mTmpRecords == nil) {
            mTmpRecords = Array()
            mTmpIsPop = Array()
        }
    }
    
    func execSingleAction(action: OpGenerator, allowStateLoss: Bool) {
        if(allowStateLoss && (mHost == nil || mDestroyed)) {
            return
        }
        ensureExecReady(allowStateLoss: allowStateLoss)
        if(action.generateOps(records: &mTmpRecords, isRecordPop: &mTmpIsPop)) {
            mExecutingActions = true
            do {
                defer {
                    cleanupExec()
                }
                try removeRedundantOperationsAndExecute(records: mTmpRecords, isRecordPop: mTmpIsPop)
            }
        }
        
        updateOnBackPressedCallbackEnabled()
        doPendingDeferredStart()
        mFragmentStore.burpActive()
    }
    
    func cleanupExec() {
        mExecutingActions = false
        mTmpIsPop.removeAll()
        mTmpRecords.removeAll()
    }
    
    @objc public func execPendingActions(allowStateLoss: Bool) -> Bool {
        ensureExecReady(allowStateLoss: allowStateLoss)
        
        var didSomething = false
        while(generateOpsForPendingActions(records: &mTmpRecords, isPop: &mTmpIsPop)) {
            mExecutingActions = true
            do {
                defer {
                    cleanupExec()
                }
                try removeRedundantOperationsAndExecute(records: mTmpRecords, isRecordPop: mTmpIsPop)
            }
            didSomething = true
        }
        
        updateOnBackPressedCallbackEnabled()
        doPendingDeferredStart()
        mFragmentStore.burpActive()
        
        return didSomething
    }
    
    private func removeRedundantOperationsAndExecute(records: Array<BackStackRecord>, isRecordPop: Array<Bool>) {
        if(records.isEmpty) {
            return
        }
        
        if(records.count != isRecordPop.count) {
            //throw RuntimeError("Internal error with the back stack records")
        }
        
        let numRecords = records.count
        var startIndex = 0
        for var recordNum in 0..<numRecords {
            let canReorder = records[recordNum].mReorderingAllowed
            if(!canReorder) {
                if(startIndex != recordNum) {
                    executeOpsTogether(records: records, isRecordPop: isRecordPop, startIndex: startIndex, endIndex: recordNum)
                }
                
                var reorderingEnd = recordNum + 1
                if(isRecordPop[recordNum]) {
                    while(reorderingEnd < numRecords && isRecordPop[reorderingEnd] && !records[reorderingEnd].mReorderingAllowed) {
                        reorderingEnd += 1
                    }
                }
                executeOpsTogether(records: records, isRecordPop: isRecordPop, startIndex: recordNum, endIndex: reorderingEnd)
                startIndex = reorderingEnd
                recordNum = reorderingEnd - 1
            }
        }
        if(startIndex != numRecords) {
            executeOpsTogether(records: records, isRecordPop: isRecordPop, startIndex: startIndex, endIndex: numRecords)
        }
    }
    
    private func executeOpsTogether(records: Array<BackStackRecord>, isRecordPop: Array<Bool>, startIndex: Int, endIndex: Int) {
        let allowReordering = records[startIndex].mReorderingAllowed
        var addToBackStack = false
        if(mTmpAddedFragments == nil) {
            mTmpAddedFragments = Array()
        } else {
            mTmpAddedFragments.removeAll()
        }
        mTmpAddedFragments.append(contentsOf: mFragmentStore.getFragments())
        var oldPrimaryNav = getPrimaryNavigationFragment()
        for recordNum in startIndex..<endIndex {
            let record = records[recordNum]
            let isPop = isRecordPop[recordNum]
            if(!isPop) {
                oldPrimaryNav = record.expandOps(added: &mTmpAddedFragments, oldPrimaryNav: &oldPrimaryNav)
            } else {
                oldPrimaryNav = record.trackAddedFragmentsInPop(added: &mTmpAddedFragments, oldPrimaryNav: &oldPrimaryNav)
            }
            addToBackStack = addToBackStack || record.mAddToBackStack
        }
        mTmpAddedFragments.removeAll()
        
        if(!allowReordering && mCurState >= FragmentState.FS_CREATED.rawValue) {
            for index in startIndex..<endIndex {
                let record = records[index]
                for op in record.mOps {
                    let fragment = op.mFragment
                    if(fragment != nil && fragment?.mFragmentManager != nil) {
                        let fragmentStateManager = createOrGetFragmentStateManager(f: fragment!)
                        mFragmentStore.makeActive(newlyActive: fragmentStateManager)
                    }
                }
            }
        }
        FragmentManager.executeOps(records: records, isRecordPop: isRecordPop, startIndex: startIndex, endIndex: endIndex)
        
        var isPop = isRecordPop[endIndex - 1]
        for index in startIndex..<endIndex {
            let record = records[index]
            if(isPop) {
                for opIndex in (0..<record.mOps.count).reversed() {
                    let op = record.mOps[opIndex]
                    let fragment = op.mFragment
                    if(fragment != nil) {
                        let fragmentStateManager = createOrGetFragmentStateManager(f: fragment!)
                        fragmentStateManager.moveToExpectedState()
                    }
                }
            } else {
                for op in record.mOps {
                    let fragment = op.mFragment
                    if(fragment != nil) {
                        let fragmentStateManager = createOrGetFragmentStateManager(f: fragment!)
                        fragmentStateManager.moveToExpectedState()
                    }
                }
            }
        }
        
        moveToState(newState: mCurState, always: true)
        //TODO special effects
        
        for recordNum in startIndex..<endIndex {
            let record = records[recordNum]
            isPop = isRecordPop[recordNum]
            if(isPop && record.mIndex > 0) {
                record.mIndex = -1
            }
            record.runOnCommitRunnables()
        }
        if(addToBackStack) {
            reportBackStackChanged()
        }
    }
    
//    private func collectChangedControllers //TODO
    
    private static func executeOps(records: Array<BackStackRecord>, isRecordPop: Array<Bool>, startIndex: Int, endIndex: Int) {
        for i in startIndex..<endIndex {
            let record = records[i]
            let isPop = isRecordPop[i]
            if(isPop) {
                record.bumpBackStackNesting(amt: -1)
                record.executePopOps()
            } else {
                record.bumpBackStackNesting(amt: 1)
                record.executeOps()
            }
        }
    }
    
    private func setVisibleRemovingFragment(f: LuaFragment) {
        var container = getFragmentContainer(f: f)
        /*if(container != nil && f.getEnterAnim() + f.getExitAnim() + f.getPopEnterAnim() + f.getPopExitAnim() > 0) {
            //TODO some tags
        }*/
    }
    
    private func getFragmentContainer(f: LuaFragment) -> LGViewGroup? {
        if(f.mContainer != nil) {
            return f.mContainer
        }
        if(f.mContainerId == nil) {
            return nil
        }
        
        if((mContainer?.onHasView()) != nil) {
            let view = mContainer?.onFindViewById(idVal: f.mContainerId)
            if(view is LGViewGroup) {
                return view as? LGViewGroup
            }
        }
        
        return nil
    }
    
    private func forcePostponedTransactions() {
        //TODO
    }
    
    private func endAnimatingAwayFragments() {
        //TODO
    }
    
    //TODO collecall
    
    private func generateOpsForPendingActions(records: inout Array<BackStackRecord>, isPop: inout Array<Bool>) -> Bool {
        var didSomething = false
        synced(mPendingActions) {
            if(mPendingActions.isEmpty) {
                return
            }
            
            do {
                defer {
                    mPendingActions.removeAll()
                    if(mHost?.runnableArray != nil) {
                        ArrayExtension.remove(list: &mHost!.runnableArray, object: mExecCommit as! Runnable)
                    }
                }
                let numActions = mPendingActions.count
                for i in 0..<numActions {
                    if(mPendingActions[i].generateOps(records: &records, isRecordPop: &isPop)) {
                        didSomething = true
                    }
                }
            }
        }
        return didSomething
    }
    
    private func doPendingDeferredStart() {
        if(mHavePendingDeferredStart) {
            mHavePendingDeferredStart = false
            startPendingDeferredFragments()
        }
    }
    
    private func reportBackStackChanged() {
        if(mBackStackChangeListeners != nil) {
            for i in 0..<mBackStackChangeListeners!.count {
                mBackStackChangeListeners![i].onBackStackChanged()
            }
        }
    }
    
    func addBackStackState(state: BackStackRecord) {
        if(mBackStack == nil) {
            mBackStack = Array()
        }
        mBackStack?.append(state)
    }
    
    func restoreBackStackState(records: inout Array<BackStackRecord>, isRecordPop: inout Array<Bool>, name: String) -> Bool {
        let backStackState = mBackStackStates.removeValue(forKey: name)
        if(backStackState == nil) {
            return false
        }
        
        var pendingSavedFragments = Dictionary<String, LuaFragment>()
        for record in records {
            if(record.mBeingSaved) {
                for op in record.mOps {
                    if(op.mFragment != nil) {
                        pendingSavedFragments[op.mFragment!.mWho] = op.mFragment
                    }
                }
            }
        }
        var backStackRecords = backStackState?.instantiate(fm: self, pendingSavedFragments: pendingSavedFragments)
        var added = false
        if(backStackRecords != nil) {
            for record in backStackRecords! {
                added = record.generateOps(records: &records, isRecordPop: &isRecordPop) || added
            }
        }
        return added
    }
    
    func saveBackStackState(records: inout Array<BackStackRecord>, isRecordPop: inout Array<Bool>, name: String) -> Bool {
        let index = findBackStackIndex(name: name, id: -1, inclusive: true)
        if(index < 0) {
            return false
        }
        
        if(mBackStack == nil) {
            return false
        }
        
        for i in index..<mBackStack!.count {
            let record = mBackStack![i]
            if(!record.mReorderingAllowed) {
                //TODO Exep
                return false
            }
        }
        
        var allFragments = Set<LuaFragment>()
        for i in index..<mBackStack!.count {
            let record = mBackStack![i]
            var affectedFragments = Set<LuaFragment>()
            var addedFragments = Set<LuaFragment>()
            for op in record.mOps {
                let f = op.mFragment
                if(f == nil) {
                    continue
                }
                if(!op.mFromExpandedOp || op.mCmd == FragmentTransaction.OP_ADD
                   || op.mCmd == FragmentTransaction.OP_REPLACE
                   || op.mCmd == FragmentTransaction.OP_SET_PRIMARY_NAV) {
                    allFragments.insert(f!)
                    affectedFragments.insert(f!)
                }
                if(op.mCmd == FragmentTransaction.OP_ADD
                   || op.mCmd == FragmentTransaction.OP_REPLACE) {
                    addedFragments.insert(f!)
                }
            }
            addedFragments.forEach {
                affectedFragments.remove($0)
            }
            if(!affectedFragments.isEmpty) {
                //TODO excep
                return false
            }
        }
        
        var fragmentsToSearch = Deque<LuaFragment>(allFragments)
        while(!fragmentsToSearch.isEmpty) {
            let currentFragment = fragmentsToSearch.removeFirst()
            if(currentFragment.mRetainInstance) {
                //TODO excep
                return false
            }
            for f in currentFragment.mChildFragmentManager.getActiveFragments() {
                if(f != nil) {
                    fragmentsToSearch.append(f!)
                }
            }
        }
        
        var fragments = Array<String>()
        for f in allFragments {
            fragments.append(f.mWho)
        }
        
        var backStackRecordStates = Array<BackStackRecordState?>()
        backStackRecordStates.reserveCapacity((mBackStack!.count - index))
        for i in index..<mBackStack!.count {
            backStackRecordStates.append(nil)
        }
        let backStackState = BackStackState(fragments: fragments, transactions: backStackRecordStates)
        for i in (index..<mBackStack!.count).reversed() {
            let record = mBackStack!.remove(at: i)
            
            let copy = BackStackRecord(bse: record)
            copy.collapseOps()
            let state = BackStackRecordState(bse: copy)
            backStackRecordStates[i - index] = state
            
            record.mBeingSaved = true
            records.append(record)
            isRecordPop.append(true)
        }
        mBackStackStates[name] = backStackState
        return true
    }
    
    func clearBackStackState(records: inout Array<BackStackRecord>, isRecordPop: inout Array<Bool>, name: String) -> Bool {
        let restoredBackStackState = restoreBackStackState(records: &records, isRecordPop: &isRecordPop, name: name)
        if(!restoredBackStackState) {
            return false
        }
        return popBackStackState(records: &records, isRecordPop: &isRecordPop, name: name, id: -1, flags: FragmentManager.POP_BACK_STACK_INCLUSIVE)
    }
    
    func popBackStackState(records: inout Array<BackStackRecord>, isRecordPop: inout Array<Bool>, name: String?, id: Int, flags: Int) -> Bool {
        let index = findBackStackIndex(name: name, id: id, inclusive: (flags & FragmentManager.POP_BACK_STACK_INCLUSIVE) != 0)
        if(index < 0) {
            return false
        }
        if(mBackStack == nil) {
            return false
        }
        for i in (index..<mBackStack!.count).reversed() {
            records.append(mBackStack!.remove(at: i))
            isRecordPop.append(true)
        }
        return true
    }
    
    private func findBackStackIndex(name: String?, id: Int, inclusive: Bool) -> Int {
        if(mBackStack == nil || mBackStack!.isEmpty) {
            return -1
        }
        if(name == nil && id < 0) {
            if(inclusive) {
                return 0
            } else {
                return mBackStack!.count - 1
            }
        } else {
            var index = mBackStack!.count - 1
            while(index >= 0) {
                let bss = mBackStack![index]
                if(name != nil && name == bss.getName()) {
                    break
                }
                if(id >= 0 && id == bss.mIndex) {
                    break
                }
                index -= 1
            }
            if(index < 0) {
                return index
            }
            if(inclusive) {
                while(index > 0) {
                    let bss = mBackStack![index - 1]
                    if((name != nil && name == bss.getName()) || (id >= 0 && id == bss.mIndex)) {
                        index -= 1
                        continue
                    }
                    break
                }
            } else if (index == mBackStack!.count - 1) {
                return -1
            } else {
                index += 1
            }
            return index
        }
    }
    
    func saveAllState() -> FragmentManagerState? {
        /*if(mHost is SavedStateRegistryOwner) {
            //TODO excep?
            return nil
        }*/
        return saveAllStateInternal()
    }
    
    @objc
    public func saveAllStateInternal() -> FragmentManagerState? {
        forcePostponedTransactions()
        endAnimatingAwayFragments()
        execPendingActions(allowStateLoss: true)
        
        mStateSaved = true
        mNonConfig.setIsStateSaved(isStateSaved: true)
        
        let active = mFragmentStore.saveActiveFragments()
        
        let savedState = mFragmentStore.getAllSavedState()
        
        if(savedState.isEmpty) {
            return nil
        }
        
        let added = mFragmentStore.saveAddedFragments()
        
        var backStack: Array<BackStackRecordState>? = nil
        if(mBackStack != nil) {
            let size = mBackStack!.count
            if(size >= 0) {
                backStack = Array()
                backStack!.reserveCapacity(16)
                for i in 0..<size {
                    backStack![i] = BackStackRecordState(bse: mBackStack![i])
                }
            }
        }
        
        let fms = FragmentManagerState()
        fms.mSavedState = savedState
        fms.mActive = active
        fms.mAdded = added
        fms.mBackStack = backStack
        fms.mBackStackIndex = mBackStackIndex.get()
        if(mPrimaryNav != nil) {
            fms.mPrimaryNavActiveWho = mPrimaryNav?.mWho
        }

        mBackStackStates.forEach {
            fms.mBackStackStateKeys.append($0.key)
        }
        mBackStackStates.forEach {
            fms.mBackStackStates.append($0.value)
        }
        mResults.forEach {
            fms.mResultKeys.append($0.key)
        }
        mResults.forEach {
            fms.mResults.append($0.value)
        }
        fms.mLaunchedFragments = Array(mLaunchedFragments)
        return fms
    }
    
    func restoreSaveState(state: FragmentManagerState?) {
//        if(mHost is SavedStateRegistryOwner)
        restoreSaveStateInternal(state: state)
    }
    
    @objc
    public func restoreSaveStateInternal(state: FragmentManagerState?) {
        if(state == nil) {
            return
        }
        let fms = state
        if(fms!.mSavedState == nil) {
            return
        }
        
        mFragmentStore.restoreSavedState(savedState: fms!.mSavedState!)
        mFragmentStore.resetActiveFragments()
        for who in fms!.mActive ?? [] {
            let fs = mFragmentStore.setSavedState(who: who, fragmentState: nil)
            if(fs != nil) {
                var fragmentStateManager: FragmentStateManager
                let retainedFragment = mNonConfig.findRetainedFragment(who: fs!.mWho ?? "")
                if(retainedFragment != nil) {
                    fragmentStateManager = FragmentStateManager(dispatcher: mLifeycleCallbackDispatcher!, fragmentStore: mFragmentStore, retainedFragment: retainedFragment!, fs: fs!)
                } else {
                    fragmentStateManager = FragmentStateManager(dispatcher: mLifeycleCallbackDispatcher!, fragmentStore: mFragmentStore, fragmentFactory: getFragmentFactory()!, fs: fs!)
                }
                let f = fragmentStateManager.getFragment()
                f.mFragmentManager = self
                fragmentStateManager.restoreState()
                mFragmentStore.makeActive(newlyActive: fragmentStateManager)
                fragmentStateManager.setFragmentManagerState(state: mCurState)
            }
        }
        
        for f in mNonConfig.getRetainedFragments() {
            if(!mFragmentStore.containsActiveFragment(who: f.mWho)) {
                
            }
            mNonConfig.removeRetainedFragment(fragment: f)
            f.mFragmentManager = self
            let fragmentStateManager = FragmentStateManager(dispatcher: mLifeycleCallbackDispatcher!, fragmentStore: mFragmentStore, fragment: f)
            fragmentStateManager.setFragmentManagerState(state: FragmentState.FS_CREATED.rawValue)
            fragmentStateManager.moveToExpectedState()
            f.mRemoving = true
            fragmentStateManager.moveToExpectedState()
        }
        
        mFragmentStore.restoreAddedFragments(added: fms?.mAdded)
        
        if(fms!.mBackStack != nil) {
            mBackStack = Array()
            mBackStack?.reserveCapacity(fms!.mBackStack!.count)
            for i in 0..<fms!.mBackStack!.count {
                let bse = fms!.mBackStack![i].instantiate(fm: self)
                mBackStack!.append(bse)
            }
        } else {
            mBackStack = nil
        }
        mBackStackIndex.set(value: fms!.mBackStackIndex)
        
        if(fms?.mPrimaryNavActiveWho != nil) {
            mPrimaryNav = findActiveFragment(who: fms!.mPrimaryNavActiveWho!)
            dispatchParentPrimaryNavigationFragmentChanged(f: mPrimaryNav)
        }
        
        let savedBackStackStateKeys = fms?.mBackStackStateKeys
        if(savedBackStackStateKeys != nil) {
            for i in 0..<savedBackStackStateKeys!.count {
                mBackStackStates[savedBackStackStateKeys![i]] = fms?.mBackStackStates[i]
            }
        }
                                 
        let savedResultKeys = fms?.mResultKeys
        if(savedResultKeys != nil) {
            for i in 0..<savedResultKeys!.count {
                mResults[savedResultKeys![i]] = fms?.mResults[i]
            }
        }
        
        mLaunchedFragments = Deque(fms?.mLaunchedFragments ?? [])
    }
    
    func getHost() -> FragmentHostCallback? {
        return mHost
    }
    
    func getParent() -> LuaFragment? {
        return mParent
    }
    
    func getContainer() -> FragmentContainer? {
        return mContainer
    }
    
    func getFragmentStore() -> FragmentStore {
        return mFragmentStore
    }
    
    @objc
    public func attachController(host: FragmentHostCallback, container: FragmentContainer, parent: LuaFragment?) {
        mHost = host
        mContainer = container
        mParent = parent
        
        class FragmentOnAttachListenerI: FragmentOnAttachListener {
            var key: String = UUID.init().uuidString
            
            var onAttachFragmentO:(FragmentManager, LuaFragment) -> () = {_,_ in }
            
            init(overrides: (FragmentOnAttachListenerI) -> FragmentOnAttachListenerI) {
                overrides(self)
            }
            
            func onAttachFragment(fragmentManager: FragmentManager, fragment: LuaFragment) {
                self.onAttachFragmentO(fragmentManager, fragment)
            }
        }
        
        if(mParent != nil) {
            addFragmentOnAttachListener(listener: FragmentOnAttachListenerI { foal in
                foal.onAttachFragmentO = { fm, fragment in
                    parent?.onAttach(fragment)
                }
                return foal
            })
        } else if(host is FragmentOnAttachListener) {
            addFragmentOnAttachListener(listener: host as! FragmentOnAttachListener)
        }
        
        if(mParent != nil) {
            updateOnBackPressedCallbackEnabled()
        }
        
        if(host is OnBackPressedDispatcherOwner) {
            let dispatchOwner = host as! OnBackPressedDispatcherOwner
            mOnBackPressedDispatcher = dispatchOwner.getOnBackPressedDispatcher()
            let owner: LifecycleOwner = parent != nil ? parent! : dispatchOwner
            mOnBackPressedDispatcher?.addCallback(owner: owner, onBackPressedCallback: mOnBackPressedCallback!)
        }
        
        if(parent != nil) {
            mNonConfig = (parent?.mFragmentManager.getChildNonConfig(f: parent!))!
        } else if(host is ViewModelStoreOwner) {
            let viewModelStore = (host as! ViewModelStoreOwner).getViewModelStore()
            mNonConfig = FragmentManagerViewModel.getInstance(viewModelStore: viewModelStore!)
        } else {
            mNonConfig = FragmentManagerViewModel(stateAutomaticallySaved: false)
        }
        
        mNonConfig.setIsStateSaved(isStateSaved: isStateSaved())
        mFragmentStore.setNonConfig(nonConfig: mNonConfig)
        
        /*
         //TODO
         
         if(mHost is SavedStateRegistryOwner && parent == nil) {
            
        }
         
         activity
         */
        
        
    }
    
    @objc
    public func noteStateNotSaved() {
        if(mHost == nil) {
            return
        }
        
        mStateSaved = false
        mStopped = false
        mNonConfig.setIsStateSaved(isStateSaved: false)
        for fragment in mFragmentStore.getFragments() {
            fragment.noteStateNotSaved()
        }
    }
 
    /*
     TODO
     launcStartActivity
     launchStartIntent
     launchRequestPerm
     */
    
    @objc
    public func dispatchAttach() {
        mStateSaved = false
        mStopped = false
        mNonConfig.setIsStateSaved(isStateSaved: false)
        dispatchStateChange(nextState: FragmentState.FS_ATTACHED.rawValue)
    }
    
    @objc
    public func dispatchCreate() {
        mStateSaved = false
        mStopped = false
        mNonConfig.setIsStateSaved(isStateSaved: false)
        dispatchStateChange(nextState: FragmentState.FS_CREATED.rawValue)
    }
    
    @objc
    public func dispatchViewCreated() {
        dispatchStateChange(nextState: FragmentState.FS_VIEW_CREATED.rawValue)
    }
    
    @objc
    public func dispatchActivityCreated() {
        mStateSaved = false
        mStopped = false
        mNonConfig.setIsStateSaved(isStateSaved: false)
        dispatchStateChange(nextState: FragmentState.FS_ACTIVITY_CREATED.rawValue)
    }
    
    @objc
    public func dispatchStart() {
        mStateSaved = false
        mStopped = false
        mNonConfig.setIsStateSaved(isStateSaved: false)
        dispatchStateChange(nextState: FragmentState.FS_STARTED.rawValue)
    }
    
    @objc
    public func dispatchResume() {
        mStateSaved = false
        mStopped = false
        mNonConfig.setIsStateSaved(isStateSaved: false)
        dispatchStateChange(nextState: FragmentState.FS_RESUMED.rawValue)
    }
    
    @objc
    public func dispatchPause() {
        dispatchStateChange(nextState: FragmentState.FS_STARTED.rawValue)
    }
    
    @objc
    public func dispatchStop() {
        mStopped = true
        mNonConfig.setIsStateSaved(isStateSaved: true)
        dispatchStateChange(nextState: FragmentState.FS_ACTIVITY_CREATED.rawValue)
    }
    
    @objc
    public func dispatchDestroyView() {
        dispatchStateChange(nextState: FragmentState.FS_CREATED.rawValue)
    }
    
    @objc
    public func dispatchDestroy() {
        mDestroyed = true
        execPendingActions(allowStateLoss: true)
        endAnimatingAwayFragments()
        clearbackStackStateViewModels()
        dispatchStateChange(nextState: FragmentState.FS_INITIALIZING.rawValue)
        mParent = nil
        mOnBackPressedCallback?.remove()
        mOnBackPressedDispatcher = nil
        //TODO
        /*if(mStartActivi)*/
    }
    
    private func dispatchStateChange(nextState: Int) {
        /*do {
            try {*/
                self.mExecutingActions = true
                self.mFragmentStore.dispatchStateChange(state: nextState)
                self.moveToState(newState: nextState, always: false)
                /*
                  special effects TODO
                 */
                //defer {
                    self.mExecutingActions = false
                //}
            /*}
        }*/
        execPendingActions(allowStateLoss: false)
    }
    
    /*
     dispatchmultiwindows
     dispatchpip
     dispatchconfig
     dispatchlowmem
     */
        //TODO
//    vunc dispatchCreateOptionsMenu(mMenu:)
    //prepare
    //optionsitem
    
    //context
    //optionsclose
    
    @objc
    public func setPrimaryNavigationFragment(f: LuaFragment?) {
        if(f != nil && (f != findActiveFragment(who: (f?.mWho!)!) || (f!.mHost != nil && f?.mFragmentManager != self))) {
            return
        }
        let previousPrimaryNav = mPrimaryNav
        mPrimaryNav = f
        dispatchParentPrimaryNavigationFragmentChanged(f: previousPrimaryNav)
        dispatchParentPrimaryNavigationFragmentChanged(f: mPrimaryNav)
    }
    
    @objc
    public func dispatchParentPrimaryNavigationFragmentChanged(f: LuaFragment?) {
        if(f != nil && f != findActiveFragment(who: f!.mWho)) {
            f!.performPrimaryNavigationFragmentChanged()
        }
    }
    
    @objc
    public func dispatchPrimaryNavigationFragmentChanged() {
        updateOnBackPressedCallbackEnabled()
        dispatchParentPrimaryNavigationFragmentChanged(f: mPrimaryNav)
    }
    
    @objc
    public func getPrimaryNavigationFragment() -> LuaFragment? {
        return mPrimaryNav
    }
    
    func setMaxLifecycle(f: LuaFragment, state: LifecycleState) {
        if(f != findActiveFragment(who: f.mWho) || (f.mHost != nil && f.mFragmentManager != self)) {
            return
        }
        
        f.mMaxState = state
    }
    
    func setFragmentFactory(fragmentFactory: FragmentFactory) {
        mFragmentFactory = fragmentFactory
    }
    
    @objc
    public func getFragmentFactory() -> FragmentFactory? {
        if(mFragmentFactory != nil) {
            return mFragmentFactory
        }
        if(mParent != nil) {
            return mParent?.mFragmentManager.getFragmentFactory()
        }
        return mHostFragmentFactory
    }
    
    //TODO
    /*
     setspecialeffects
     getspecialeffects
     */
    
    func getLifecycleCallbacksDispatcher() -> FragmentLifecycleCallbacksDispatcher {
        return mLifeycleCallbackDispatcher!
    }
    
    @objc
    public func registerFragmentLifecycleCallbacks(cb: FragmentLifecycleCallbacks, recursive: Bool) {
        mLifeycleCallbackDispatcher!.registerFragmentLifecycleCallbacks(cb: cb, recursive: recursive)
    }
    
    @objc
    public func unregisterFragmentLifecycleCallbacks(cb: FragmentLifecycleCallbacks) {
        mLifeycleCallbackDispatcher!.unregisterFragmentLifecycleCallbacks(cb: cb)
    }
    
    func addFragmentOnAttachListener(listener: FragmentOnAttachListener) {
        mOnAttachListeners.append(listener)
    }
    
    @objc
    public func dispatchOnAttachFragment(fragment: LuaFragment) {
        for listener in mOnAttachListeners {
            listener.onAttachFragment(fragmentManager: self, fragment: fragment)
        }
    }
    
    func removeFragmentOnAttachListener(listener: FragmentOnAttachListener) {
        ArrayExtension.remove(list: &mOnAttachListeners, object: listener)
    }
    
    func dispatchOnHiddenChanged() {
        for fragment in mFragmentStore.getActiveFragments() {
            fragment?.onHiddenChanged(fragment?.isHidden() ?? true)
            fragment?.mChildFragmentManager.dispatchOnHiddenChanged()
        }
    }
    
    //check for menus todo
    
    func reverseTransit(transit: Int) -> Int {
        var rev = 0
        switch(transit) {
        case FragmentTransaction.TRANSIT_FRAGMENT_OPEN:
            rev = FragmentTransaction.TRANSIT_FRAGMENT_CLOSE
        break
        case FragmentTransaction.TRANSIT_FRAGMENT_CLOSE:
            rev = FragmentTransaction.TRANSIT_FRAGMENT_OPEN
        break
        case FragmentTransaction.TRANSIT_FRAGMENT_FADE:
            rev = FragmentTransaction.TRANSIT_FRAGMENT_FADE
        break
        case FragmentTransaction.TRANSIT_FRAGMENT_MATCH_ACTIVITY_OPEN:
            rev = FragmentTransaction.TRANSIT_FRAGMENT_MATCH_ACTIVITY_CLOSE
        break
        case FragmentTransaction.TRANSIT_FRAGMENT_MATCH_ACTIVITY_CLOSE:
            rev = FragmentTransaction.TRANSIT_FRAGMENT_MATCH_ACTIVITY_OPEN
        break
        default:
            break
        }
        return rev
    }
    
    @objc
    public func getLayoutInflaterFactory() -> LGFragmentLayoutParser {
        return mLayoutInflaterFactory!
    }
}
