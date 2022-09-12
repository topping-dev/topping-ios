import Foundation
open class AbstractSavedStateViewModelFactory: ViewModelProviderKeyedFactory {
    let TAG_SAVED_STATE_HANDLE_COTNROLLER = "androidx.lifecycle.savedstate.vm.tag"
    
    let mSavedStateRegistry: SavedStateRegistry
    let mLifecycle: LuaLifecycle
    let mDefaultArgs: Bundle?
    
    init(owner: SavedStateRegistryOwner, defaultArgs: Bundle?) {
        mSavedStateRegistry = owner.getSavedStateRegistry()
        mLifecycle = owner.getLifecycle()
        mDefaultArgs = defaultArgs
    }
    
    public override func create(key: String) -> LuaViewModel {
        let controller = SavedStateHandleController.create(registry: mSavedStateRegistry, lifecycle: mLifecycle, key: key, defaultArgs: mDefaultArgs)
        let viewModel: LuaViewModel = create(key: key, handle: controller.getHandle())
        viewModel.setTagIfAbsent(TAG_SAVED_STATE_HANDLE_COTNROLLER, controller)
        return viewModel
    }
    
    public override func create() -> LuaViewModel {
        return create(key: "LuaViewModel")
    }
    
    func create(key: String, handle: SavedStateHandle) -> LuaViewModel {
        return LuaViewModel()
    }
    
    override func onRequery(viewModel: LuaViewModel) {
        SavedStateHandleController.attachHandleIfNeeded(viewModel: viewModel, registry: mSavedStateRegistry, lifecycle: mLifecycle)
    }
}

@objc(Navigation)
open class Navigation: NSObject {
    @objc
    public static func findNavController(form: LuaForm, viewId: String) -> NavController {
        let view = form.getViewById(viewId)
        let navController = findViewNavController(view: view!)
        return navController!
    }
    
    @objc
    public static func findNavController(view: LGView) -> NavController {
        let navController = findViewNavController(view: view)
        return navController!
    }
    
//    public static func createNavigateOnClickListener(restId: String) -
    
    @objc
    public static func setViewNavController(view: LGView, controller: NavController?) {
        view.navController = controller
    }
    
    @objc
    public static func findViewNavController(view: LGView) -> NavController? {
        var viewToLoop: LGView? = view
        while(viewToLoop != nil) {
            let controller = getViewNavController(view: viewToLoop!)
            if(controller != nil) {
                return controller
            }
            viewToLoop = viewToLoop!.parent
        }
        return nil
    }
    
    @objc
    public static func getViewNavController(view: LGView) -> NavController? {
        return view.navController
    }
}

class NavControllerViewModel : LuaViewModel {
    class NavControllerViewModelProviderFactory : NSObject, ViewModelProviderFactory {
        func create() -> LuaViewModel {
            return NavControllerViewModel()
        }
    }
    
    static func getInstance(viewModelStore: ViewModelStore) -> NavControllerViewModel {
        let vmp = ViewModelProvider(store: viewModelStore, factory: NavControllerViewModelProviderFactory())
        return vmp.get() as! NavControllerViewModel
    }
    
    var mViewModelStores = Dictionary<UUID, ViewModelStore>()
    
    func clear(backStackEntryUUID: UUID) {
        let viewModelStore = mViewModelStores.removeValue(forKey: backStackEntryUUID)
        viewModelStore?.clear()
    }
    
    override func onCleared() {
        for store in mViewModelStores.values {
            store.clear()
        }
        mViewModelStores.removeAll()
    }
    
    func getViewModelStore(backStackEntryUUID: UUID) -> ViewModelStore {
        var viewModelStore = mViewModelStores[backStackEntryUUID]
        if(viewModelStore == nil) {
            viewModelStore = ViewModelStore()
            mViewModelStores[backStackEntryUUID] = viewModelStore
        }
        return viewModelStore!
    }
}

@objc(NavBackStackEntry)
open class NavBackStackEntry : NSObject, LifecycleOwner, ViewModelStoreOwner, HasDefaultViewModelProviderFactory, SavedStateRegistryOwner
{
    class SavedStateViewModel : LuaViewModel {
        let mHandle: SavedStateHandle
        
        init(handle: SavedStateHandle) {
            mHandle = handle
        }
        
        func getHandle() -> SavedStateHandle {
            return mHandle
        }
    }
    
    class NavResultSavedStateFactory : AbstractSavedStateViewModelFactory {
        override func create(key: String, handle: SavedStateHandle) -> LuaViewModel {
            let savedStateViewModel = SavedStateViewModel(handle: handle)
            return savedStateViewModel
        }
    }
    
    var mContext: LuaContext
    var mDestination: NavDestination
    var mArgs: Bundle?
    var mLifecycle: LifecycleRegistry
    var mSavedStateRegistryController: SavedStateRegistryController?
    var mId: UUID
    var mHostLifecycle = LifecycleState.LIFECYCLESTATE_CREATED
    var mMaxLifecycle = LifecycleState.LIFECYCLESTATE_RESUMED
    var mNavControllerViewModel: NavControllerViewModel?
    var mDefaultFactory: ViewModelProviderFactory?
    var mSavedStateHandle: SavedStateHandle?
    
    init(context: LuaContext,
         destination: NavDestination, args: Bundle?,
         navControllerLifecycleOwner: LifecycleOwner?, navControllerViewModel: NavControllerViewModel?,
         uuid: UUID, savedState: Bundle?) {
        mContext = context
        mId = uuid
        mDestination = destination
        mArgs = args
        mNavControllerViewModel = navControllerViewModel
        mLifecycle = LifecycleRegistry()
        super.init()
        mSavedStateRegistryController = SavedStateRegistryController(owner: self)
        mSavedStateRegistryController!.performRestore(savedStrate: savedState)
        if(navControllerLifecycleOwner != nil) {
            mHostLifecycle = navControllerLifecycleOwner!.getLifecycle().getCurrentState()
        }
        mLifecycle = LifecycleRegistry(owner: self)
    }
    
    convenience init(context: LuaContext,
                     destination: NavDestination, args: Bundle?,
                     navControllerLifecycleOwner: LifecycleOwner?, navControllerViewModel: NavControllerViewModel?) {
        self.init(context: context, destination: destination, args: args, navControllerLifecycleOwner: navControllerLifecycleOwner, navControllerViewModel: navControllerViewModel, uuid: UUID.init(), savedState: nil)
    }
    
    func getDestination() -> NavDestination {
        return mDestination
    }
    
    func getArguments() -> Bundle? {
        return mArgs
    }
    
    func replaceArguments(newArgs: Bundle?) {
        mArgs = newArgs
    }
    
    public func getLifecycle() -> LuaLifecycle! {
        return mLifecycle
    }
    
    func setMaxLifecycle(maxState: LifecycleState) {
        mMaxLifecycle = maxState
        updateState()
    }
    
    func getMaxLifecycle() -> LifecycleState {
        return mMaxLifecycle
    }
    
    func handleLifecycleEvent(event: LifecycleEvent) {
        mHostLifecycle = NavBackStackEntry.getStateAfter(event: event)
        updateState()
    }
    
    func updateState() {
        if(mHostLifecycle.rawValue < mMaxLifecycle.rawValue) {
            mLifecycle.setCurrentState(mHostLifecycle)
        } else {
            mLifecycle.setCurrentState(mMaxLifecycle)
        }
    }
    
    public func getViewModelStore() -> ViewModelStore! {
        return mNavControllerViewModel!.getViewModelStore(backStackEntryUUID: mId)
    }
    
    func getDefaultViewModelProviderFactory() -> ViewModelProviderFactory {
        if(mDefaultFactory == nil) {
            mDefaultFactory = SavedStateViewModelFactory(context: mContext, owner: self, defaultArgs: mArgs?.objcDictionary)
        }
        return mDefaultFactory!
    }
    
    public func getSavedStateRegistry() -> SavedStateRegistry {
        return mSavedStateRegistryController!.getSavedStateRegistry()
    }
    
    func saveState(outBundle: Bundle)  {
        mSavedStateRegistryController!.performSave(outBundle: outBundle)
    }
    
    func getSavedStateHandle() -> SavedStateHandle {
        if(mSavedStateHandle == nil) {
            mSavedStateHandle = (ViewModelProvider(owner: self, factory: NavResultSavedStateFactory(owner: self, defaultArgs: nil)).get() as! SavedStateViewModel).getHandle()
        }
        return mSavedStateHandle!
    }
    
    static func getStateAfter(event: LifecycleEvent) -> LifecycleState {
        switch(event) {
        case .LIFECYCLEEVENT_ON_CREATE:
            return LifecycleState.LIFECYCLESTATE_CREATED
        case .LIFECYCLEEVENT_ON_STOP:
            return LifecycleState.LIFECYCLESTATE_CREATED
        case .LIFECYCLEEVENT_ON_START:
            return LifecycleState.LIFECYCLESTATE_STARTED
        case .LIFECYCLEEVENT_ON_PAUSE:
            return LifecycleState.LIFECYCLESTATE_STARTED
        case .LIFECYCLEEVENT_ON_RESUME:
            return LifecycleState.LIFECYCLESTATE_RESUMED
        case .LIFECYCLEEVENT_ON_DESTROY:
            return LifecycleState.LIFECYCLESTATE_DESTROYED
        case .LIFECYCLEEVENT_ON_ANY:
            return LifecycleState.LIFECYCLESTATE_NIL
        case .LIFECYCLEEVENT_NIL:
            return LifecycleState.LIFECYCLESTATE_NIL
        }
    }
}

protocol NavigatorExtras {
    
}

@objc(Navigator)
open class Navigator : NSObject {
    @objc public func getName() -> String {
        return ""
    }
    
    func createDestination() -> NavDestination {
        return NavDestination()
    }
    
    func navigate(destination: NavDestination, args: Bundle?, navOptions: NavOptions?, navigatorExtras: NavigatorExtras?) -> NavDestination? {
        return nil;
    }
    
    func popBackStack() -> Bool {
        return false
    }
    
    func onSaveState() -> Bundle? {
        return nil
    }
    
    func onRestoreState(savedState: Bundle?) {
        
    }
}

@objc(NavigationProvider)
open class NavigatorProvider: NSObject {
    var mNavigators = Dictionary<String, Navigator>()
    
    @objc
    public func getNavigator(name: String) -> Navigator {
        let navigator = mNavigators[name]
        return navigator!
    }
    
    @objc
    public func getNavigator(navigator: Navigator) -> Navigator {
        return getNavigator(name: navigator.getName())
    }
    
    @objc
    public func addNavigator(navigator: Navigator) -> Navigator {
        mNavigators[navigator.getName()] = navigator
        return navigator
    }
    
    @objc
    public func addNavigator(name: String, navigator: Navigator) -> Navigator {
        mNavigators[name] = navigator
        return navigator
    }
    
    @objc
    public func getNavigators() -> Dictionary<String, Navigator> {
        return mNavigators
    }
}

@objc(OnDestinationChanged)
public protocol OnDestinationChangedListener: NSObjectProtocol {
    func onDestinationChanged(controller: NavController, destination: NavDestination, arguments: NSMutableDictionary?)
}

class OnBackPressedCallbackN: OnBackPressedCallback {
    var handleOnBackPressedO:() -> () = { }
    
    init(enabled: Bool, overrides: (OnBackPressedCallbackN) -> OnBackPressedCallbackN) {
        super.init(enabled: enabled)
        overrides(self)
    }
    
    override func handleOnBackPressed() {
        self.handleOnBackPressedO()
    }
}

class NavGraphNavigator : Navigator
{
    let mNavigationProvider: NavigatorProvider
    
    init(navigationProvider: NavigatorProvider) {
        mNavigationProvider = navigationProvider
    }
    
    override func createDestination() -> NavDestination {
        return NavGraph(navigator: self)
    }
    
    override func navigate(destination: NavDestination, args: Bundle?, navOptions: NavOptions?, navigatorExtras: NavigatorExtras?) -> NavDestination? {
        if(destination is NavGraph) {
            let startId = (destination as! NavGraph).mStartDestinationId
            if(startId == nil || startId == "") {
                return nil
            }
            let startDestination = (destination as! NavGraph).findNode(startId, false)
            if(startDestination == nil) {
                return nil
            }
            let navigator: Navigator = mNavigationProvider.getNavigator(name: startDestination!.mNavigatorName)
            return navigator.navigate(destination: startDestination! as! NavGraph,
                                      args: startDestination!.add(inDefaultArgs: args?.objcDictionary).swiftDictionaryObj,
                                      navOptions: navOptions,
                                      navigatorExtras: navigatorExtras)
        }
        return nil
    }
    
    override func popBackStack() -> Bool {
        return true
    }
}

/*class ActivityNavigator : Navigator {
    var mContext: LuaContext
    var mHostActivity: LuaForm
    
    init(context: LuaContext) {
        mContext = context
        mHostActivity = context.form
    }
    
    override func createDestination() -> NavDestination {
        
    }
}*/

class NavBackStackEntryState : NSObject {
    let mUUID: UUID
    let mDestinationId: String
    let mArgs: Bundle?
    let mSavedState: Bundle
    
    init(entry: NavBackStackEntry) {
        mUUID = entry.mId
        mDestinationId = entry.getDestination().idVal
        mArgs = entry.getArguments()
        mSavedState = Bundle()
        entry.saveState(outBundle: mSavedState)
    }
}

@objc(NavHostController)
open class NavHostController: NavController {
    override public func setLifecycleOwner(owner: LifecycleOwner) {
        super.setLifecycleOwner(owner: owner)
    }
    
    override public func setOnBackPressedDispatcher(dispatcher: OnBackPressedDispatcher) {
        super.setOnBackPressedDispatcher(dispatcher: dispatcher)
    }
    
    override public func enableOnBackPressed(enabled: Bool) {
        super.enableOnBackPressed(enabled: enabled)
    }
    
    override public func setViewModelStore(viewModelStore: ViewModelStore) {
        super.setViewModelStore(viewModelStore: viewModelStore)
    }
}

class FragmentDestination: NavDestination {
    var mClassName: String = ""
    
    override init!(navigator: Navigator!) {
        super.init(navigator: navigator)
    }
}

@objc(FragmentNavigator)
open class FragmentNavigator: Navigator {
    static let BACK_STACK_STACK_IDS = "androidx-nav-fragment:navigator:backStackIds"
    let mContext: LuaContext
    let mFragmentManager: FragmentManager
    let mContainerId: String
    var mBackStack = Deque<String>()
    
    @objc
    public init(context: LuaContext, manager: FragmentManager, containerId: String) {
        mContext = context
        mFragmentManager = manager
        mContainerId = containerId
    }
    
    override func popBackStack() -> Bool {
        if(mBackStack.isEmpty) {
            return false
        }
        if(mFragmentManager.isStateSaved()) {
            return false
        }
        mFragmentManager.popBackStack(name: generateBackStackName(backStackIndex: mBackStack.count, destId: mBackStack.getLast()!), flags: FragmentManager.POP_BACK_STACK_INCLUSIVE)
        mBackStack.removeLast()
        return true
    }
    
    override func createDestination() -> NavDestination {
        return FragmentDestination(navigator: self)
    }
    
    func instantiateFragment(context: LuaContext, fragmentManager: FragmentManager, className: String, args: NSMutableDictionary?) -> LuaFragment {
        return (fragmentManager.getFragmentFactory()?.instantiate(className: className)!)!
    }
    
    override func navigate(destination: NavDestination, args: Bundle?, navOptions: NavOptions?, navigatorExtras: NavigatorExtras?) -> NavDestination? {
        if(mFragmentManager.isStateSaved()) {
            return nil
        }
        if(!(destination is FragmentDestination)) {
            return nil
        }
        let fDestination = destination as! FragmentDestination
        var className = fDestination.mClassName
        if(className[0] == ".") {
            className = mContext.packageName + className
        }
        let frag = instantiateFragment(context: mContext, fragmentManager: mFragmentManager, className: className, args: args?.objcDictionary)
        frag.mArguments = args?.objcDictionary
        let ft = mFragmentManager.beginTransaction()
        
        var enterAnim = navOptions != nil ? navOptions?.mEnterAnim : ""
        var exitAnim = navOptions != nil ? navOptions?.mExitAnim : ""
        var popEnterAnim = navOptions != nil ? navOptions?.mPopEnterAnim : ""
        var popExitAnim = navOptions != nil ? navOptions?.mPopExitAnim : ""
        if(enterAnim != "" || exitAnim != "" || popEnterAnim != "" || popExitAnim != "") {
            enterAnim = enterAnim != "" ? enterAnim : ""
            exitAnim = exitAnim != "" ? exitAnim : ""
            popEnterAnim = popEnterAnim != "" ? popEnterAnim : ""
            popExitAnim = popExitAnim != "" ? popExitAnim : ""
            ft.setCustomAnimations(enter: enterAnim!, exit: exitAnim!, popEnter: popEnterAnim!, popExit: popExitAnim!)
        }
        
        ft.replace(containerViewId: mContainerId, fragment: frag)
        ft.setPrimaryNavigationFragment(fragment: frag)
        
        let destId = destination.idVal
        let initialNavigation = mBackStack.isEmpty
        let isSingleTopReplacement = navOptions != nil && !initialNavigation && ((navOptions?.mSingleTop) != nil) && mBackStack.getLast() == destId
        
        var isAdded: Bool
        if(initialNavigation) {
            isAdded = true
        } else if(isSingleTopReplacement) {
            if(mBackStack.count > 1) {
                mFragmentManager.popBackStack(name: generateBackStackName(backStackIndex: mBackStack.count, destId: mBackStack.getLast()!), flags: FragmentManager.POP_BACK_STACK_INCLUSIVE)
                ft.addToBackStack(name: generateBackStackName(backStackIndex: mBackStack.count, destId: destId!))
            }
            isAdded = true
        } else {
            ft.addToBackStack(name: generateBackStackName(backStackIndex: mBackStack.count + 1, destId: destId!))
            isAdded = true
        }
        if(navigatorExtras != nil && navigatorExtras is FragmentNavigatorExtras) {
            var extras = navigatorExtras as! FragmentNavigatorExtras
            for sharedElement in extras.mSharedElements {
                ft.addSharedElement(sharedElement: sharedElement.key, name: sharedElement.value)
            }
        }
        ft.mReorderingAllowed = true
        ft.commit()
        if(isAdded) {
            mBackStack.append(destId!)
            return destination
        } else {
            return nil
        }
    }
    
    override func onSaveState() -> Bundle? {
        var b = Bundle()
        var backStack = Array<String>()
        for id in mBackStack {
            backStack.append(id)
        }
        b[FragmentNavigator.BACK_STACK_STACK_IDS] = backStack.objcArray
        return b
    }
    
    override func onRestoreState(savedState: Bundle?) {
        if(savedState != nil) {
            var backStack = savedState![FragmentNavigator.BACK_STACK_STACK_IDS] as? NSArray
            if(backStack != nil) {
                mBackStack.removeAll()
                var sArr = backStack!.swiftArrayObj
                for destId in sArr {
                    mBackStack.append((destId as? NSString)! as String)
                }
            }
        }
    }
    
    private func generateBackStackName(backStackIndex: Int, destId: String) -> String {
        return String(backStackIndex) + "-" + destId
    }
    
    class FragmentNavigatorExtras : NavigatorExtras {
        let mSharedElements: Dictionary<LGView, String> = Dictionary()
    }
}

class DialogDestination: NavDestination {
}

@objc(DialogFragmentNavigator)
open class DialogFragmentNavigator: Navigator {
    private static let KEY_DIALOG_COUNT = "androidx-nav-dialogfragment:navigator:count"
    private static let DIALOG_TAG = "androidx-nav-fragment:navigator:dialog:"
    var mContext: LuaContext
    var mFragmentManager: FragmentManager
    var mDialogCount = 0
    var mRestoredTagsAwaitingAttach = Set<String>()
    
    private var mObserver: LifecycleEventObserver
    
    init(context: LuaContext, manager: FragmentManager) {
        mContext = context
        mFragmentManager = manager
        
        mObserver = LifecycleEventObserverI { leo in
            leo.onStateChangedO = { source, event in
                if(event == LifecycleEvent.LIFECYCLEEVENT_ON_STOP) {
                    //TODO:DialogFragment
                }
            }
            return leo
        }
    }
    
    override func popBackStack() -> Bool {
        if(mDialogCount == 0) {
            return false
        }
        if(mFragmentManager.isStateSaved()) {
            return false
        }
        mDialogCount -= 1
        let existingFragment = mFragmentManager.findFragmentByTag(tag: DialogFragmentNavigator.DIALOG_TAG + String(mDialogCount))
        if(existingFragment != nil) {
            existingFragment?.getLifecycle().remove(mObserver)
            //TODO
            //Dialog dismiss
        }
        return true
    }
    
    override func createDestination() -> NavDestination {
        return DialogDestination(navigator: self)
    }
    
    override func navigate(destination: NavDestination, args: Bundle?, navOptions: NavOptions?, navigatorExtras: NavigatorExtras?) -> NavDestination? {
        if(mFragmentManager.isStateSaved()) {
            return nil
        }
        let frag = mFragmentManager.getFragmentFactory()?.instantiate()
        frag?.mArguments = args?.objcDictionary
        frag?.getLifecycle().add(mObserver)
        
        //TODO:Show
        return destination
    }
    
    override func onSaveState() -> Bundle? {
        if(mDialogCount == 0) {
            return nil
        }
        var b = Bundle()
        b[DialogFragmentNavigator.KEY_DIALOG_COUNT] = NSNumber(value: mDialogCount)
        return b
    }
    
    override func onRestoreState(savedState: Bundle?) {
        if(savedState != nil) {
            let mDialogCountN = savedState![DialogFragmentNavigator.KEY_DIALOG_COUNT] as? NSNumber
            if(mDialogCountN != nil) {
                mDialogCount = mDialogCountN!.intValue
            } else {
                mDialogCount = 0
            }
            for index in 0..<mDialogCount {
                let fragment = mFragmentManager.findFragmentByTag(tag: DialogFragmentNavigator.DIALOG_TAG + String(index))
                if(fragment != nil) {
                    fragment?.getLifecycle().add(mObserver)
                } else {
                    mRestoredTagsAwaitingAttach.insert(DialogFragmentNavigator.DIALOG_TAG + String(index))
                }
            }
        }
    }
    
    func onAttachFragment(childFragment: LuaFragment) {
        let needToAddObserver = mRestoredTagsAwaitingAttach.remove(childFragment.mTag)
        if(needToAddObserver != nil) {
            childFragment.getLifecycle().add(mObserver)
        }
    }
}
