import Foundation
open class AbstractSavedStateViewModelFactory: ViewModelProviderKeyedFactory {
    let TAG_SAVED_STATE_HANDLE_COTNROLLER = "androidx.lifecycle.savedstate.vm.tag"
    
    let mSavedStateRegistry: SavedStateRegistry
    let mLifecycle: Lifecycle
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
    
    public func getLifecycle() -> Lifecycle! {
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

@objc(NavigatorExtras)
public protocol NavigatorExtras {
    
}

@objc(Navigator)
open class Navigator : NSObject {
    @objc public func getName() -> String {
        return ""
    }
    
    @objc public func createDestination() -> NavDestination {
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
    
    override func getName() -> String {
        return "navigation"
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
            return navigator.navigate(destination: startDestination!,
                                      args: startDestination!.add(inDefaultArgs: args?.objcDictionary)?.swiftDictionaryObj,
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
    override init!(navigator: Navigator!) {
        super.init(navigator: navigator)
    }
    
    func getClassName() -> String {
        return name
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
    
    public override func getName() -> String {
        return "fragment"
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
    
    public override func createDestination() -> NavDestination {
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
        var className = fDestination.getClassName()
        if(className[0] == ".") {
            className = mContext.packageName + className
        }
        let frag = instantiateFragment(context: mContext, fragmentManager: mFragmentManager, className: className, args: args?.objcDictionary)
        frag.luaId = fDestination.idVal.components(separatedBy: "/").last
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
    
    @objc
    public init(context: LuaContext, manager: FragmentManager) {
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
    
    public override func getName() -> String {
        return "dialog"
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
    
    public override func createDestination() -> NavDestination {
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

protocol OnNavigateUpListener
{
    func onNavigateUp() -> Bool
}

@objc(AbstractAppBarOnDestinationChangedListener)
open class AbstractAppBarOnDestinationChangedListener : NSObject, OnDestinationChangedListener {
    let mContext: LuaContext
    let mTopLevelDestinations: NSMutableSet
    let mOpenableLayout: LGView?
    var mArrowDrawable: UIImage?
    //TODO: Animation?
    
    init(context: LuaContext, configuration: AppBarConfiguration) {
        mContext = context
        mTopLevelDestinations = configuration.getTopLevelDestinations()
        mOpenableLayout = configuration.getOpenableLayout()
    }
    
    func setTitle(title: String) {
        
    }
    
    func setNavigationIcon(drawable: UIImage?) {
        
    }
    
    public func onDestinationChanged(controller: NavController, destination: NavDestination, arguments: NSMutableDictionary?) {
        /*
         //TODO
         if (destination instanceof FloatingWindow) {
                     return;
                 }
         */
        if(mOpenableLayout == nil) {
            controller.removeOnDestinationChangedListener(listener: self)
        }
        let label = destination.mLabel
        if(label != nil) {
            setTitle(title: label!)
        }
        let isTopLevelDestination = NavigationUI.matchDestinations(destination: destination, destinationIds: mTopLevelDestinations)
        if(mOpenableLayout == nil && isTopLevelDestination) {
            setNavigationIcon(drawable: nil)
        }
        else {
            setActionBarUpIndicator(showAsDrawerIndicator: self.mOpenableLayout != nil && isTopLevelDestination)
        }
    }
    
    func setActionBarUpIndicator(showAsDrawerIndicator: Bool) {
        var animate = true
        if(mArrowDrawable == nil) {
            let strBase64 = "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"
            let dataDecoded : Data = Data(base64Encoded: strBase64, options: .ignoreUnknownCharacters)!
            mArrowDrawable = UIImage(data: dataDecoded)!
            animate = false
        }
        setNavigationIcon(drawable: mArrowDrawable)
        //TODO: Animation
    }
}

class ActionBarOnDestinationChangedListener : AbstractAppBarOnDestinationChangedListener {
    let form: LuaForm
    
    init(form: LuaForm, configuration: AppBarConfiguration) {
        self.form = form
        super.init(context: form.context, configuration: configuration)
    }
    
    override func setTitle(title: String) {
        let toolbar = form.toolbar
        toolbar?.setTitle(title)
    }
    
    override func setNavigationIcon(drawable: UIImage?) {
        let toolbar = form.toolbar
        if(drawable == nil) {
            toolbar?.setNavigationIcon(nil)
        }
        else {
            let stream = LuaStream()
            stream.nonStreamData = drawable
            toolbar?.setNavigationIcon(stream)
        }
    }
}

class ToolbarOnDestinationChangedListener : AbstractAppBarOnDestinationChangedListener {
    let toolbar: LGToolbar?
    
    init(toolbar: LGToolbar, configuration: AppBarConfiguration) {
        self.toolbar = toolbar
        super.init(context: toolbar.lc, configuration: configuration)
    }
    
    override func onDestinationChanged(controller: NavController, destination: NavDestination, arguments: NSMutableDictionary?) {
        if(self.toolbar == nil) {
            controller.removeOnDestinationChangedListener(listener: self)
        }
        
        super.onDestinationChanged(controller: controller, destination: destination, arguments: arguments)
    }
    
    override func setTitle(title: String) {
        self.toolbar?.setTitle(title)
    }
    
    override func setNavigationIcon(drawable: UIImage?) {
        if(drawable == nil) {
            toolbar?.setNavigationIcon(nil)
        }
        else {
            let stream = LuaStream()
            stream.nonStreamData = drawable
            toolbar?.setNavigationIcon(stream)
        }
    }
}

@objc(AppBarConfiguration)
open class AppBarConfiguration: NSObject {
    @objc public var mTopLevelDestinations: NSMutableSet
    var mOpenableLayout: LGView?
    var mFallbackOnNavigateUpListener: OnNavigateUpListener?
    
    @objc override public init() {
        mTopLevelDestinations = NSMutableSet()
    }
    
    func getTopLevelDestinations() -> NSMutableSet {
        return mTopLevelDestinations
    }
    
    func getOpenableLayout() -> LGView? {
        return mOpenableLayout
    }
    
    //TODO drawer?
    
    func getFallbackOnNavigateUpListener() -> OnNavigateUpListener? {
        return mFallbackOnNavigateUpListener
    }
    
    func Builder(navGraph: NavGraph) {
        mTopLevelDestinations.add(NavigationUI.findStartDestination(graph: navGraph))
    }
}

//TODO: Populate this with menuitem?
@objc(NavigationUI)
open class NavigationUI : NSObject, LuaClass, LuaInterface
{
    public func getId() -> String! {
        return "LuaNavigationUI"
    }
    
    public static func className() -> String! {
        return "LuaNavigationUI"
    }
    
    public static func luaMethods() -> NSMutableDictionary! {
        let dict = NSMutableDictionary()
        
        dict["navigateUp"] = LuaFunction.createC(true, class_getClassMethod(self, #selector(navigateUp(navController:configuration:))), #selector(navigateUp(navController:configuration:)), LuaBool.self, [LuaNavController.self, LuaAppBarConfiguration.self], NavigationUI.self)
        dict["navigateUpView"] = LuaFunction.createC(true, class_getClassMethod(self, #selector(navigateUp(navController:openableLayout:))), #selector(navigateUp(navController:openableLayout:)), LuaBool.self, [LuaNavController.self, LGView.self], NavigationUI.self)
        dict["setupActionBarWithNavController"] = LuaFunction.createC(true, class_getClassMethod(self, #selector(setupActionBarWithNavController(form:navController:))), #selector(setupActionBarWithNavController(form:navController:)), nil, [LuaForm.self, LuaNavController.self], NavigationUI.self)
        dict["setupActionBarWithNavControllerView"] = LuaFunction.createC(true, class_getClassMethod(self, #selector(setupActionBarWithNavController(form:navController:openableLayout:))), #selector(setupActionBarWithNavController(form:navController:openableLayout:)), nil, [LuaForm.self, LuaNavController.self, LGView.self], NavigationUI.self)
        dict["setupActionBarWithNavControllerConfiguration"] = LuaFunction.createC(true, class_getClassMethod(self, #selector(setupActionBarWithNavController(form:navController:configuration:))), #selector(setupActionBarWithNavController(form:navController:configuration:)), nil, [LuaForm.self, LuaNavController.self, LuaAppBarConfiguration.self], NavigationUI.self)
        dict["setupWithNavController"] = LuaFunction.createC(true, class_getClassMethod(self, #selector(setupWithNavController(toolbar:navController:))), #selector(setupWithNavController(toolbar:navController:)), nil, [LGToolbar.self, LuaNavController.self], NavigationUI.self)
        dict["setupWithNavControllerView"] = LuaFunction.createC(true, class_getClassMethod(self, #selector(setupWithNavController(toolbar:navController:openableLayout:))), #selector(setupWithNavController(toolbar:navController:openableLayout:)), nil, [LGToolbar.self, LuaNavController.self, LGView.self], NavigationUI.self)
        dict["setupWithNavControllerConfiguration"] = LuaFunction.createC(true, class_getClassMethod(self, #selector(setupWithNavController(toolbar:navController:configuration:))), #selector(setupWithNavController(toolbar:navController:configuration:)), nil, [LGToolbar.self, LuaNavController.self, LuaAppBarConfiguration.self], NavigationUI.self)
        
        return dict
    }
    
    @objc public static func navigateUp(navController: LuaNavController, openableLayout: LGView) -> Bool {
        return NavigationUI.navigateUpI(navController: navController.no, openableLayout: openableLayout)
    }
    
    @objc public static func navigateUpI(navController: NavController, openableLayout: LGView) -> Bool {
        let controller = AppBarConfiguration()
        controller.Builder(navGraph: navController.getGraph())
        controller.mOpenableLayout = openableLayout
        return NavigationUI.navigateUpI(navController: navController, configuration: controller)
    }
    
    @objc public static func navigateUp(navController: LuaNavController, configuration: LuaAppBarConfiguration) -> Bool {
        NavigationUI.navigateUpI(navController: navController.no, configuration: configuration.no)
    }
    
    @objc public static func navigateUpI(navController: NavController, configuration: AppBarConfiguration) -> Bool {
        let openableLayout = configuration.mOpenableLayout
        let currentDestination = navController.getCurrentDestination()
        let topLevelDestinations = configuration.getTopLevelDestinations()
        if(openableLayout != nil && currentDestination != nil && NavigationUI.matchDestinations(destination: currentDestination!, destinationIds: topLevelDestinations)) {
            //TODO:Open layout?
            return true
        }
        else {
            if(navController.navigateUp()) {
                return true
            }
            else if(configuration.getFallbackOnNavigateUpListener() != nil) {
                return configuration.getFallbackOnNavigateUpListener()!.onNavigateUp()
            }
            else {
                return false
            }
        }
    }
    
    @objc public static func setupActionBarWithNavController(form: LuaForm, navController: LuaNavController) {
        NavigationUI.setupActionBarWithNavControllerI(form: form, navController: navController.no)
    }
    
    @objc public static func setupActionBarWithNavControllerI(form: LuaForm, navController: NavController) {
        let configuration = AppBarConfiguration()
        configuration.Builder(navGraph: navController .getGraph())
        setupActionBarWithNavControllerI(form: form, navController: navController, configuration: configuration)
    }
    
    @objc public static func setupActionBarWithNavController(form: LuaForm, navController: LuaNavController, openableLayout: LGView) {
        NavigationUI.setupActionBarWithNavControllerI(form: form, navController: navController.no, openableLayout: openableLayout)
    }
    
    @objc public static func setupActionBarWithNavControllerI(form: LuaForm, navController: NavController, openableLayout: LGView) {
        let configuration = AppBarConfiguration()
        configuration.Builder(navGraph: navController .getGraph())
        configuration.mOpenableLayout = openableLayout
        setupActionBarWithNavControllerI(form: form, navController: navController, configuration: configuration)
    }
    
    @objc public static func setupActionBarWithNavController(form: LuaForm, navController: LuaNavController, configuration: LuaAppBarConfiguration) {
        NavigationUI.setupActionBarWithNavControllerI(form: form, navController: navController.no, configuration: configuration.no)
    }
    
    @objc public static func setupActionBarWithNavControllerI(form: LuaForm, navController: NavController, configuration: AppBarConfiguration) {
        navController.addOnDestinationChangedListener(listener: ActionBarOnDestinationChangedListener(form: form, configuration: configuration))
    }
    
    @objc public static func setupWithNavController(toolbar: LGToolbar, navController: LuaNavController) {
        NavigationUI.setupWithNavControllerI(toolbar: toolbar, navController: navController.no)
    }
    
    @objc public static func setupWithNavControllerI(toolbar: LGToolbar, navController: NavController) {
        let configuration = AppBarConfiguration()
        configuration.Builder(navGraph: navController.getGraph())
        setupWithNavControllerI(toolbar: toolbar, navController: navController, configuration: configuration)
    }
    
    @objc public static func setupWithNavController(toolbar: LGToolbar, navController: LuaNavController, openableLayout: LGView) {
        NavigationUI.setupWithNavControllerI(toolbar: toolbar, navController: navController.no, openableLayout: openableLayout)
    }
    
    @objc public static func setupWithNavControllerI(toolbar: LGToolbar, navController: NavController, openableLayout: LGView) {
        let configuration = AppBarConfiguration()
        configuration.Builder(navGraph: navController.getGraph())
        configuration.mOpenableLayout = openableLayout
        setupWithNavControllerI(toolbar: toolbar, navController: navController, configuration: configuration)
    }
    
    class ClickListener : NSObject, OnClickListenerInternal {
        let navController: NavController
        let configuration: AppBarConfiguration
        
        init(navController: NavController, configuration: AppBarConfiguration) {
            self.navController = navController
            self.configuration = configuration
        }
        
        func onClick(_ view: LGView!) -> Any! {
            NavigationUI.navigateUpI(navController:navController, configuration:configuration)
        }
    }
    
    @objc public static func setupWithNavController(toolbar: LGToolbar, navController: LuaNavController, configuration: LuaAppBarConfiguration) {
        NavigationUI.setupWithNavControllerI(toolbar: toolbar, navController: navController.no, configuration: configuration.no)
    }
    
    @objc public static func setupWithNavControllerI(toolbar: LGToolbar, navController: NavController, configuration: AppBarConfiguration) {
        navController.addOnDestinationChangedListener(listener: ToolbarOnDestinationChangedListener(toolbar: toolbar, configuration: configuration))
        toolbar.setNavigationOnClickListenerInternal(ClickListener(navController: navController, configuration: configuration))
    }
    
    @objc public static func matchDestination(destination: NavDestination, destId: String) -> Bool {
        var currentDestination = destination;
        while (currentDestination.idVal != destId && currentDestination.mParent != nil) {
            currentDestination = currentDestination.mParent
        }
        return currentDestination.idVal == destId;
    }
    
    @objc public static func matchDestinations(destination: NavDestination, destinationIds: NSSet) -> Bool {
        var currentDestination: NavDestination? = destination;
        repeat {
            if(destinationIds.contains(currentDestination?.idVal)) {
                return true
            }
            currentDestination = currentDestination?.mParent
        } while(currentDestination != nil)
        return false;
    }
    
    @objc public static func findStartDestination(graph: NavGraph) -> NavDestination {
        var startDestination = graph as NSObject
        while (startDestination.isKind(of: NavGraph.self)) {
            let parent = startDestination as! NavGraph
            startDestination = parent.findNode(parent.mStartDestinationId)
        }
        return startDestination as! NavDestination
    }
}
