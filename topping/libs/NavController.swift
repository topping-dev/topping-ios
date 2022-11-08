import UIKit

@objc(NavController)
open class NavController: NSObject {    
    static let KEY_NAVIGATOR_STATE = "android-support-nav:controller:navigatorState"
    static let KEY_NAVIGATOR_STATE_NAMES = "android-support-nav:controller:navigatorState:names"
    static let KEY_BACK_STACK = "android-support-nav:controller:backSTack"
    
    var mContext: LuaContext
    var mActivity: LuaForm
    var mInflater: LGNavigationParser?
    var mGraph: NavGraph?
    
    var mNavigatorStateToRestore: Bundle?
    var mBackStackToRestore: Array<NavBackStackEntryState>?
    
    var mBackStack = Deque<NavBackStackEntry>()
    
    var mLifecycleOwner: LifecycleOwner?
    var mViewModel: NavControllerViewModel?
    
    var mNavigatiorProvider = NavigatorProvider()
    
    var mLifecycleObserver: LifecycleEventObserver?
    
    var mOnBackPressedCallback: OnBackPressedCallback?
    
    var mEnableOnBackPressedCallback = true
    
    var mOnDestinationChangedListeners = Array<OnDestinationChangedListener>()
    
    @objc public init(context: LuaContext) {
        mContext = context
        mActivity = context.form
        super.init()
        mLifecycleObserver = LifecycleEventObserverI { leo in
            leo.onStateChangedO = { source, event in
                if(self.mGraph != nil) {
                    for entry in self.mBackStack {
                        entry.handleLifecycleEvent(event: event)
                    }
                }
            }
            return leo
        }
        
        mOnBackPressedCallback = OnBackPressedCallbackN(enabled: false) { obpc in
            obpc.handleOnBackPressedO = {
                self.popBackStack()
            }
            
            return obpc
        }
        
        mNavigatiorProvider.addNavigator(navigator: NavGraphNavigator(navigationProvider: mNavigatiorProvider))
    }
    
    func getBackStack() -> Deque<NavBackStackEntry> {
        return mBackStack
    }
    
    func getContext() -> LuaContext {
        return mContext
    }
    
    @objc
    public func getNavigationProvider() -> NavigatorProvider {
        return mNavigatiorProvider
    }
    
    @objc
    public func addOnDestinationChangedListener(listener: OnDestinationChangedListener) {
        if(!mBackStack.isEmpty) {
            let backStackEntry: NavBackStackEntry = mBackStack.getLast()!
            listener.onDestinationChanged(controller: self, destination: backStackEntry.getDestination(), arguments: backStackEntry.getArguments()?.objcDictionary)
        }
        mOnDestinationChangedListeners.append(listener)
    }
    
    func removeOnDestinationChangedListener(listener: OnDestinationChangedListener) {
        mOnDestinationChangedListeners.remove(nsobject: listener)
    }
    
    func popBackStack() -> Bool {
        if(mBackStack.isEmpty) {
            return false
        }
        return popBackStack(destinationId: getCurrentDestination()!.idVal, inclusive: true)
    }
    
    func popBackStack(destinationId: String, inclusive: Bool) -> Bool {
        let popped = popBackStackInternal(destinationId: destinationId, inclusive: inclusive)
        
        return popped && dispatchOnDestinationChanged()
    }
    
    private func popBackStackInternal(destinationId: String, inclusive: Bool) -> Bool {
        if(mBackStack.isEmpty) {
            return false
        }
        var popOperations = Array<Navigator>()
        var iterator = mBackStack.reversedIterator()
        var foundDestination = false

        var backStackEntry = iterator.next()
        while(backStackEntry != nil) {
            let destination = backStackEntry!.getDestination()
            let navigator = mNavigatiorProvider.getNavigator(name: destination.mNavigatorName)
            if(inclusive || destination.idVal != destinationId) {
                popOperations.append(navigator)
            }
            if(destination.idVal == destinationId) {
                foundDestination = true
                break
            }
            backStackEntry = iterator.next()
        }
        if(!foundDestination) {
            return false
        }
        var popped = false
        for navigator in popOperations {
            if(navigator.popBackStack()) {
                let entry = mBackStack.removeLast()
                if(Lifecycle.is(atLeast: entry.getLifecycle().getCurrentState(), LifecycleState.LIFECYCLESTATE_CREATED)) {
                    entry.setMaxLifecycle(maxState: LifecycleState.LIFECYCLESTATE_DESTROYED)
                }
                if(mViewModel != nil) {
                    mViewModel?.clear(backStackEntryUUID: entry.mId)
                }
                popped = true
            } else {
                break
            }
        }
        updateOnBackPressedCallbackEnabled()
        return popped
    }
    
    @objc
    public func navigateUp() -> Bool {
        if(getDestinationCountOnBackStack() == 1) {
            let currentDestination = getCurrentDestination()
            var destId = currentDestination?.idVal
            var parent = currentDestination?.mParent
            while(parent != nil) {
                if(parent!.mStartDestinationId != destId) {
                    var args = Bundle()
                    
                    //TODO:Activity
                    /*if(mActivity != nil && mActivity. != nil) {
                        
                    }*/
                    if(mActivity != nil) {
                        mActivity.close()
                    }
                    return true
                }
                destId = parent?.idVal
                parent = parent?.mParent
            }
            return false
        } else {
            return popBackStack()
        }
    }
    
    func getDestinationCountOnBackStack() -> Int {
        var count = 0
        for indice in mBackStack.indices {
            let entry = mBackStack[indice]
            if(!(entry.getDestination() is NavGraph)){
                count += 1
            }
        }
        return count
    }
    
    func dispatchOnDestinationChanged() -> Bool {
        while(!mBackStack.isEmpty
              && mBackStack.getLast()!.getDestination() is NavGraph
              && popBackStackInternal(destinationId: mBackStack.getLast()!.getDestination().idVal, inclusive: true)) {
            
        }
        if(!mBackStack.isEmpty) {
            var nextResumed: NavDestination? = mBackStack.getLast()!.getDestination()
            var nextStarted: NavDestination? = nil
            /*if(nextResumed) Floating?*/
            var upwardStateTransitions = Dictionary<NavBackStackEntry, LifecycleState>()
            let iterator = mBackStack.reversedIterator()
            var entry:NavBackStackEntry? = iterator.next()
            while(entry != nil) {
                let currentMaxLifecycle = entry!.getMaxLifecycle()
                let destination = entry!.getDestination()
                if(nextResumed != nil && destination.idVal == nextResumed!.idVal) {
                    if(currentMaxLifecycle != LifecycleState.LIFECYCLESTATE_RESUMED) {
                        upwardStateTransitions[entry!] = LifecycleState.LIFECYCLESTATE_RESUMED
                    }
                    nextResumed = nextResumed?.mParent
                }
                else if(nextStarted != nil && destination.idVal == nextStarted?.idVal) {
                    if(currentMaxLifecycle == LifecycleState.LIFECYCLESTATE_RESUMED) {
                        entry!.setMaxLifecycle(maxState: LifecycleState.LIFECYCLESTATE_STARTED)
                    }
                    else if(currentMaxLifecycle != LifecycleState.LIFECYCLESTATE_STARTED) {
                        upwardStateTransitions[entry!] = LifecycleState.LIFECYCLESTATE_STARTED
                    }
                    nextStarted = nextStarted?.mParent
                } else {
                    entry!.setMaxLifecycle(maxState: LifecycleState.LIFECYCLESTATE_CREATED)
                }
                entry = iterator.next()
            }
            let iteratorN = mBackStack.iterator()
            entry = iteratorN.next()
            while(entry != nil) {
                let newState = upwardStateTransitions[entry!]
                if(newState != nil) {
                    entry!.setMaxLifecycle(maxState: newState!)
                } else {
                    entry!.updateState()
                }
                
                entry = iteratorN.next()
            }
            
            let backStackEntry = mBackStack.getLast()
            for listener in mOnDestinationChangedListeners {
                listener.onDestinationChanged(controller: self, destination: backStackEntry!.getDestination(), arguments: backStackEntry!.getArguments()?.objcDictionary)
            }
            return true
        }
        return false
    }
    
    func getNavInflater() -> LGNavigationParser {
        if(mInflater == nil) {
            mInflater = LGNavigationParser.getInstance()
        }
        return mInflater!
    }
    
    @objc
    public func setGraph(graphResId: String) {
        setGraph(graphResId: graphResId, startDestinationArgsP: nil)
    }
    
    @objc
    public func setGraph(graphResId: String, startDestinationArgsP: NSMutableDictionary?) {
        let startDestinationArgs = startDestinationArgsP?.swiftDictionaryObj
        setGraph(graph: getNavInflater().getNavigation(self, graphResId), startDestinationArgs: startDestinationArgs)
    }
    
    func setGraph(graph: NavGraph) {
        setGraph(graph: graph, startDestinationArgs: nil)
    }
    
    func setGraph(graph: NavGraph, startDestinationArgs: Bundle?) {
        if(mGraph != nil) {
            popBackStackInternal(destinationId: mGraph!.idVal, inclusive: true)
        }
        mGraph = graph
        onGraphCreated(startDestinationArgs: startDestinationArgs)
    }
    
    private func onGraphCreated(startDestinationArgs: Bundle?) {
        if(mNavigatorStateToRestore != nil) {
            let navigatorNames = mNavigatorStateToRestore![NavController.KEY_NAVIGATOR_STATE_NAMES] as? NSMutableArray;
            if(navigatorNames != nil) {
                for name in navigatorNames! {
                    let nameS = name as! String
                    let navigator = mNavigatiorProvider.getNavigator(name: nameS)
                    let bundle = mNavigatorStateToRestore![nameS] as? Bundle
                    if(bundle != nil) {
                        navigator.onRestoreState(savedState: bundle)
                    }
                }
            }
        }
        if(mBackStackToRestore != nil) {
            for state in mBackStackToRestore! {
                let node = findDestination(destinationId: state.mDestinationId)
                if(node == nil) {
                    //TODO:Excep
                    return
                }
                let args = state.mArgs
                let entry = NavBackStackEntry(context: mContext, destination: node!, args: args, navControllerLifecycleOwner: mLifecycleOwner, navControllerViewModel: mViewModel, uuid: state.mUUID, savedState: state.mSavedState)
                mBackStack.append(entry)
            }
            updateOnBackPressedCallbackEnabled()
            mBackStackToRestore = nil
        }
        if(mGraph != nil && mBackStack.isEmpty) {
            //TODO:Deep link
            navigate(node: mGraph!, args: startDestinationArgs, navOptions: nil, navigatorExtras: nil)
        }
        else {
            dispatchOnDestinationChanged()
        }
        
    }
    
    func getGraph() -> NavGraph {
        return mGraph!
    }
    
    func getCurrentDestination() -> NavDestination? {
        let entry = getCurrentBackStackEntry()
        return entry != nil ? entry?.getDestination() : nil
    }
    
    func findDestination(destinationId: String) -> NavDestination? {
        if(mGraph == nil) {
            return nil
        }
        if(mGraph?.idVal == destinationId) {
            return mGraph
        }
        let currentNode = mBackStack.isEmpty ? mGraph : mBackStack.getLast()?.getDestination()
        let currentGraph = currentNode is NavGraph ? currentNode as? NavGraph : currentNode?.mParent
        return currentGraph?.findNode(destinationId)
    }
    
    @objc
    public func navigateRef(ref: LuaRef) {
        navigate(resId: ref.idRef)
    }
    
    @objc
    public func navigate(resId: String) {
        navigate(resId: resId, args: nil)
    }
    
    @objc
    public func navigateRef(ref: LuaRef, args: Dictionary<String, NSObject>?) {
        navigate(resId: ref.idRef, args: args)
    }
    
    @objc
    public func navigate(resId: String, args: Dictionary<String, NSObject>?) {
        navigate(resId: resId, args: args, navOptions: nil)
    }
    
    @objc
    public func navigateRef(ref: LuaRef, args: Dictionary<String, NSObject>?, navOptions: NavOptions?) {
        navigate(resId: ref.idRef, args: args, navOptions: navOptions)
    }
    
    @objc
    public func navigate(resId: String, args: Dictionary<String, NSObject>?, navOptions: NavOptions?) {
        navigate(resId: resId, args: args, navOptions: navOptions, navigatorExtras: nil)
    }
    
    @objc
    public func navigateRef(ref: LuaRef, args: Dictionary<String, NSObject>?, navOptions: NavOptions?, navigatorExtras: NavigatorExtras?) {
        navigate(resId: ref.idRef, args: args, navOptions: navOptions, navigatorExtras: navigatorExtras)
    }
    
    @objc
    public func navigate(resId: String, args: Dictionary<String, NSObject>?, navOptions: NavOptions?, navigatorExtras: NavigatorExtras?) {
        let currentNode = mBackStack.isEmpty ? mGraph : mBackStack.getLast()?.mDestination
        if(currentNode == nil) {
            //TODO:Excep
            return;
        }
        var destId = resId
        let navAction = currentNode?.getAction(resId)
        var combinedArgs: Bundle? = nil
        var navOptionsD: NavOptions? = navOptions
        if(navAction != nil) {
            if(navOptionsD == nil) {
                navOptionsD = navAction!.mNavOptions
            }
            destId = navAction!.mDestinationId
            let navActionArgs = navAction!.mDefaultArguments
            if(navActionArgs != nil) {
                combinedArgs = Bundle()
                combinedArgs = combinedArgs!.merging(navActionArgs!.swiftDictionaryObj) { $1 }
            }
        }
        
        if(args != nil) {
            if(combinedArgs == nil) {
                combinedArgs = Bundle()
            }
            combinedArgs = combinedArgs!.merging(args!) { $1 }
        }
        
        if(destId == "" && navOptions != nil && navOptions?.mPopUpTo != nil) {
            popBackStack(destinationId: navOptions!.mPopUpTo, inclusive: navOptions!.mPopUpToInclusive)
        }
        
        if(destId == "") {
            //TODO:Excep
            return;
        }
        
        let node = findDestination(destinationId: destId)
        if(node == nil) {
            //TODO:Excep
            return;
        }
        navigate(node: node!, args: combinedArgs, navOptions: navOptions, navigatorExtras: navigatorExtras)
    }
    
    func navigate(node: NavDestination, args: Bundle?, navOptions: NavOptions?, navigatorExtras: NavigatorExtras?) {
        var popped = false
        var launchSingleTop = false
        if(navOptions != nil) {
            if(navOptions!.mPopUpTo != "-1") {
                popped = popBackStackInternal(destinationId: navOptions!.mPopUpTo, inclusive: navOptions!.mPopUpToInclusive)
            }
        }
        let navigator = mNavigatiorProvider.getNavigator(name: node.mNavigatorName)
        let finalArgs = node.add(inDefaultArgs: args?.objcDictionary)
        let newDest = navigator.navigate(destination: node, args: finalArgs?.swiftDictionaryObj, navOptions: navOptions, navigatorExtras: navigatorExtras)
        if(newDest != nil) {
            //FloatingWindow check TODO?
            var hierarchy = Deque<NavBackStackEntry>()
            var destination = newDest
            if(node is NavGraph) {
                repeat {
                    let parent = destination!.mParent
                    if(parent != nil) {
                        let entry = NavBackStackEntry(context: mContext, destination: parent!, args: finalArgs?.swiftDictionaryObj, navControllerLifecycleOwner: mLifecycleOwner, navControllerViewModel: mViewModel)
                        hierarchy.insert(entry, at: 0)
                        if(!mBackStack.isEmpty && mBackStack.getLast()!.getDestination() == parent) {
                            popBackStackInternal(destinationId: parent!.idVal, inclusive: true)
                        }
                    }
                    destination = parent
                } while(destination != nil && destination != node)
            }
            
            destination = hierarchy.isEmpty ? newDest : hierarchy.getFirst()!.getDestination()
            while(destination != nil && findDestination(destinationId: destination!.idVal) == nil) {
                let parent = destination!.mParent
                if(parent != nil) {
                    let entry = NavBackStackEntry(context: mContext, destination: parent!, args: finalArgs as? Bundle, navControllerLifecycleOwner: mLifecycleOwner, navControllerViewModel: mViewModel)
                    hierarchy.insert(entry, at: 0)
                }
                destination = parent
            }
            let overlappingDestination = hierarchy.isEmpty ? newDest : hierarchy.getLast()!.getDestination()
            while(!mBackStack.isEmpty
                  && mBackStack.getLast()!.getDestination() is NavGraph
                  && (mBackStack.getLast()!.getDestination() as? NavGraph)?.findNode(overlappingDestination?.idVal, false) == nil
                  && popBackStackInternal(destinationId: mBackStack.getLast()!.getDestination().idVal, inclusive: true)) {
                // Keep popping
            }
            mBackStack.append(contentsOf: hierarchy)
            if(mBackStack.isEmpty || mBackStack.getFirst()!.getDestination() != mGraph) {
                let entry = NavBackStackEntry(context: mContext, destination: mGraph!, args: finalArgs?.swiftDictionaryObj, navControllerLifecycleOwner: mLifecycleOwner, navControllerViewModel: mViewModel)
                mBackStack.insert(entry, at: 0)
            }
            let navBackStackEntry: NavBackStackEntry = NavBackStackEntry(context: mContext,
                                                      destination: newDest!,
                                                      args: newDest!.add(inDefaultArgs: finalArgs)?.swiftDictionaryObj,
                                                      navControllerLifecycleOwner: mLifecycleOwner,
                                                      navControllerViewModel: mViewModel)
            mBackStack.append(navBackStackEntry)
        } else if(navOptions != nil && navOptions!.mSingleTop) {
            launchSingleTop = true
            let singleTopBackStackEntry = mBackStack.getLast()
            if(singleTopBackStackEntry != nil) {
                singleTopBackStackEntry!.replaceArguments(newArgs: finalArgs?.swiftDictionaryObj)
            }
        }
        updateOnBackPressedCallbackEnabled()
        if(popped || newDest != nil || launchSingleTop) {
            dispatchOnDestinationChanged()
        }
    }
    
    @objc
    public func saveState() -> NSMutableDictionary? {
        var b: Bundle? = nil
        let navigatorNames = NSMutableArray()
        var navigatorState = Bundle()
        for entry in mNavigatiorProvider.getNavigators() {
            let name = entry.key
            let savedState = entry.value.onSaveState()
            if(savedState != nil) {
                navigatorNames.add(name)
                navigatorState[name] = savedState as NSObject?
            }
        }
        if(navigatorNames.count != 0) {
            b = Bundle()
            navigatorState[NavController.KEY_NAVIGATOR_STATE_NAMES] = navigatorNames
            b![NavController.KEY_NAVIGATOR_STATE] = navigatorState.objcDictionary
        }
        if(!mBackStack.isEmpty) {
            if(b == nil) {
                b = Bundle()
            }
            let backStack = NSMutableArray()
            for v in mBackStack {
                backStack.add(v)
            }
            b![NavController.KEY_BACK_STACK] = backStack
        }
        return b?.objcDictionary
    }
    
    @objc
    public func restoreState(navStateP: NSMutableDictionary?) {
        let navState = navStateP?.swiftDictionaryObj
        if(navState == nil) {
            return
        }
        
        mNavigatorStateToRestore = (navState![NavController.KEY_NAVIGATOR_STATE] as? NSMutableDictionary)?.swiftDictionaryObj
        
        let arr = navState![NavController.KEY_BACK_STACK] as? NSMutableArray
        if(arr != nil) {
            mBackStackToRestore = Array()
            for v in arr! {
                mBackStackToRestore!.append(v as! NavBackStackEntryState)
            }
        }
    }
    
    @objc
    public func setLifecycleOwner(owner: LifecycleOwner) {
        /*if(owner == mLifecycleOwner!) {
            return
        }*/
        mLifecycleOwner = owner
        mLifecycleOwner?.getLifecycle().add(mLifecycleObserver)
    }
    
    @objc
    public func setOnBackPressedDispatcher(dispatcher: OnBackPressedDispatcher) {
        if(mLifecycleOwner == nil) {
            return
        }
        mOnBackPressedCallback!.remove()
        dispatcher.addCallback(owner: mLifecycleOwner!, onBackPressedCallback: mOnBackPressedCallback!)
        mLifecycleOwner?.getLifecycle().remove(mLifecycleObserver)
        mLifecycleOwner?.getLifecycle().add(mLifecycleObserver)
    }
    
    @objc
    public func enableOnBackPressed(enabled: Bool) {
        mEnableOnBackPressedCallback = enabled
        updateOnBackPressedCallbackEnabled()
    }
    
    func updateOnBackPressedCallbackEnabled() {
        mOnBackPressedCallback?.setEnabled(enabled: mEnableOnBackPressedCallback && getDestinationCountOnBackStack() > 1)
    }
    
    @objc
    public func setViewModelStore(viewModelStore: ViewModelStore) {
        if(mViewModel == NavControllerViewModel.getInstance(viewModelStore: viewModelStore)) {
            return
        }
        if(!mBackStack.isEmpty) {
            return
        }
        mViewModel = NavControllerViewModel.getInstance(viewModelStore: viewModelStore)
    }
    
    func getViewModelStoreOwner(navGraphId: String) -> ViewModelStoreOwner {
        if(mViewModel == nil) {
            
        }
        let lastFromBackStack = getBackStackEntry(destinationId: navGraphId)
        if(!(lastFromBackStack.getDestination() is NavGraph)) {
            
        }
        return lastFromBackStack
    }
    
    func getBackStackEntry(destinationId: String) -> NavBackStackEntry {
        var lastFromBackStack: NavBackStackEntry? = nil
        let iterator = mBackStack.reversedIterator()
        var entry:NavBackStackEntry? = iterator.next()
        while(entry != nil) {
            let destination = entry!.getDestination()
            if(destination.idVal == destinationId) {
                lastFromBackStack = entry
                break
            }
            entry = iterator.next()
        }
        return lastFromBackStack!
    }
    
    func getCurrentBackStackEntry() -> NavBackStackEntry? {
        if(mBackStack.isEmpty) {
            return nil
        } else {
            return mBackStack.getLast()
        }
    }
    
    func getPreviousBackStackEntry() -> NavBackStackEntry? {
        let iterator = mBackStack.reversedIterator()
        var entry:NavBackStackEntry? = iterator.next()
        if(entry != nil) {
            entry = iterator.next()
        }
        while(entry != nil) {
            if(!(entry?.getDestination() is NavGraph)) {
                return entry
            }
            entry = iterator.next()
        }
        return nil
    }
}
